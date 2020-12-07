import 'package:vehicles_saver_partner/data/models/bill/bill_item.dart';

class Validations {
  String validateName(String value) {
    if (value.isEmpty) return 'Tên hiển thị không được để trống.';
    return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Email không hợp lệ.';
    else
      return null;
  }

  String validatePassword(String value) {
    Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Mật khẩu không hợp lệ.';
    else
      return null;
  }

  String validatePhone(String value) {
    if (value.length != 10)
      return 'Số điện thoại phải gồm 10 chữ số';
    else
      return null;
  }

  String validateAddress(String value) {
    return null;
  }

  String validateInvoice(List<BillItem> bill){
    if(bill.length <= 0){
      return 'Bạn phải thêm ít nhất một dịch vụ để hoàn thành yêu cầu';
    }
    double total = 0;
    for (int i = 0; i< bill.length; i++){
      total += bill[i].cost;
    }
    if(total <= 0){
      return 'Tổng chi phí phải lớn hơn 0';
    }
    return null;
  }
}