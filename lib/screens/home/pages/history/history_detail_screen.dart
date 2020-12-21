import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:vehicles_saver_partner/components/ink_well_custom.dart';
import 'package:vehicles_saver_partner/data/models/demand/demand.dart';
import 'package:vehicles_saver_partner/theme/style.dart';
import 'package:vehicles_saver_partner/utils/utility.dart';

class HistoryDetail extends StatefulWidget {
  final Demand demand;

  HistoryDetail({this.demand});

  @override
  _HistoryDetailState createState() => _HistoryDetailState();
}

class _HistoryDetailState extends State<HistoryDetail> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text("Lịch sử chi tiết",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    )),
                background: Container(
                  color: whiteColor,
                ),
              ),
            ),
          ];
        },
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overScroll) {
            overScroll.disallowGlow();
            return false;
          },
          child: SingleChildScrollView(
            child: InkWellCustom(
              // onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10.0),
                      color: whiteColor,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(70.0),
                            child: SizedBox(
                              height: 70,
                              width: 70,
                              child: Hero(
                                tag: "avatar_profile",
                                child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: CachedNetworkImageProvider(
                                      widget?.demand?.customer?.avatarUrl,
                                    )),
                              ),
                            ),
                          ),
                          Container(
                              width: screenSize.width - 100,
                              padding: EdgeInsets.only(left: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          widget?.demand?.customer?.name,
                                          style: textBoldBlack,
                                        ),
                                      ),
                                      Text(
                                        Utility.parseTimeDate(
                                            widget?.demand?.createdDate),
                                        style: textStyle,
                                      ),
                                    ],
                                  ),
                                ],
                              ))
                        ],
                      ),
                    ),
                    rideHistory(),
                    new Container(
                        padding:
                            EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                        color: whiteColor,
                        child: widget?.demand?.status == DemandStatus.COMPLETED
                            ? Column(
                                children: <Widget>[
                                  new Row(
                                    children: <Widget>[
                                      new Text(
                                        "Hóa đơn:",
                                        style: TextStyle(
                                            color: blackColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.all(8.0),
                                      reverse: true,
                                      itemCount:
                                          widget?.demand?.bill?.items?.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                widget?.demand?.bill
                                                    ?.items[index].service,
                                                style: textStyle,
                                              ),
                                              Text(
                                                Utility.convertCurrency(widget
                                                    ?.demand
                                                    ?.bill
                                                    ?.items[index]
                                                    .cost),
                                                style: textStyle,
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                  Divider(),
                                  Container(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text("Phí", style: textStyle),
                                        Text(
                                            Utility.convertCurrency(
                                                widget?.demand?.bill?.fee),
                                            style: textStyle),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "Tổng",
                                          style: TextStyle(
                                              color: blackColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            Utility.convertCurrency(
                                                widget?.demand?.calTotalCost()),
                                            style: TextStyle(
                                                color: blackColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                Divider(),
                                Container(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Text(
                                    "Hủy bởi: " + widget?.demand?.canceledBy,
                                    style: TextStyle(
                                        color: blackColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 20, top: 10, right: 20),
                                  color: whiteColor,
                                  child: Container(
                                    height: 130,
                                    width: double.infinity,
                                    padding: EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: primaryColor),
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: SingleChildScrollView(
                                      child: Text(
                                        widget?.demand?.canceledReason,
                                        style: new TextStyle(
                                          color: Colors.black,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ])),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget rideHistory() {
    return Material(
      elevation: 0.0,
      borderRadius: BorderRadius.circular(15.0),
      color: whiteColor,
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
        margin: EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: greyColor, width: 1.0),
          color: whiteColor,
        ),
        child: Container(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        Utility.parseTimeInDay(widget?.demand?.createdDate),
                        style:
                            TextStyle(color: Color(0xFF97ADB6), fontSize: 13.0),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                        height: 25,
                        width: 1.0,
                        color: Colors.grey,
                      ),
                      Text(
                        widget?.demand?.completedDate != null? Utility.parseTimeInDay(widget?.demand?.completedDate):"Canceled",
                        style:
                            TextStyle(color: Color(0xFF97ADB6), fontSize: 13.0),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Icon(
                          Icons.motorcycle_rounded,
                          color: blackColor,
                        ),
                        SizedBox(width: 5.0),
                        Flexible(
                          child: Text(
                            widget?.demand?.vehicleType,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.report_problem,
                          color: blackColor,
                        ),
                        SizedBox(width: 5.0),
                        Flexible(
                          child: Text(
                            widget?.demand?.problemDescription,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
