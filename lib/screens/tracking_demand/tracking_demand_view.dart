import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as IMG;

import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehicles_saver_partner/blocs/auth_bloc.dart';
import 'package:vehicles_saver_partner/blocs/demand_bloc.dart';
import 'package:vehicles_saver_partner/blocs/place_bloc.dart';
import 'package:vehicles_saver_partner/components/dialog/loading.dart';
import 'package:vehicles_saver_partner/components/dialog/msg_dialog.dart';
import 'package:vehicles_saver_partner/data/models/demand/demand.dart';
import 'package:vehicles_saver_partner/data/models/map/direction_model.dart';
import 'package:vehicles_saver_partner/data/models/map/get_routes_request_model.dart';
import 'package:vehicles_saver_partner/network/http/apis.dart';
import 'package:vehicles_saver_partner/components/auto_rotation_marker.dart' as rm;
import 'package:vehicles_saver_partner/screens/tracking_demand/screens/chat_screen/chat_screen.dart';
import 'package:vehicles_saver_partner/screens/tracking_demand/widgets/demand_detail_widget.dart';
import 'package:vehicles_saver_partner/screens/tracking_demand/widgets/icon_action_widget.dart';
import 'package:vehicles_saver_partner/theme/style.dart';
import 'package:vehicles_saver_partner/utils/utility.dart';
import 'package:vehicles_saver_partner/config.dart' as Config;
import '../../app_router.dart';
import '../../google_map_helper.dart';
import 'widgets/select_service_widget.dart';

class TrackingDemandView extends StatefulWidget {
  final PlaceBloc placeBloc;
  final DemandBloc demandBloc;
  final AuthBloc authBloc;

  TrackingDemandView({this.placeBloc, this.demandBloc, this.authBloc});

  @override
  _TrackingDemandViewState createState() => _TrackingDemandViewState();
}

