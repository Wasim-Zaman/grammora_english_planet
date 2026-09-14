import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/constants.dart';
import '../../cubits/announcement_strip/announcement_strip_cubit.dart';
import '../../cubits/announcement_strip/announcement_strip_state.dart';
import '../../models/updates.dart';
import '../../router/app_navigation.dart';
import '../../router/app_routes.dart';

class AnnouncementStrip extends StatelessWidget {
  const AnnouncementStrip({super.key});

  static String _typeLabel(UpdateType type) {
    return switch (type) {
      UpdateType.newCourse => 'COURSE',
      UpdateType.event => 'EVENT',
      UpdateType.resourceUpdate => 'UPDATE',
    };
  }

  static IconData _typeIcon(UpdateType type) {
    return switch (type) {
      UpdateType.newCourse => Icons.school_rounded,
      UpdateType.event => Icons.event_rounded,
      UpdateType.resourceUpdate => Icons.update_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnnouncementStripCubit(),
      child: const _AnnouncementStripContent(),
    );
  }
}

class _AnnouncementStripContent extends StatelessWidget {
  const _AnnouncementStripContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AnnouncementStripCubit, AnnouncementStripState>(
      builder: (context, state) {
        final current = state.currentUpdate;
        if (current == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => AppNavigation.push(context, AppRoutes.kUpdatesRoute),
          child: Container(
            height: 40,
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 650),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final isIncoming = child.key == ValueKey(current.title);

                  final slideTween = Tween<Offset>(
                    begin: isIncoming ? const Offset(0.35, 0) : Offset.zero,
                    end: isIncoming ? Offset.zero : const Offset(-0.35, 0),
                  );

                  final fadeTween = isIncoming
                      ? Tween<double>(begin: 0, end: 1)
                      : Tween<double>(begin: 1, end: 0);

                  return ClipRect(
                    child: SlideTransition(
                      position: slideTween.animate(animation),
                      child: FadeTransition(
                        opacity: fadeTween.animate(animation),
                        child: child,
                      ),
                    ),
                  );
                },
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [...previousChildren, ?currentChild],
                  );
                },
                child: Row(
                  key: ValueKey(current.title),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkNeutral
                            : AppColors.lightNeutral,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AnnouncementStrip._typeIcon(current.type),
                            size: 12,
                            color: isDark
                                ? AppColors.accent
                                : AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AnnouncementStrip._typeLabel(current.type),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: isDark
                                  ? AppColors.accent
                                  : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MarqueeText(
                        text: current.title,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkBodyText
                              : AppColors.lightBodyText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: isDark
                          ? AppColors.darkBodyTextSecondary
                          : AppColors.lightBodyTextSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms);
      },
    );
  }
}

class _MarqueeText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const _MarqueeText({required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MarqueeCubit(),
      child: _MarqueeTextView(text: text, style: style),
    );
  }
}

class _MarqueeTextView extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const _MarqueeTextView({required this.text, this.style});

  @override
  State<_MarqueeTextView> createState() => _MarqueeTextViewState();
}

class _MarqueeTextViewState extends State<_MarqueeTextView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant _MarqueeTextView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _controller.stop();
      _controller.reset();
      if (mounted) {
        context.read<MarqueeCubit>().updateMeasurement(
              needsScroll: false,
              textWidth: 0,
            );
        WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
      }
    }
  }

  void _measure() {
    if (!mounted) return;

    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    final textWidth = tp.width;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final maxWidth = box.size.width;

    final needs = textWidth > maxWidth;
    context.read<MarqueeCubit>().updateMeasurement(
          needsScroll: needs,
          textWidth: textWidth,
        );

    if (needs) {
      const gap = 48.0;
      final durationMs = ((textWidth + gap) * 18).toInt().clamp(4000, 12000);
      _controller.duration = Duration(milliseconds: durationMs);
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarqueeCubit, MarqueeState>(
      builder: (context, marqueeState) {
        if (!marqueeState.needsScroll) {
          return Text(widget.text, style: widget.style, maxLines: 1);
        }

        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              const gap = 48.0;
              final offset = (marqueeState.textWidth + gap) * _controller.value;
              return Transform.translate(
                offset: Offset(-offset, 0),
                child: child,
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.text, style: widget.style, maxLines: 1),
                const SizedBox(width: 48),
                Text(widget.text, style: widget.style, maxLines: 1),
              ],
            ),
          ),
        );
      },
    );
  }
}
