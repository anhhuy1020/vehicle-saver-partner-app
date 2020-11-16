import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehicles_saver_partner/blocs/auth_bloc.dart';
import 'package:vehicles_saver_partner/screens/edit_profile/edit_profile.dart';
import 'package:vehicles_saver_partner/theme/style.dart';

import '../../../app_router.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage>{
  AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    authBloc = Provider.of<AuthBloc>(context);
    return Container(
      child:NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overScroll) {
          overScroll.disallowGlow();
          return false;
        },
        child: SingleChildScrollView(
          child: Container(
            color: appTheme.backgroundColor,
            child: Column(
              children: <Widget>[
                Center(
                  child: Stack(
                    children: <Widget>[
                      Material(
                        elevation: 10.0,
                        color: Colors.white,
                        shape: CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: SizedBox(
                            height: 150,
                            width: 150,
                            child: Hero(
                              tag: "avatar_profile",
                              child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: CachedNetworkImageProvider(
                                    "https://source.unsplash.com/300x300/?portrait",
                                  )
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10.0,
                        left: 25.0,
                        height: 15.0,
                        width: 15.0,
                        child: Container(
                          width: 15.0,
                          height: 15.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: greenColor,
                              border: Border.all(
                                  color: Colors.white, width: 2.0)),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        authBloc.myInfo.name,
                        style: TextStyle( color: blackColor,fontSize: 35.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 50,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: whiteColor,
                            border: Border(
                                bottom: BorderSide(width: 1.0,color: appTheme?.backgroundColor)
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Email',style: textStyle,),
                            Text(authBloc.myInfo.email,style: textGrey,)
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: whiteColor,
                            border: Border(
                                bottom: BorderSide(width: 1.0,color: appTheme?.backgroundColor)
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Phone Number',style: textStyle,),
                            Text(authBloc.myInfo.phone,style: textGrey,)
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: whiteColor,
                            border: Border(
                                bottom: BorderSide(width: 1.0,color: appTheme?.backgroundColor)
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Address',style: textStyle,),
                            Text(authBloc.myInfo.address,style: textGrey,)
                          ],
                        ),
                      ),
                        Padding(padding: EdgeInsets.only(bottom: 30)),
                        ButtonTheme(
                          height: 40.0,
                          minWidth: MediaQuery.of(context).size.width,
                          child: RaisedButton.icon(
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                            elevation: 0.0,
                            color: primaryColor,
                            icon: new Text(""),
                            label: new Text('Thay đổi thông tin', style: TextStyle(color: Colors.black),),
                            onPressed: (){
                              Navigator.of(context).push(MaterialPageRoute<Null>(
                                builder: (BuildContext context) {
                                  return EditProfile();
                                },
                              ));
                            },
                          ),
                        ),
                        ButtonTheme(
                          height: 40.0,
                          minWidth: MediaQuery.of(context).size.width,
                          child: RaisedButton.icon(
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                            elevation: 0.0,
                            color: primaryColor,
                            icon: new Text(""),
                            label: new Text('Đăng xuất', style: TextStyle(color: Colors.black),),
                            onPressed: (){
                              Navigator.of(context).pushReplacementNamed(AppRoute.loginScreen);
                            },
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}