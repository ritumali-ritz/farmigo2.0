import 'package:supabase_flutter/supabase_flutter.dart';

class BannerSeeder {
  static Future<void> seedBanners() async {
    final supabase = Supabase.instance.client;

    // Check if banners already exist
    final data = await supabase.from('banners').select().limit(1);
    
    if (data.isNotEmpty) {
      print('Banners already exist. Skipping seed.');
      return;
    }

    final List<Map<String, dynamic>> dummyBanners = [
      {
        'image_url': 'https://placehold.co/600x300/green/white?text=Fresh+Vegetables',
        'title': 'Fresh Vegetables',
        'subtitle': 'Get 20% off on all leafy greens',
        'is_active': true,
      },
      {
        'image_url': 'https://placehold.co/600x300/orange/white?text=Summer+Fruits',
        'title': 'Summer Fruits',
        'subtitle': 'Sweetest mangoes directly from farms',
        'is_active': true,
      },
      {
        'image_url': 'https://placehold.co/600x300/red/white?text=Organic+Spices',
        'title': 'Organic Spices',
        'subtitle': 'Authentic flavors for your kitchen',
        'is_active': true,
      },
      {
        'image_url': 'https://placehold.co/600x300/blue/white?text=Dairy+Delights',
        'title': 'Dairy Delights',
        'subtitle': 'Pure cow milk and ghee available',
        'is_active': true,
      },
      {
        'image_url': 'https://placehold.co/600x300/purple/white?text=Flash+Sale',
        'title': 'Flash Sale',
        'subtitle': 'Hurry! Limited stock on staples',
        'is_active': true,
      },
    ];

    await supabase.from('banners').insert(dummyBanners);
    print('Banners seeded successfully!');
  }
}
