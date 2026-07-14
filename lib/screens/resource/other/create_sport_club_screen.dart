import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/widgets/common/map_picker_screen.dart';
import 'package:image_picker/image_picker.dart'; // Adjust path as needed

class CreateSportClubScreen extends StatefulWidget {
  const CreateSportClubScreen({super.key});

  @override
  State<CreateSportClubScreen> createState() => _CreateSportClubScreenState();
}

class _CreateSportClubScreenState extends State<CreateSportClubScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _latController = TextEditingController(); // Hidden but keeps value
  final _lngController = TextEditingController(); // Hidden but keeps value
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryIdController = TextEditingController();

  // Variables for other fields
  bool? _isOpen;
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  List<File> _images = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _categoryIdController.dispose();
    super.dispose();
  }

  // Convert TimeOfDay to Duration
  Duration? _timeToDuration(TimeOfDay? time) {
    if (time == null) return null;
    return Duration(hours: time.hour, minutes: time.minute);
  }

  // Pick images from gallery
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> pickedImages = await picker.pickMultiImage();

    setState(() {
      _images = pickedImages.map((file) => File(file.path)).toList();
    });
  }

  // Remove image
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // ── Open Map Picker ──────────────────────────────────────────────────────
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

      setState(() {
        _isSubmitting = true;
      });

      // Collect all data with lat/lng from hidden controllers
      // ignore: unused_local_variable
      final clubData = {
        'name': _nameController.text,
        'lat': double.tryParse(_latController.text),
        'lng': double.tryParse(_lngController.text),
        'location': _locationController.text,
        'isOpen': _isOpen,
        'openTime': _timeToDuration(_openTime),
        'closeTime': _timeToDuration(_closeTime),
        'description': _descriptionController.text,
        'categoryId': int.tryParse(_categoryIdController.text),
        'images': _images,
      };

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Club created successfully! 🎉'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      });
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
          'Create Sport Club',
          style: AppTheme.tsTitleAdaptive(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.kAccent,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.kAccent,
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
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

                    // ── Category ──────────────────────────────────────────
                    _buildSectionTitle('Category', Icons.category, isDark),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _categoryIdController,
                      label: 'Category ID',
                      hint: 'Enter category number',
                      icon: Icons.numbers,
                      keyboardType: TextInputType.number,
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
                'Club Images',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${_images.length}/5',
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Image grid
          if (_images.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(_images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
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
                    ],
                  );
                },
              ),
            ),

          if (_images.isNotEmpty) const SizedBox(height: 12),

          // Upload button
          GestureDetector(
            onTap: _images.length < 5 ? _pickImages : null,
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
                    color: _images.length < 5 ? AppTheme.kAccent : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _images.isEmpty
                        ? 'Tap to upload images'
                        : 'Add more images (${5 - _images.length} remaining)',
                    style: TextStyle(
                      color: _images.length < 5
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

  // ── Select Time ────────────────────────────────────────────────────────
  Future<void> _selectTime({required bool isOpen}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.kAccent),
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
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Create Club',
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
