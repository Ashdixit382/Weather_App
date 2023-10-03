import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:weather_app2/Widgets/additional_info_item.dart';
import 'package:weather_app2/Widgets/daily_forcast.dart';
import 'package:weather_app2/Widgets/hourly_item.dart';
import 'package:weather_app2/Widgets/rise_row.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app2/models/constant.dart';
import 'package:weather_app2/models/weather_data.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late String lat;
  late String long;
  late Future<Map<String, dynamic>> weather;

  // Future<Position> getcurrentlocation() async {
  //   try {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       await Geolocator.requestPermission();
  //     }

  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied ||
  //         permission == LocationPermission.deniedForever) {
  //       return Future.error('Location permission are denied');
  //     }
  //     return await Geolocator.getCurrentPosition();
  //   } catch (e) {
  //     throw (e.toString());
  //   }
  // }

  Future<Position> getcurrentlocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> fetchData() async {
    try {
      final position = await getcurrentlocation();
      lat = position.latitude.toString();
      long = position.longitude.toString();
      return getWeather();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getWeather() async {
    try {
      // final weatherApiKey = "30693e73553d422d8d352010232709";

      final result = await http.get(
        Uri.parse(
            'https://api.weatherapi.com/v1/forecast.json?key=30693e73553d422d8d352010232709&q=$lat,$long&days=3&aqi=no&alerts=no'),
      );
      final data = jsonDecode(result.body);
      if (result.statusCode != 200) {
        throw 'An unexpected error occurred';
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final currentHour = int.parse(DateFormat.H().format(DateTime.now()));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            setState(
              () {
                weather = getWeather();
              },
            );
          },
        ),
        title: const Text('Weather App'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 28, 16, 46),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 28, 16, 46),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: weather,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text(snapshot.hasError.toString());
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              WeatherData weatherData = WeatherData.fromMap(data);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              weatherData.location,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              '${weatherData.currentTempInC.round()}°C',
                              style:
                                  TextStyle(fontSize: 52, color: Colors.white),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 54, 46, 101),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                weatherData.currentCondition,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                        Icon(
                          getIcons(data['forecast']['forecastday'][0]['day']
                              ['condition']['code']),
                          size: 100,
                          color: Colors.white,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AdditionalInfoItem(
                            title: '${weatherData.humidity}%',
                            icon: Icons.water_drop_outlined),
                        AdditionalInfoItem(
                            title: '${weatherData.currentPressureInBar} mBar',
                            icon: Icons.arrow_downward),
                        AdditionalInfoItem(
                            title: '${weatherData.currentWindSpeedInKph} km/h',
                            icon: Icons.air),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Stack(
                      children: [
                        SvgPicture.asset('line/6.svg'),
                        Positioned(
                          top: 25,
                          left: 0,
                          child: RiseRow(
                              image: 'images/sun2.svg',
                              text: data['forecast']['forecastday'][0]['astro']
                                  ['sunrise']),
                        ),
                        Positioned(
                          bottom: 20,
                          right: 0,
                          child: RiseRow(
                              image: 'images/moon1.svg',
                              text: data['forecast']['forecastday'][0]['astro']
                                  ['sunset']),
                        )
                      ],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Today',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 18),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 24 - currentHour,
                        itemBuilder: (context, index) {
                          final hourlyForecast = data['forecast']['forecastday']
                              [0]['hour'][index + currentHour];
                          final hourlyTime =
                              DateTime.parse(hourlyForecast['time']);
                          return HourlyItem(
                              hour: DateFormat.j().format(hourlyTime),
                              icon:
                                  getIcons(hourlyForecast['condition']['code']),
                              temp: '${hourlyForecast['temp_c'].round()}°C');
                        },
                      ),
                    ),
                    Column(
                      children: [
                        for (int i = 0;
                            i < data['forecast']['forecastday'].length;
                            i++) ...[
                          DailyForecast(
                            day: data['forecast']['forecastday'][i]['date'],
                            icon: getIcons(data['forecast']['forecastday'][i]
                                ['day']['condition']['code']),
                            maxTemp:
                                '${data['forecast']['forecastday'][i]['day']['maxtemp_c'].round()}°C',
                            minTemp:
                                '${data['forecast']['forecastday'][i]['day']['mintemp_c'].round()}°C',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                  child: Text('Weather data not available yet. Try Refresh'));
            }
          },
        ),
      ),
    );
  }
}
