import 'package:flutter/material.dart';
import 'package:vehicles_saver_partner/screens/home/home.dart';
import 'package:vehicles_saver_partner/screens/listDemand/list_demand.dart';
import 'package:vehicles_saver_partner/screens/login/login.dart';
import 'package:vehicles_saver_partner/screens/splash/splash_screen.dart';

class PageViewTransition<T> extends MaterialPageRoute<T> {
  PageViewTransition({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (animation.status == AnimationStatus.reverse)
      return super.buildTransitions(context, animation, secondaryAnimation, child);
    return FadeTransition(opacity: animation, child: child);
  }
}

class AppRoute {
  static const String splashScreen = '/splashScreen';
  static const String loginScreen = '/login';
  static const String homeScreen = '/home';
  static const String listDemandScreen = '/list-demand';
  static const String trackingDemandScreen = '/tracking-demand';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return PageViewTransition(builder: (_) => SplashScreen());
      case loginScreen:
        return PageViewTransition(builder: (_) => LoginScreen());
      case homeScreen:
        return PageViewTransition(builder: (_) => HomeScreen());
      case listDemandScreen:
        return PageViewTransition(builder: (_) => ListDemandScreen());
      default:
        return PageViewTransition(
            builder: (_) => Scaffold(
              appBar: AppBar(),
              body: Center(
                  child: Text('No route defined for ${settings.name}')),
            ));
    }
  }
}
