import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehicles_saver_partner/blocs/demand_bloc.dart';
import 'package:vehicles_saver_partner/components/animation_list_view.dart';
import 'package:vehicles_saver_partner/data/models/demand/demand.dart';
import 'package:vehicles_saver_partner/screens/home/pages/history/history_detail_screen.dart';
import 'package:vehicles_saver_partner/theme/style.dart';
import 'package:vehicles_saver_partner/utils/utility.dart';

class HistoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DemandBloc demandBloc;
  navigateToDetail(Demand demand) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => HistoryDetail(
          demand: demand,
            )
    ));
  }

  @override
  Widget build(BuildContext context) {
    demandBloc = Provider.of<DemandBloc>(context);

    return Scaffold(
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overScroll) {
            overScroll.disallowGlow();
            return false;
          },
          child:demandBloc.demandHistory.length > 0? ListView.separated(
              itemCount: demandBloc.demandHistory.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              separatorBuilder: (_, int i) {
                return Divider();
              },
              itemBuilder: (BuildContext context, int index) {
                return AnimationListView(
                    index: index,
                    child: GestureDetector(
                        onTap: () {
                          print('$index = ${demandBloc.demandHistory[index]}');
                          navigateToDetail(demandBloc.demandHistory[index]);
                        },
                        child: demandHistory(demandBloc.demandHistory[index])));
              })
          : Center(child: Text("Lịch sử trống", style: TextStyle(fontSize: 20),),),
        ),
    );
  }

  Widget demandHistory(Demand demand) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(15.0),
      color: whiteColor,
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0), color: whiteColor),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  Utility.parseTimeDate(demand.createdDate),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  Utility.statusToString(demand.status),
                  style: TextStyle(
                      color: demand.status == DemandStatus.CANCELED? redColor: greenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                )
              ],
            ),
            Divider(),
            Container(
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
                            Utility.parseTimeInDay(demand.createdDate),
                            style: TextStyle(
                                color: Color(0xFF97ADB6), fontSize: 13.0),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                            height: 25,
                            width: 1.0,
                            color: Colors.grey,
                          ),
                          Text(
                            demand.completedDate != null? Utility.parseTimeInDay(demand.completedDate):"Canceled",
                            style: TextStyle(
                                color: Color(0xFF97ADB6), fontSize: 13.0),
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
                                demand.vehicleType,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                                ),
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
                            Flexible(child:
                            Text(
                              demand.problemDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),)
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
