import 'dart:math';

import 'package:intl/intl.dart';
import 'package:vehicles_saver_partner/config.dart';
import 'package:vehicles_saver_partner/data/models/demand/demand.dart';

class Utility {
  static const MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  static double calculateDistance(lat1, lng1, lat2, lng2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
  static String convertCurrency(double amount){
    NumberFormat formatter = NumberFormat('#,###');
    return formatter.format(amount) + " " + Config.CURRENCY;
  }
  static String parseTimeDate(DateTime time){
    if(time == null){
      return "Null";
    }
    return "${time.day} ${MONTHS[time.month - 1]} ${time.year}";
  }
  static String parseTimeInDay(DateTime time){
    if(time == null){
      return "Null";
    }
    DateFormat formatter = DateFormat("HH:mm");
    return formatter.format(time);
  }
  static String statusToString(DemandStatus status){
    switch(status){
      case DemandStatus.SEARCHING_PARTNER:
        return "SEARCHING_PARTNER";
      case DemandStatus.HANDLING:
        return "HANDLING";
      case DemandStatus.PAYING:
        return "PAYING";
      case DemandStatus.COMPLETED:
        return "COMPLETED";
      case DemandStatus.CANCELED:
        return "CANCELED";
    }
  }
}