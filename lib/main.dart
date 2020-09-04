import 'package:flutter/material.dart';
import 'package:flutter_coolrunning/home.dart';
import 'package:flutter_coolrunning/map_routes.dart';
import 'package:flutter_coolrunning/results.dart';
import 'package:flutter_coolrunning/running.dart';

void main()
{
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Home(),
      '/running': (context) => Running(),
      '/results': (context) => Result(),
      '/map_routes': (context) => MapRoutes(),
    },
  ));
}