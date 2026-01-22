import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:joblyx_front/providers/shared_preferences_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

const _locationKey = 'user_location';

final locationProvider =
    NotifierProvider<LocationNotifier, String?>(LocationNotifier.new);

class LocationNotifier extends Notifier<String?> {
  bool _hasRefreshed = false;

  @override
  String? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final cached = prefs.getString(_locationKey);

    // Refresh en arrière-plan une seule fois par session
    if (!_hasRefreshed) {
      _hasRefreshed = true;
      Future.microtask(() => _refreshLocationIfNeeded());
    }

    return cached;
  }

  /// Met à jour la localisation manuellement
  Future<void> setLocation(String? location) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (location == null) {
      state = null;
      await prefs.remove(_locationKey);
    } else {
      state = location;
      await prefs.setString(_locationKey, location);
    }
  }

  /// Récupère la localisation GPS et la sauvegarde
  Future<void> fetchCurrentLocation() async {
    final newLocation = await _fetchFromGPS();
    if (newLocation != null) {
      await setLocation(newLocation);
    }
  }

  /// Refresh si la localisation a changé
  Future<void> _refreshLocationIfNeeded() async {
    try {
      final newLocation = await _fetchFromGPS();
      if (newLocation != null && newLocation != state) {
        await setLocation(newLocation);
      }
    } catch (_) {
      // GPS indisponible, on garde le cache
    }
  }

  /// Fetch la localisation depuis le GPS
  Future<String?> _fetchFromGPS() async {
    // Vérifier si le service de localisation est activé
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Vérifier les permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Obtenir la position GPS
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low, // Suffisant pour ville
      ),
    );

    // Convertir en adresse (reverse geocoding)
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      final city = place.locality ?? place.subAdministrativeArea;
      final province = place.administrativeArea;

      if (city != null && province != null) {
        final provinceAbbr = _getProvinceAbbreviation(province);
        return '$city, $provinceAbbr';
      } else if (city != null) {
        return city;
      }
    }

    return null;
  }

  /// Convertit le nom complet de la province en abréviation
  String _getProvinceAbbreviation(String province) {
    const abbreviations = {
      // Canada
      'Alberta': 'AB',
      'British Columbia': 'BC',
      'Manitoba': 'MB',
      'New Brunswick': 'NB',
      'Newfoundland and Labrador': 'NL',
      'Nova Scotia': 'NS',
      'Ontario': 'ON',
      'Prince Edward Island': 'PE',
      'Quebec': 'QC',
      'Québec': 'QC',
      'Saskatchewan': 'SK',
      'Northwest Territories': 'NT',
      'Nunavut': 'NU',
      'Yukon': 'YT',
    };

    return abbreviations[province] ?? province;
  }
}
