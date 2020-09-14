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
  double speedScore = 0.0;
  double speedError = 0.0;
  double toleranceThreshold = 1.0;
  double totalComparisons = 0.0;
  double badComparisons = 0.0;
  RunningType runType;
  ErrorType errorType;

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

  static List<double> getStartCoord()
  {
    var startCoords = [_originLatitude, _originLongitude];

    return startCoords;
  }

  static List<double> getDestCoord()
  {
    var destCoords = [_destLatitude, _destLongitude];

    return destCoords;
  }

  static void setStartLatLng(double originLatitude, double originLongitude)
  {
    _originLatitude = originLatitude;
    _originLongitude = originLongitude;
  }

  static void setDestLatLng(double destLatitude, double destLongitude)
  {
    _destLatitude = destLatitude;
    _destLongitude = destLongitude;
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