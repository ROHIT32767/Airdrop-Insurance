import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';

class Precipitation extends StatefulWidget {
  const Precipitation({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PrecipitationState();
  }
}

class _PrecipitationState extends State<Precipitation> {
  dynamic temp;
  dynamic description;
  dynamic currently;
  dynamic humidilty;
  dynamic windSpeed;

  Future getWeather() async {
    var url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=Hyderabad&appid=dc594be602bfec786cac46ff0383a6d0");

    http.Response response = await http.get(url);
    var results = jsonDecode(response.body);
    setState(() {
      temp = (results['main']['temp'] - 273).round();
      description = results['weather'][0]['description'];
      currently = results['weather'][0]['main'];
      humidilty = results['main']['humidity'];
      windSpeed = results['wind']['speed'];
    });
  }

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height / 3,
          width: MediaQuery.of(context).size.width,
          color: const Color(0xff392850),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "Currently in Hyderabad",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                temp != null ? "$temp\u00B0" : "loading",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40.0,
                    fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  currently != null ? currently.toString() : "loading",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(children: <Widget>[
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.thermometer),
                    title: const Text("Temperature"),
                    trailing: Text(
                        temp != null ? "$temp\u00B0" : "loading"),
                  ),
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.cloud),
                    title: const Text("Weather"),
                    trailing: Text(
                      description != null ? description.toString() : "loading",
                    ),
                  ),
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.sun),
                    title: const Text("Humidity"),
                    trailing: Text(
                      humidilty != null ? humidilty.toString() : "loading",
                    ),
                  ),
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.wind),
                    title: const Text("Wind Speed"),
                    trailing: Text(
                      windSpeed != null ? windSpeed.toString() : "loading",
                    ),
                  )
                ])))
      ]),
    );
  }
}
