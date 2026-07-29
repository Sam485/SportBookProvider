// widgets/cards/club_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/features/SportClub/model/sport_club_model.dart';
import 'package:flutter_application_1/features/SportClub/service/sport_club_service.dart';
import 'package:flutter_application_1/routes/app_routes.dart';
import 'package:flutter_application_1/screens/resource/other/create_sport_club_screen.dart';
import '../../core/theme.dart';
import '../../translations/app_translations.dart';

class ClubCard extends StatefulWidget {
  final SportClubModel club;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete; // Add delete callback

  const ClubCard({
    super.key,
    required this.club,
    this.onEdit,
    this.onDelete, // Add this
  });

  @override
  State<ClubCard> createState() => _ClubCardState();
}

class _ClubCardState extends State<ClubCard> {
  int _page = 0;
  late PageController _ctrl;
  bool _isDeleting = false;
  final SportClubService _sportClubService = getIt<SportClubService>();

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get hasImages => widget.club.imageUrls.isNotEmpty;
  List<String> get urls => widget.club.imageUrls;
  SportClubModel get c => widget.club;

  // Generate initials from club name
  String get initials {
    final parts = c.name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return c.name.substring(0, 2).toUpperCase();
  }

  // Generate a consistent color based on club name
  Color get clubColor {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.cyan,
      Colors.purple,
      Colors.red,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.lime,
    ];
    final index = c.name.hashCode.abs() % colors.length;
    return colors[index];
  }

  // Format Duration to time string (HH:MM AM/PM)
  String formatDurationToTimeString(Duration duration) {
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final period = hours >= 12 ? 'PM' : 'AM';
    final displayHours = hours == 0
        ? 12
        : hours > 12
        ? hours - 12
        : hours;
    return '$displayHours:${minutes.toString().padLeft(2, '0')} $period';
  }

  void _navigateToAddSlot(int id) {
    Navigator.pushNamed(context, AppRoutes.slot, arguments: widget.club);
  }

  void _navigateToEditSportClub() {
    if (widget.onEdit != null) {
      widget.onEdit!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateSportClubScreen(clubToEdit: widget.club),
        ),
      );
    }
  }

  // Show delete confirmation dialog
  Future<void> _showDeleteConfirmation() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.kBg : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Text(
                'delete_club'.tr(context),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            'delete_club_confirmation'
                .tr(context)
                .replaceAll('{name}', widget.club.name),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.grey,
                textStyle: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text('cancel'.tr(context)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text('delete'.tr(context)),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteClub();
      }
    });
  }

  // Delete club
  Future<void> _deleteClub() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await _sportClubService.deleteSportClub(widget.club.id!);

      if (mounted) {
        setState(() {
          _isDeleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'club_deleted_success'
                  .tr(context)
                  .replaceAll('{name}', widget.club.name),
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Call the delete callback to refresh the parent
        if (widget.onDelete != null) {
          widget.onDelete!();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'club_delete_failed'
                  .tr(context)
                  .replaceAll('{error}', e.toString()),
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 14),
        clipBehavior: Clip.hardEdge,
        decoration: AppTheme.cardDecorationAdaptive(context, radius: 22),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image carousel ──────────────────────────────────────────
                GestureDetector(
                  onHorizontalDragUpdate: hasImages && urls.length > 1
                      ? _onDragUpdate
                      : null,
                  onHorizontalDragEnd: hasImages && urls.length > 1
                      ? _onDragEnd
                      : null,
                  behavior: HitTestBehavior.opaque,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (hasImages)
                            PageView.builder(
                              controller: _ctrl,
                              itemCount: urls.length,
                              physics: const NeverScrollableScrollPhysics(),
                              onPageChanged: (i) => setState(() => _page = i),
                              itemBuilder: (_, i) => Image.network(
                                urls[i],
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: isDark
                                      ? AppTheme.kCardAlt
                                      : AppTheme.kLightCardAlt,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                                loadingBuilder: (_, ch, p) => p == null
                                    ? ch
                                    : Container(
                                        color: isDark
                                            ? AppTheme.kCardAlt
                                            : AppTheme.kLightCardAlt,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: AppTheme.kAccent,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                              ),
                            )
                          else
                            Container(
                              color: isDark
                                  ? AppTheme.kCardAlt
                                  : AppTheme.kLightCardAlt,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sports,
                                    color: isDark
                                        ? Colors.white38
                                        : AppTheme.kLightTextSub,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'no_images'.tr(context),
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      color: isDark
                                          ? Colors.white38
                                          : AppTheme.kLightTextSub,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Scrim
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  isDark
                                      ? const Color(0xCC0A1828)
                                      : const Color(0xCCF0F6FF),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.4, 1.0],
                              ),
                            ),
                          ),

                          // Open/close badge
                          Positioned(
                            top: 8,
                            left: 10,
                            child: _openCloseBadge(isDark),
                          ),

                          // Settings button - TOP RIGHT
                          Positioned(
                            top: 8,
                            right: 10,
                            child: GestureDetector(
                              onTap: _navigateToEditSportClub,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.kAccent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.settings,
                                  color: AppTheme.kAccent,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),

                          // Delete button - TOP LEFT (below open badge)
                          Positioned(
                            top: 8,
                            right: 50, // Position next to settings button
                            child: GestureDetector(
                              onTap: _showDeleteConfirmation,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1.5,
                                  ),
                                ),
                                child: _isDeleting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.red,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                              ),
                            ),
                          ),

                          // Page count badge - Only show if multiple images
                          if (urls.length > 1)
                            Positioned(
                              bottom: 8,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Text(
                                  '${_page + 1}/${urls.length}',
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          // Dot indicators - Only show if multiple images
                          if (urls.length > 1)
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  urls.length,
                                  (i) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    width: i == _page ? 14 : 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: i == _page
                                          ? AppTheme.kAccent
                                          : (isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.35,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.35,
                                                  )),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Details ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + hours
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: clubColor.withValues(alpha: 0.2),
                              border: Border.all(color: clubColor, width: 1.8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                color: isDark
                                    ? Colors.white
                                    : AppTheme.kLightText,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    color: isDark
                                        ? Colors.white
                                        : AppTheme.kLightText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.lock_open_outlined,
                                      color: AppTheme.kAccent,
                                      size: 11,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      formatDurationToTimeString(c.openTime),
                                      style: const TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        color: AppTheme.kAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 3,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppTheme.kTextSub
                                            : AppTheme.kLightTextSub,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.lock_outline,
                                      color: AppTheme.kTextSub,
                                      size: 11,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      formatDurationToTimeString(c.closeTime),
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        color: isDark
                                            ? AppTheme.kTextSub
                                            : AppTheme.kLightTextSub,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      Container(
                        height: 1,
                        color: isDark
                            ? AppTheme.kBorder
                            : AppTheme.kLightBorder,
                      ),
                      const SizedBox(height: 6),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            color: AppTheme.kAccent,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              c.location,
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                color: isDark
                                    ? Colors.white70
                                    : AppTheme.kLightTextSub,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Categories + Favorite count + Book button
                      Row(
                        children: [
                          // Categories
                          if (c.categories.isNotEmpty) ...[
                            Icon(
                              Icons.category_outlined,
                              color: AppTheme.kAccent,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                c.categories.map((cat) => cat.name).join(', '),
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: isDark
                                      ? AppTheme.kTextSub
                                      : AppTheme.kLightTextSub,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],

                          const Spacer(),

                          // Favorite count indicator
                          if (c.favoriteCount > 0) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite_rounded,
                                  color: AppTheme.kAccent.withValues(
                                    alpha: 0.7,
                                  ),
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${c.favoriteCount}',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    color: isDark
                                        ? AppTheme.kTextSub
                                        : AppTheme.kLightTextSub,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Book button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => _navigateToAddSlot(c.id!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.kAccent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.kAccent.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Add slot',
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: Color(0xFF0A1828),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (widget.club.imageUrls.length <= 1 || !_ctrl.hasClients) return;
    _ctrl.position.moveTo(_ctrl.offset - (d.primaryDelta ?? 0), clamp: false);
  }

  void _onDragEnd(DragEndDetails d) {
    if (widget.club.imageUrls.length <= 1 || !_ctrl.hasClients) return;
    final v = d.primaryVelocity ?? 0;
    final c = _ctrl.page?.round() ?? 10000;
    if (v < -300) {
      _ctrl.animateToPage(
        c + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else if (v > 300) {
      _ctrl.animateToPage(
        c - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _ctrl.animateToPage(
        c,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget _openCloseBadge(bool isDark) {
    final isOpen = widget.club.isOpen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen
              ? Colors.greenAccent.withValues(alpha: 0.7)
              : Colors.redAccent.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOpen ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            isOpen ? 'open'.tr(context) : 'closed'.tr(context),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: isOpen ? Colors.greenAccent : Colors.redAccent,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
