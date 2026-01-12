import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/product_card.dart';
import '../../services/database_service.dart';
import '../../models/banner_model.dart';
import 'cart_screen.dart';
import 'product_search_delegate.dart';
import '../common/chat_rooms_screen.dart';
import 'farms_map_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/language_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auction_provider.dart';
import '../../models/product_model.dart';
import 'bidding_arena_screen.dart';

class BuyerHomeTab extends StatefulWidget {
  const BuyerHomeTab({super.key});

  @override
  State<BuyerHomeTab> createState() => _BuyerHomeTabState();
}

class _BuyerHomeTabState extends State<BuyerHomeTab> {
  String _selectedCategory = 'All';
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
        Provider.of<ProductProvider>(context, listen: false).fetchProducts();
        Provider.of<AuctionProvider>(context, listen: false).fetchActiveAuctions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final user = userProvider.user;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? langProvider.translate('good_morning') : (hour < 17 ? langProvider.translate('good_afternoon') : langProvider.translate('good_evening'));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          // Subtle Ambient Background
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppConstants.primaryColor.withOpacity(0.04),
              ),
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Premium Minimalist Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.name.split(' ')[0] ?? langProvider.translate('friend'),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmsMapScreen())),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.map_outlined, color: AppConstants.primaryColor, size: 22),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatRoomsScreen())),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.chat_bubble_outline_rounded, color: AppConstants.primaryColor, size: 22),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                                child: Text(
                                  user?.name != null && user!.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    color: AppConstants.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Linear Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: GestureDetector(
                      onTap: () => showSearch(context: context, delegate: ProductSearchDelegate()),
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: Colors.grey[400], size: 24),
                            const SizedBox(width: 12),
                            Text(
                              langProvider.translate('search_fresh_harvest'),
                              style: TextStyle(color: Colors.grey[400], fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.tune_rounded, color: AppConstants.primaryColor, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Hero Carousel (Premium Visuals)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 200,
                            viewportFraction: 0.9,
                            enlargeCenterPage: true,
                            autoPlay: true,
                            onPageChanged: (index, reason) {
                              setState(() => _currentBannerIndex = index);
                            },
                          ),
                          items: [
                            {'image': 'assets/banners/image.png', 'title': langProvider.translate('fresh_from_organic_farms')},
                            {'image': 'assets/banners/image copy.png', 'title': langProvider.translate('direct_harvest_to_your_door')},
                            {'image': 'assets/banners/Untitled design.png', 'title': langProvider.translate('support_local_farmers_today')},
                          ].map((item) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                image: DecorationImage(
                                  image: AssetImage(item['image']!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppConstants.primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        langProvider.translate('featured').toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      item['title']!,
                                      style: const TextStyle(
                                        color: Colors.white, 
                                        fontSize: 22, 
                                        fontWeight: FontWeight.bold, 
                                        height: 1.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black45,
                                            offset: Offset(0, 2),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [0, 1, 2].map((i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _currentBannerIndex == i ? 24 : 8,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppConstants.primaryColor.withOpacity(
                                  _currentBannerIndex == i ? 1.0 : 0.2,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Live Bidding Section
                SliverToBoxAdapter(
                  child: Consumer<AuctionProvider>(
                    builder: (context, provider, child) {
                      if (provider.activeAuctions.isEmpty) return const SizedBox();
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                            child: Row(
                              children: [
                                const Text(
                                  'Live Bidding',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 500.ms).fadeOut(delay: 500.ms),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: provider.activeAuctions.length,
                              itemBuilder: (context, index) {
                                final auction = provider.activeAuctions[index];
                                return GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BiddingArenaScreen(auctionId: auction.id))),
                                  child: Container(
                                    width: 280,
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: FutureBuilder<ProductModel?>(
                                      future: DatabaseService().getProductById(auction.productId),
                                      builder: (context, prodSnap) {
                                        final product = prodSnap.data;
                                        return Stack(
                                          children: [
                                            if (product != null && product.images.isNotEmpty)
                                              Positioned.fill(
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(24),
                                                  child: Image.network(product.images[0], fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.3)),
                                                ),
                                              ),
                                            Positioned(
                                              right: -20,
                                              bottom: -20,
                                              child: Icon(Icons.gavel_rounded, size: 100, color: Colors.white.withOpacity(0.05)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                                        child: Text(auction.timeLeft, style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                                      ),
                                                      const Icon(Icons.trending_up, color: AppConstants.primaryColor, size: 20),
                                                    ],
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    product?.name ?? 'Auction ID: ...${auction.id.substring(auction.id.length - 6)}',
                                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    auction.purpose,
                                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        '\u{20B9}${auction.currentHighestBid.toStringAsFixed(0)}',
                                                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 4),
                                                        child: Text('Current Bid', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),
                ),

                // 4. Circular Category Menu
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Text(
                      langProvider.translate('categories'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // _sectionHeader('Marketplace'), // Replaced by the above Text widget
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 115,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: AppConstants.categories.length + 1,
                          itemBuilder: (context, index) {
                            String category = index == 0 ? 'All' : AppConstants.categories[index - 1];
                            return _categoryItem(category);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),

                // 5. Products Grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                    child: Text(
                      langProvider.translate('fresh_picks'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                  sliver: productProvider.isLoading
                    ? SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 20,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildShimmerCard(),
                          childCount: 4,
                        ),
                      )
                    : productProvider.products.isEmpty
                      ? SliverToBoxAdapter(child: Center(child: Text(langProvider.translate('no_products_found_in_category'))))
                      : SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 20,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return ProductCard(product: productProvider.products[index])
                                  .animate(delay: (index * 100).ms)
                                  .fadeIn()
                                  .slideY(begin: 0.1);
                            },
                            childCount: productProvider.products.length,
                          ),
                        ),
                ),
                
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Center(
                      child: Text(
                        AppConstants.developedBy,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
        },
        backgroundColor: AppConstants.primaryColor,
        elevation: 12,
        highlightElevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        label: const Text('Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        icon: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'See all',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryItem(String category) {
    bool isSelected = _selectedCategory == category;
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = category);
        productProvider.fetchProducts(category: category);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 24),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: isSelected ? AppConstants.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                      ? AppConstants.primaryColor.withOpacity(0.25) 
                      : Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey[100]!,
                  width: 1,
                ),
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppConstants.primaryColor : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables': return Icons.eco_rounded;
      case 'fruits': return Icons.apple_rounded;
      case 'dairy': return Icons.water_drop_rounded;
      case 'grains': return Icons.grass_rounded;
      default: return Icons.grid_view_rounded;
    }
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}
