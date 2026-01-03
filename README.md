# 🚜 Farmigo 2.0

Farmigo 2.0 is a premium Flutter application and the next-generation evolution of **Farmer Mall**. While the original version focused on local hosting, Farmigo 2.0 leverages **Supabase Cloud Storage and Database** to provide a global, real-time marketplace experience, bridging the gap between farmers and buyers with enhanced scalability and reliability.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)

## ✨ Key Features

### 👨‍🌾 For Farmers
- **Product Management:** Easily list products with images, descriptions, and pricing.
- **Order Tracking:** Monitor incoming orders and manage deliveries.
- **Profile Customization:** Build trust with a detailed farmer profile.

### 🛒 For Buyers
- **Intuitive Marketplace:** Browse fresh produce with high-quality images.
- **Smart Search:** Find specifically what you need with an advanced search delegate.
- **Secure Cart:** Add products to cart and manage purchases seamlessly.
- **Direct Communication:** Integrated WhatsApp support for direct contact with sellers.

## 🚀 Tech Stack

- **Framework:** Flutter (Android & iOS)
- **Backend:** Supabase (Auth, Database, Storage)
- **State Management:** Provider
- **UI Components:** 
  - `google_fonts` for premium typography.
  - `carousel_slider` for dynamic banners.
  - `cached_network_image` for optimized loading.
  - `flutter_spinkit` for elegant loading states.

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- A Supabase account and project

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ritumali-ritz/farmigo2.0.git
   cd farmigo
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase:**
   Update the `Supabase.initialize` call in `lib/main.dart` with your project credentials:
   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_ANON_KEY',
   );
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

*Made with ❤️ by [Ritesh](https://github.com/ritumali-ritz)*