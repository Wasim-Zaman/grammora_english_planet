import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../cubits/qr_attendance/qr_attendance_cubit.dart';
import '../../../../../models/shift/shift.dart';
import '../../../../../services/attendance/attendance_service.dart';
import '../../../../../services/shifts/shifts_service.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_outlined_button.dart';
import '../../../../widgets/app_scaffold.dart';

class QrAttendanceScreen extends StatelessWidget {
  const QrAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          QrAttendanceCubit(ShiftsService(), AttendanceService())..loadShifts(),
      child: const _QrAttendanceView(),
    );
  }
}

class _QrAttendanceView extends StatelessWidget {
  const _QrAttendanceView();

  Future<void> _shareToken(Shift? shift, DateTime date, String token) async {
    final dateFormatted = DateFormat('yyyy-MM-dd').format(date);
    final textContent =
        'Attendance Pass\n'
        'Shift: ${shift?.name ?? 'N/A'}\n'
        'Date: $dateFormatted\n'
        'Code: $token';

    await SharePlus.instance.share(
      ShareParams(text: textContent, subject: 'Attendance Pass'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final secondaryTextColor = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return AppScaffold(
      title: 'Attendance QR',
      body: BlocConsumer<QrAttendanceCubit, QrAttendanceState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<QrAttendanceCubit>();
          final dateFormatted = DateFormat(
            'EEE, MMM d, yyyy',
          ).format(state.selectedDate);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: 16,
            ),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Configuration Card
                Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shift Selection
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                color: secondaryTextColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SELECT SHIFT',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkNeutral
                                  : AppColors.lightNeutral,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Shift>(
                                value: state.selectedShift,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                ),
                                hint: const Text('Select Shift'),
                                onChanged: (val) {
                                  if (val != null) cubit.setShift(val);
                                },
                                items: state.shifts.map((shift) {
                                  return DropdownMenuItem<Shift>(
                                    value: shift,
                                    child: Text(
                                      shift.name,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Date Selection
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                color: secondaryTextColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SELECT DATE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: state.selectedDate,
                                firstDate: DateTime(DateTime.now().year - 1),
                                lastDate: DateTime(DateTime.now().year + 5),
                              );
                              if (picked != null) {
                                cubit.setDate(picked);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkNeutral
                                    : AppColors.lightNeutral,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateFormatted,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    Icons.edit_calendar_rounded,
                                    size: 18,
                                    color: secondaryTextColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.04, end: 0),

                const SizedBox(height: 16),

                // Generate Pass Action
                AppButton(
                  label: state.isGenerating
                      ? 'Generating Code…'
                      : 'Generate Pass',
                  icon: state.isGenerating
                      ? null
                      : const Icon(Icons.qr_code_2_rounded),
                  onPressed: state.isGenerating || state.selectedShift == null
                      ? null
                      : () => cubit.generateQr(),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.04, end: 0),

                const SizedBox(height: 24),

                // Digital Pass Card
                if (state.qrToken != null)
                  Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.35 : 0.06,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Accent Header Strip
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  // Pass Header Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white10
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          size: 14,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'PASS ACTIVE',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                letterSpacing: 1.1,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Clean Dot-Matrix QR View
                                  QrImageView(
                                    data: state.qrToken!,
                                    size: 210,
                                    version: QrVersions.auto,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.circle,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.95)
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Ticket Perforated Line
                                  Row(
                                    children: List.generate(
                                      22,
                                      (index) => Expanded(
                                        child: Container(
                                          height: 1.5,
                                          color: index % 2 == 0
                                              ? borderColor
                                              : Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Pass Details Summary
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildDetailTile(
                                          theme,
                                          secondaryTextColor,
                                          'SHIFT',
                                          state.selectedShift?.name ?? '-',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildDetailTile(
                                          theme,
                                          secondaryTextColor,
                                          'DATE',
                                          DateFormat(
                                            'MMM dd, yyyy',
                                          ).format(state.selectedDate),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Outlined Share Button
                                  AppOutlinedButton(
                                    label: 'Share Pass Token',
                                    icon: const Icon(Icons.share_outlined),
                                    expanded: false,
                                    onPressed: () => _shareToken(
                                      state.selectedShift,
                                      state.selectedDate,
                                      state.qrToken!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.04, end: 0),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailTile(
    ThemeData theme,
    Color secondaryTextColor,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: secondaryTextColor,
            letterSpacing: 1.1,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}
