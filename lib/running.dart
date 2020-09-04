import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_coolrunning/constants.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:geolocator/geolocator.dart';

class Running extends StatefulWidget
{
  @override
  _RunningState createState() => _RunningState();
}

class _RunningState extends State<Running>
{
  Map data = {};
  var displayTime;
  double speedInMps = 0.0;

  // stop watch timer instance
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  // location instances
  final Stream<Position> _position = GeolocatorPlatform.instance.getPositionStream();
  StreamSubscription<Position> _positionStream;

  Future listenPosition() async
  {
    _positionStream = await _position.listen((Position position) {
      setState(() {
        print(position);
        speedInMps = position.speed.roundToDouble();
      });
    });
  }

  @override
  void initState()
  {
    super.initState();
    listenPosition();
  }

  @override
  void dispose() async
  {
    await _stopWatchTimer.dispose();
    await _positionStream.pause();
    await _positionStream.cancel();
    super.dispose();
  }

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
            // DISPLAY STOP WATCH TIME
            Padding(
              padding: EdgeInsets.only(bottom: 0.0),
              child: StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: _stopWatchTimer.rawTime.value,
                builder: (context, snap) {
                  final value = snap.data;
                  displayTime = StopWatchTimer.getDisplayTime(value, hours: true);
                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          displayTime,
                          style: TextStyle(fontSize: 40, fontFamily: 'Helvetica', fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          value.toString(),
                          style: TextStyle(fontSize: 16, fontFamily: 'Helvetica', fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'CURRENT SPEED',
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      '$speedInMps',
                      style: TextStyle(fontSize:20.0),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      'TARGET SPEED',
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      data['difficulty'].toString(),
                      style: TextStyle(fontSize:20.0),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 50.0),
            // BUTTONS
            Padding(
              padding: EdgeInsets.all(2.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: RaisedButton(
                            padding: EdgeInsets.all(4),
                            color: Colors.lightBlue,
                            shape: StadiumBorder(),
                            child: Text(
                              'START',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: RaisedButton(
                            padding: EdgeInsets.all(4),
                            color: Colors.green,
                            shape: StadiumBorder(),
                            child: Text(
                              'STOP',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                              await Navigator.pushReplacementNamed(context, '/results', arguments: {
                                'totalTime': displayTime,
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}