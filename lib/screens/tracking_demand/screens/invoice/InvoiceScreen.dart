import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:vehicles_saver_partner/app_router.dart';
import 'package:vehicles_saver_partner/blocs/auth_bloc.dart';
import 'package:vehicles_saver_partner/blocs/demand_bloc.dart';
import 'package:vehicles_saver_partner/blocs/place_bloc.dart';
import 'package:vehicles_saver_partner/components/dialog/loading.dart';
import 'package:vehicles_saver_partner/components/dialog/loading_dialog.dart';
import 'package:vehicles_saver_partner/components/dialog/msg_dialog.dart';
import 'package:vehicles_saver_partner/components/ink_well_custom.dart';
import 'package:vehicles_saver_partner/utils/validations.dart';
import 'package:vehicles_saver_partner/config.dart';
import 'package:vehicles_saver_partner/data/models/bill/bill.dart';
import 'package:vehicles_saver_partner/data/models/bill/bill_item.dart';
import 'package:vehicles_saver_partner/data/models/demand/demand.dart';
import 'package:vehicles_saver_partner/theme/style.dart';
import 'package:vehicles_saver_partner/utils/utility.dart';

class InvoiceView extends StatefulWidget {
  @override
  InvoiceState createState() => InvoiceState();
}

class InvoiceState extends State<InvoiceView> {
  List<BillItem> billItems = new List();
  PlaceBloc placeBloc;
  DemandBloc demandBloc;
  AuthBloc authBloc;
  final NumberFormat formatter = NumberFormat("#,###");
  final Validations validations = Validations();

  onInvoice() {
    String err = validations.validateInvoice(billItems);
    if (err != null) {
      MsgDialog.showMsgDialog(context, "Xuất hóa đơn", err, null);
    } else {
      LoadingDialog.showLoadingDialog(context, "Loading...");
      demandBloc.invoice(billItems, () {
        LoadingDialog.hideLoadingDialog(context);
        print("invoice success");
      }, (err) {
        LoadingDialog.hideLoadingDialog(context);
        print("invoice fail");
        MsgDialog.showMsgDialog(context, "Xuất hóa đơn", err, null);
      });
    }
  }

