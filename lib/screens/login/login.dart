import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehicles_saver_partner/blocs/auth_bloc.dart';
import 'package:vehicles_saver_partner/blocs/demand_bloc.dart';
import 'package:vehicles_saver_partner/components/dialog/loading_dialog.dart';
import 'package:vehicles_saver_partner/components/dialog/msg_dialog.dart';
import 'package:vehicles_saver_partner/components/ink_well_custom.dart';
import 'package:vehicles_saver_partner/network/socket/socket_connector.dart';
import 'package:vehicles_saver_partner/utils/validations.dart';
import 'package:vehicles_saver_partner/data/models/auth/user_login.dart';
import 'package:vehicles_saver_partner/theme/style.dart';

import '../../app_router.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  UserLogin _userLogin = new UserLogin();
  AuthBloc authBloc;
  bool autoValidate = false;
  Validations validations = new Validations();

  onLogin(){
    final FormState form = formKey.currentState;
    if (!form.validate()) {
      autoValidate = true; // Start validating on every change.
    } else {
      form.save();
      LoadingDialog.showLoadingDialog(context, 'Loading...');
      authBloc.login(_userLogin, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.of(context).pushReplacementNamed(AppRoute.homeScreen);
      } , (msg) {
        LoadingDialog.hideLoadingDialog(context);
        MsgDialog.showMsgDialog(context, "Đăng nhập", msg, null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    authBloc = Provider.of<AuthBloc>(context);
    DemandBloc demandBloc = Provider.of<DemandBloc>(context);
    _userLogin = new UserLogin();
    return Scaffold(
        body: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height,
            child: InkWellCustom(
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(children: <Widget>[
                      Container(
                        height: 220.0,
                        width: double.infinity,
                        color: Color(0xFFFDD148),
                      ),
                      Positioned(
                        bottom: 230.0,
                        right: 100.0,
                        child: Container(
                          height: 400.0,
                          width: 400.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200.0),
                            color: Color(0xFFFEE16D),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 280.0,
                        left: 150.0,
                        child: Container(
                            height: 300.0,
                            width: 300.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(150.0),
                                color: Color(0xFFFEE16D).withOpacity(0.5))),
                      ),
                      new Padding(
                          padding: EdgeInsets.fromLTRB(32.0, 120.0, 32.0, 0.0),
                          child: Container(
                              height: MediaQuery.of(context).size.height - 120.0,
                              width: double.infinity,
                              child: new Column(
                                children: <Widget>[
                                  new Container(
                                    padding: EdgeInsets.only(top: 100.0),
                                      child: new Material(
                                        borderRadius: BorderRadius.circular(7.0),
                                        elevation: 5.0,
                                        child: new Container(
                                          width: MediaQuery.of(context).size.width - 20.0,
                                          height: MediaQuery.of(context).size.height* 0.5,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20.0)),
                                          child: new Form(
                                              key: formKey,
                                              child: new Container(
                                                padding: EdgeInsets.all(32.0),
                                                child: new Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text('Đăng nhập', style: heading35Black,
                                                    ),
                                                    new Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          height:80,
                                                          child: TextFormField(
                                                            initialValue: "huyho1712@gmail.com",
                                                              keyboardType: TextInputType.emailAddress,
                                                            autovalidate:autoValidate,
                                                            validator: validations.validateEmail,
                                                              decoration: InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                  ),
                                                                  prefixIcon: Icon(Icons.email,
                                                                      color: Color(getColorHexFromStr('#FEDF62')), size: 20.0),
                                                                  contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                                                                  hintText: 'Email',
                                                                  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Quicksand')
                                                              ),
                                                            onSaved: (String value) {
                                                              _userLogin.email = value;
                                                            },
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 80,
                                                          child: TextFormField(
                                                            initialValue: "Huy3763958",

                                                            keyboardType: TextInputType.text,
                                                            autovalidate:autoValidate,
                                                            validator: validations.validatePassword,
                                                              obscureText: true,
                                                              decoration: InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                  ),
                                                                  prefixIcon: Icon(Icons.lock,
                                                                      color: Color(getColorHexFromStr('#FEDF62')), size: 20.0),
                                                                  contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                                                                  hintText: 'Mật khẩu',
                                                                  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Quicksand')
                                                              ),
                                                              onSaved: (String value) {
                                                                _userLogin.password = value;
                                                              },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    new ButtonTheme(
                                                      height: 50.0,
                                                      minWidth: MediaQuery.of(context).size.width,
                                                      child: RaisedButton.icon(
                                                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15.0)),
                                                        elevation: 0.0,
                                                        color: primaryColor,
                                                        icon: new Text(''),
                                                        label: new Text('ĐĂNG NHẬP', style: headingWhite,),
                                                        onPressed: (){
                                                          onLogin();
                                                          },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                          ),
                                        ),
                                      )
                                  ),
                                ],
                              )
                          )
                      ),
                    ]
                    )
                  ]
              ),
            )
        ),
      ),
    );
  }
}
