import 'package:flutter/material.dart';
import 'package:flutter_coolrunning/constants.dart';

class Result extends StatefulWidget
{
  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result>
{
  Map data = {};

  @override
  Widget build(BuildContext context)
  {
    data = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: titleAppBar,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'TOTAL RUNNING TIME',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Text(
              data['totalTime'],
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 50.0),
            Text(
              'SCORE',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height:20.0),
            Text(
              data['speedScore'].toString(),
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50.0),
            Align(
              child: RaisedButton(
                padding: EdgeInsets.all(4.0),
                color: Colors.lightBlue,
                shape: StadiumBorder(),
                child: Text(
                  'START AGAIN',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/map_routes');
        },
        child: Icon(
          Icons.map,
        ),
        backgroundColor: Colors.lightBlue
      ),
    );
  }
}