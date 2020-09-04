import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.pink, width: 2.0),
  ),
);

var titleAppBar = AppBar(
  backgroundColor: Colors.cyan[300],
  title: Text('CoolRunning'),
  centerTitle: true,
);