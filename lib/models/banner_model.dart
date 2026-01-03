class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final bool isActive;
  final String? link;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.isActive = true,
    this.link,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_url': imageUrl,  // Use snake_case for database
      'title': title,
      'subtitle': subtitle,
      'is_active': isActive,  // Use snake_case for database
      'link': link,
    };
  }

  factory BannerModel.fromMap(Map<String, dynamic> map, String docId) {
    return BannerModel(
      id: docId,
      imageUrl: map['image_url'] ?? '',  // Read from snake_case
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      isActive: map['is_active'] ?? true,  // Read from snake_case
      link: map['link'],
    );
  }
}
