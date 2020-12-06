class Config{
  static const String API_KEY = 'AIzaSyAi8DFXT-2iM2wTHYR1Bd1KDRrY1RAY-Jc';
  static const String LANGUAGE = 'vi';
  static const String REGION = 'VN';
  static const String CURRENCY = "đ";
  static const String MODE = "dev";
  static const String DEV = "dev";
  static const String RELEASE = "dev";
  static const String SERVICE_URI = MODE ==DEV?'http://10.0.2.2:3002':'https://vehicle-saver.herokuapp.com';

}

class SharedPreferenceKeys {
  static const String IS_USER_LOGGED_IN = "IS_USER_LOGGED_IN";
  static const String USER = "USER";
}