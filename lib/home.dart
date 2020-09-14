import 'package:flutter/material.dart';
import 'package:flutter_coolrunning/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget
{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver
{
  final List<String> programs = ['Interval', 'Increasing Speed',
                                 'Constant Speed', 'Random Speed'];

  String _currentProgram;
  int _currentDifficulty = 1;
  bool _toggleValue = false;
  bool _permissionGranted = false;

  void toggleButton()
  {
    setState(() {
      _toggleValue = !_toggleValue;
    });
  }

  void checkStatus() async
  {
    var permission = await Permission.location.status;

    if (permission == PermissionStatus.undetermined)
    {
      permission = await Permission.location.request();
      if (permission == PermissionStatus.denied)
      {
        _permissionGranted = false;
        await openAppSettings();
      }
      else
      {
        _permissionGranted = true;
      }
    }
    else
    {
      if (permission == PermissionStatus.granted)
      {
        _permissionGranted = true;
      }
      else
      {
        _permissionGranted = false;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state)
  {
    if (state == AppLifecycleState.resumed)
    {
      checkStatus();
    }
  }

  @override
  void initState()
  {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkStatus();
  }

  @override
  void dispose()
  {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: titleAppBar,
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Select Running Mode',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20.0),
            DropdownButtonFormField(
              decoration: textInputDecoration,
              value: _currentProgram = programs[0],
              items: programs.map((program) {
                return DropdownMenuItem(
                  value: program,
                  child: Text('$program'),
                );
              }).toList(),
              onChanged: (String val) {
                setState(() {
                  _currentProgram = val;
                });
              },
            ),
            SizedBox(height:50.0),
            Text(
              'Difficulty Level   $_currentDifficulty KM/H',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height:20.0),
            Slider(
              value: _currentDifficulty.toDouble(),
              min: 1.0,
              max: 12.0,
              divisions: 11,
              label: 'Starting Speed: $_currentDifficulty KM/H',
              onChanged: (double val) {
                setState(() {
                  _currentDifficulty = val.round();
                });
              },
            ),
            SizedBox(height: 50.0),
            Row(
              children: <Widget>[
                Text(
                  'Save     ',
                  style: TextStyle(fontSize: 20.0),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 0),
                  height: 40.0,
                  width: 100.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: _toggleValue ? Colors.greenAccent[100] : Colors.redAccent[100].withOpacity(0.5)
                  ),
                  child: Stack(
                    children: <Widget>[
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                        top: 3.0,
                        left: _toggleValue ? 60.0 : 0.0,
                        right: _toggleValue ? 0.0 : 60.0,
                        child: InkWell(
                          onTap: toggleButton,
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 0),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return RotationTransition(
                                  child: child, turns: animation
                              );
                            },
                            child: _toggleValue ? Icon(Icons.check_circle, color: Colors.green, size: 35.0, key: UniqueKey(),
                            ) : Icon(Icons.remove_circle_outline, color: Colors.red, size: 35.0, key: UniqueKey()
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              children: <Widget>[
                Text(
                  'Track Name:  ',
                  style: TextStyle(fontSize: 20.0),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: '',
                    enabled: _toggleValue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 100.0),
            Align(
              child: RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                padding: EdgeInsets.all(0.0),
                onPressed: () {
                  if (_permissionGranted)
                  {
                    Navigator.pushReplacementNamed(context, '/running', arguments: {
                      'program': _currentProgram,
                      'difficulty': _currentDifficulty,
                    });
                  }
                  else
                  {
                    Fluttertoast.showToast(
                      msg: 'Please enable location service',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red[200],
                      textColor: Colors.white,
                      fontSize: 15.0
                    );
                  }
                  //print('Button Works!');
                },
                child: Ink(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.cyan,
                        Colors.cyanAccent,
                        Colors.blueAccent,
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(80.0)),
                  ),
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'PREPARE RUNNING',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}