import 'package:material_ui/material_ui.dart';

import '../../core/constants/constants.dart';

/// Ultra-compact, single-row pagination controls bar.
class PaginatedWidget extends StatelessWidget {
  final bool isLoading;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int>? onPageSelected;
  final VoidCallback? onRefresh;
  final int currentPage;
  final int? totalPages;
  final int? totalCount;
  final int? pageSize;

  const PaginatedWidget({
    super.key,
    required this.isLoading,
    required this.hasPrevious,
    required this.hasNext,
    this.onPrevious,
    this.onNext,
    this.onPageSelected,
    this.onRefresh,
    required this.currentPage,
    this.totalPages,
    this.totalCount,
    this.pageSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final disabledColor = isDark
        ? AppColors.darkBodyTextSecondary.withValues(alpha: 0.4)
        : AppColors.lightBodyTextSecondary.withValues(alpha: 0.4);
    final activeColor = isDark
        ? AppColors.darkBodyText
        : AppColors.lightBodyText;

    final startItem = totalCount != null && pageSize != null
        ? (currentPage * pageSize!) + 1
        : null;
    final endItem = totalCount != null && pageSize != null
        ? ((currentPage + 1) * pageSize!).clamp(0, totalCount!)
        : null;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          // Refresh Button
          if (onRefresh != null)
            _IconButton(
              icon: Icons.refresh_rounded,
              onTap: isLoading ? null : onRefresh,
              color: isLoading ? disabledColor : activeColor,
            )
          else
            const SizedBox(width: 8),

          // Center: Item Range or Single Page Indicator Chips
          Expanded(
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : _PageNumbersRow(
                      currentPage: currentPage,
                      hasNext: hasNext,
                      totalPages: totalPages,
                      onPageSelected: onPageSelected,
                      label: startItem != null && endItem != null
                          ? '$startItem–$endItem of $totalCount'
                          : null,
                    ),
            ),
          ),

          // Previous / Next Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconButton(
                icon: Icons.chevron_left_rounded,
                onTap: hasPrevious && !isLoading ? onPrevious : null,
                color: hasPrevious && !isLoading ? activeColor : disabledColor,
              ),
              const SizedBox(width: 4),
              _IconButton(
                icon: Icons.chevron_right_rounded,
                onTap: hasNext && !isLoading ? onNext : null,
                color: hasNext && !isLoading ? activeColor : disabledColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageNumbersRow extends StatelessWidget {
  final int currentPage;
  final bool hasNext;
  final int? totalPages;
  final ValueChanged<int>? onPageSelected;
  final String? label;

  const _PageNumbersRow({
    required this.currentPage,
    required this.hasNext,
    this.totalPages,
    this.onPageSelected,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (label != null) {
      return Text(
        label!,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final pages = _buildPageList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: pages.map((p) {
          if (p == -1) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '…',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? AppColors.darkBodyTextSecondary
                      : AppColors.lightBodyTextSecondary,
                ),
              ),
            );
          }

          final isCurrent = p == currentPage;
          final primaryColor = isDark
              ? AppColors.darkAppBarForeground
              : AppColors.lightAppBarForeground;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isCurrent || onPageSelected == null
                  ? null
                  : () => onPageSelected!(p),
              child: Container(
                height: 28,
                constraints: const BoxConstraints(minWidth: 28),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCurrent ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${p + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    // color: isCurrent
                    //     ? theme.colorScheme.onPrimary
                    //     : (isDark
                    //           ? AppColors.darkBodyText
                    //           : AppColors.lightBodyText),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<int> _buildPageList() {
    final pages = <int>[];
    final current = currentPage;
    final lastKnown = totalPages ?? (hasNext ? current + 2 : current);

    if (lastKnown <= 0) return [0];

    pages.add(0);
    final effectiveStart = (current - 1).clamp(1, lastKnown);
    final effectiveEnd = (current + 1).clamp(effectiveStart, lastKnown);

    if (effectiveStart > 1) pages.add(-1);
    for (int i = effectiveStart; i <= effectiveEnd; i++) {
      if (!pages.contains(i)) pages.add(i);
    }

    if (totalPages == null && hasNext && effectiveEnd + 1 <= lastKnown) {
      if (!pages.contains(effectiveEnd + 1)) pages.add(effectiveEnd + 1);
    }

    if (totalPages != null && totalPages! > 1) {
      if (!pages.contains(totalPages! - 1)) {
        if (pages.last < totalPages! - 2) pages.add(-1);
        pages.add(totalPages! - 1);
      }
    }

    return pages;
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _IconButton({required this.icon, this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      width: 34,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
