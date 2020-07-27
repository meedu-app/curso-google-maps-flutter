import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_maps/api/search_api.dart';
import 'package:google_maps/blocs/pages/home/home_bloc.dart';
import 'package:google_maps/blocs/pages/home/home_state.dart';
import 'package:google_maps/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  CustomAppBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeBloc>(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (_, state) {
        return Container(
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Search place ... ",
                        style: TextStyle(
                          color: Colors.black26,
                        ),
                      ),
                      Icon(Icons.search),
                    ],
                  ),
                  onPressed: () async {
                    SearchPlacesDelegate delegate = SearchPlacesDelegate(
                      state.myLocation,
                    );
                    final Place place = await showSearch<Place>(
                      context: context,
                      delegate: delegate,
                    );
                    if (place != null) {
                      bloc.goToPlace(place);
                    }
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, 50);
}

class SearchPlacesDelegate extends SearchDelegate<Place> {
  final LatLng at;
  final SearchAPI _api = SearchAPI.instance;

  SearchPlacesDelegate(this.at);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          this.query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    print("query:::  ${this.query}");

    if (this.query.trim().length >= 3) {
      return FutureBuilder<List<Place>>(
        future: _api.searchPlace(this.query, this.at),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemBuilder: (__, index) {
                final Place place = snapshot.data[index];
                return ListTile(
                  onTap: () => this.close(context, place),
                  title: Text(
                    place.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(place.vicinity.replaceAll('<br/>', ' - ')),
                );
              },
              itemCount: snapshot.data.length,
            );
          } else if (snapshot.hasError) {
            return Text("ERROR");
          }
          return CircularProgressIndicator();
        },
      );
    }

    return Text("invalid query");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Text("🥶");
  }
}
