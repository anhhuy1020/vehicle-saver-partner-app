import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehicles_saver_partner/blocs/place_bloc.dart';

import 'tracking_demand_view.dart';

class TrackingDemandScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var placeBloc = Provider.of<PlaceBloc>(context);

    return Scaffold(
      body: TrackingDemandView(
        placeBloc: placeBloc,
      ),
    );
  }
}
