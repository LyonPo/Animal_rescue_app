import 'package:geolocator/geolocator.dart';

class LocationService {

  Future<Position?> getCurrentLocation() async {

    bool serviceEnabled;
    LocationPermission permission;

    // GPS activado
    serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return null;
    }

    // Permisos
    permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {

      permission =
          await Geolocator.requestPermission();

      if (permission ==
          LocationPermission.denied) {

        return null;
      }
    }

    if (permission ==
        LocationPermission.deniedForever) {

      return null;
    }

    return await Geolocator.getCurrentPosition();
  }
}