import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as IMG;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vehicles_saver_partner/app_router.dart';
import 'package:vehicles_saver_partner/blocs/auth_bloc.dart';
import 'package:vehicles_saver_partner/blocs/demand_bloc.dart';
import 'package:vehicles_saver_partner/blocs/place_bloc.dart';
import 'package:vehicles_saver_partner/components/dialog/loading_dialog.dart';
import 'package:vehicles_saver_partner/components/dialog/msg_dialog.dart';
import 'package:vehicles_saver_partner/data/models/demand/demand.dart';
import 'package:vehicles_saver_partner/data/models/map/mapTypeModel.dart';
import 'package:vehicles_saver_partner/data/models/map/place_model.dart';
import 'package:vehicles_saver_partner/screens/listDemand/item_demand.dart';
import 'package:vehicles_saver_partner/screens/search_address/search_address_screen.dart';
import 'package:vehicles_saver_partner/theme/style.dart';
import 'package:vehicles_saver_partner/utils/utility.dart';
import 'package:vehicles_saver_partner/config.dart' as Config;

class ListDemandScreen extends StatefulWidget {
  @override
  _ListDemandScreenState createState() => _ListDemandScreenState();
}

class _ListDemandScreenState extends State<ListDemandScreen> {
  _ListDemandScreenState();

  DemandBloc demandBloc;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<LatLng> points = <LatLng>[];
  GoogleMapController _mapController;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<CircleId, Circle> circles = <CircleId, Circle>{};
  double _zoom = 12.0;
  bool _addedMarker = false;
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  PolylineId selectedPolyline;
  Position currentLocation;
  final Geolocator _locationService = Geolocator();
  PermissionStatus permission;
  bool isEnabledLocation = false;
  double range = 5;
  final List<Map<String, dynamic>> listRange = [
    {"id": 1, "title": "5 km", "range": 5.0, "zoom": 11.5},
    {"id": 2, "title": "10 km", "range": 10.0, "zoom": 11.2},
    {"id": 3, "title": "15 km", "range": 20.0, "zoom": 10.5}
  ];
  Map selectedRange;

  Timer timer;

  @override
  void initState() {
    super.initState();
    print("initState");
    _getCurrentLocation().then((_) {
      if(selectedRange == null) selectedRange = listRange[0];
      changeCircle();
      print("updateListDemand initState $currentLocation");
      if (currentLocation != null) {
        moveCameraToMyLocation();
      }
      updateListDemand();
    });
  }

  Future updateListDemand() async {
    print("updateListDemand");
    await checkPermission();
    if (!isEnabledLocation) {
      return;
    }
    if(timer != null){
      timer.cancel();
    }

    fetchListDemand();

    const timeRequest = const Duration(seconds: 15);
    Timer.periodic(timeRequest, (Timer t) {
      timer = t;
      t.cancel();
      if (!demandBloc.isHavingDemand()) {
        _getCurrentLocation().then((_) {
          fetchListDemand();
        });
      }
    });
  }

  fetchListDemand() {
    print("fetchListDemand");
    _addedMarker = false;
    if (currentLocation != null) {
      demandBloc.fetchListDemand(
          currentLocation.latitude, currentLocation.longitude, range, addMarkers);
    }
  }

  /// Get current location
  Future<void> _getCurrentLocation() async {
    print("_initCurrentLocation");

    currentLocation = await _locationService.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    if(Config.Config.MODE == Config.Config.DEV){
      currentLocation = Position(latitude: 16.08488181220697, longitude: 108.1487294517269);
    }
    print("currentLocation: $currentLocation");
  }

