import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_coolrunning/constants.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_coolrunning/speed_monitor.dart';

class Running extends StatefulWidget
{
  @override
  _RunningState createState() => _RunningState();
}

class _RunningState extends State<Running>
{
  /// Instances
  Map data = {};
  String displayTime;
  Position _position;
  double currentSpeed = 0.0;
  double targetSpeed = 0.0;
  bool startEnabled = false;
  AudioPlayer player = AudioPlayer();
  AudioCache cache;
  SpeedMonitor speedMonitor = SpeedMonitor(runType: RunningType.start, errorType: ErrorType.correct);
  final Stream<Position> _positionStream = GeolocatorPlatform.instance.getPositionStream(
    desiredAccuracy: LocationAccuracy.bestForNavigation,
  );
  final String _slowDownSound = 'slow_down.mp3';
  final String _speedUpSound = 'speed_up.mp3';
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  void startRunning()
  {
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    speedMonitor.setRunType(RunningType.running);
    print('State after start is pressed ' + speedMonitor.getRunType().toString());
  }

  void stopRunning() async
  {
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    speedMonitor.setRunType(RunningType.finished);
    print('State after stop is pressed ' + speedMonitor.getRunType().toString());
    await Navigator.pushReplacementNamed(context, '/results', arguments: {
      'totalTime': displayTime,
      'speedScore': speedMonitor.getScore().roundToDouble(),
    });
  }

  void checkMonitor()
  {
    SpeedMonitor.addCoordinates(_position.latitude, _position.longitude);
    print('Current running type: ' + speedMonitor.getRunType().toString());
    speedMonitor.compareSpeed(currentSpeed, targetSpeed);
    print('Current error type: ' + speedMonitor.getErrorType().toString());
    if (speedMonitor.getErrorType() == ErrorType.tooSlow)
    {
      //Timer.periodic(const Duration(seconds: 3), (_) => cache.play(speedUpSound));
      cache.play(_speedUpSound);
    }
    else if (speedMonitor.getErrorType() == ErrorType.tooFast)
    {
      //Timer.periodic(const Duration(seconds: 3), (_) => cache.play(slowDownSound));
      cache.play(_slowDownSound);
    }
    else
    {
      player?.stop();
    }
  }

  @override
  void initState()
  {
    super.initState();
  }

  @override
  void dispose()
  {
    _stopWatchTimer?.dispose();
    player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    data = ModalRoute.of(context).settings.arguments;
    targetSpeed = data['difficulty'].roundToDouble();
    cache = AudioCache(fixedPlayer: player);
    cache.loadAll([_speedUpSound, _slowDownSound]);

    return Scaffold(
      appBar: titleAppBar,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            /// DISPLAY STOP WATCH TIME
            Padding(
              padding: EdgeInsets.only(bottom: 0.0),
              child: StreamBuilder<int> (
                stream: _stopWatchTimer.rawTime,
                initialData: _stopWatchTimer.rawTime.value,
                builder: (context, snapshot) {
                  final value = snapshot.data;
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
                  children: <Widget>[
                    Text(
                      'CURRENT SPEED',
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20.0),
                    /// DISPLAY CURRENT SPEED FROM GEOLOCATOR STREAM
                    Padding(
                      padding: EdgeInsets.only(bottom: 0.0),
                      child: StreamBuilder<Position>(
                        stream: _positionStream,
                        initialData: _position,
                        builder: (context, snapshot) {
                          print(snapshot);
                          if (snapshot.hasData)
                          {
                            _position = snapshot.data;
                            if (startEnabled == false)
                            {
                              startEnabled = !startEnabled;
                            }
                            if (speedMonitor.getRunType() == RunningType.running)
                            {
                              currentSpeed = _position.speed * 3.6;
                              checkMonitor();
                            }
                          }
                          return Column(
                            children: <Widget>[
                              Text(
                                currentSpeed.toStringAsFixed(1) + ' KM/H',
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ],
                          );
                        },
                      ),
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
                      targetSpeed.toString() + 'KM/H',
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
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: RaisedButton(
                            padding: EdgeInsets.all(4.0),
                            color: Colors.greenAccent,
                            shape: StadiumBorder(),
                            child: Text(
                              'START',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              startEnabled ? startRunning() : Fluttertoast.showToast(
                                  msg: 'PLEASE WAIT',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.redAccent,
                                  textColor: Colors.white,
                                  fontSize: 15.0);
                            }
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: RaisedButton(
                            padding: EdgeInsets.all(4),
                            color: Colors.redAccent,
                            shape: StadiumBorder(),
                            child: Text(
                              'STOP',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              stopRunning();
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