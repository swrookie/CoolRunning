import 'package:google_maps_flutter/google_maps_flutter.dart';

enum ErrorType
{
  tooSlow,
  correct,
  tooFast,
}

enum RunningType
{
  start,
  running,
  finished,
}

class SpeedMonitor
{
  SpeedMonitor({RunningType runType, ErrorType errorType})
  {
    this.runType = runType;
    this.errorType = errorType;
  }

  static double _originLatitude, _originLongitude;
  static double _destLatitude, _destLongitude;
  static List<LatLng> coordinates = [];
  double speedScore = 0.0;
  double speedError = 0.0;
  double toleranceThreshold = 1.0;
  double totalComparisons = 0.0;
  double badComparisons = 0.0;
  RunningType runType;
  ErrorType errorType;

  static void addCoordinates(double latitude, double longitude)
  {
    coordinates.add(LatLng(latitude, longitude));
  }

  static List<LatLng> getCoordinates()
  {
    return coordinates;
  }

  double getScore()
  {
    if (totalComparisons > 0)
    {
      speedScore = 100.0 * ((totalComparisons - badComparisons) / totalComparisons);
    }
    else
    {
      speedScore = 0.0;
    }

    return speedScore;
  }

  ErrorType getErrorType()
  {
    return errorType;
  }

  void setErrorType(ErrorType errorType)
  {
    this.errorType = errorType;
  }

  RunningType getRunType()
  {
    return runType;
  }

  void setRunType(RunningType runType)
  {
    this.runType = runType;
  }

  void compareSpeed(double currentSpeed, double targetSpeed) async
  {
    totalComparisons++;
    speedError = currentSpeed - targetSpeed;

    if (speedError <= -toleranceThreshold)
    {
      errorType = ErrorType.tooSlow;
      badComparisons++;
    }
    else if (speedError >= toleranceThreshold)
    {
      errorType = ErrorType.tooFast;
      badComparisons++;
    }
    else
    {
      errorType = ErrorType.correct;
    }
  }
}