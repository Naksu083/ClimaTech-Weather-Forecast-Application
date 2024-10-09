import 'package:final_project_appdev/const.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

void main() {
  runApp(const SecondTab(title: 'ClimaTech',));
}

class SecondTab extends StatefulWidget {
  const SecondTab({super.key, required this.title});

  final String title;

  @override
  State<SecondTab> createState() => _SecondTabState();
}

class _SecondTabState extends State<SecondTab> with SingleTickerProviderStateMixin {
  //API initialization
  final WeatherFactory _weatherFactory = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;

  //list of forecast
  List<Weather>? _forecast;
  List<Weather>? _hourlyForecast;

  //string capitalization for the weather forecast
  String capitalize(String? text) {
    if (text == null) return "";
    return text.toUpperCase();
  }

  //animation controller for the background
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
      //top alignment animation
      _topAlignmentAnimation = TweenSequence<Alignment>(
        [
          TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
            weight: 1,
          ),
          TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight),
            weight: 1,
          ),
          TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
            weight: 1,
          ),
          TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.topLeft),
            weight: 1,
          ),
        ]
      ).animate(_controller);

      //bottom alignment animation
      _bottomAlignmentAnimation = TweenSequence<Alignment>(
        [
          TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
            weight: 1,
          ),
          TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.topLeft),
            weight: 1,
          ),
          TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
            weight: 1,
          ),
          TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight),
            weight: 1,
          ),
        ]
      ).animate(_controller);

      _controller.repeat();
      //fetch weather forecast from the API
      _fetchWeather();
    }

  //fetch weataher by day and 3-hour interval
  Future<void> _fetchWeather() async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final forecast = await _weatherFactory.fiveDayForecastByCityName("Batangas");
      final hourlyForecast = await _weatherFactory.fiveDayForecastByCityName("Batangas");

      setState(() {
        _forecast = forecast;
        _hourlyForecast = hourlyForecast;
        if (_forecast != null && _forecast!.isNotEmpty) {
          _weather = _forecast![0];
          // ignore: avoid_print
          print("Weather data fetched successfully: $_weather");
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching weather data: $e");
    }
  }

  //refresh gesture to sync weather forecast
  Future<void> _refreshWeather() async {
    await _fetchWeather();
  }

  //color animation
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

//refresh animation
@override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshWeather,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return _buildUI();
          },
        ),
      ),
    ),
  );
}

//page layout, page color and scroll gesture
Widget _buildUI() {
  return Container(
    padding: const EdgeInsets.all(20.0),
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: const [
          Color.fromARGB(255, 37, 15, 65),
          Color.fromARGB(255, 129, 19, 198),
        ],
          begin: _topAlignmentAnimation.value,
          end: _bottomAlignmentAnimation.value,
        ),
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //dateTimeInfo widget and sizing
            const SizedBox(height: 10),
            dateTimeInfo(),
            //hourlyForecast widget and sizing
            const SizedBox(height: 35),
            hourlyForecast(),
            //additionalInfo widget and sizing
            const SizedBox(height: 35),
            Center(
              child: additionalInfo(_weather)),
          ],
        ),
      ),
    );
  }
  
  //realtime date and time information on the top part of the page
  Widget dateTimeInfo() {
    DateTime now = DateTime.now();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //icon format
            const Icon(
              Icons.access_time,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 16,
            ),
            //time format
            const SizedBox(width: 4),
            Text(DateFormat("h:mm a  |").format(now),
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            //icon format
            const SizedBox(width: 4),
            const Icon(
              Icons.calendar_today,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 16,
            ),
            //date format
            Text("  ${DateFormat("M.d.y").format(now)}",
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        //day format
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 4),
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontFamily: 'Manrope',
                fontSize: 40,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  //hourlyForecast layout and sizing
  Widget hourlyForecast() {
    return _hourlyForecast == null
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _hourlyForecast!.length,
              itemBuilder: (context, index) {
                final weather = _hourlyForecast![index];
                return hourlyForecastTile(weather);
              },
            ),
          );
  }

  //Icon and sizing of the forecast
  Widget hourlyForecastTile(Weather weather) {
  String iconUrl = 'http://openweathermap.org/img/wn/${weather.weatherIcon}@2x.png';

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 7.0),
    padding: const EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
    ),
    //day format
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          DateFormat("EEE").format(weather.date!), 
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        //time format
        const SizedBox(height: 5),
        Text(
          DateFormat("h a").format(weather.date!),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        //icon format
        const SizedBox(height: 5),
        Image.network(
          iconUrl,
          width: 40,
          height: 40,
        ),
        //temperature format
        const SizedBox(height: 5),
        Text(
          '${weather.temperature?.celsius?.toStringAsFixed(0) ?? '--'}°C',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

//additional information layout and sizing below the page
Widget additionalInfo(Weather? weather) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.70,
    width: MediaQuery.of(context).size.width * 0.80,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
    ),
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  //max temperature
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_fire_department_outlined, color: Colors.white),
                      Expanded(
                        child: Text(
                          weather != null ? 'Max Temp: ${weather.tempMax?.celsius?.toStringAsFixed(0) ?? '--'}°C' : 'Loading...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  //minimum temperature
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.thermostat_outlined, color: Colors.white),
                      Expanded(
                        child: Text(
                          weather != null ? 'Min Temp: ${weather.tempMin?.celsius?.toStringAsFixed(0) ?? '--'}°C' : 'Loading...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  //wind speed
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.air_outlined, color: Colors.white),
                      Expanded(
                        child: Text(
                          weather != null ? 'Wind Speed: ${weather.windSpeed?.toStringAsFixed(2) ?? '--'} m/s' : 'Loading...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  //humidity
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.water_drop_outlined, color: Colors.white),
                      Expanded(
                        child: Text(
                          weather != null ? 'Humidity: ${weather.humidity?.toStringAsFixed(0) ?? '--'}%' : 'Loading...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  //pressure
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_tethering_sharp, color: Colors.white),
                      Expanded(
                        child: Text(
                          weather != null ? 'Pressure: ${weather.pressure?.toStringAsFixed(0) ?? '--'} psi' : 'Loading...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  //wind direction
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rotate_90_degrees_ccw_sharp, color: Colors.white),
                      Expanded(
                        child: Text(
                          weather != null ? 'Wind Direction: ${weather.windDegree?.toStringAsFixed(0) ?? '--'}°' : 'Loading...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  //latitude
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.blur_circular, color: Colors.white),
                      Expanded(
                        child: Text(
                          weather != null ? 'Latitude: ${weather.latitude ?? '--'}°' : 'Loading...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  //longitude
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.blur_circular_outlined, color: Colors.white),
                      Expanded(
                        child: Text(
                          weather != null ? 'Longitude: ${weather.longitude ?? '--'}°' : 'Loading...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
