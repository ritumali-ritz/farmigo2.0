class ProductImageMatcher {
  // Smart keyword-based image matching
  static final Map<String, List<String>> _imageKeywords = {
    // Vegetables (14)
    'assets/products/veges/fresh-background-potatoes-close-nutrition.jpg': ['potato', 'potatoes', 'aloo'],
    'assets/products/veges/top-view-potatoes-spilling-out-sack-wooden-surface-with-copy-space.jpg': ['potato', 'potatoes', 'aloo'],
    'assets/products/veges/fresh-red-tomatoes.jpg': ['tomato', 'tomatoes', 'tamatar'],
    'assets/products/veges/close-up-view-basket-onions-sackloth-white-background.jpg': ['onion', 'onions', 'pyaz'],
    'assets/products/veges/bell-pepper.jpg': ['bell pepper', 'capsicum', 'shimla mirch'],
    'assets/products/veges/red-pepper.jpg': ['pepper', 'red pepper', 'capsicum'],
    'assets/products/veges/close-up-green-chili-pepper-photo-high-quality-photo.jpg': ['chili', 'chilli', 'green chili', 'mirch'],
    'assets/products/veges/stack-carrots-tray-marble-surface.jpg': ['carrot', 'carrots', 'gajar'],
    'assets/products/veges/fresh-broccoli-wooden-box-black-surface-green-vegetables.jpg': ['broccoli'],
    'assets/products/veges/front-view-fresh-cauliflower-with-greens-grey-desk.jpg': ['cauliflower', 'gobi', 'phool gobi'],
    'assets/products/veges/washed-spinach-leaves-bowl-wooden-table.jpg': ['spinach', 'palak'],
    'assets/products/veges/peas-white-bowl-white-grungy-wooden-wall-side-view.jpg': ['peas', 'green peas', 'matar'],
    'assets/products/veges/coriander-isolated.jpg': ['coriander', 'cilantro', 'dhania'],
    'assets/products/veges/bunches-garlic-bowl-dark-wooden-table.jpg': ['garlic', 'lehsun'],
    
    // Fruits (11)
    'assets/products/fruits/bananas.jpg': ['banana', 'bananas', 'kela'],
    'assets/products/fruits/green-banana.jpg': ['banana', 'green banana', 'raw banana', 'kela'],
    'assets/products/fruits/closeup-shot-oranges-top-each-other-white-surface-great-background.jpg': ['orange', 'oranges', 'santra'],
    'assets/products/fruits/fresh-strawberries-bowl.jpg': ['strawberry', 'strawberries'],
    'assets/products/fruits/front-view-fresh-green-grapes-sour-juicy-mellow-wooden-desk-dark-background-fruit-ripe-plant-green.jpg': ['grape', 'grapes', 'angoor'],
    'assets/products/fruits/pngjuicy-pomegranate-isolated-white-background.jpg': ['pomegranate', 'anar'],
    'assets/products/fruits/mango-still-life.jpg': ['mango', 'mangoes', 'aam'],
    'assets/products/fruits/fresh-green-mango-dark-surface.jpg': ['mango', 'green mango', 'raw mango', 'kairi'],
    'assets/products/fruits/fresh-papaya-cut-into-half-put-dark-floor.jpg': ['papaya', 'papita'],
    'assets/products/fruits/guava-fruits-wooden-table.jpg': ['guava', 'amrood'],
    'assets/products/fruits/brown-coco-fresh-ripe-sliced-nut.jpg': ['coconut', 'nariyal'],
    
    // Dairy (4)
    'assets/products/dairy/milk.jpg': ['milk', 'doodh'],
    'assets/products/dairy/avocado-avocado-yogurt-products-made-from-avocado-food-nutrition-concept.jpg': ['yogurt', 'curd', 'dahi'],
    'assets/products/dairy/ayran-drink-with-mint-cucumber-glass.jpg': ['buttermilk', 'chaas', 'lassi'],
    'assets/products/dairy/nutritious-baby-food-jar.jpg': ['cream', 'dairy product'],
    
    // Other (2)
    'assets/products/other/—Pngtree—organic raw jaggery sweet natural_23138562.png': ['jaggery', 'gur', 'gud'],
    'assets/products/other/—Pngtree—tempting nut almond_5544074.png': ['almond', 'almonds', 'badam', 'nuts'],
  };

  /// Get all images for a specific category
  static List<String> getImagesForCategory(String category) {
    final lowerCategory = category.toLowerCase();
    
    if (lowerCategory.contains('vegetable') || lowerCategory.contains('veges')) {
      return _imageKeywords.keys
          .where((path) => path.contains('/veges/'))
          .toList();
    } else if (lowerCategory.contains('fruit')) {
      return _imageKeywords.keys
          .where((path) => path.contains('/fruits/'))
          .toList();
    } else if (lowerCategory.contains('dairy')) {
      return _imageKeywords.keys
          .where((path) => path.contains('/dairy/'))
          .toList();
    } else if (lowerCategory.contains('other')) {
      return _imageKeywords.keys
          .where((path) => path.contains('/other/'))
          .toList();
    }
    
    // Return all images if category not matched
    return _imageKeywords.keys.toList();
  }

  /// Smart matching: Find best image match for a product name
  static String? findBestMatch(String productName, String category) {
    final lowerName = productName.toLowerCase();
    final categoryImages = getImagesForCategory(category);
    
    // First, try exact keyword match
    for (var imagePath in categoryImages) {
      final keywords = _imageKeywords[imagePath] ?? [];
      for (var keyword in keywords) {
        if (lowerName.contains(keyword.toLowerCase())) {
          return imagePath;
        }
      }
    }
    
    // If no match found, return first image from category
    return categoryImages.isNotEmpty ? categoryImages.first : null;
  }

  /// Get suggested images for a product (returns top 3 matches)
  static List<String> getSuggestedImages(String productName, String category) {
    final lowerName = productName.toLowerCase();
    final categoryImages = getImagesForCategory(category);
    final Map<String, int> scoreMap = {};
    
    // Score each image based on keyword matches
    for (var imagePath in categoryImages) {
      final keywords = _imageKeywords[imagePath] ?? [];
      int score = 0;
      
      for (var keyword in keywords) {
        if (lowerName.contains(keyword.toLowerCase())) {
          score += 10; // Exact match gets high score
        } else if (keyword.toLowerCase().contains(lowerName) || 
                   lowerName.contains(keyword.toLowerCase().substring(0, keyword.length > 3 ? 3 : keyword.length))) {
          score += 3; // Partial match gets lower score
        }
      }
      
      if (score > 0 || categoryImages.length <= 3) {
        scoreMap[imagePath] = score;
      }
    }
    
    // Sort by score and return top 3
    final sortedImages = scoreMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final result = sortedImages.take(3).map((e) => e.key).toList();
    
    // If less than 3, fill with remaining category images
    if (result.length < 3) {
      for (var img in categoryImages) {
        if (!result.contains(img) && result.length < 3) {
          result.add(img);
        }
      }
    }
    
    return result;
  }

  /// Get display name from image path
  static String getImageDisplayName(String imagePath) {
    final fileName = imagePath.split('/').last
        .replaceAll('.jpg', '')
        .replaceAll('.png', '')
        .replaceAll('-', ' ')
        .replaceAll('—Pngtree—', '');
    final keywords = _imageKeywords[imagePath] ?? [];
    
    if (keywords.isNotEmpty) {
      return keywords.first.split(' ').map((word) => 
        word[0].toUpperCase() + word.substring(1)
      ).join(' ');
    }
    
    return fileName.split(' ').take(2).map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }
}
