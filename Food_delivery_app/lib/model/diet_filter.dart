enum DietFilter {
  all,
  veg,
  nonVeg;

  static DietFilter fromStorage(String? value, {bool vegOnlyLegacy = false}) {
    return switch (value) {
      'veg' => DietFilter.veg,
      'nonVeg' => DietFilter.nonVeg,
      'all' => DietFilter.all,
      _ => vegOnlyLegacy ? DietFilter.veg : DietFilter.all,
    };
  }
}
