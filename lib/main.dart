import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehicles_saver_partner/blocs/auth_bloc.dart';
import 'package:vehicles_saver_partner/blocs/demand_bloc.dart';
import 'package:vehicles_saver_partner/screens/splash/splash_screen.dart';
import 'package:vehicles_saver_partner/theme/style.dart';

import 'app_router.dart';
import 'blocs/place_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<PlaceBloc>(create: (context) => PlaceBloc()),
          ChangeNotifierProvider<AuthBloc>(create: (context) => AuthBloc()),
          ChangeNotifierProvider<DemandBloc>(create: (context) => DemandBloc()),
        ],
        child: MaterialApp(
          title: 'Vehicles Saver',
          theme: appTheme,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: AppRoute.generateRoute,
          home: SplashScreen(),
        ));
  }
}
