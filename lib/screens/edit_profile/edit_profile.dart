import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vehicles_saver_partner/blocs/auth_bloc.dart';
import 'package:vehicles_saver_partner/components/dialog/loading_dialog.dart';
import 'package:vehicles_saver_partner/components/dialog/msg_dialog.dart';
import 'package:vehicles_saver_partner/components/ink_well_custom.dart';
import 'package:vehicles_saver_partner/components/inputDropdown.dart';
import 'package:vehicles_saver_partner/theme/style.dart';
import 'package:intl/intl.dart';
import 'package:vehicles_saver_partner/utils/validations.dart';
import 'dart:io' as IO;


class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  AuthBloc authBloc;
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> listGender = [{"id": '0',"name" : 'Male',},{"id": '1',"name" : 'Female',}];
  String selectedGender;
  String lastSelectedValue;
  bool autoValidate = false;
  Validations validations = new Validations();

  DateTime date = DateTime.now();
  var _image;

  Map editedProfile = new Map();


  submit() {
    final FormState form = formKey.currentState;
    if(!form.validate()){
      autoValidate = true; // Start validating on every change.
    }else {
      form.save();
      if (editedProfile.isEmpty) {
        MsgDialog.showMsgDialog(
            context, "Cập nhật thông tin", "Bạn không thay đổi gì cả", null);
        return;
      }
      LoadingDialog.showLoadingDialog(context, "Loading..");
      authBloc.updateProfile(editedProfile, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.pop(context);
      }, (msg) {
        LoadingDialog.hideLoadingDialog(context);
        MsgDialog.showMsgDialog(context, "Cập nhật thông tin", msg, null);
      });
    }
  }

  parseImage(IO.File image){
    if (image == null) return;
    String base64Image = base64Encode(image.readAsBytesSync());
    editedProfile['avatarUrl'] = base64Image;
  }

  Future getImageLibrary() async {
    IO.File gallery = await ImagePicker.pickImage(source: ImageSource.gallery,maxWidth: 700);
    parseImage(gallery);
    setState(() {
      _image = gallery;
    });
  }

  Future cameraImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 700);
    parseImage(image);
    setState(() {
      _image = image;
    });
  }

  void showDemoActionSheet({BuildContext context, Widget child}) {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => child,
    ).then((String value) {
      if (value != null) {
        setState(() { lastSelectedValue = value; });
      }
    });
  }

  selectCamera () {
    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
          title: const Text('Select Camera'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: const Text('Camera'),
              onPressed: () {
                Navigator.pop(context, 'Camera');
                cameraImage();
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Photo Library'),
              onPressed: () {
                Navigator.pop(context, 'Photo Library');
                getImageLibrary();
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, 'Cancel');
            },
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("build editprofie");
    authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: whiteColor,
        title: Text(
          'Edit profile',
          style: TextStyle(color: blackColor),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 20.0,right: 20.0, bottom: 20.0),
        child: ButtonTheme(
          height: 50.0,
          minWidth: MediaQuery.of(context).size.width-50,
          child: RaisedButton.icon(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            elevation: 0.0,
            color: primaryColor,
            icon: Text(''),
            label: Text('LƯU', style: headingBlack,),
            onPressed: (){
              submit();
            },
          ),
        ),
      ),
      body: Scrollbar(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overScroll) {
              overScroll.disallowGlow();
              return false;
            },
            child: SingleChildScrollView(
              child: InkWellCustom(
                  onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                  child: Form(
                    key: formKey,
                    child: Container(
                      color: Color(0xffeeeeee),
                      child: Column(
                        children: <Widget>[
                          Container(
                            color: whiteColor,
                            padding: EdgeInsets.all(10.0),
                            margin: EdgeInsets.only(bottom: 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Material(
                                  elevation: 5.0,
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100.0),
                                      child:_image == null
                                          ?GestureDetector(
                                          onTap: (){selectCamera();},
                                          child: Container(
                                            height: 80.0,
                                            width: 80.0,
                                            color: primaryColor,
                                            child: Hero(
                                              tag: "avatar_profile",
                                              child: CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor: Colors.transparent,
                                                  backgroundImage: CachedNetworkImageProvider(
                                                    authBloc.myInfo.avatarUrl,
                                                  )
                                              ),
                                            ),
                                          )
                                      ): GestureDetector(
                                          onTap: () {selectCamera();},
                                          child: Container(
                                            height: 80.0,
                                            width: 80.0,
                                            child: Image.file(_image,fit: BoxFit.cover, height: 800.0,width: 80.0,),
                                          )
                                      )
                                  ),
                                ),
                                Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(left: 20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          TextFormField(
                                            style: textStyle,
                                            initialValue:authBloc.myInfo.name,
                                            autovalidate:autoValidate,
                                            validator: validations.validateName,
                                            decoration: InputDecoration(
                                                fillColor: whiteColor,
                                                labelStyle: textStyle,
                                                hintStyle: TextStyle(color: Colors.white),
                                                counterStyle: textStyle,
                                                hintText: "Tên",
                                                border: UnderlineInputBorder(
                                                    borderSide:
                                                    BorderSide(color: Colors.white))),
                                            onChanged: (String name) {
                                              editedProfile['name'] = name;
                                            },
                                          ),
                                        ],
                                      ),
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            color: whiteColor,
                            padding: EdgeInsets.all(10.0),
                            margin: EdgeInsets.only(top: 10.0),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.only(right: 10.0),
                                          child: Text(
                                            "Số điện thoại",
                                            style: textStyle,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          initialValue: authBloc.myInfo.phone,
                                          autovalidate:autoValidate,
                                          validator: validations.validatePhone,
                                          style: textStyle,
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                              fillColor: whiteColor,
                                              labelStyle: textStyle,
                                              hintStyle: TextStyle(color: Colors.white),
                                              counterStyle: textStyle,
                                              border: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white))
                                          ),
                                          onChanged: (String phone) {
                                            editedProfile['phone'] = phone;
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.only(right: 10.0),
                                          child: Text(
                                            "Email",
                                            style: textStyle,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          initialValue: authBloc.myInfo.email,
                                          autovalidate:autoValidate,
                                          validator: validations.validateEmail,
                                          keyboardType: TextInputType.emailAddress,
                                          style: textStyle,
                                          decoration: InputDecoration(
                                              fillColor: whiteColor,
                                              labelStyle: textStyle,
                                              hintStyle:
                                              TextStyle(color: Colors.white),
                                              counterStyle: textStyle,
                                              border: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white))
                                          ),
                                          onChanged: (String email) {
                                            editedProfile['email'] = email;
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.only(right: 10.0),
                                          child: Text(
                                            "Địa chỉ",
                                            style: textStyle,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          initialValue: authBloc.myInfo.address,
                                          autovalidate:autoValidate,
                                          validator: validations.validateAddress,
                                          keyboardType: TextInputType.text,
                                          style: textStyle,
                                          decoration: InputDecoration(
                                              fillColor: whiteColor,
                                              labelStyle: textStyle,
                                              hintStyle:
                                              TextStyle(color: Colors.white),
                                              counterStyle: textStyle,
                                              border: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white))
                                          ),
                                          onChanged: (String address) {
                                            editedProfile['address'] = address;
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ),
            ),
          )
      ),
    );
  }
}

