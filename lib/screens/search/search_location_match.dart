import 'package:flutter/material.dart';
import 'package:fulbito_app/models/map_box_search_response.dart';
import 'package:fulbito_app/services/map_box_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class SearchLocationMatch extends SearchDelegate<Feature?> {
  @override
  final String searchFieldLabel;
  bool calledFromCreate;
  final MapBoxService _mapBoxService;
  final LatLng myCurrentLocation;

  SearchLocationMatch({required this.calledFromCreate, required this.myCurrentLocation})
      : this.searchFieldLabel = translations[localeName!]!['search']! + '...',
        this._mapBoxService = new MapBoxService();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          if (this.query.isEmpty) {
            close(context, null);
          }
          this.query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return this._buildResultSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return this._buildResultSuggestions(context);
  }

  Widget _buildResultSuggestions(BuildContext context) {

    if (this.query.isEmpty) {
      return Container();
    }

    this._mapBoxService.getSuggestionsByQuery(
          this.query.trim(),
          this.myCurrentLocation,
        );

    return StreamBuilder(
      stream: this._mapBoxService.suggestionsStream,
      builder: (context, AsyncSnapshot<MapBoxSearchResponse?> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [circularLoading],
            ),
          );
        }

        final places = snapshot.data?.features;

        if (snapshot.data == null || places == null || places.isEmpty) {
          return ListTile(
            title: Text('${translations[localeName]!['search.noResultsFor']!} $query'),
          );
        }

        return ListView.builder(
          itemCount: places.length,
          itemBuilder: (context, index) {

            final place = places[index];
            return ListTile(
              leading: Icon(Icons.location_on),
              title: Text(place.text),
              subtitle: Text(place.placeName),
              onTap: () async {

                close(context, place);

              },
            );
          },
        );

      },
    );
  }
}
