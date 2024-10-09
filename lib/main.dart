import 'package:final_project_appdev/const.dart';
import 'package:final_project_appdev/splash_screen.dart';
import 'package:final_project_appdev/second_tab.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

void main() {
  runApp(const MaterialApp(home: SplashScreen()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //title and theme of the page
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClimaTech',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'ClimaTech'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  //API initialization
  final WeatherFactory _weatherFactory = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;
  List<Weather>? _forecast;

  //string capitalization for the weather forecast
  String capitalize(String? text) {
    if (text == null) return "";
    return text.toUpperCase();
  }
  
  //animation controller for the background
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));

    //top alignment animation
    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
        tween:
            Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
    ]).animate(_controller);

    //bottom alignment animation
    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween:
            Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
    ]).animate(_controller);

    _controller.repeat();
    //fetch weather forecast from the API
    _fetchWeather();
  }

  //color animation
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;


  //fetch weather forecast
  Future<void> _fetchWeather() async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final forecast =
          await _weatherFactory.fiveDayForecastByCityName("Batangas");
      setState(() {
        _forecast = forecast;
        if (_forecast != null && _forecast!.isNotEmpty) {
          _weather = _forecast![0];
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

  //tab bar theme and design
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 29, 3, 45),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                  size: 30.0,
                ),
              ), // Second tab
            ],
          ),
        ),
        //tab bar refresh and navigation routing
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: _refreshWeather,
              color: Colors.deepPurple,
              backgroundColor: Colors.white,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return _buildUI();
                },
                child: _buildUI(),
              ),
            ), // First tab content
            const SecondTab(
              title: 'ClimaTech',
            ), // Second tab content from the new file
          ],
        ),
      ),
    );
  }

  //widget UI background decoration
  Widget _buildUI() {
    if (_forecast == null) {
      return Stack(
        children: [
          Container(
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
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: LinearProgressIndicator(
              color: Colors.deepPurple, // Set your desired color here
            ),
          ),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchWeather,
      color: Colors.deepPurple,
      backgroundColor: Colors.white,
      child: Container(
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
        //scroll animation for the day forecast part of the page
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          //alignment of the page
          child: Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.07),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //dateTimeInfo widget and sizing
                dateTimeInfo(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                //weatherIcon widget and sizing
                weatherIcon(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                //forecastContainer widget
                forecastContainer(),
              ],
            ),
          ),
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
            const Icon(
              Icons.access_time,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 16,
            ),
            //time format
            const SizedBox(
                width: 4),
            Text(
              DateFormat("h:mm a  |").format(now),
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            //date format
            const SizedBox(
                width: 4),
            const Icon(
              Icons.calendar_today,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 16,
            ),
            Text("  ${DateFormat("M.d.y").format(now)}",
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontFamily: 'Manrope',
                fontSize: 16, // Reduced font size
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        //day format
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 4),
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontFamily: 'Manrope',
                fontSize: 40, // Reduced font size
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 1,
        ),
      ],
    );
  }

  Widget weatherIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png",
              ),
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: Text(
            "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C",
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontFamily: 'Manrope',
              fontSize: 50,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          child: Text(
            capitalize(_weather?.weatherDescription ?? ""),
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        const SizedBox(
            height:
                30), // Optional: Add some space between the description and the forecast text
        const Text(
          "7 Days Forecast",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget forecastContainer() {
    return SizedBox(
      height: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: _forecast!.map((weather) {
            return Center(
              // To center all the containers
              child: weatherDayContainer(
                DateFormat("EEEE").format(weather.date!),
                DateFormat("h:mm a").format(weather.date!),
                "${weather.temperature?.celsius?.toStringAsFixed(0)}°C",
                weather.weatherIcon, // Pass the icon code or URL here
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget weatherDayContainer(
      String day, String time, String temperature, String? iconCode) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              temperature,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Icon(
              _getWeatherIcon(iconCode),
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String? iconCode) {
    switch (iconCode) {
      case '01d':
        return Icons.wb_sunny;
      case '01n':
        return Icons.night_shelter;
      case '02d':
        return Icons.cloud;
      case '02n':
        return Icons.cloud;
      case '03d':
        return Icons.cloud;
      case '03n':
        return Icons.cloud;
      case '04d':
        return Icons.cloud;
      case '04n':
        return Icons.cloud;
      case '09d':
        return Icons.umbrella;
      case '09n':
        return Icons.umbrella;
      case '10d':
        return Icons.beach_access;
      case '10n':
        return Icons.beach_access;
      case '11d':
        return Icons.flash_on;
      case '11n':
        return Icons.flash_on;
      case '13d':
        return Icons.ac_unit;
      case '13n':
        return Icons.ac_unit;
      case '50d':
        return Icons.foggy;
      case '50n':
        return Icons.foggy;
      default:
        return Icons.help_outline;
    }
  }
}
