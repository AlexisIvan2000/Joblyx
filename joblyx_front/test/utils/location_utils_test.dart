import 'package:flutter_test/flutter_test.dart';

// Abréviations des provinces canadiennes
class LocationUtils {
  static const Map<String, String> provinceAbbreviations = {
    'Alberta': 'AB',
    'British Columbia': 'BC',
    'Manitoba': 'MB',
    'New Brunswick': 'NB',
    'Newfoundland and Labrador': 'NL',
    'Northwest Territories': 'NT',
    'Nova Scotia': 'NS',
    'Nunavut': 'NU',
    'Ontario': 'ON',
    'Prince Edward Island': 'PE',
    'Quebec': 'QC',
    'Québec': 'QC',
    'Saskatchewan': 'SK',
    'Yukon': 'YT',
  };

  static String getProvinceAbbreviation(String province) {
    return provinceAbbreviations[province] ?? province;
  }

  static String formatLocation(String? city, String? province) {
    if (city == null && province == null) {
      return 'Location unknown';
    }
    if (city == null) {
      return getProvinceAbbreviation(province!);
    }
    if (province == null) {
      return city;
    }
    return '$city, ${getProvinceAbbreviation(province)}';
  }
}

void main() {
  group('LocationUtils.getProvinceAbbreviation', () {
    test('retourne AB pour Alberta', () {
      expect(LocationUtils.getProvinceAbbreviation('Alberta'), 'AB');
    });

    test('retourne BC pour British Columbia', () {
      expect(LocationUtils.getProvinceAbbreviation('British Columbia'), 'BC');
    });

    test('retourne ON pour Ontario', () {
      expect(LocationUtils.getProvinceAbbreviation('Ontario'), 'ON');
    });

    test('retourne QC pour Quebec', () {
      expect(LocationUtils.getProvinceAbbreviation('Quebec'), 'QC');
    });

    test('retourne QC pour Québec avec accent', () {
      expect(LocationUtils.getProvinceAbbreviation('Québec'), 'QC');
    });

    test('retourne MB pour Manitoba', () {
      expect(LocationUtils.getProvinceAbbreviation('Manitoba'), 'MB');
    });

    test('retourne SK pour Saskatchewan', () {
      expect(LocationUtils.getProvinceAbbreviation('Saskatchewan'), 'SK');
    });

    test('retourne la province inchangée si non trouvée', () {
      expect(LocationUtils.getProvinceAbbreviation('Unknown'), 'Unknown');
    });
  });

  group('LocationUtils.formatLocation', () {
    test('formate ville et province', () {
      expect(LocationUtils.formatLocation('Toronto', 'Ontario'), 'Toronto, ON');
    });

    test('formate ville et province avec accent', () {
      expect(LocationUtils.formatLocation('Montréal', 'Québec'), 'Montréal, QC');
    });

    test('retourne seulement la ville si province null', () {
      expect(LocationUtils.formatLocation('Vancouver', null), 'Vancouver');
    });

    test('retourne seulement la province si ville null', () {
      expect(LocationUtils.formatLocation(null, 'Alberta'), 'AB');
    });

    test('retourne message par défaut si tout est null', () {
      expect(LocationUtils.formatLocation(null, null), 'Location unknown');
    });

    test('formate Calgary, Alberta', () {
      expect(LocationUtils.formatLocation('Calgary', 'Alberta'), 'Calgary, AB');
    });

    test('formate Ottawa, Ontario', () {
      expect(LocationUtils.formatLocation('Ottawa', 'Ontario'), 'Ottawa, ON');
    });
  });

  group('Toutes les provinces', () {
    test('couvre toutes les provinces canadiennes', () {
      expect(LocationUtils.provinceAbbreviations.length, 14);
    });

    test('toutes les abréviations ont 2 caractères', () {
      for (final abbr in LocationUtils.provinceAbbreviations.values) {
        expect(abbr.length, 2);
      }
    });

    test('toutes les abréviations sont en majuscules', () {
      for (final abbr in LocationUtils.provinceAbbreviations.values) {
        expect(abbr, abbr.toUpperCase());
      }
    });
  });
}
