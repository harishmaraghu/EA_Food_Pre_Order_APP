class RoleLimits {
  static const Map<String, Map<String, int>> _limits = {
    'Customer': {
      'Milk': 5,
      'Bread': 3,
      'Rice': 10,
      'Oil': 2,
    },
    'TSU': {
      'Milk': 20,
      'Bread': 15,
      'Rice': 50,
      'Oil': 10,
    },
    'SR': {
      'Milk': 50,
      'Bread': 30,
      'Rice': 100,
      'Oil': 25,
    },
  };

  static int getMaxQuantity(String userType, String productName) {
    return _limits[userType]?[productName] ?? 1;
  }

  static String getRoleDescription(String userType) {
    switch (userType) {
      case 'Customer':
        return 'Individual consumer with basic quantity limits';
      case 'TSU':
        return 'Trade Support Unit with moderate quantity limits';
      case 'SR':
        return 'Sales Representative with high quantity limits';
      default:
        return 'Standard user';
    }
  }

  static List<String> getTypicalQuantities(String userType) {
    switch (userType) {
      case 'Customer':
        return ['1-5 L Milk', '1-3 Bread', '1-10 kg Rice', '1-2 L Oil'];
      case 'TSU':
        return ['5-20 L Milk', '5-15 Bread', '10-50 kg Rice', '2-10 L Oil'];
      case 'SR':
        return ['20-50 L Milk', '15-30 Bread', '50-100 kg Rice', '10-25 L Oil'];
      default:
        return [];
    }
  }
}