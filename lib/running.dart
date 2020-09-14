import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_coolrunning/constants.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audio_cache.dart';
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
  AudioPlayer player = AudioPlayer();
  AudioCache cache;
  /// Timer timer;
  SpeedMonitor speedMonitor = SpeedMonitor(runType: RunningType.start, errorType: ErrorType.correct);
  final Stream<Position> _positionStream = GeolocatorPlatform.instance.getPositionStream();
  final String _slowDownSound = 'slow_down.mp3';
  final String _speedUpSound = 'speed_up.mp3';
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  void checkMonitor()
  {
    print('Current running type: ' + speedMonitor.getRunType().toString());
    speedMonitor.compareSpeed(currentSpeed, targetSpeed);
    print('Current error type: ' + speedMonitor.getErrorType().toString());
    if (speedMonitor.getErrorType() == ErrorType.tooSlow)
    {
      //timer = Timer.periodic(const Duration(seconds: 3), (_) => cache.play(speedUpSound));
      cache.play(_speedUpSound);
    }
    else if (speedMonitor.getErrorType() == ErrorType.tooFast)
    {
      //timer = Timer.periodic(const Duration(seconds: 3), (_) => cache.play(slowDownSound));
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
                    /// DISPLAY CURRENT SPEED FROM STREAM
                    Padding(
                      padding: EdgeInsets.only(bottom: 0.0),
                      child: StreamBuilder<Position>(
                        stream: _positionStream,
                        initialData: _position,
                        builder: (context, snapshot) {
                          if (snapshot.hasData)
                          {
                            _position = snapshot.data;
                            currentSpeed = _position.speed * 3.6;
                            if (speedMonitor.getRunType() == RunningType.running)
                            {
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
                              speedMonitor.setRunType(RunningType.running);
                              print('State after start is pressed ' + speedMonitor.getRunType().toString());
                              SpeedMonitor.setStartLatLng(_position?.latitude, _position?.longitude);
                              print('Starting coordinate: ${SpeedMonitor.getStartCoord()}');
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
                              speedMonitor.setRunType(RunningType.finished);
                              print('State after stop is pressed ' + speedMonitor.getRunType().toString());
                              SpeedMonitor.setDestLatLng(_position?.latitude, _position?.longitude);
                              await Navigator.pushReplacementNamed(context, '/results', arguments: {
                                'totalTime': displayTime,
                                'speedScore': speedMonitor.getScore().roundToDouble(),
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