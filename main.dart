import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikacja pogodowa',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Aplikacja pogodowa'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _cityName = '';
  String _temperature = '';
  String _humidity = '';
  String _windSpeed = '';
  String _pressure = '';
  String _description = '';
  List<String> _searchHistory = [];
  String _currentLocation = '';
  bool _isDarkMode = true;

  Future<void> _getWeatherData(String cityName) async {
    final apiKey = '00be36383cc200087226dc2b9f8e83fb';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _temperature = data['main']['temp'].toString();
        _humidity = data['main']['humidity'].toString();
        _windSpeed = data['wind']['speed'].toString();
        _pressure = data['main']['pressure'].toString();
        _description = data['weather'][0]['description'];
      });
    } else {
      throw Exception('Błąd podczas pobierania danych pogodowych');
    }
  }

  void _updateSearchHistory(String cityName) {
    setState(() {
      _searchHistory.add(cityName);
    });
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final latitude = position.latitude;
    final longitude = position.longitude;
    final placemarks = await placemarkFromCoordinates(latitude, longitude);
    final cityName = placemarks[0].locality;

    setState(() {
      _currentLocation = 'Twoja obecna lokalizacja to: $cityName';
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikacja pogodowa',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Wpisz nazwę miasta:',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'np. Warszawa',
                ),
                onChanged: (value) {
                  _cityName = value;
                },
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _getWeatherData(_cityName);
                      _updateSearchHistory(_cityName);
                    },
                    icon: Icon(Icons.cloud),
                    label: Text('Wyszukaj'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _getCurrentLocation();
                    },
                    icon: Icon(Icons.location_on),
                    label: Text('Obecna lokalizacja'),
                  ),
                  SizedBox(
                    width: 50.0,
                    height: 40.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        _toggleTheme();
                      },
                      child: Icon(Icons.lightbulb),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Text(
                'Dane pogodowe:',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Icon(Icons.thermostat),
                  SizedBox(width: 8.0),
                  Text('Temperatura: $_temperature°C'),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Icon(Icons.opacity),
                  SizedBox(width: 8.0),
                  Text('Wilgotność: $_humidity%'),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Icon(Icons.air),
                  SizedBox(width: 8.0),
                  Text('Prędkość wiatru: $_windSpeed m/s'),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Icon(Icons.speed),
                  SizedBox(width: 8.0),
                  Text('Ciśnienie: $_pressure hPa'),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Icon(Icons.description),
                  SizedBox(width: 8.0),
                  Text('Opis: $_description'),
                ],
              ),
              SizedBox(height: 16.0),
              Text(
                'Historia wyszukiwania:',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _searchHistory.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_searchHistory[index]),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.0),
              Text(_currentLocation),
            ],
          ),
        ),
      ),
    );
  }
}
