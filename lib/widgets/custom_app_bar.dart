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
                    final List<Place> history = state.history.values.toList();
                    SearchPlacesDelegate delegate = SearchPlacesDelegate(
                      state.myLocation,
                      history,
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
  final List<Place> history;
  final SearchAPI _api = SearchAPI.instance;

  SearchPlacesDelegate(this.at, this.history);

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
        future: _api.search(this.query, this.at),
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
            return Center(child: Text("ERROR"));
          }
          return Center(child: CircularProgressIndicator());
        },
      );
    }

    return Text("invalid query");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Place> history = this.history;

    if (this.query.trim().length > 0) {
      final tmp = this.query.toLowerCase();
      history = history.where((element) {
        if (element.title.toLowerCase().contains(tmp)) {
          return true;
        } else if (element.vicinity.toLowerCase().contains(tmp)) {
          return true;
        }

        return false;
      }).toList();
    }

    return ListView.builder(
      itemBuilder: (_, index) {
        final Place place = history[index];
        return ListTile(
          leading: Icon(Icons.history),
          onTap: () => this.close(context, place),
          title: Text(
            place.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(place.vicinity.replaceAll('<br/>', ' - ')),
        );
      },
      itemCount: history.length,
    );
  }
}
