import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_saver_partner/blocs/place_bloc.dart';
import 'package:vehicles_saver_partner/data/models/map/place_model.dart';
import 'package:vehicles_saver_partner/theme/style.dart';

class SearchAddressView extends StatefulWidget {
  final PlaceBloc placeBloc;
  final Function(Place) onSelected;
  SearchAddressView({this.placeBloc, this.onSelected});

  @override
  _SearchAddressViewState createState() => _SearchAddressViewState();
}

class _SearchAddressViewState extends State<SearchAddressView> {
  bool checkAutoFocus = false;
  String currentLocation;

  @override
  void initState() {
    super.initState();
    currentLocation = widget?.placeBloc?.pickupLocation?.formattedAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: whiteColor,
      child: Column(
        children: <Widget>[
          buildForm(widget?.placeBloc),
          Container(
            height: 20,
            color: Color(0xfff5f5f5),
          ),
          widget?.placeBloc?.listPlace != null ?
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget?.placeBloc?.listPlace?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget?.placeBloc?.listPlace[index].name),
                  subtitle: Text(widget?.placeBloc?.listPlace[index].formattedAddress),
                  onTap: () {
                    Navigator.of(context).pop();
                    widget?.onSelected(widget?.placeBloc?.listPlace[index]);
                  },
                );
              },
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: greyColor.withOpacity(0.5),
              ),
            ),
          ): addressDefault(),
        ],
      ),
    );
  }

  Widget buildForm(PlaceBloc placeBloc){

    return Container(
      padding: EdgeInsets.only(bottom: 20.0),
      color: whiteColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Icon(Icons.location_on, color: primaryColor,)
          ),
          Expanded(
            flex: 6,
            child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                      Container(
                        height: 30,
                        child: TextField(
                          style: textStyle,
                          decoration: InputDecoration(
                            fillColor: whiteColor,
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: greyColor),
                            hintText: "Vị trí hiện tại",
                            contentPadding:
                            const EdgeInsets.symmetric(
                                vertical: -10.0),
                          ),
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: currentLocation != null ? currentLocation :'',
                              selection: TextSelection.collapsed(
                                offset: currentLocation != null ? currentLocation?.length : 0),
                            ),
                          ),
                          onChanged: (String value) async {
                            currentLocation = value;
                            await placeBloc?.search(value);
                          },
                        ),
                      ),
                    Container(
                        child: Divider(color: Colors.grey,)
                    ),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget addressDefault(){
    return Container(
      color: Color(0xfff5f5f5),
      padding: EdgeInsets.only(left: 20,right: 20,bottom: 20),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: (){
            },
            child: Material(
              elevation: 1.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              child: Container(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.home, color: greyColor,),
                    SizedBox(width: 10),
                    Text("Home",
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: (){
            },
            child: Material(
              elevation: 1.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              child: Container(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.work, color: greyColor,),
                    SizedBox(width: 10),
                    Text("Company",
                      style: TextStyle(
                          color: blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
