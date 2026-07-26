import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/features/Slot/model/dto/create_slot_dto.dart';
import 'package:flutter_application_1/features/Slot/service/slot_service.dart';
import 'package:flutter_application_1/features/SportClub/model/dto/category_dto.dart';
import 'package:flutter_application_1/features/SportClub/model/sport_club_model.dart';
import 'package:flutter_application_1/translations/app_translations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';

class AdjustSlotScreen extends StatefulWidget {
  final SportClubModel sportClub;

  const AdjustSlotScreen({super.key, required this.sportClub});

  @override
  State<AdjustSlotScreen> createState() => _AdjustSlotScreenState();
}

class _AdjustSlotScreenState extends State<AdjustSlotScreen> {
  // ── Controllers ──────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();

  // ── State variables ──────────────────────────────────────────────────
  bool _isAvailable = true;
  File? _imageFile;
  bool _isSubmitting = false;

  // Category related - using categories from SportClubModel
  CategoryDto? _selectedCategory;

  // ── Services ──────────────────────────────────────────────────────────
  SlotService get _slotService => GetIt.instance<SlotService>();

  @override
  void initState() {
    super.initState();
    // Auto-select first category if available
    if (widget.sportClub.categories.isNotEmpty) {
      _selectedCategory = widget.sportClub.categories.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  // ── Image Picker ──────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  // ── Submit Form ──────────────────────────────────────────────────────
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('please_select_slot_image'.tr(context)),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('please_select_category'.tr(context)),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        final createDto = CreateSlotDto(
          sportClubId: widget.sportClub.id!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          capacity: int.parse(_capacityController.text),
          isAvailable: _isAvailable,
          categoryId: _selectedCategory!.id,
          image: _imageFile!,
        );

        await _slotService.createSlot(createDto);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('slot_created_success'.tr(context)),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        title: Text(
          'create_slot'.tr(context),
          style: AppTheme.tsTitleAdaptive(context),
        ),
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
                    // ── Header ─────────────────────────────────────────────
                    _buildHeader(isDark),
                    const SizedBox(height: 20),

                    // ── Image Upload ──────────────────────────────────────
                    _buildImageSection(isDark),
                    const SizedBox(height: 24),

                    // ── Basic Information ─────────────────────────────────
                    _buildSectionTitle(
                      'basic_information'.tr(context),
                      Icons.info_outline,
                      isDark,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _nameController,
                      label: 'slot_name'.tr(context),
                      hint: 'enter_slot_name'.tr(context),
                      icon: Icons.label,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'please_enter_slot_name'.tr(context);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _descriptionController,
                      label: 'description'.tr(context),
                      hint: 'enter_slot_description'.tr(context),
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // ── Price & Capacity Row ──────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _priceController,
                            label: 'price_label'.tr(context),
                            hint: '0.00',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'enter_price'.tr(context);
                              }
                              if (double.tryParse(value!) == null) {
                                return 'invalid_price'.tr(context);
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _capacityController,
                            label: 'capacity'.tr(context),
                            hint: '0',
                            icon: Icons.people,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'enter_capacity'.tr(context);
                              }
                              if (int.tryParse(value!) == null) {
                                return 'invalid_number'.tr(context);
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Category Dropdown ─────────────────────────────────
                    _buildCategoryDropdown(isDark),
                    const SizedBox(height: 24),

                    // ── Availability ───────────────────────────────────────
                    _buildSectionTitle(
                      'availability'.tr(context),
                      Icons.check_circle_outline,
                      isDark,
                    ),
                    const SizedBox(height: 12),

                    _buildAvailabilityToggle(isDark),
                    const SizedBox(height: 24),

                    // ── Sport Club Info ────────────────────────────────────
                    _buildSportClubInfo(isDark),
                    const SizedBox(height: 24),

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

  // ── Category Dropdown ──────────────────────────────────────────────────
  Widget _buildCategoryDropdown(bool isDark) {
    final categories = widget.sportClub.categories;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.category, color: AppTheme.kAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'category'.tr(context),
                  style: TextStyle(
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (categories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'no_categories_available'.tr(context),
                  style: const TextStyle(color: Colors.orange, fontSize: 14),
                ),
              )
            else
              DropdownButtonFormField<CategoryDto>(
                initialValue: _selectedCategory,
                isExpanded: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  hintText: 'select_category'.tr(context),
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 16,
                ),
                dropdownColor: isDark ? AppTheme.kCardAlt : Colors.white,
                items: categories.map((category) {
                  return DropdownMenuItem<CategoryDto>(
                    value: category,
                    child: Row(
                      children: [
                        // Category image thumbnail if available
                        if (category.imageUrl.isNotEmpty)
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              image: DecorationImage(
                                image: NetworkImage(category.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppTheme.kAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'please_select_category'.tr(context);
                  }
                  return null;
                },
              ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.kAccent.withValues(alpha: 0.1),
            const Color(0xFF00B4D8).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.kAccent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.kAccent, Color(0xFF00B4D8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'create_new_slot'.tr(context),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'fill_slot_details'.tr(context),
                  style: TextStyle(
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sport Club Info ──────────────────────────────────────────────────
  Widget _buildSportClubInfo(bool isDark) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.kAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.sports, color: AppTheme.kAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'sport_club'.tr(context),
                  style: TextStyle(
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    fontSize: 12,
                  ),
                ),
                Text(
                  widget.sportClub.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.sportClub.isOpen
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.sportClub.isOpen
                  ? 'open'.tr(context)
                  : 'closed'.tr(context),
              style: TextStyle(
                color: widget.sportClub.isOpen ? Colors.green : Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Image Section ──────────────────────────────────────────────────────
  Widget _buildImageSection(bool isDark) {
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
              Icon(Icons.image, color: AppTheme.kAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'slot_image_required'.tr(context),
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_imageFile != null)
                TextButton(
                  onPressed: _removeImage,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('remove'.tr(context)),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Image preview or upload button
          if (_imageFile != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(_imageFile!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'image_loaded'.tr(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.kAccent.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, color: AppTheme.kAccent, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'tap_to_upload_image'.tr(context),
                      style: TextStyle(
                        color: AppTheme.kAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'image_formats'.tr(context),
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.kTextSub
                            : AppTheme.kLightTextSub,
                        fontSize: 11,
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
    int maxLines = 1,
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
        maxLines: maxLines,
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

  // ── Availability Toggle ──────────────────────────────────────────────
  Widget _buildAvailabilityToggle(bool isDark) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isAvailable
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isAvailable ? Icons.check_circle : Icons.cancel,
              color: _isAvailable ? Colors.green : Colors.red,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'slot_status'.tr(context),
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _isAvailable
                      ? 'available_emoji'.tr(context)
                      : 'unavailable_emoji'.tr(context),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailable,
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
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

  // ── Submit Button ──────────────────────────────────────────────────────
  Widget _buildSubmitButton(bool isDark) {
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
                  const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'create_slot'.tr(context),
                    style: const TextStyle(
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
