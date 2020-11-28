import 'package:flutter/cupertino.dart';
import 'package:vehicles_saver_partner/data/models/map/get_routes_request_model.dart';
import 'package:vehicles_saver_partner/network/http/web_api_client.dart';
import 'package:vehicles_saver_partner/config.dart';
import 'package:vehicles_saver_partner/data/models/auth/user_login.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'json_message.dart';

class APIs {
  static final GMapClient _gmapClient = GMapClient();

  static login(UserLogin userLogin, Function(Map) onSuccess,
      Function onError) async {
    String tokenURL = Config.SERVICE_URI + "/login";

    print("url: " + tokenURL);
    final http.Response response = await http.post(
      tokenURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(userLogin.toJson()),
    );
    if (response.statusCode == 200) {
      onSuccess(json.decode(response.body));
    } else {
      onError(json.decode(response.body));
    }
  }

  static Future<JsonMessage> getRoutes({@required GetRoutesRequestModel getRoutesRequest}) async {
    return await _gmapClient.fetch(
      url: 'https://maps.googleapis.com/maps/api/directions/json',
      key: Config.API_KEY,
      queryParameters: getRoutesRequest.toJson(),
    );
  }
}
