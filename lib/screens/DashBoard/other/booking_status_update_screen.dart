// lib/features/Booking/widgets/booking_status_update_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/features/Booking/Model/booking_model.dart';
import 'package:flutter_application_1/features/Booking/Service/booking_service.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';

class BookingStatusUpdateSheet extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback onStatusUpdated;

  const BookingStatusUpdateSheet({
    super.key,
    required this.booking,
    required this.onStatusUpdated,
  });

  @override
  State<BookingStatusUpdateSheet> createState() =>
      _BookingStatusUpdateSheetState();
}

class _BookingStatusUpdateSheetState extends State<BookingStatusUpdateSheet> {
  final BookingService _bookingService = getIt<BookingService>();
  bool _isUpdating = false;
  String? _selectedStatus;
  String? _selectedPaymentStatus;

  // Available statuses
  final List<String> _availableStatuses = [
    'pending',
    'confirmed',
    'cancelled',
    'completed',
  ];

  final List<String> _availablePaymentStatuses = [
    'pending',
    'paid',
    'failed',
    'refunded',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.booking.status;
    _selectedPaymentStatus = widget.booking.paymentStatus;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kBg : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.kAccent, Color(0xFF00B4D8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_calendar,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Booking Status',
                      style: AppTheme.tsTitleAdaptive(context),
                    ),
                    Text(
                      'Booking #${widget.booking.id}',
                      style: AppTheme.tsSubAdaptive(context),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Booking Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  'Customer',
                  widget.booking.user.fullName,
                  Icons.person,
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Court',
                  widget.booking.slot.name,
                  Icons.sports,
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Date & Time',
                  '${_formatDate(widget.booking.bookingDate)} • ${_formatTime(widget.booking.startTime)} - ${_formatTime(widget.booking.endTime)}',
                  Icons.calendar_today,
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Amount',
                  '\$${widget.booking.totalAmount}',
                  Icons.attach_money,
                  isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Status Dropdown
          _buildStatusDropdown(
            'Booking Status',
            _selectedStatus!,
            _availableStatuses,
            (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            isDark,
          ),

          const SizedBox(height: 16),

          // Payment Status Dropdown
          _buildStatusDropdown(
            'Payment Status',
            _selectedPaymentStatus!,
            _availablePaymentStatuses,
            (value) {
              setState(() {
                _selectedPaymentStatus = value;
              });
            },
            isDark,
          ),

          const SizedBox(height: 16),

          // Note TextField
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                width: 1,
              ),
            ),
            child: TextFormField(
              maxLines: 3,
              initialValue: widget.booking.note,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
              ),
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: Icon(
                  Icons.note_add,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
              ),
              onChanged: (value) {
              },
            ),
          ),

          const SizedBox(height: 24),

          // Update Button
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isUpdating ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppTheme.kLightText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.kAccent, Color(0xFF00B4D8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : _updateStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Update Status',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
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
          '$label: ',
          style: TextStyle(
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 13,
          ),
        ),
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

  Widget _buildStatusDropdown(
    String label,
    String currentValue,
    List<String> options,
    Function(String?) onChanged,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentValue,
            isExpanded: true,
            hint: Text(label),
            items: options.map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Row(
                  children: [
                    _buildStatusIndicator(status),
                    const SizedBox(width: 8),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.kLightText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
            dropdownColor: isDark ? AppTheme.kBg : Colors.white,
            icon: Icon(
              Icons.arrow_drop_down,
              color: isDark ? Colors.white70 : AppTheme.kLightText,
            ),
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.kLightText,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
      case 'failed':
        color = Colors.red;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      case 'refunded':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(Duration time) {
    final hours = time.inHours.toString().padLeft(2, '0');
    final minutes = time.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      // Update booking status
      await _bookingService.updateBookingStatus(
        widget.booking.id,
      );

      // If payment status is also changed, update it
      if (_selectedPaymentStatus != widget.booking.paymentStatus) {
        // Note: You might need a separate API endpoint for payment status update
        // For now, we'll just show a message
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking status updated to ${_selectedStatus?.toUpperCase()}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Notify parent
      widget.onStatusUpdated();

      // Close sheet
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Helper method to show the sheet
Future<void> showBookingStatusUpdateSheet(
  BuildContext context,
  BookingModel booking,
  VoidCallback onStatusUpdated,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BookingStatusUpdateSheet(
      booking: booking,
      onStatusUpdated: onStatusUpdated,
    ),
  );
}
