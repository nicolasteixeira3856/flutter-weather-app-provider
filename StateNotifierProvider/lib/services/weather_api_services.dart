import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_weather_app_provider/constants/constants.dart';
import 'package:flutter_weather_app_provider/exceptions/weather_exception.dart';
import 'package:flutter_weather_app_provider/models/direct_geocoding.dart';
import 'package:flutter_weather_app_provider/services/http_error_handler.dart';
import 'package:http/http.dart' as http;

import '../models/weather.dart';

class WeatherApiServices {
  final http.Client httpClient;

  WeatherApiServices({required this.httpClient});

  Future<DirectGeocoding> getDirectGeocoding(String city) async {
    final Uri uri = Uri(
        scheme: 'https',
        host: kApiHost,
        path: '/geo/1.0/direct',
        queryParameters: {
          'q': city,
          'limit': kLimit,
          'appId': dotenv.env['APPID'],
        });

    try {
      final http.Response response = await httpClient.get(uri);

      if (response.statusCode != 200) {
        throw Exception(httpErrorHandler(response));
      }

      final responseBody = json.decode(response.body);

      if (responseBody.isEmpty) {
        throw WeatherException(message: 'Cannot get the location of $city');
      }

      final directGeocoding = DirectGeocoding.fromJson(responseBody);

      print('directGeocoding: ${directGeocoding}');

      return directGeocoding;
    } catch (e) {
      rethrow;
    }
  }

  Future<Weather> getWeather(DirectGeocoding directGeocoding) async {
    final Uri uri = Uri(
        scheme: 'https',
        host: kApiHost,
        path: '/data/2.5/weather',
        queryParameters: {
          'lat': directGeocoding.lat.toString(),
          'lon': directGeocoding.lon.toString(),
          'units': kUnit,
          'appId': dotenv.env['APPID'],
        });

    try {
      final http.Response response = await httpClient.get(uri);

      if (response.statusCode != 200) {
        throw Exception(httpErrorHandler(response));
      }

      final weatherJson = json.decode(response.body);

      if (weatherJson.isEmpty) {
        throw WeatherException(
            message: 'Cannot get the temperature of ${directGeocoding.name}');
      }

      final weather = Weather.fromJson(weatherJson);

      return weather;
    } catch (e) {
      print('Caiu no erro do get weather: ${e}');
      rethrow;
    }
  }
}
