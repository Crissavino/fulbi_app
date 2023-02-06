import 'dart:convert';

import 'package:fulbito_app/models/booking.dart';
import 'package:fulbito_app/utils/api.dart';

class BookingRepository {
  Api api = Api();

  Future getBooking(bookingId) async {
    final res = await api.getData('/booking/get/$bookingId');
    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      final response = {
        'success': true,
        'booking': Booking.fromJson(body['booking']),
      };

      return response;

    }

    return body;
  }

  Future getMyBookings() async {
    final res = await api.getData('/booking/get-my-bookings');
    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {

      List bookings = body['bookings'];
      body['bookings'] = bookings.map((booking) => Booking.fromJson(booking)).toList();

    }

    return body;
  }




}