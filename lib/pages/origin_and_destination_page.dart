import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/api/search_api.dart';
import 'package:google_maps/models/place.dart';
import 'package:google_maps/utils/debounce.dart';

class OriginAndDestinationPage extends StatefulWidget {
  final Place origin, destination;
  final List<Place> history;
  final void Function(Place origin) onOriginChanged;
  final void Function(bool isOrigin) onMapPick;
  final bool hasOriginFocus;

  const OriginAndDestinationPage({
    Key key,
    @required this.origin,
    @required this.destination,
    @required this.history,
    @required this.onOriginChanged,
    @required this.onMapPick,
    this.hasOriginFocus = false,
  }) : super(key: key);

  @override
  _OriginAndDestinationPageState createState() =>
      _OriginAndDestinationPageState();
}

class _OriginAndDestinationPageState extends State<OriginAndDestinationPage> {
  final FocusNode _originFocus = FocusNode();
  final FocusNode _destinationFocus = FocusNode();

  bool _searching = false;
  List<Place> _results = [];
  ValueNotifier<String> _query = ValueNotifier('');

  bool _originHasFocus = false;
  SearchAPI _searchAPI = SearchAPI.instance;
  Debounce _debounce = Debounce(Duration(milliseconds: 300));
  StreamSubscription _subscription;
  TextEditingController _originController, _destinationController;

  @override
  void initState() {
    super.initState();
    _originHasFocus = widget.hasOriginFocus;
    _originController = TextEditingController(text: widget.origin.title);
    if (widget.destination != null) {
      _destinationController = TextEditingController(
        text: widget.destination.title,
      );
    } else {
      _destinationController = TextEditingController();
    }

    _originFocus.addListener(() {
      setState(() {
        _originHasFocus = true;
      });
    });

    _destinationFocus.addListener(() {
      setState(() {
        _originHasFocus = false;
      });
    });

    if (_originHasFocus) {
      _originFocus.requestFocus();
    } else {
      _destinationFocus.requestFocus();
    }
  }

  @override
  void dispose() {
    _originController?.dispose();
    _destinationController?.dispose();
    _originFocus.dispose();
    _destinationFocus.dispose();
    _searchAPI.cancel();
    _debounce.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  _onInputChanged(String query) {
    _query.value = query;
    if (_subscription != null) {
      _subscription.cancel();
    }
    _debounce.cancel();
    if (query.trim().length >= 3) {
      setState(() {
        _searching = true;
      });
      _debounce.create(() => this._search(query));
    } else {
      if (_searching || _results.length > 0) {
        setState(() {
          _searching = false;
          _results = [];
        });
      }
      _searchAPI.cancel();
    }
  }

  _search(String query) {
    _subscription = _searchAPI
        .search(
          query,
          widget.origin.position,
        )
        .asStream()
        .listen((List<Place> results) {
      setState(() {
        _searching = false;
        _results = results ?? [];
      });
    });
  }

  Widget _buildList(bool isHistory) {
    List<Place> items = isHistory ? widget.history : this._results;

    if (isHistory) {
      items = items.where((e) {
        if (e.title.toLowerCase().contains(_query.value)) {
          return true;
        }

        if (e.vicinity.toLowerCase().contains(_query.value)) {
          return true;
        }

        return false;
      }).toList();
    }

    return ListView.builder(
      itemBuilder: (_, index) {
        final Place item = items[index];
        return ListTile(
          leading: isHistory ? Icon(Icons.history) : null,
          onTap: () {
            if (_originHasFocus) {
              _originController.text = item.title;
              widget.onOriginChanged(item);
              _destinationFocus.requestFocus();
            } else {
              Navigator.pop(context, item);
            }
          },
          title: Text(
            item.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            item.vicinity.replaceAll('<br/>', ' - '),
          ),
        );
      },
      itemCount: items.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          "A donde vas?",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    _Input(
                      onChanged: this._onInputChanged,
                      hasFocus: this._originHasFocus,
                      focusNode: _originFocus,
                      controller: _originController,
                      iconData: Icons.gps_fixed,
                      placeholder: "Tu punto de salida",
                      onClear: () {
                        _query.value = "";
                      },
                    ),
                    SizedBox(height: 10),
                    _Input(
                      onChanged: this._onInputChanged,
                      hasFocus: !this._originHasFocus,
                      focusNode: _destinationFocus,
                      controller: _destinationController,
                      iconData: Icons.pin_drop,
                      placeholder: "Dinos a donde vas?",
                      onClear: () {
                        _query.value = "";
                      },
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                child: Text(
                  "Definir ${this._originHasFocus ? 'origen' : 'destino'} en el mapa",
                ),
                onPressed: () {
                  widget.onMapPick(_originHasFocus);
                  Navigator.pop(context);
                },
              ),
              if (_searching)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Expanded(
                  child: ValueListenableBuilder<String>(
                    valueListenable: this._query,
                    builder: (_, query, __) => _buildList(
                      query.trim().length >= 3 ? false : true,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final IconData iconData;
  final String placeholder;
  final FocusNode focusNode;
  final bool hasFocus;
  final TextEditingController controller;
  final void Function(String) onChanged;
  final VoidCallback onClear;

  const _Input(
      {Key key,
      @required this.iconData,
      this.placeholder = '',
      @required this.focusNode,
      this.hasFocus = false,
      this.controller,
      @required this.onChanged,
      this.onClear})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      focusNode: this.focusNode,
      controller: this.controller,
      onChanged: this.onChanged,
      prefix: Padding(
        padding: EdgeInsets.all(5.0),
        child: Icon(this.iconData),
      ),
      suffix: Padding(
        padding: EdgeInsets.only(right: 5),
        child: CupertinoButton(
          child: Icon(
            Icons.clear,
            size: 14,
          ),
          onPressed: () {
            this.controller.text = "";
            if (this.onClear != null) {
              this.onClear();
            }
          },
          minSize: 20,
          padding: EdgeInsets.all(5),
          borderRadius: BorderRadius.circular(20),
          color: Colors.black26,
        ),
      ),
      placeholder: this.placeholder,
      decoration: BoxDecoration(
        color: Color(0xfff7f7f7),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          width: 2,
          color: this.hasFocus ? Colors.blue : Colors.white,
        ),
      ),
    );
  }
}
