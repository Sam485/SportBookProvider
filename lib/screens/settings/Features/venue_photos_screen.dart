import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';

class VenuePhotosScreen extends StatefulWidget {
  const VenuePhotosScreen({super.key});

  @override
  State<VenuePhotosScreen> createState() => _VenuePhotosScreenState();
}

class _VenuePhotosScreenState extends State<VenuePhotosScreen> {
  List<Category> categories = [
    Category(category: 'All'),
    Category(category: 'Badminton'),
    Category(category: 'Soccer'),
    Category(category: 'Tennis'),
  ];

  int selectedCategoryIndex = 0;
  List<PhotoItem> photos = [
    PhotoItem(
      title: 'Main entrance image',
      subtitle: 'Main entrance',
      isCover: true,
    ),
    PhotoItem(title: 'Court view', subtitle: 'Badminton court', isCover: false),
    // Add more photos as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.all(10),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text('Venue photos'),
        actions: [
          SizedBox(
            width: 100,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                // Handle upload
              },
              style: AppTheme.elevatedButtonStyle(),
              child: const Text('Upload'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(child: _buildCategory()),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(child: _buildAddPhotosContainer()),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(child: _buildShowPhotos()),
            SliverToBoxAdapter(child: _buildGuiding()),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (_, index) {
            final isSelected = selectedCategoryIndex == index;
            return GestureDetector(
              onTap: () => setState(() {
                selectedCategoryIndex = index;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.kCardAlt : AppTheme.kCard,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? AppTheme.kCardAlt : AppTheme.kBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      categories[index].category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddPhotosContainer() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          // Handle photo upload
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecorationAdaptive(context).copyWith(
            color: AppTheme.kCard.withOpacity(0.3),
            border: Border.all(color: AppTheme.kBorder, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate,
                color: AppTheme.kAccent,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text('Add more photos', style: AppTheme.tsLabelAdaptive(context)),
              const SizedBox(height: 4),
              Text(
                'Tap to upload from gallery or camera',
                style: AppTheme.tsSubAdaptive(context).copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShowPhotos() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${photos.length} photos uploaded',
                style: AppTheme.tsSubAdaptive(context).copyWith(fontSize: 14),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Handle edit order
                },
                child: Text('Edit order', style: AppTheme.tsAccent),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: photos.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildPhotoCard(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(int index) {
    final photo = photos[index];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder - replace with actual image widget
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.image, color: Colors.grey[600], size: 50),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: photo.isCover
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2.5,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.blue,
                            ),
                            child: const Text(
                              'Cover',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // Handle edit
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          color: Colors.amber,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.5),
                            padding: const EdgeInsets.all(6),
                            minimumSize: const Size(30, 30),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              photos.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.delete, size: 18),
                          color: Colors.red,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.5),
                            padding: const EdgeInsets.all(6),
                            minimumSize: const Size(30, 30),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  photo.subtitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuiding() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: AppTheme.cardDecorationAdaptive(context),
        child: Text(
          'High quality photos help attract more outcomes. Use bright, well-lit shots of your courts and facilites. The cover photo appears first in search results.',
          style: AppTheme.tsSubAdaptive(context),
        ),
      ),
    );
  }
}

class Category {
  final String category;
  Category({required this.category});
}

class PhotoItem {
  final String title;
  final String subtitle;
  final bool isCover;

  PhotoItem({
    required this.title,
    required this.subtitle,
    this.isCover = false,
  });
}
