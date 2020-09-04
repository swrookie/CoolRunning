import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget
{
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading>
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.cyan[300],
      body: Center(
        child: SpinKitThreeBounce(
          color: Colors.blue[500],
          size: 80.0,
        )
      )
    );
  }
}