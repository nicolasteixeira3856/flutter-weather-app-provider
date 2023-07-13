import 'package:flutter_weather_app_provider/exceptions/weather_exception.dart';
import 'package:flutter_weather_app_provider/models/custom_error.dart';
import 'package:flutter_weather_app_provider/models/direct_geocoding.dart';
import 'package:flutter_weather_app_provider/services/weather_api_services.dart';

import '../models/weather.dart';

class WeatherRepository {
  final WeatherApiServices weatherApiServices;

  WeatherRepository({required this.weatherApiServices});

  Future<Weather> fetchWeather(String city) async {
    try {
      final DirectGeocoding directGeocoding = await weatherApiServices.getDirectGeocoding(city);
      final Weather tempWeather = await weatherApiServices.getWeather(directGeocoding);
      final Weather weather = tempWeather.copyWith(
        name: directGeocoding.name,
        country: directGeocoding.country
      );
      return weather;
    } on WeatherException catch (e) {
      throw CustomError(errMsg: e.message);
    } catch (e) {
      throw CustomError(errMsg: e.toString());
    }
  }
}