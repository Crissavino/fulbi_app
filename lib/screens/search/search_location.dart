import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fulbito_app/bloc/complete_profile/complete_profile_bloc.dart';
import 'package:fulbito_app/models/user_location.dart';
import 'package:fulbito_app/repositories/location_repository.dart';
import 'package:fulbito_app/services/place_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/create_map.dart';
import 'package:fulbito_app/widgets/modal_top_bar.dart';
import 'package:uuid/uuid.dart';

@deprecated
class SearchLocation extends SearchDelegate<Suggestion?> {
  final sessionToken = Uuid().v4();

  @override
  final String searchFieldLabel;

  SearchLocation() : this.searchFieldLabel = translations[localeName!]!['search']! + '...';

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
    return Text('buildResults');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      // We will put the api call here
      future: PlaceApiProvider(sessionToken).fetchSuggestions(query),
      builder: (context, AsyncSnapshot<List<Suggestion>> snapshot) => query ==
              ''
          ? BlocBuilder<CompleteProfileBloc, CompleteProfileState>(
              builder: (BuildContext context, state) {
              if (state is ProfileCompleteLoadingUserLocationState) {
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
              return Container(
                padding: EdgeInsets.all(16.0),
                child: ListTile(
                  leading: Icon(Icons.my_location),
                  title: Text(translations[localeName!]!['myLocation']!),
                  onTap: () async {
                    // BlocProvider.of<CompleteProfileBloc>(context)
                    //     .add(ProfileCompleteLoadingUserLocationEvent());
                    final myLatLong =
                        await LocationRepository().determinePosition();
                    final location = await PlaceApiProvider(sessionToken)
                        .fetchMyLocation(
                            myLatLong.latitude, myLatLong.longitude);
                    final UserLocation locationDetails =
                        await PlaceApiProvider(sessionToken)
                            .getPlaceDetailFromId(location.placeId!);
                    locationDetails.lat = location.details!.lat;
                    locationDetails.lng = location.details!.lng;
                    final Suggestion myLocationSuggestion = Suggestion(
                      location.placeId,
                      location.description,
                      locationDetails,
                    );

                    close(context, myLocationSuggestion);
                  },
                ),
              );
            })
          : snapshot.hasData
              ? BlocBuilder<CompleteProfileBloc, CompleteProfileState>(
                  builder: (BuildContext context, state) {
                    if (state is ProfileCompleteLoadingUserLocationState) {
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

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          // we will display the data returned from our future here
                          title: Text(
                              snapshot.data![index].description != null
                                  ? snapshot.data![index].description!
                                  : '${snapshot.data![0].details!.lat.toString()} ${snapshot.data![0].details!.lng.toString()}'
                          ),
                          onTap: () async {
                            final UserLocation locationDetails =
                                await PlaceApiProvider(sessionToken)
                                    .getPlaceDetailFromId(
                                        snapshot.data![index].placeId!);
                            locationDetails.lng =
                                snapshot.data![index].details!.lng;
                            locationDetails.lat =
                                snapshot.data![index].details!.lat;
                            final Suggestion myLocationSuggestion = Suggestion(
                              snapshot.data![index].placeId,
                              snapshot.data![index].description,
                              locationDetails,
                            );

                            close(context, myLocationSuggestion);
                          },
                        );
                      },
                    );
                  },
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [circularLoading],
                  ),
                ),
    );
  }
}
