import 'dart:math';

class QiblaUtils {
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLon = 39.8262;

  static double calculateQiblaDirection(double lat, double lon) {
    final latR = lat * pi / 180;
    final lonR = lon * pi / 180;
    final kaabaLatR = _kaabaLat * pi / 180;
    final kaabaLonR = _kaabaLon * pi / 180;

    final direction = atan2(
      sin(kaabaLonR - lonR),
      cos(latR) * tan(kaabaLatR) - sin(latR) * cos(kaabaLonR - lonR),
    );

    double degrees = direction * 180 / pi;
    return (degrees + 360) % 360;
  }
}