  moveCameraToMyLocation() {
    print("moveCameraToMyLocation: $currentLocation");

    if (currentLocation == null) return;
    _mapController?.animateCamera(
      CameraUpdate?.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation?.latitude, currentLocation?.longitude),
          zoom: _zoom,
        ),
      ),
    );
    print("moveCameraToMyLocation 2");
  }

  Future<void> checkPermission() async {
    isEnabledLocation = await Permission.location.serviceStatus.isEnabled;
  }

  void _onMapCreated(GoogleMapController controller) {
    this._mapController = controller;
    _mapController
        ?.animateCamera(CameraUpdate?.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation != null ? currentLocation.latitude : 0.0,
          currentLocation != null ? currentLocation.longitude : 0.0),
      zoom: 12,
    )));
    _addCircle();
  }

  String calDistanceStrFromCurLocation(Demand demand) {
    double distance = Utility.calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        demand.pickupLatitude,
        demand.pickupLongitude);
    return distance.toStringAsFixed(2);
  }


  @override
  void dispose() {
    super.dispose();
    if(this.timer != null){
      timer.cancel();
    }
  }

  Widget getListOptionDistance() {
    final List<Widget> choiceChips = listRange.map<Widget>((value) {
      return new Padding(
          padding: const EdgeInsets.all(3.0),
          child: ChoiceChip(
              key: ValueKey<String>(value['id'].toString()),
              labelStyle: textGrey,
              backgroundColor: greyColor2,
              selectedColor: primaryColor,
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
              ),
              selected: selectedRange == value,
              label: Text((value['title'])),
              onSelected: (bool check) {
                if(check) {
                  selectedRange = value;
                  changeCircle();
                  updateListDemand();
                }
              }));
    }).toList();
    return new Wrap(children: choiceChips);
  }

  Future<void> _addMarker(
      String markerIdVal, String avatarUrl, double lat, double lng) async {
    final MarkerId markerId = MarkerId(markerIdVal);
    print("addmarker: $markerIdVal");
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
        ..color = primaryColor
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
        onTap: () {
          _onMarkerTapped(markerId);
        },
      );
      setState(() {
        markers[markerId] = marker;

      });
    });
  }

  _onMarkerTapped(markerId) {
    print("_onMarkerTapped $markerId");
  }

    void _addCircle() {
    if (currentLocation == null) return;
    final int circleCount = circles.length;
    if (circleCount == 12) {
      return;
    }
    final String circleIdVal = 'circle_id';
    final CircleId circleId = CircleId(circleIdVal);
    print("_addCircle $circleIdVal, $circleId, $circles, range = $range");

    final Circle circle = Circle(
      circleId: circleId,
      consumeTapEvents: true,
      strokeColor: Color.fromRGBO(135, 206, 250, 0.9),
      fillColor: Color.fromRGBO(135, 206, 250, 0.3),
      strokeWidth: 4,
      center: LatLng(currentLocation.latitude, currentLocation.longitude),
      radius: range * 1000,
    );
    setState(() {
      circles[circleId] = circle;
    });
  }

  /// Widget change the radius Circle.

  ///Filter and display markers in that area
  ///My data is demo. You can get data from your api and use my function
  ///to filter and display markers around the current location.

  changeCircle() {
    if (this.selectedRange == null) return;
    range = this.selectedRange['range'];
    _zoom = this.selectedRange['zoom'];
    _moveCamera(_zoom);

    _addCircle();
  }

  addMarkers() async{
    if(currentLocation == null) return;
    this.markers.clear();
    for (int i = 0; i < demandBloc.availableDemands.length; i++) {
      Demand demand = demandBloc.availableDemands[i];
        _addMarker(demand.id, demand.customer.avatarUrl, demand.pickupLatitude,
            demand.pickupLongitude);

    }
  }

  _moveCamera(double zoom) {
    _mapController?.animateCamera(
      CameraUpdate?.newCameraPosition(CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: zoom,
      )),
    );
  }

  _selectDemand(Demand demand) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              content: Container(
                  color: whiteColor,
                  width: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.transparent,
                            backgroundImage: CachedNetworkImageProvider(
                              demand != null?
                              demand.customer.avatarUrl
                              :"https://source.unsplash.com/300x300/?portrait",
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0, top:5.0),
                        child: Text(
                          demand.customer.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(calDistanceStrFromCurLocation(
                            demand) +
                            " km"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          demand.addressDetail,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          demand.vehicleType,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          demand.problemDescription,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        width: 200,
                        height: 40,
                        child: RaisedButton(
                          child: new Text(
                            'Chấp nhận',
                            style: TextStyle(color: blackColor),
                          ),
                          color: primaryColor,
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(15.0),
                          ),
                          onPressed: () {
                            acceptDemand(demand);
                          },
                        ),
                      ),
                    ],
                  )),
            ));
  }

  acceptDemand(Demand demand){
    LoadingDialog.showLoadingDialog(context, "Loading...");
    demandBloc.acceptDemand(demand.id, (){
      LoadingDialog.hideLoadingDialog(context);
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed(AppRoute.trackingDemandScreen);
    },
      (msg){
        LoadingDialog.hideLoadingDialog(context);
        Navigator.of(context).pop();
        MsgDialog.showMsgDialog(context, "Chấp nhận yêu cầu", msg, null);
      });
  }

  @override
  Widget build(BuildContext context) {
    demandBloc = Provider.of<DemandBloc>(context);
    if(demandBloc.isHavingDemand()){
      Future.microtask(() => Navigator.pushReplacementNamed(context, AppRoute.trackingDemandScreen));
    }
    print("build ${demandBloc.availableDemands}");


    print("build circles =  ${circles}");
    print("build marker =  ${markers}");


    return new Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
                height: 100,
                width: double.infinity,
                color: primaryColor,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "Danh sách yêu cầu",
                        style: headingBlack,
                      )
                    ])),
            demandBloc.availableDemands.length > 0? Expanded(
              child: SingleChildScrollView(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: demandBloc.availableDemands.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          _selectDemand(demandBloc.availableDemands[index]);
                        },
                        child: Container(
                          child: ItemDemand(
                              demand: demandBloc.availableDemands[index],
                              distance: calDistanceStrFromCurLocation(
                                      demandBloc.availableDemands[index]) +
                                  " km"),
                        ));
                  },
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: greyColor.withOpacity(0.5),
                  ),
                ),
              ),
            )
            : Container(padding:EdgeInsets.only(top: 300),child: (Text("Danh sách Trống", style: TextStyle(fontSize: 20),))),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
          color: Colors.white,
          child: SingleChildScrollView(
              child: new Stack(
            children: <Widget>[
              new Column(
                children: <Widget>[
                  SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: GoogleMap(
                        circles: Set<Circle>.of(circles.values),
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              currentLocation != null
                                  ? currentLocation.latitude
                                  : 0.0,
                              currentLocation != null
                                  ? currentLocation.longitude
                                  : 0.0),
                          zoom: 12,
                        ),
                        markers: Set<Marker>.of(markers.values),
                      )),
                ],
              ),
              Positioned(
                left: 0,
                top: 50,
                right: 0,
                child: Center(
                  child: getListOptionDistance(),
                ),
              ),
              Positioned(
                  top: MediaQuery.of(context).size.height / 2,
                  right: 0,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius:
                            BorderRadius.horizontal(left: Radius.circular(5.0))),
                    child: GestureDetector(
                      onTap: _scaffoldKey?.currentState?.openEndDrawer,
                      child: Icon(
                        Icons.arrow_back_ios_sharp,
                        size: 20,
                        color: blackColor,
                      ),
                    ),
                  )),
            ],
          )),
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
            bottom: 120,
            right: 10,
            child: Container(
                height: 40.0,
                width: 40.0,
                child: GestureDetector(
                  onTap: moveCameraToMyLocation,
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
            ),
        ]
      ),
    );
  }
}
