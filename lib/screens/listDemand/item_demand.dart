import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_saver_partner/data/models/demand/demand.dart';
import 'package:vehicles_saver_partner/theme/style.dart';

class ItemDemand extends StatelessWidget {
  final Demand demand;
  final distance;

  const ItemDemand(
      {Key key,
        this.demand,
        this.distance
      })
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 50.0,
        color: whiteColor,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 10.0,right: 10.0),
                  child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.transparent,
                      backgroundImage: CachedNetworkImageProvider(
                        demand.customer.avatarUrl,
                      )
                  ),
                ),
                Expanded(
                    flex: 5,
                    child: Container(
                      height: 65.0,
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(demand.customer.name,style: textBoldBlack,overflow: TextOverflow.ellipsis,),
                          Container(
                              child: Text(distance,style: textStyle,overflow: TextOverflow.ellipsis,)
                          )
                        ],
                      ),
                    )
                ),
                SizedBox(width: 10.0,)
              ],
            ),
           // Divider(),
          ],
        )
    );
  }
}
