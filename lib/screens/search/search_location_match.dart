import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fulbito_app/bloc/complete_profile/complete_profile_bloc.dart';
import 'package:fulbito_app/models/map_box_search_response.dart';
import 'package:fulbito_app/models/user_location.dart';
import 'package:fulbito_app/repositories/location_repository.dart';
import 'package:fulbito_app/services/map_box_service.dart';
import 'package:fulbito_app/services/place_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/create_map.dart';
import 'package:fulbito_app/widgets/map.dart';
import 'package:fulbito_app/widgets/modal_top_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:uuid/uuid.dart';

class SearchLocationMatch extends SearchDelegate<Feature?> {
  final sessionToken = Uuid().v4();

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
      return ListTile(
        leading: Icon(Icons.location_on),
        title: Text('place.text'),
        subtitle: Text('place.placeName'),
        onTap: () async {

          print('place');

          // close(context, myLocationSuggestion);
        },
      );
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
            title: Text('No hay resultados para $query'),
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





    // return FutureBuilder(
    //   // We will put the api call here
    //   future: this._mapBoxService.searchPlaceByQuery(this.query.trim(), this.myCurrentLocation),
    //   builder: (context, AsyncSnapshot<MapBoxSearchResponse?> snapshot) => query ==
    //       ''
    //       ? BlocBuilder<CompleteProfileBloc, CompleteProfileState>(
    //       builder: (BuildContext context, state) {
    //         if (state is ProfileCompleteLoadingUserLocationState) {
    //           return Container(
    //             width: MediaQuery.of(context).size.width,
    //             height: MediaQuery.of(context).size.height,
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               children: [circularLoading],
    //             ),
    //           );
    //         }
    //         return Container();
    //       })
    //       : snapshot.hasData
    //       ? BlocBuilder<CompleteProfileBloc, CompleteProfileState>(
    //     builder: (BuildContext context, state) {
    //       if (state is ProfileCompleteLoadingUserLocationState) {
    //         return Container(
    //           width: MediaQuery.of(context).size.width,
    //           height: MediaQuery.of(context).size.height,
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: [circularLoading],
    //           ),
    //         );
    //       }
    //
    //       return ListView.builder(
    //         itemCount: snapshot.data!.length,
    //         itemBuilder: (context, index) {
    //           return ListTile(
    //             // we will display the data returned from our future here
    //             title: Text(
    //                 snapshot.data![index].description != null
    //                     ? snapshot.data![index].description!
    //                     : '${snapshot.data![0].details!.lat.toString()} ${snapshot.data![0].details!.lng.toString()}'
    //             ),
    //             onTap: () async {
    //               final UserLocation locationDetails =
    //               await PlaceApiProvider(sessionToken)
    //                   .getPlaceDetailFromId(
    //                   snapshot.data![index].placeId!);
    //               locationDetails.lng =
    //                   snapshot.data![index].details!.lng;
    //               locationDetails.lat =
    //                   snapshot.data![index].details!.lat;
    //               final Suggestion myLocationSuggestion = Suggestion(
    //                 snapshot.data![index].placeId,
    //                 snapshot.data![index].description,
    //                 locationDetails,
    //               );
    //
    //               close(context, myLocationSuggestion);
    //             },
    //           );
    //         },
    //       );
    //     },
    //   )
    //       : Container(
    //     width: MediaQuery.of(context).size.width,
    //     height: MediaQuery.of(context).size.height,
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [circularLoading],
    //     ),
    //   ),
    // );
  }
}
