import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehicles_saver_partner/app_router.dart';
import 'package:vehicles_saver_partner/blocs/auth_bloc.dart';
import 'package:vehicles_saver_partner/blocs/demand_bloc.dart';
import 'package:vehicles_saver_partner/blocs/place_bloc.dart';

import 'tracking_demand_view.dart';

class TrackingDemandScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var placeBloc = Provider.of<PlaceBloc>(context);
    var demandBloc = Provider.of<DemandBloc>(context);
    var authBloc = Provider.of<AuthBloc>(context);
    if(!demandBloc.isHavingDemand()){
      Future.microtask(() => Navigator.of(context).pushNamedAndRemoveUntil(AppRoute.homeScreen, (Route<dynamic> route) => false));
    }
    return Scaffold(
      body: TrackingDemandView(
        placeBloc: placeBloc,
        demandBloc: demandBloc,
        authBloc: authBloc,
      ),
    );
  }
}
