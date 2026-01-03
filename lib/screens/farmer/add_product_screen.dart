import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../models/product_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/stock_images.dart';
import '../../utils/product_image_matcher.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _unitController = TextEditingController(text: 'kg');
  String _selectedCategory = AppConstants.categories[0];
  bool _isDailySubAvailable = false;
  File? _image;
  String? _selectedStockImage;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: _image == null && _selectedStockImage == null ? Colors.grey[200] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                          image: _selectedStockImage != null && _image == null 
                              ? DecorationImage(
                                  image: _selectedStockImage!.startsWith('http') 
                                      ? NetworkImage(_selectedStockImage!) 
                                      : AssetImage(_selectedStockImage!) as ImageProvider,
                                  fit: BoxFit.cover
                                ) 
                              : null,
                        ),
                        child: _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_image!, fit: BoxFit.cover),
                              )
                            : (_selectedStockImage != null 
                                ? null 
                                : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Tap to add Photo'),
                                ],
                              )),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _showStockImagePicker,
                      icon: const Icon(Icons.image_search),
                      label: const Text('Select from Stock Images'),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Product Name',
                      prefixIcon: Icons.shopping_bag_outlined,
                      validator: (v) => v!.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descController,
                      label: 'Description',
                      prefixIcon: Icons.description_outlined,
                      validator: (v) => v!.isEmpty ? 'Enter description' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _priceController,
                            label: 'Price (₹)',
                            prefixIcon: Icons.currency_rupee,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Enter price' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _unitController,
                            label: 'Unit (e.g. kg, liter)',
                            prefixIcon: Icons.scale_outlined,
                            validator: (v) => v!.isEmpty ? 'Enter unit' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _stockController,
                      label: 'Stock Quantity',
                      prefixIcon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Enter stock' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: AppConstants.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Available for Daily Subscription?'),
                      value: _isDailySubAvailable,
                      onChanged: (v) => setState(() => _isDailySubAvailable = v),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveProduct,
                      child: const Text('Save Product'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showStockImagePicker() {
    // Get smart suggestions based on product name and category
    final productName = _nameController.text.trim();
    final List<String> suggestedImages;
    
    if (productName.isNotEmpty) {
      suggestedImages = ProductImageMatcher.getSuggestedImages(productName, _selectedCategory);
    } else {
      suggestedImages = ProductImageMatcher.getImagesForCategory(_selectedCategory);
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 400,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      productName.isNotEmpty 
                          ? 'Suggested Images for "$productName"' 
                          : 'Select Image for $_selectedCategory',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (productName.isEmpty)
                      const Text(
                        'Tip: Enter product name first for smart suggestions!',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: suggestedImages.length,
                  itemBuilder: (context, index) {
                    final imagePath = suggestedImages[index];
                    final displayName = ProductImageMatcher.getImageDisplayName(imagePath);
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStockImage = imagePath;
                          _image = null; // Clear manual upload if stock selected
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedStockImage == imagePath 
                                ? AppConstants.primaryColor 
                                : Colors.grey.shade300,
                            width: _selectedStockImage == imagePath ? 3 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image, size: 40),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _selectedStockImage == imagePath 
                                    ? AppConstants.primaryColor.withOpacity(0.1)
                                    : Colors.grey.shade50,
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                              ),
                              child: Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _selectedStockImage == imagePath 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                  color: _selectedStockImage == imagePath 
                                      ? AppConstants.primaryColor 
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_image == null && _selectedStockImage == null) {
      bool proceed = await _showNoImageDialog();
      if (!proceed) return;
    }

    setState(() => _isLoading = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user!;
      List<String> images = [];

      if (_image != null) {
        try {
          String imageUrl = await StorageService().uploadProductImage(_image!, user.uid);
          images.add(imageUrl);
        } catch (e) {
          setState(() => _isLoading = false);
          bool proceed = await _showErrorImageDialog(e.toString());
          if (!proceed) return;
          setState(() => _isLoading = true);
        }
      } else if (_selectedStockImage != null) {
        images.add(_selectedStockImage!);
      }

      ProductModel product = ProductModel(
        id: '',
        farmerId: user.uid,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        unit: _unitController.text.trim(),
        stockQuantity: int.parse(_stockController.text.trim()),
        category: _selectedCategory,
        images: images,
        isDailySubscriptionAvailable: _isDailySubAvailable,
      );

      await DatabaseService().addProduct(product);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ... (rest of the file)

  Future<bool> _showNoImageDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Photo Selected'),
            content: const Text('Do you want to add this product without a photo?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add Without Photo')),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showErrorImageDialog(String error) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Upload Error'),
            content: Text('Image upload failed ($error). Do you want to add this product without a photo?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add Without Photo')),
            ],
          ),
        ) ??
        false;
  }
}