  void addItem() {
    TextEditingController serviceController = TextEditingController();
    TextEditingController costController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Thêm dịch vụ"),
        content: Container(
          width: 300,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 60,
                child: TextField(
                  controller: serviceController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    labelText: 'Dịch vụ',
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 10.0)),
              Container(
                height: 60,
                child: Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: <Widget>[
                      TextField(
                        controller: costController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                          labelText: 'Giá',
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(
                              left: 3.0, right: 5.0, bottom: 2.0),
                          child: Text(
                            Config.CURRENCY,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))
                    ]),
              ),
              Padding(padding: EdgeInsets.only(top: 20.0)),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      child: new Text(
                        'Hủy',
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
                    RaisedButton(
                      child: new Text(
                        'Thêm',
                        style: TextStyle(color: blackColor),
                      ),
                      color: primaryColor,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                      ),
                      onPressed: () {
                        double cost = 0.0;
                        String service = serviceController.text;
                        try {
                          cost = double.parse(costController.text);
                        } catch (e) {}
                        if (service.trim().length <= 0) {
                          MsgDialog.showMsgDialog(context, "",
                              "Dịch vụ nhập vào không hợp lệ!", null);
                        } else if (cost == 0) {
                          MsgDialog.showMsgDialog(
                              context, "", "Giá nhập vào không hợp lệ!", null);
                        } else {
                          BillItem item = BillItem(service, cost);
                          billItems.add(item);
                          print("build, $billItems");
                          Navigator.of(context).pop();
                          setState(() {});
                        }
                      },
                    ),
                  ])
            ],
          ),
        ),
      ),
    );
  }

  void subItem(index) {
    setState(() {
      billItems.removeAt(index);
    });
  }

  String calTotalCost() {
    double total = 0;
    for (int i = 0; i < billItems.length; i++) {
      total += billItems[i].cost;
    }
    if(demandBloc.isStatus(DemandStatus.PAYING)){
      total += demandBloc.currentDemand.bill.fee;
    }

    return Utility.convertCurrency(total);
  }

  @override
  Widget build(BuildContext context) {
    print("build, $billItems");
    placeBloc = Provider.of<PlaceBloc>(context);
    demandBloc = Provider.of<DemandBloc>(context);
    authBloc = Provider.of<AuthBloc>(context);
    if(demandBloc.isStatus(DemandStatus.PAYING) && demandBloc.currentDemand.bill != null){
      billItems = demandBloc.currentDemand.bill.items;
    }
    if(!demandBloc.isHavingDemand()){
      Future.microtask(() => Navigator.of(context).pushNamedAndRemoveUntil(AppRoute.homeScreen, (Route<dynamic> route) => false));
      return LoadingWidget('');
    }
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
        child: ButtonTheme(
          minWidth: screenSize.width,
          height: 50.0,
          child: RaisedButton(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(15.0)),
            elevation: 0.0,
            color: demandBloc.isStatus(DemandStatus.PAYING)
                ? greyColor
                : primaryColor,
            child: new Text(
              demandBloc.isStatus(DemandStatus.PAYING)
                  ? 'Khách hàng thanh toán'
                  : 'Hoàn thành',
              style: headingWhite,
            ),
            onPressed:
                demandBloc.isStatus(DemandStatus.PAYING) ? null : onInvoice,
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text("Hóa đơn",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    )),
                background: Container(
                  color: whiteColor,
                ),
              ),
            ),
            // FlatButton.icon(onPressed: null, icon: Icon(Icons.edit), label: Text(''))
          ];
        },
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overScroll) {
            overScroll.disallowGlow();
            return false;
          },
          child: SingleChildScrollView(
            child: InkWellCustom(
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Material(
                      elevation: 10.0,
                      color: Colors.white,
                      shape: CircleBorder(),
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              backgroundImage: CachedNetworkImageProvider(
                                demandBloc.isHavingDemand()?
                                demandBloc?.currentDemand?.customer?.avatarUrl
                                :"https://source.unsplash.com/300x300/?portrait",
                              )),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
                      child: Text(
                        demandBloc?.currentDemand?.customer?.name,
                        style: heading18Black,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                      color: whiteColor,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                "Thông tin yêu cầu:",
                                style: TextStyle(
                                    color: blackColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Loại xe",
                                  style: textStyle,
                                ),
                                Container(
                                  width: 200.0,
                                  child: Text(
                                    demandBloc.currentDemand.vehicleType,
                                    textAlign: TextAlign.right,
                                    style: textStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Vấn đề gặp phải",
                                  style: textStyle,
                                ),
                                Container(
                                  width: 200.0,
                                  child: Text(
                                    demandBloc.currentDemand.problemDescription,
                                    textAlign: TextAlign.right,
                                    style: textStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                      color: whiteColor,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                "Hóa đơn chi tiết:",
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
                              itemCount: billItems.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            demandBloc.isStatus(DemandStatus.HANDLING)? Container(
                                                padding:
                                                    EdgeInsets.only(right: 5.0),
                                                width: 30,
                                                height: 30,
                                                child: RawMaterialButton(
                                                  onPressed: () =>
                                                      subItem(index),
                                                  elevation: 2.0,
                                                  fillColor: primaryColor,
                                                  child: Text(
                                                    "-",
                                                    style: TextStyle(
                                                        fontSize: 25.0,
                                                        color: blackColor),
                                                  ),
                                                  shape: CircleBorder(),
                                                )) : Text(''),
                                            Container(
                                              width:200,
                                              child: Text(
                                                billItems[index].service,
                                                textAlign: TextAlign.left,
                                                style: textStyle,
                                              ),
                                            ),
                                          ]),
                                      Container(
                                        width:80,
                                        child: Text(
                                          Utility.convertCurrency(billItems[index].cost),
                                          textAlign: TextAlign.right,
                                          style: textStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          demandBloc.isStatus(DemandStatus.HANDLING)
                              ? RawMaterialButton(
                                  onPressed: addItem,
                                  elevation: 2.0,
                                  fillColor: primaryColor,
                                  child: Icon(
                                    Icons.add,
                                    size: 25.0,
                                    color: blackColor,
                                  ),
                                  padding: EdgeInsets.all(5.0),
                                  shape: CircleBorder(),
                                ):Text(''),
                          Divider(),
                          demandBloc.isStatus(DemandStatus.PAYING)? Container(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                    "Phí",
                                    style: textStyle),
                                Text(Utility.convertCurrency(demandBloc.currentDemand.bill.fee),
                                    style: textStyle),
                              ],
                            ),
                          ): Text(''),
                          Container(
                            padding: EdgeInsets.only(top: 8.0, bottom: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Tổng",
                                  style: TextStyle(
                                      color: blackColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(calTotalCost(),
                                    style: TextStyle(
                                        color: blackColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
