class Validations {
  String validateName(String value) {
    if (value.isEmpty) return 'Tên không được để trống';
    final RegExp nameExp = new RegExp(r'^[A-za-z ]+$');
    if (!nameExp.hasMatch(value))
      return 'Chỉ được nhập ký tự chữ';
    return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Nhập sai định dạng email';
    else
      return null;
  }

  String validatePassword(String value) {
  Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return 'Mật khẩu không hợp lệ';
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
}
