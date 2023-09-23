import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/addtional_info_item.dart';
import 'package:weather/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  final TextEditingController _cityNameController =
      TextEditingController(); // Added TextEditingController

  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    // Updated getCurrentWeather method
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$openWeatherAPIKey'),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  double kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather('London'); // Default city name
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather(
                    _cityNameController.text); // Use the entered city name
              });
            },
            icon: const Icon(Icons.refresh),
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _cityNameController,
              decoration: InputDecoration(
                hintText: 'Enter a city or country',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    String cityName = _cityNameController.text;
                    setState(() {
                      weather = getCurrentWeather(cityName);
                    });
                  },
                ),
              ),
              onSubmitted: (_) {
                String cityName = _cityNameController.text;
                setState(() {
                  weather = getCurrentWeather(cityName);
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: weather, // Use the weather future
        builder: (context, snapshot) {
          print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp = data['list'][0]['main']['temp'];
          final currentSky = data['list'][0]['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWinSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];

          final currentTempKelvin = data['list'][0]['main']['temp'];
          final currentTempCelsius = kelvinToCelsius(currentTempKelvin);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // main card man....
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '${currentTempCelsius.toStringAsFixed(2)} °C', // Display in Celsius with two decimal places
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Icon(
                                  currentSky == 'Clouds' || currentSky == 'Rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 64,
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  currentSky,
                                  style: TextStyle(fontSize: 20),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Weather forecast cards
                  const Text(
                    'Hourly Forecast',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 16,
                  ),

                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final HourlyForecast = data['list'][index + 1];
                        final HourlySky =
                            data['list'][index + 1]['weather'][0]['main'];
                        final HourlyTemp =
                            HourlyForecast['main']['temp'].toString();
                        final time = DateTime.parse(HourlyForecast['dt_txt']);
                        return HourlyForeCastItem(
                          time: DateFormat.Hm().format(time),
                          temperature: HourlyTemp,
                          icon: HourlySky == 'Clouds' || HourlySky == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny,
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Additional Forecast',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AddtionalInfoItem(
                        icon: Icons.water_drop,
                        label: 'humidity',
                        value: currentHumidity.toString(),
                      ),
                      AddtionalInfoItem(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        value: currentWinSpeed.toString(),
                      ),
                      AddtionalInfoItem(
                        icon: Icons.beach_access,
                        label: 'Pressure',
                        value: currentPressure.toString(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
