import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/core/util/image_utils.dart';
import 'package:flutter_application_1/features/Category/model/category_model.dart';
import 'package:flutter_application_1/features/Category/service/category_service.dart';
import 'package:flutter_application_1/features/SportClub/model/dto/created_sport_clubs_dto.dart';
import 'package:flutter_application_1/features/SportClub/model/dto/update_sport_club_dto.dart';
import 'package:flutter_application_1/features/SportClub/model/dto/update_sport_club_images.dart';
import 'package:flutter_application_1/features/SportClub/model/sport_club_model.dart';
import 'package:flutter_application_1/features/SportClub/service/sport_club_service.dart';
import 'package:flutter_application_1/widgets/common/map_picker_screen.dart';

class CreateSportClubScreen extends StatefulWidget {
  final SportClubModel? clubToEdit;

  const CreateSportClubScreen({super.key, this.clubToEdit});

  @override
  State<CreateSportClubScreen> createState() => _CreateSportClubScreenState();
}

class _CreateSportClubScreenState extends State<CreateSportClubScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final CategoryService categoryService = getIt<CategoryService>();
  final SportClubService sportClubService = getIt<SportClubService>();

  // Variables for other fields
  bool? _isOpen;
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  List<File> _images = [];
  List<String> _keptImageUrls = [];
  bool _isSubmitting = false;
  bool _isEditMode = false;
  int? _editingClubId;

  // Category selection
  CategoriesModel? _selectedCategory;
  List<CategoriesModel> _categories = [];
  bool _isLoadingCategories = false;

  // Original images for edit mode
  List<String> _originalImageUrls = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initializeWithEditData();
  }

  void _initializeWithEditData() {
    final club = widget.clubToEdit;
    if (club != null) {
      _isEditMode = true;
      _editingClubId = club.id;

      // Fill text fields
      _nameController.text = club.name;
      _latController.text = club.lat.toString();
      _lngController.text = club.lng.toString();
      _locationController.text = club.location;
      _descriptionController.text = club.description;

      // Fill other fields
      _isOpen = club.isOpen;

      // Convert Duration to TimeOfDay
      _openTime = _durationToTimeOfDay(club.openTime);
      _closeTime = _durationToTimeOfDay(club.closeTime);

      // Store original image URLs
      _originalImageUrls = club.imageUrls.map((img) => img).toList();
      _keptImageUrls = List.from(_originalImageUrls);
    }
  }

  // Helper to convert Duration to TimeOfDay
  TimeOfDay _durationToTimeOfDay(Duration duration) {
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    return TimeOfDay(hour: hours, minute: minutes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Load categories from API
  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final categories = await categoryService.fetchAllCategories(1, 100, '');

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;

          // If in edit mode, select the category
          if (_isEditMode && widget.clubToEdit != null) {
            final clubCategories = widget.clubToEdit!.categories;
            if (clubCategories.isNotEmpty) {
              final categoryId = clubCategories.first.id;
              _selectedCategory = _categories.firstWhere(
                (cat) => cat.id == categoryId,
                orElse: () => _categories.first,
              );
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Convert TimeOfDay to Duration
  Duration _timeToDuration(TimeOfDay time) {
    return Duration(hours: time.hour, minutes: time.minute);
  }

  // Pick images from gallery
  Future<void> _pickImages() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: MediaQuery.of(dialogContext).size.height * 0.75,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.kBg : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with drag indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.kCardAlt : Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isEditMode ? 'Update Images' : 'Select Images',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.kLightText,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            icon: Icon(
                              Icons.close,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Choose up to ${5 - _images.length} images',
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.kTextSub
                              : AppTheme.kLightTextSub,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Image picker options
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Gallery option
                        _buildPickerOption(
                          icon: Icons.photo_library,
                          title: 'Choose from Gallery',
                          subtitle: 'Select multiple images from your gallery',
                          color: AppTheme.kAccent,
                          isDark: isDark,
                          onTap: () => _handleGalleryPick(dialogContext),
                        ),
                        const SizedBox(height: 12),

                        // Camera option
                        _buildPickerOption(
                          icon: Icons.camera_alt,
                          title: 'Take Photo',
                          subtitle: 'Capture a new photo with camera',
                          color: Colors.orange,
                          isDark: isDark,
                          onTap: () => _handleCameraPick(dialogContext),
                        ),
                        const SizedBox(height: 12),

                        // Cancel option
                        _buildPickerOption(
                          icon: Icons.cancel,
                          title: 'Cancel',
                          subtitle: 'Go back without selecting',
                          color: Colors.red,
                          isDark: isDark,
                          onTap: () => Navigator.pop(dialogContext, false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleGalleryPick(BuildContext dialogContext) async {
    Navigator.pop(dialogContext, false);
    if (!mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final savedImages = await ImageUtils.pickMultipleImages(context);

      if (mounted) {
        Navigator.pop(context);
      }

      if (savedImages.isNotEmpty && mounted) {
        setState(() {
          _images = savedImages;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${savedImages.length} images selected successfully',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No images selected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting images: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleCameraPick(BuildContext dialogContext) async {
    Navigator.pop(dialogContext, false);
    if (!mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final savedImage = await ImageUtils.pickImageFromCamera(context);

      if (mounted) {
        Navigator.pop(context);
      }

      if (savedImage != null && mounted) {
        setState(() {
          _images.add(savedImage);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo captured successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.kCardAlt : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.kBorder : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.kLightText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }


  // Open Map Picker
  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLat: _latController.text.isNotEmpty
              ? double.tryParse(_latController.text)
              : null,
          initialLng: _lngController.text.isNotEmpty
              ? double.tryParse(_lngController.text)
              : null,
          initialLabel: _locationController.text.isNotEmpty
              ? _locationController.text
              : null,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _latController.text = result['lat'].toString();
        _lngController.text = result['lng'].toString();
        _locationController.text = result['label'];
      });
    }
  }

  // Submit form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Validate location is selected
      if (_locationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a location on the map'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Validate category is selected
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Validate images for create mode
      if (!_isEditMode && _images.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload at least one image'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Validate status is selected
      if (_isOpen == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select club status (Open/Closed)'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Validate times are selected
      if (_openTime == null || _closeTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select opening and closing times'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Validate lat/lng are present
      final lat = double.tryParse(_latController.text);
      final lng = double.tryParse(_lngController.text);

      if (lat == null || lng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid location coordinates'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      if (_isEditMode && _editingClubId != null) {
        _updateSportClub(lat, lng);
      } else {
        _createSportClub(lat, lng);
      }
    }
  }

  // Create method
  Future<void> _createSportClub(double lat, double lng) async {
    try {
      final sportClubDto = CreatedSportClubsDto(
        name: _nameController.text,
        lat: lat,
        lng: lng,
        location: _locationController.text,
        isOpen: _isOpen!,
        openTime: _timeToDuration(_openTime!),
        closeTime: _timeToDuration(_closeTime!),
        description: _descriptionController.text,
        categoryId: _selectedCategory!.id,
        images: _images,
      );

      final createdClub = await sportClubService.createSportClub(sportClubDto);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Club "${createdClub.name}" created successfully! 🎉',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create club: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Update method - FIXED to use correct DTOs
  Future<void> _updateSportClub(double lat, double lng) async {
    try {
      final clubId = _editingClubId!;

      // Check if images were changed
      final imagesChanged =
          _images.isNotEmpty ||
          _keptImageUrls.length != _originalImageUrls.length;

      if (imagesChanged) {
        // Update with images using UpdateSportClubImages
        final updateImagesDto = UpdateSportClubImages(
          name: _nameController.text,
          isOpen: _isOpen!,
          imagesChanged: true,
          keptImageUrls: _keptImageUrls,
          images: _images.isNotEmpty ? _images : null,
        );

        final updatedClub = await sportClubService.updateSportClubImages(
          updateImagesDto,
          clubId,
        );

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Club "${updatedClub.name}" updated successfully! ✏️',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Update without images using UpdateSportClubDto
        final updateDto = UpdateSportClubDto(
          name: _nameController.text,
          location: _locationController.text,
          description: _descriptionController.text,
          openTime: _timeToDuration(_openTime!),
          closeTime: _timeToDuration(_closeTime!),
          lat: lat,
          lng: lng,
          isOpen: _isOpen!,
          categoryId: _selectedCategory!.id, // List of category IDs
        );

        final updatedClub = await sportClubService.updateSportClub(
          updateDto,
          clubId,
        );

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Club "${updatedClub.name}" updated successfully! ✏️',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update club: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Time picker helper
  Future<void> _selectTime({required bool isOpen}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpen
          ? (_openTime ?? TimeOfDay.now())
          : (_closeTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme(
              primary: AppTheme.kAccent,
              primaryContainer: AppTheme.kAccent.withValues(alpha: 0.1),
              secondary: AppTheme.kAccent,
              surface: isDark ? AppTheme.kBg : Colors.white,
              error: Colors.red,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: isDark ? Colors.white : AppTheme.kLightText,
              onError: Colors.white,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
            cardColor: isDark ? AppTheme.kCardAlt : Colors.white,
            scaffoldBackgroundColor: isDark ? AppTheme.kBg : Colors.white,
            timePickerTheme: TimePickerThemeData(
              backgroundColor: isDark ? AppTheme.kBg : Colors.white,
              dialBackgroundColor: isDark
                  ? AppTheme.kCardAlt
                  : Colors.grey.shade50,
              dialHandColor: AppTheme.kAccent,
              hourMinuteTextColor: isDark ? Colors.white : AppTheme.kLightText,
              hourMinuteColor: isDark
                  ? AppTheme.kCardAlt
                  : Colors.grey.shade100,
              dayPeriodTextColor: isDark ? Colors.white : AppTheme.kLightText,
              dayPeriodColor: isDark ? AppTheme.kCardAlt : Colors.grey.shade100,
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.kAccent, width: 2),
                ),
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                labelStyle: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
              ),
              helpTextStyle: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              dialTextStyle: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              entryModeIconColor: AppTheme.kAccent,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: isDark ? AppTheme.kBg : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOpen) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = _isEditMode ? 'Edit Sport Club' : 'Create Sport Club';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : AppTheme.kLightText,
          ),
        ),
        title: Text(title, style: AppTheme.tsTitleAdaptive(context)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Image Upload Section ──────────────────────────────
                    _buildImageSection(isDark),
                    const SizedBox(height: 24),

                    // ── Basic Information ─────────────────────────────────
                    _buildSectionTitle(
                      'Basic Information',
                      Icons.info_outline,
                      isDark,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _nameController,
                      label: 'Club Name',
                      hint: 'Enter club name',
                      icon: Icons.sports,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter club name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Category Selection ─────────────────────────────────
                    _buildCategoryDropdown(isDark),
                    const SizedBox(height: 16),

                    // ── Location with Map Picker ──────────────────────────
                    _buildLocationField(isDark),
                    const SizedBox(height: 24),

                    // ── Operating Hours ───────────────────────────────────
                    _buildSectionTitle(
                      'Operating Hours',
                      Icons.access_time,
                      isDark,
                    ),
                    const SizedBox(height: 12),

                    // Open/Closed Status
                    _buildStatusToggle(isDark),
                    const SizedBox(height: 16),

                    // Time pickers
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimePicker(
                            label: 'Opening Time',
                            time: _openTime,
                            onTap: () => _selectTime(isOpen: true),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimePicker(
                            label: 'Closing Time',
                            time: _closeTime,
                            onTap: () => _selectTime(isOpen: false),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Description ────────────────────────────────────────
                    _buildSectionTitle(
                      'Description',
                      Icons.description,
                      isDark,
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.kCardAlt
                            : AppTheme.kLightCardAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.kBorder
                              : AppTheme.kLightBorder,
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.kLightText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Describe your club...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppTheme.kTextSub
                                : AppTheme.kLightTextSub,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          suffixIcon: Icon(
                            Icons.edit_note,
                            color: isDark
                                ? AppTheme.kTextSub
                                : AppTheme.kLightTextSub,
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── Submit Button ─────────────────────────────────────
                    _buildSubmitButton(isDark),
                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Category Dropdown ─────────────────────────────────────────────────
  Widget _buildCategoryDropdown(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          width: 1,
        ),
      ),
      child: _isLoadingCategories
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading categories...',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                    ),
                  ),
                ],
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<CategoriesModel>(
                value: _selectedCategory,
                isExpanded: true,
                hint: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.category, color: AppTheme.kAccent),
                      const SizedBox(width: 8),
                      Text(
                        'Select Category',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : AppTheme.kLightTextSub,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<CategoriesModel>(
                    value: category,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          if (category.imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                category.imageUrl,
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 30,
                                    height: 30,
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.error_outline,
                                      size: 16,
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppTheme.kAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.category,
                                color: AppTheme.kAccent,
                                size: 16,
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category.name,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppTheme.kLightText,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (CategoriesModel? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                dropdownColor: isDark ? AppTheme.kBg : Colors.white,
                icon: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: isDark ? Colors.white70 : AppTheme.kLightText,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 14,
                ),
                borderRadius: BorderRadius.circular(12),
                elevation: 8,
              ),
            ),
    );
  }

  // ── Location Field with Map Picker ──────────────────────────────────────
  Widget _buildLocationField(bool isDark) {
    return GestureDetector(
      onTap: _openMapPicker,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _locationController.text.isNotEmpty
                ? Colors.green.withValues(alpha: 0.5)
                : AppTheme.kAccent.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.kAccent.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: _locationController.text.isNotEmpty
                      ? const LinearGradient(
                          colors: [Colors.green, Color(0xFF00C853)],
                        )
                      : const LinearGradient(
                          colors: [AppTheme.kAccent, Color(0xFF00B4D8)],
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _locationController.text.isNotEmpty
                      ? Icons.location_pin
                      : Icons.map_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _locationController.text.isNotEmpty
                          ? 'Location Selected ✓'
                          : 'Select Location on Map',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.kLightText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _locationController.text.isNotEmpty
                          ? _locationController.text
                          : 'Tap to pick location from map',
                      style: TextStyle(
                        color: _locationController.text.isNotEmpty
                            ? (isDark ? Colors.white70 : AppTheme.kLightText)
                            : (isDark
                                  ? AppTheme.kTextSub
                                  : AppTheme.kLightTextSub),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _locationController.text.isNotEmpty
                      ? Colors.green.withValues(alpha: 0.1)
                      : AppTheme.kAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _locationController.text.isNotEmpty
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_ios_rounded,
                  color: _locationController.text.isNotEmpty
                      ? Colors.green
                      : AppTheme.kAccent,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Image Section ──────────────────────────────────────────────────────
  Widget _buildImageSection(bool isDark) {
    // Combine original images and new images for display
    List<Widget> imageWidgets = [];

    // Display original images if in edit mode
    if (_isEditMode) {
      for (int i = 0; i < _originalImageUrls.length; i++) {
        final url = _originalImageUrls[i];
        // Check if this image is being kept
        final isKept = _keptImageUrls.contains(url);
        if (isKept) {
          imageWidgets.add(
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _keptImageUrls.remove(url);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Existing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }
    }

    // Display new images
    for (int i = 0; i < _images.length; i++) {
      final index = i;
      imageWidgets.add(
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(_images[i]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _images.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
            if (_isEditMode)
              Positioned(
                bottom: 4,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'New',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_library, color: AppTheme.kAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                _isEditMode ? 'Update Images' : 'Club Images',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${_keptImageUrls.length + _images.length}/5',
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Image grid
          if (imageWidgets.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: imageWidgets,
              ),
            ),

          if (imageWidgets.isNotEmpty) const SizedBox(height: 12),

          // Upload button
          if (_keptImageUrls.length + _images.length < 5)
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.kAccent.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.kAccent.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      color: _keptImageUrls.length + _images.length < 5
                          ? AppTheme.kAccent
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _images.isEmpty && _keptImageUrls.isEmpty
                          ? (_isEditMode
                                ? 'Add new images'
                                : 'Tap to upload images')
                          : 'Add more images (${5 - (_keptImageUrls.length + _images.length)} remaining)',
                      style: TextStyle(
                        color: _keptImageUrls.length + _images.length < 5
                            ? AppTheme.kAccent
                            : Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Section Title ──────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.kAccent, Color(0xFF00B4D8)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── Text Field ──────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: isDark ? Colors.white : AppTheme.kLightText),
        keyboardType: keyboardType,
        validator: validator,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
          ),
          prefixIcon: Icon(icon, color: AppTheme.kAccent, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  // ── Status Toggle ──────────────────────────────────────────────────────
  Widget _buildStatusToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isOpen ?? false ? Icons.check_circle : Icons.cancel,
            color: _isOpen ?? false ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Club Status',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _isOpen == null
                      ? 'Select club status'
                      : (_isOpen!
                            ? 'Currently Open 🟢'
                            : 'Currently Closed 🔴'),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOpen ?? false,
            onChanged: (value) {
              setState(() {
                _isOpen = value;
              });
            },
            activeThumbColor: AppTheme.kAccent,
            activeTrackColor: AppTheme.kAccent.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.red,
            inactiveTrackColor: Colors.red.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  // ── Time Picker ────────────────────────────────────────────────────────
  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: AppTheme.kAccent, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              time?.format(context) ?? 'Select time',
              style: TextStyle(
                color: time != null
                    ? (isDark ? Colors.white : AppTheme.kLightText)
                    : (isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub),
                fontSize: 16,
                fontWeight: time != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit Button ──────────────────────────────────────────────────────
  Widget _buildSubmitButton(bool isDark) {
    final buttonText = _isEditMode ? 'Update Club' : 'Create Club';
    final icon = _isEditMode ? Icons.edit : Icons.check_circle_outline;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.kAccent, Color(0xFF00B4D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.kAccent.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    buttonText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