class _TrackingDemandViewState extends State<TrackingDemandView> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<LatLng> points = <LatLng>[];
  GoogleMapController _mapController;
  Timer timer;

  ExpandableController _expandableController =
  new ExpandableController(initialExpanded: true);
  Position currentLocation;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  PermissionStatus permission;
  bool isEnabledLocation = false;
  Map<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{};
  int _polylineIdCounter = 1;
  PolylineId selectedPolyline;

  bool checkPlatform = Platform.isIOS;
  String distance, duration;

  List<Routes> routesData;
  final Geolocator _locationService = Geolocator();
  final GMapViewHelper _gMapViewHelper = GMapViewHelper();
  String toAddressMarkerId = "to_address";
  void _onMapCreated(GoogleMapController controller) {
    this._mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) {
      print("updateListDemand initState $currentLocation");
      if (currentLocation != null) {
        moveCameraToMyLocation();
        final Demand currentDemand  = widget?.demandBloc?.currentDemand;
        _addMarker(toAddressMarkerId, currentDemand.customer.avatarUrl, currentDemand.pickupLatitude, currentDemand.pickupLongitude, Colors.blue);

        this.updateLocation();
        // getRouter();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget?.demandBloc?.listenUpdateListDemand(() => print("update partner"));
    if(timer != null){
      timer.cancel();
    }
  }

  _addMarker(
      String markerIdVal, String avatarUrl, double lat, double lng, Color borderColor) async {
    print("_addMarker $lat, $lng, $currentLocation");
    final MarkerId markerId = MarkerId(markerIdVal);
    final size = Size(60, 60);
    final double borderStroke = 10;

    //get image from internet or cache
    final File markerImageFile =
    await DefaultCacheManager().getSingleFile(avatarUrl);
    final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
    //resize
    final IMG.Image image = IMG.decodeImage(markerImageBytes);
    final IMG.Image resized =
    IMG.copyResize(image, width: (size.width - borderStroke).toInt());
    final List<int> resizedBytes = IMG.encodePng(resized);

    ui.decodeImageFromList(resizedBytes, (image) async {
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      final center = Offset(size.width / 2, size.height / 2);
      final radius = size.width / 2;
      double drawImageWidth = 0;
      double drawImageHeight = 0;

      Path path = Path()
        ..addOval(Rect.fromLTWH(
            drawImageWidth, drawImageHeight, size.width, size.height));

      canvas.clipPath(path);

      canvas.drawImage(
          image, Offset(borderStroke / 2, borderStroke / 2), Paint());

      Paint paintBorder = Paint()
        ..color = borderColor
        ..strokeWidth = borderStroke.toDouble()
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius, paintBorder);
      final img = await pictureRecorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
      final data = await img.toByteData(format: ui.ImageByteFormat.png);

      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.fromBytes(data.buffer.asUint8List()),
      );
      setState(() {
        markers[markerId] = marker;
      });
    });
  }

  ///Calculate and return the best router
  void getRouter() async {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    final PolylineId polylineId = PolylineId(polylineIdVal);
    polyLines.clear();
    var router;
    LatLng _pickupLocation = LatLng(widget?.demandBloc?.currentDemand?.pickupLatitude,
        widget?.demandBloc?.currentDemand?.pickupLongitude);
    LatLng _currentLocation = LatLng(currentLocation.latitude, currentLocation.longitude);

    await APIs.getRoutes(
      getRoutesRequest: GetRoutesRequestModel(
          fromLocation: _pickupLocation,
          toLocation: _currentLocation,
          mode: "driving"
      ),
    ).then((data) {
      if (data != null) {
        print("getRoutes: $data");
        router = data?.result?.routes[0]?.overviewPolyline?.points;
        routesData = data?.result?.routes;
      }
    }).catchError((error) {
      print("GetRoutesRequest > $error");
    });

    distance = routesData[0]?.legs[0]?.distance?.text;
    duration = routesData[0]?.legs[0]?.duration?.text;

    polyLines[polylineId] = GMapViewHelper.createPolyline(
      polylineIdVal: polylineIdVal,
      router: router,
      pickupLocation: _pickupLocation,
      toLocation: _currentLocation,
    );
    setState(() {});
    _gMapViewHelper.cameraMove(fromLocation: _pickupLocation,
        toLocation: _currentLocation,
        mapController: _mapController);
  }
  
  Future<void> checkPermission() async {
    isEnabledLocation = await Permission.location.serviceStatus.isEnabled;
  }

  void fetchLocation() {
    checkPermission()?.then((_) {
      if (isEnabledLocation) {
        _getCurrentLocation();
      }
    });
  }

  void updateLocation() async{
    print("updateLocation");
    await checkPermission();
    if (!isEnabledLocation) {
      return;
    }
    if(timer != null){
      timer.cancel();
    }
    widget.demandBloc.updateLocation(currentLocation.latitude, currentLocation.longitude);


    const timeRequest = const Duration(seconds: 5);
    Timer.periodic(timeRequest, (Timer t) {
      timer = t;
      t.cancel();
      if (widget.demandBloc.isStatus(DemandStatus.HANDLING)) {
        _getCurrentLocation().then((_){
          updateLocation();
        });
      }
    });
  }

  /// Get current location
  Future<Position> _getCurrentLocation() async {
    print("_initCurrentLocation");


    Random random = new Random();
    if(Config.Config.MODE == Config.Config.DEV){
      currentLocation = Position(latitude: 16.08488181220697 , longitude: 108.1487294517269);
    } else {
      currentLocation = await _locationService.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
    }

    currentLocation = Position(latitude: currentLocation.latitude + random.nextDouble() * 1.0 - 0.5,
        longitude: currentLocation.longitude + random.nextDouble()* 1.0 - 0.5);


    await _addMarker("MyCurrentLocation",widget.authBloc.myInfo.avatarUrl, currentLocation.latitude, currentLocation.longitude, Colors.red);
    print("currentLocation: $currentLocation");
    return currentLocation;

  }

  void _onTapMap(LatLng latLng) {
    // FocusScope.of(context).requestFocus(new FocusNode());

    if (_expandableController.expanded) {
      _expandableController.expanded = false;
    }
  }

  void moveCameraToMyLocation() {
    moveCameraToLocation(currentLocation?.latitude, currentLocation?.longitude);
  }

  moveCameraToLocation(double lat, double lng){
    _mapController?.animateCamera(
      CameraUpdate?.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 14.0,
        ),
      ),
    );
  }

  onCompleteDemand(){
    Navigator.of(context).pushNamed(AppRoute.invoiceScreen);
  }

  onCancelDemand(){
    MsgDialog.showConfirmDialog(context, "Hủy yêu cầu", "Bạn có muốn hủy yêu cầu?", () {
      showCanceledReasonDialog();
    }, null);
  }

  showCanceledReasonDialog(){
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hủy yêu cầu"),
        content: Container(
          width: 300,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 5.0)),
              Container(
                height: 145,
                child: TextField(
                        controller: reasonController,
                        keyboardType: TextInputType.text,
                        maxLines: 5,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 5.0),
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                          labelText: 'Lý do',
                        ),
                      ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      child: new Text(
                        'Hủy yêu cầu',
                        style: TextStyle(color: blackColor),
                      ),
                      color: primaryColor,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                      ),
                      onPressed: () {
                        String reason = reasonController.text;
                        if (reason.trim().length <= 0) {
                          MsgDialog.showMsgDialog(this.context, "",
                              "Bạn phải nhập lý do mới có thể hủy!", null);
                        } else {
                          widget?.demandBloc?.cancelDemand(reason, (){print("canceled success");}, (msg){
                            print("canceled fail $msg");
                            MsgDialog.showMsgDialog(this.context, "Hủy yêu cầu thất bại",
                                msg, () => Navigator.of(this.context).pushNamedAndRemoveUntil(AppRoute.homeScreen, (Route<dynamic> route) => false));
                          });
                          Navigator.of(this.context).pop();
                        }
                      },
                    ),
                    RaisedButton(
                      child: new Text(
                        'Quay lại',
                        style: TextStyle(color: blackColor),
                      ),
                      color: greyColor,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ])
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch(widget?.demandBloc?.currentDemand?.status){
      case DemandStatus.PAYING:
        Future.microtask(() => Navigator.pushReplacementNamed(context, AppRoute.invoiceScreen));
        return LoadingWidget('');
        break;
      case DemandStatus.COMPLETED:
        Future.microtask(() => Navigator.pushReplacementNamed(context, AppRoute.homeScreen));
        return LoadingWidget('');
        break;
      case DemandStatus.CANCELED:
        Future.microtask(() => Navigator.pushReplacementNamed(context, AppRoute.homeScreen));
        return LoadingWidget('');
        break;
    }

      return Scaffold(
      body: GestureDetector(
        onTap: () {
          // FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Stack(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: GoogleMap(
                markers: Set<Marker>.of(markers.values),
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                onTap: _onTapMap,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation != null
                          ? currentLocation?.latitude
                          : 0.0,
                      currentLocation != null
                          ? currentLocation?.longitude
                          : 0.0),
                  zoom: 12.0,
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    centerTitle: true,
                    leading: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed(
                              AppRoute.homeScreen);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.0),
                                color: Colors.white
                            ),
                            child: Icon(Icons.arrow_back_ios, color: blackColor,)
                        )
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SingleChildScrollView(
                  child: ExpandablePanel(
                    controller: _expandableController,
                    header: Padding(
                      padding: const EdgeInsets.only(right: 18.0, bottom: 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 40.0,
                            width: 40.0,
                            child: GestureDetector(
                              onTap: () {
                                moveCameraToMyLocation();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(100.0),
                                  ),
                                ),
                                child: Icon(
                                  Icons.my_location,
                                  size: 20.0,
                                  color: blackColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    collapsed: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          color: Colors.white),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 10.0, top: 10.0),
                            child: ExpandableButton(
                                child: Icon(
                                  Icons.keyboard_arrow_up,
                                  size: 32.0,
                                )),
                          ),
                          Container(
                            height: 200.0,
                            padding: EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 10),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: <Widget>[
                                          Material(
                                            elevation: 10.0,
                                            color: Colors.white,
                                            shape: CircleBorder(),
                                            child: Padding(
                                              padding: EdgeInsets.all(2.0),
                                              child: SizedBox(
                                                height: 70,
                                                width: 70,
                                                child: CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor: Colors.transparent,
                                                    backgroundImage: CachedNetworkImageProvider(
                                                      widget?.demandBloc?.isHavingDemand()?
                                                      widget?.demandBloc?.currentDemand?.customer?.avatarUrl
                                                      :"https://source.unsplash.com/300x300/?portrait",
                                                    )
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(widget?.demandBloc?.currentDemand?.customer?.name,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.clip,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        padding: EdgeInsets.only(left: 20.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(50.0),
                                                color: Colors.amber[100],
                                              ),
                                              padding: EdgeInsets.fromLTRB(7.0, 5.0, 7.0, 5.0),
                                              child: Text(widget?.demandBloc?.currentDemand?.vehicleType,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: blackColor,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top:3.0,right:5.0),
                                              child: Text(currentLocation != null?(Utility.calculateDistance(
                                                  currentLocation.latitude,
                                                  currentLocation.longitude,
                                                  widget?.demandBloc?.currentDemand?.pickupLatitude,
                                                  widget?.demandBloc?.currentDemand?.pickupLongitude)
                                                  .toStringAsFixed(2) + " km"):"",style: textGrey,),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      IconAction(
                                          icon: Icons.call,
                                          onTap: () => launch('tel:${widget?.demandBloc?.currentDemand?.customer?.phone}')
                                      ),
                                      IconAction(
                                        icon: MdiIcons.chatOutline,
                                        onTap: (){
                                          Navigator.of(context).push(new MaterialPageRoute<Null>(
                                              builder: (BuildContext context) {
                                                return ChatScreen();
                                              },
                                              fullscreenDialog: true
                                          ));
                                        },
                                      ),
                                      IconAction(
                                        icon: Icons.clear,
                                        onTap: onCancelDemand
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                          ),
                        ],
                      ),
                    ),
                    expanded: Container(
                      padding: EdgeInsets.only(right: 10.0),
                      height: 500.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          color: Colors.white),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 10.0, top: 0.0),
                            child: ExpandableButton(
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 32.0,
                                )),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: <Widget>[
                                          Material(
                                            elevation: 10.0,
                                            color: Colors.white,
                                            shape: CircleBorder(),
                                            child: Padding(
                                              padding: EdgeInsets.all(2.0),
                                              child: SizedBox(
                                                height: 70,
                                                width: 70,
                                                child: CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor: Colors.transparent,
                                                    backgroundImage: CachedNetworkImageProvider(
                                                      widget?.demandBloc?.isHavingDemand()?
                                                      widget?.demandBloc?.currentDemand?.customer?.avatarUrl
                                                      :"https://source.unsplash.com/300x300/?portrait",
                                                    )
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(widget?.demandBloc?.currentDemand?.customer?.name,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.clip,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        padding: EdgeInsets.only(left: 20.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(50.0),
                                                color: Colors.amber[100],
                                              ),
                                              padding: EdgeInsets.fromLTRB(7.0, 5.0, 7.0, 5.0),
                                              child: Text(widget?.demandBloc?.currentDemand?.vehicleType,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: blackColor,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top:3.0, right:5.0),
                                              child: Text(currentLocation != null?(Utility.calculateDistance(
                                                  currentLocation.latitude,
                                                  currentLocation.longitude,
                                                  widget?.demandBloc?.currentDemand?.pickupLatitude,
                                                  widget?.demandBloc?.currentDemand?.pickupLongitude)
                                                  .toStringAsFixed(2) + " km"):"",style: textGrey,),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 0.0, 5.0),
                                    child: Text("Địa chỉ", style: textGrey,)
                                  ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: greyColor2,
                                  ),
                                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                  child: Text(widget?.demandBloc?.currentDemand?.addressDetail,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: blackColor,
                                    ),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.fromLTRB(15.0, 10.0, 0.0, 5.0),
                                  child: Text("Vấn đề", style: textGrey,),
                                ),
                                Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color: greyColor2,
                                  ),
                                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                  child: SingleChildScrollView(
                                    child: Text(widget?.demandBloc?.currentDemand?.problemDescription,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: blackColor,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(bottom: 15.0)),
                                Center(
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                              color: greyColor,
                                              borderRadius:
                                              new BorderRadius.circular(15.0)),
                                          width: 152.0,
                                          child: FlatButton.icon(
                                            icon: new Text(''),
                                            label: new Text(
                                              'HỦY',
                                              style: heading18Black,
                                            ),
                                            onPressed: onCancelDemand
                                          ),
                                        ),
                                        Container(width: 10.0),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius:
                                              new BorderRadius.circular(15.0)),
                                          width: 152.0,
                                          child: FlatButton.icon(
                                            icon: new Text(''),
                                            label: new Text(
                                                'HOÀN THÀNH',
                                                style: heading18Black,
                                              ),
                                              onPressed: onCompleteDemand
                                          ),
                                        ),
                                      ])

                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    tapHeaderToExpand: false,
                    hasIcon: false,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
