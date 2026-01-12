import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/subscription_model.dart';
import '../auth/login_screen.dart';
import '../../services/chat_service.dart';
import '../common/chat_detail_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../../providers/language_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final langProvider = Provider.of<LanguageProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Sleek SliverAppBar with Image
              SliverAppBar(
                expandedHeight: 450,
                pinned: true,
                stretch: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                leadingWidth: 70,
                leading: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black38 : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: isDark ? Colors.white : Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'product-${widget.product.id}',
                        child: _buildProductImage(),
                      ),
                      // Premium Gradient Overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Theme.of(context).scaffoldBackgroundColor,
                                Colors.transparent,
                                isDark ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.3),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Product Info Content
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -20, 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Price Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product.category.toUpperCase(),
                                    style: TextStyle(
                                      color: AppConstants.primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2.0,
                                    ),
                                  ).animate().fadeIn().slideX(begin: -0.2),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.product.name,
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -1,
                                    ),
                                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${widget.product.price.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: AppConstants.primaryColor,
                                  ),
                                ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut, duration: 800.ms),
                                  Text(
                                    'per ${widget.product.unit}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Section Hooks
                        _buildInfoSection(
                          title: langProvider.translate('description'),
                          content: widget.product.description,
                          icon: Icons.notes_rounded,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 24),

                        // Farmer Info (Mock / UI only for now)
                        _buildFarmerCard(),

                        const SizedBox(height: 24),

                        if (widget.product.isDailySubscriptionAvailable)
                          _buildSubscriptionCard(context, userProvider),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 3. Floating Glassmorphic Bottom Bar
          _buildFloatingActionBar(context, userProvider, cartProvider),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    if (widget.product.images.isEmpty) {
      return Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 80));
    }
    final img = widget.product.images[0];
    return img.startsWith('http')
        ? CachedNetworkImage(imageUrl: img, fit: BoxFit.cover)
        : Image.asset(img, fit: BoxFit.cover);
  }

  Widget _buildInfoSection({required String title, required String content, required IconData icon, required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 15, 
            color: isDark ? Colors.grey[400] : Colors.grey[600], 
            height: 1.6, 
            fontWeight: FontWeight.w400
          ),
        ),
      ],
    );
  }

  Widget _buildFarmerCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront_rounded, color: AppConstants.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Harvested by',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const Text(
                  'Local Organic Farmer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded, color: Colors.blue, size: 20),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, UserProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [Colors.blue[900]!.withOpacity(0.3), Theme.of(context).cardColor]
            : [Colors.blue[50]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.blue[800]!.withOpacity(0.5) : Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                langProvider.translate('daily_subscription'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Get fresh delivery every single morning at your doorstep.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _subscribe(context, userProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(langProvider.translate('subscribe_now')),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionBar(BuildContext context, UserProvider userProvider, CartProvider cartProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langProvider = Provider.of<LanguageProvider>(context);
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: isDark ? Colors.white12 : Colors.white.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                // Quantity Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey[100]!.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      _qtyBtn(Icons.remove, () => setState(() => _quantity > 1 ? _quantity-- : null), isDark),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      _qtyBtn(Icons.add, () => setState(() => _quantity++), isDark),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Chat Button
                _actionIcon(Icons.chat_bubble_outline_rounded, Colors.green, () async {
                  if (userProvider.user == null) {
                    _showLoginPrompt(context);
                    return;
                  }

                  final farmer = await AuthService().getUserData(widget.product.farmerId);
                  if (farmer != null) {
                    final chatService = ChatService();
                    final room = await chatService.getOrCreateRoom(
                      userProvider.user!.uid,
                      widget.product.farmerId,
                    );
                    
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            roomId: room.id,
                            otherUserName: farmer.name,
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(langProvider.translate('farmer_info_not_available'))),
                    );
                  }
                }),
                const SizedBox(width: 8),
                // Add to Cart
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.product.isAvailable && widget.product.stockQuantity > 0
                        ? () {
                            HapticFeedback.lightImpact();
                            if (userProvider.user == null) {
                              _showLoginPrompt(context);
                            } else {
                              for (int i = 0; i < _quantity; i++) {
                                cartProvider.addItem(widget.product);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Colors.white),
                                      const SizedBox(width: 12),
                                      Text('Added $_quantity ${widget.product.name} to cart'),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  backgroundColor: AppConstants.primaryColor,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: AppConstants.primaryColor.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      Provider.of<LanguageProvider>(context, listen: false).translate('add_to_cart'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .shimmer(delay: 3.seconds, duration: 1500.ms, color: Colors.white30),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return IconButton(
      icon: Icon(icon, size: 16, color: isDark ? Colors.white : Colors.black),
      onPressed: onTap,
      splashRadius: 20,
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  void _subscribe(BuildContext context, UserProvider userProvider) async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    if (userProvider.user == null) {
      _showLoginPrompt(context);
      return;
    }
    int dailyQty = 1;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(langProvider.translate('daily_subscription')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(langProvider.translate('how_many_per_day', {'unit': widget.product.unit})),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: () => setDialogState(() => dailyQty > 1 ? dailyQty-- : null), icon: const Icon(Icons.remove)),
                  Text('$dailyQty', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => setDialogState(() => dailyQty++), icon: const Icon(Icons.add)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(langProvider.translate('cancel'), style: const TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                SubscriptionModel sub = SubscriptionModel(
                  id: '',
                  buyerId: userProvider.user!.uid,
                  farmerId: widget.product.farmerId,
                  productId: widget.product.id,
                  productName: widget.product.name,
                  price: widget.product.price,
                  quantityPerDay: dailyQty,
                  status: 'Active',
                  startDate: DateTime.now(),
                );
                await DatabaseService().addSubscription(sub);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(langProvider.translate('subscription_active'))));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(langProvider.translate('confirm')),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginPrompt(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(langProvider.translate('join_farmigo')),
        content: Text(langProvider.translate('login_prompt')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(langProvider.translate('maybe_later'), style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(langProvider.translate('login')),
          ),
        ],
      ),
    );
  }
}
