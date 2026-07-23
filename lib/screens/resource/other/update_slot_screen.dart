import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/features/Slot/model/dto/update_slot_dto.dart';
import 'package:flutter_application_1/features/Slot/model/slot_model.dart';
import 'package:flutter_application_1/features/Slot/service/slot_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';

class UpdateSlotScreen extends StatefulWidget {
  final SlotModel slot;

  const UpdateSlotScreen({super.key, required this.slot});

  @override
  State<UpdateSlotScreen> createState() => _UpdateSlotScreenState();
}

class _UpdateSlotScreenState extends State<UpdateSlotScreen> {
  // ── Controllers ──────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController();

  // ── State variables ──────────────────────────────────────────────────
  bool _isAvailable = true;
  String? _existingImageUrl;
  File? _newImageFile;
  bool _isSubmitting = false;
  bool _imageChanged = false;

  // ── Services ──────────────────────────────────────────────────────────
  SlotService get _slotService => GetIt.instance<SlotService>();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _nameController.text = widget.slot.name;
    _priceController.text = widget.slot.price.toString();
    _descriptionController.text = widget.slot.description;
    _capacityController.text = widget.slot.capacity.toString();
    _isAvailable = widget.slot.isAvailable;
    _existingImageUrl = widget.slot.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
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
        _newImageFile = File(pickedImage.path);
        _imageChanged = true;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _newImageFile = null;
      _existingImageUrl = null;
      _imageChanged = true;
    });
  }

  void _keepExistingImage() {
    setState(() {
      _newImageFile = null;
      _imageChanged = false;
    });
  }

  // ── Submit Form ──────────────────────────────────────────────────────
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Create the UpdateSlotDto with all fields
        final updateDto = UpdateSlotDto(
          name: _nameController.text.trim(),
          price: int.parse(_priceController.text.trim()),
          isAvailable: _isAvailable,
          description: _descriptionController.text.trim(),
          capacity: int.parse(_capacityController.text.trim()),
        );

        // Call the repository update method
        await _slotService.updateSlot(updateDto, widget.slot.id);

        // Handle image separately if changed
        if (_imageChanged) {
          if (_newImageFile != null) {
            // Upload new image
            await _slotService.updateSlotImage(
              widget.slot.id,
              _newImageFile!,
              _nameController.text.trim(),
            );
          } else if (_existingImageUrl == null) {
            // Remove image if no image exists
            await _slotService.removeSlotImage(widget.slot.id);
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Slot updated successfully! ✨'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
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
        title: Text('Update Slot', style: AppTheme.tsTitleAdaptive(context)),
        actions: [
          IconButton(
            onPressed: _isSubmitting ? null : _submitForm,
            icon: const Icon(Icons.save),
            color: AppTheme.kAccent,
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
                    // ── Header ─────────────────────────────────────────────
                    _buildHeader(isDark),
                    const SizedBox(height: 20),

                    // ── Slot ID ────────────────────────────────────────────
                    _buildSlotIdInfo(isDark),
                    const SizedBox(height: 24),

                    // ── Image Section ──────────────────────────────────────
                    _buildImageSection(isDark),
                    const SizedBox(height: 24),

                    // ── Update Information ────────────────────────────────
                    _buildSectionTitle(
                      'Update Information',
                      Icons.edit_note,
                      isDark,
                    ),
                    const SizedBox(height: 12),

                    // ✅ Name Field
                    _buildTextField(
                      controller: _nameController,
                      label: 'Slot Name',
                      hint: 'Enter slot name',
                      icon: Icons.label,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter slot name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Price Field
                    _buildTextField(
                      controller: _priceController,
                      label: 'Price',
                      hint: 'Enter price',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Enter price';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Capacity Field
                    _buildTextField(
                      controller: _capacityController,
                      label: 'Capacity',
                      hint: 'Enter capacity (number of people)',
                      icon: Icons.people,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Enter capacity';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Invalid capacity';
                        }
                        if (int.parse(value) <= 0) {
                          return 'Capacity must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Description Field
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Enter slot description',
                      icon: Icons.description,
                      maxLines: 3,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter description';
                        }
                        if (value!.length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Availability ───────────────────────────────────────
                    _buildSectionTitle(
                      'Availability',
                      Icons.check_circle_outline,
                      isDark,
                    ),
                    const SizedBox(height: 12),

                    _buildAvailabilityToggle(isDark),
                    const SizedBox(height: 24),

                    // ── Additional Info ────────────────────────────────────
                    _buildAdditionalInfo(isDark),
                    const SizedBox(height: 24),

                    // ── Update Button ─────────────────────────────────────
                    _buildUpdateButton(isDark),
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
            child: const Icon(Icons.edit_note, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Slot #${widget.slot.id}',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Modify the slot details below',
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

  // ── Slot ID Info ──────────────────────────────────────────────────────
  Widget _buildSlotIdInfo(bool isDark) {
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
                  'Slot ID',
                  style: TextStyle(
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '#${widget.slot.id}',
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
              color: widget.slot.isAvailable
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.slot.isAvailable ? 'Active' : 'Inactive',
              style: TextStyle(
                color: widget.slot.isAvailable ? Colors.green : Colors.red,
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
    final hasExistingImage =
        _existingImageUrl != null && _existingImageUrl!.isNotEmpty;
    final hasNewImage = _newImageFile != null;

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
                'Slot Image',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_imageChanged && hasNewImage)
                TextButton(
                  onPressed: _keepExistingImage,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Keep Existing'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (hasNewImage)
            _buildNewImagePreview(isDark)
          else if (hasExistingImage)
            _buildExistingImagePreview(isDark)
          else
            _buildImageUploadPlaceholder(isDark),

          if (!hasExistingImage && !hasNewImage)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'No image available. Upload a new one.',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── New Image Preview ──────────────────────────────────────────────────
  Widget _buildNewImagePreview(bool isDark) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(_newImageFile!),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'New',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              onPressed: _removeImage,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Existing Image Preview ──────────────────────────────────────────────
  Widget _buildExistingImagePreview(bool isDark) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                _existingImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text('Failed to load image'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 8,
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Current',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: IconButton(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Image Upload Placeholder ────────────────────────────────────────────
  Widget _buildImageUploadPlaceholder(bool isDark) {
    return GestureDetector(
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
              'Tap to upload new image',
              style: TextStyle(
                color: AppTheme.kAccent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'JPG, PNG, GIF supported',
              style: TextStyle(
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Additional Info ──────────────────────────────────────────────────
  Widget _buildAdditionalInfo(bool isDark) {
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
          Text(
            'Additional Information',
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.kLightText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Created',
            widget.slot.createdAt?.toString() ?? 'N/A',
            Icons.calendar_today,
            isDark,
          ),
          const Divider(height: 16),
          _buildInfoRow(
            'Last Updated',
            widget.slot.updatedAt?.toString() ?? 'N/A',
            Icons.access_time,
            isDark,
          ),
          const Divider(height: 16),
          _buildInfoRow(
            'Sport Club ID',
            widget.slot.sportClubId?.toString() ?? 'N/A',
            Icons.business,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.kAccent, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.kLightText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
    int? maxLines,
    String? Function(String?)? validator,
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
        maxLines: maxLines ?? 1,
        validator: validator,
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
                  'Slot Status',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _isAvailable ? 'Available 🟢' : 'Unavailable 🔴',
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

  // ── Update Button ──────────────────────────────────────────────────────
  Widget _buildUpdateButton(bool isDark) {
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
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.update, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Update Slot',
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
