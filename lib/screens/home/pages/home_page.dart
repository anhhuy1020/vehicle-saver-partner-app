import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehicles_saver_partner/blocs/auth_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
  String _name;
  @override
  Widget build(BuildContext context) {
    _name=  Provider.of<AuthBloc>(context).myInfo.name;
    return ListView(children: [Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 30, left: 15, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào,',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    Text(
                      _name,
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),

                Container(
                  width: MediaQuery.of(context).size.width / 2.6,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.transparent,
                        backgroundImage: CachedNetworkImageProvider(
                          "https://source.unsplash.com/300x300/?portrait",
                        )
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ),],);
  }
}