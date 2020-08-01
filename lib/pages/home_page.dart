import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/widgets/bottom_view.dart';
import 'package:google_maps/widgets/centered_marker.dart';
import 'package:google_maps/widgets/custom_app_bar.dart';
import 'package:google_maps/widgets/my_location_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../blocs/pages/home/bloc.dart';
import '../blocs/pages/home/bloc.dart';

class HomePage extends StatefulWidget {
  static const routeName = 'home-page';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeBloc _bloc = HomeBloc();
  // -0.1081339,-78.4699519,18z

  @override
  void initState() {
    super.initState();

    print("HOOOOOOOLA 😸");
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: this._bloc,
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (_, state) {
                if (!state.gpsEnabled) {
                  return Center(
                    child: Text(
                      "Para utilizar la app active el GPS",
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (state.loading) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                final CameraPosition initialPosition = CameraPosition(
                  target: state.myLocation,
                  zoom: 15,
                );

                return Column(
                  children: <Widget>[
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          GoogleMap(
                            initialCameraPosition: initialPosition,
                            zoomControlsEnabled: false,
                            compassEnabled: false,
                            myLocationEnabled: true,
                            markers: state.markers.values.toSet(),
                            polylines: state.polylines.values.toSet(),
                            polygons: state.polygons.values.toSet(),
                            myLocationButtonEnabled: false,
                            onMapCreated: (GoogleMapController controller) {
                              this._bloc.setMapController(controller);
                            },
                          ),
                          MyLocationButton(),
                          // CenteredMarked(
                          //   label: state.arrival != null
                          //       ? state.arrival.title
                          //       : '',
                          // )
                        ],
                      ),
                    ),
                    BottomView()
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
