import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../models/student_spotlight.dart';
import '../../../../../router/app_navigation.dart';
import '../../../../../router/app_routes.dart';
import '../../../../widgets/cached_image_widget.dart';

class SpotlightStoryViewerScreen extends StatefulWidget {
  final List<StudentSpotlightModel> spotlights;
  final int initialIndex;

  const SpotlightStoryViewerScreen({
    super.key,
    required this.spotlights,
    this.initialIndex = 0,
  });

  static Route<void> route({
    required List<StudentSpotlightModel> spotlights,
    int initialIndex = 0,
  }) {
    return PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      pageBuilder: (context, _, _) => SpotlightStoryViewerScreen(
        spotlights: spotlights,
        initialIndex: initialIndex,
      ),
      transitionsBuilder: (context, anim, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  @override
  State<SpotlightStoryViewerScreen> createState() =>
      _SpotlightStoryViewerScreenState();
}

class _SpotlightStoryViewerScreenState extends State<SpotlightStoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animController;
  bool _isPaused = false;
  double _dragOffsetY = 0.0;

  static const Duration _storyDuration = Duration(milliseconds: 5500);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.spotlights.length - 1);
    _animController = AnimationController(
      vsync: this,
      duration: _storyDuration,
    );
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextStory() {
    if (_currentIndex < widget.spotlights.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _animController.reset();
      _animController.forward();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStory() {
    if (_animController.value > 0.25) {
      _animController.reset();
      _animController.forward();
    } else if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _animController.reset();
      _animController.forward();
    } else {
      _animController.reset();
      _animController.forward();
    }
  }

  void _pause() {
    if (!_isPaused) {
      _animController.stop();
      setState(() {
        _isPaused = true;
      });
    }
  }

  void _resume() {
    if (_isPaused) {
      _animController.forward();
      setState(() {
        _isPaused = false;
      });
    }
  }

  void _shareCurrentStudent(StudentSpotlightModel student) {
    _pause();
    final text = '🌟 Congratulations to ${student.studentName}!\n'
        'Honored as ${student.awardTitle} (${student.period}) at Gramora English Planet.\n'
        '${student.quoteOrMessage.isNotEmpty ? '"${student.quoteOrMessage}"\n' : ''}'
        'Keep shining and inspiring excellence! 🏆';
    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.spotlights[_currentIndex];
    final isYear = student.awardTitle.toLowerCase().contains('year');
    final accent = isYear ? AppColors.accent : AppColors.secondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0 || _dragOffsetY > 0) {
            _pause();
            setState(() {
              _dragOffsetY += details.delta.dy;
            });
          }
        },
        onVerticalDragEnd: (details) {
          if (_dragOffsetY > 110 || (details.primaryVelocity ?? 0) > 600) {
            Navigator.of(context).pop();
          } else {
            setState(() {
              _dragOffsetY = 0;
            });
            _resume();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(0, _dragOffsetY, 0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Blurry ambient backdrop
              Positioned.fill(
                child: CachedImageWidget(
                  imageUrl: student.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.black.withValues(alpha: 0.65),
                          Colors.black.withValues(alpha: 0.92),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Main story contents
              SafeArea(
                child: Column(
                  children: [
                    // Segmented progress bars
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: List.generate(
                          widget.spotlights.length,
                          (index) => Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: _buildProgressBar(index),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Top Bar (Avatar, Name, Badge, Close button)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: accent, width: 1.8),
                            ),
                            child: ClipOval(
                              child: CachedImageWidget(
                                imageUrl: student.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        student.studentName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      isYear ? Iconsax.cup : Iconsax.award,
                                      size: 13,
                                      color: accent,
                                    ),
                                  ],
                                ),
                                Text(
                                  '${student.awardTitle} • ${student.period}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: accent.withValues(alpha: 0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Story Central Content & Gestures
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Central Content Area
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // High-res portrait frame
                                Expanded(
                                  flex: 7,
                                  child: Center(
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxHeight: 330,
                                        maxWidth: 300,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: accent.withValues(alpha: 0.7),
                                          width: 2.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accent.withValues(alpha: 0.35),
                                            blurRadius: 24,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(22),
                                        child: CachedImageWidget(
                                          imageUrl: student.imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Glassmorphic Quote & Details Card
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.15),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.3),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Course/Batch badge
                                      if (student.courseOrBatch.isNotEmpty)
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: accent.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: accent.withValues(
                                                alpha: 0.4,
                                              ),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Iconsax.teacher,
                                                size: 13,
                                                color: accent,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                student.courseOrBatch,
                                                style: TextStyle(
                                                  color: accent,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      // Inspiring quote or message
                                      if (student.quoteOrMessage.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          child: Text(
                                            '"${student.quoteOrMessage}"',
                                            textAlign: TextAlign.center,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontStyle: FontStyle.italic,
                                              fontSize: 13.5,
                                              height: 1.35,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),

                                      // Achievement Highlights
                                      if (student.achievementHighlights
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.star_rounded,
                                              size: 14,
                                              color: AppColors.accent,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                student.achievementHighlights,
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.85),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Left tap (Previous) & Right tap (Next) & Press to Pause overlay
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: _previousStory,
                                  onLongPressStart: (_) => _pause(),
                                  onLongPressEnd: (_) => _resume(),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: _nextStory,
                                  onLongPressStart: (_) => _pause(),
                                  onLongPressEnd: (_) => _resume(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bottom Action Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _shareCurrentStudent(student),
                              icon: const Icon(Icons.share_outlined, size: 16),
                              label: const Text(
                                'Share Achievement',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: isYear
                                    ? AppColors.primary
                                    : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.of(context).pop();
                              AppNavigation.push(
                                context,
                                AppRoutes.kStudentSpotlightRoute,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Iconsax.cup,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Hall of Fame',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(int index) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (index < _currentIndex) {
            return Container(
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          } else if (index == _currentIndex) {
            return AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: constraints.maxWidth * _animController.value,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
