class StockImages {
  static const Map<String, List<String>> categoryImages = {
    'Vegetables': [
      'assets/stock/vegetables.jpg',
    ],
    'Fruits': [
      'assets/stock/fruits.jpg',
    ],
    'Dairy': [
      'assets/stock/dairy.jpg',
    ],
    'Grains': [
      'assets/stock/grains.jpg',
    ],
    'Other': [
      'assets/stock/vegetables.jpg', // Default fallback
    ]
  };

  // Helper to get all flat list if needed, or by specific category
  static List<String> getImages(String category) {
    return categoryImages[category] ?? categoryImages['Other']!;
  }
}
