import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
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
import 'package:vehicles_saver_partner/data/models/demand/demand.dart';
import 'package:vehicles_saver_partner/data/models/map/mapTypeModel.dart';
import 'package:vehicles_saver_partner/data/models/map/place_model.dart';
import 'package:vehicles_saver_partner/screens/listDemand/item_demand.dart';
import 'package:vehicles_saver_partner/screens/search_address/search_address_screen.dart';
import 'package:vehicles_saver_partner/theme/style.dart';

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
  MarkerId selectedMarker;
  BitmapDescriptor _markerIcon;
  CircleId selectedCircle;

  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  PolylineId selectedPolyline;
  Position _position;
  String placemark = '';
  double distance = 0;
  LatLng currentLocation = LatLng(39.170655, -95.449974);
  List<Map<String, dynamic>> listDistance = [
    {"id": 1, "title": "5 km"},
    {"id": 2, "title": "10 km"},
    {"id": 3, "title": "15 km"}
  ];
  String selectedDistance = "1";
  double _radius = 5000;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    this._mapController = controller;
    _mapController
        ?.animateCamera(CameraUpdate?.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom: 12,
    )));
    _addCircle();
  }

  String calDistanceStrFromCurLocation(Place place) {
    double distance = calculateDistance(currentLocation.latitude,
        currentLocation.longitude, place.lat, place.lng);
    return distance.toString() + " km";
  }

  double calculateDistance(lat1, lng1, lat2, lng2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    Position position;
    try {
      final Geolocator geolocator = Geolocator()
        ..forceAndroidLocationManager = true;
      position = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
    } on PlatformException {
      position = null;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _position = position;
    });
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(_position.latitude, _position.longitude);
    if (placemarks != null && placemarks.isNotEmpty) {
      final Placemark pos = placemarks[0];
      setState(() {
        placemark = pos.thoroughfare + ', ' + pos.locality;
      });
    }
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/image/marker/car_top_96.png")
          .then(_updateBitmap);
    }
  }

  void _updateBitmap(BitmapDescriptor bitmap) {
    setState(() {
      _markerIcon = bitmap;
    });
  }

  void _addMarker(
      String markerIdVal, String avatarUrl, double lat, double lng) async {
    final MarkerId markerId = MarkerId(markerIdVal);
    print("addmarker: $markerIdVal");
    final size = Size(120, 120);
    final double borderStroke = 20;

    final File markerImageFile = await DefaultCacheManager().getSingleFile(avatarUrl);
    final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
    final IMG.Image image = IMG.decodeImage(markerImageBytes);
    final IMG.Image resized = IMG.copyResize(image, width: (size.width - borderStroke).toInt());
    final List<int> resizedBytes = IMG.encodePng(resized);

    ui.decodeImageFromList(resizedBytes, (image) async {

      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);


      final center = Offset(size.width/2, size.height/2);
      final radius = size.width / 2;
      double drawImageWidth = 0;
      double drawImageHeight = 0;

      Path path = Path()
        ..addOval(Rect.fromLTWH(drawImageWidth, drawImageHeight,
            size.width, size.height));

      canvas.clipPath(path);

      canvas.drawImage(image, Offset(borderStroke/2, borderStroke/2), Paint());

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
    final int circleCount = circles.length;
    if (circleCount == 12) {
      return;
    }
    final String circleIdVal = 'circle_id';
    final CircleId circleId = CircleId(circleIdVal);

    final Circle circle = Circle(
      circleId: circleId,
      consumeTapEvents: true,
      strokeColor: Color.fromRGBO(135, 206, 250, 0.9),
      fillColor: Color.fromRGBO(135, 206, 250, 0.3),
      strokeWidth: 4,
      center: LatLng(currentLocation.latitude, currentLocation.longitude),
      radius: _radius,
    );
    setState(() {
      circles[circleId] = circle;
    });
  }

  /// Widget change the radius Circle.

  Widget getListOptionDistance() {
    final List<Widget> choiceChips = listDistance.map<Widget>((value) {
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
              selected: selectedDistance == value['id'].toString(),
              label: Text((value['title'])),
              onSelected: (bool check) {
                setState(() {
                  selectedDistance = check ? value["id"].toString() : '';
                  changeCircle(selectedDistance);
                });
              }));
    }).toList();
    return new Wrap(children: choiceChips);
  }

  ///Filter and display markers in that area
  ///My data is demo. You can get data from your api and use my function
  ///to filter and display markers around the current location.

  changeCircle(String selectedCircle) {
    if (selectedCircle == "1") {
      setState(() {
        _radius = 5000;
        _moveCamera(11.5);
      });
    }
    if (selectedCircle == "2") {
      setState(() {
        _radius = 10000;
        _moveCamera(11.2);
      });
    }
    if (selectedCircle == "3") {
      setState(() {
        _radius = 15000;
        _moveCamera(10.5);
      });
    }
    _addCircle();
    for (int i = 0; i < demandBloc.availableDemands.length; i++) {
      Demand demand = demandBloc.availableDemands[i];
      Place place = demand.pickupLocation;
      distance = calculateDistance(currentLocation.latitude,
          currentLocation.longitude, place.lat, place.lng);
      if (distance * 1000 < _radius) {
        _addMarker(demand.id, demand.customer.avatarUrl, place.lat, place.lng);
      } else {
        print("remove demand ${demand.id}");
        _remove(demand.id);
      }
    }
  }

  void _remove(String idMarker) {
    final MarkerId markerId = MarkerId(idMarker);
    setState(() {
      markers.remove(markerId);
    });
  }

  _moveCamera(double zoom) {
    _mapController?.animateCamera(
      CameraUpdate?.newCameraPosition(CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: zoom,
      )),
    );
  }

  _selectDemand(int index) {
    print("select demand: $index");
  }

  @override
  Widget build(BuildContext context) {
    demandBloc = Provider.of<DemandBloc>(context);
    _createMarkerImageFromAsset(context);
    return new Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
                height: 30,
                color: Color(0xfff5f5f5),
                child: Text("Danh sách yêu cầu")),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: demandBloc.availableDemands.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        _selectDemand(index);
                      },
                      child: ItemDemand(
                          demand: demandBloc.availableDemands[index],
                          distance: calDistanceStrFromCurLocation(demandBloc
                              .availableDemands[index].pickupLocation)));
                },
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: greyColor.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
      body: new Container(
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
                        target: LatLng(currentLocation.latitude,
                            currentLocation.longitude),
                        zoom: 12,
                      ),
                      markers: Set<Marker>.of(markers.values),
                    )),
              ],
            ),
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    centerTitle: true,
                    leading: FlatButton(
                        onPressed: () {
                          _scaffoldKey.currentState.openDrawer();
                        },
                        child: Icon(
                          Icons.menu,
                          color: blackColor,
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: getListOptionDistance(),
                  )
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }
}
