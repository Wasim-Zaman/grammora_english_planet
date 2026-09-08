import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/scan_attendance/scan_attendance_cubit.dart';
import 'package:gep/cubits/scan_attendance/scan_attendance_state.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanAttendanceScreen extends StatelessWidget {
  const ScanAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanAttendanceCubit(),
      child: const _ScanAttendanceView(),
    );
  }
}

class _ScanAttendanceView extends StatelessWidget {
  const _ScanAttendanceView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return AppScaffold(
      title: 'Mark Attendance',
      body: BlocBuilder<ScanAttendanceCubit, ScanAttendanceState>(
        builder: (context, state) {
          final cubit = context.read<ScanAttendanceCubit>();

          return Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: MobileScanner(
                      controller: MobileScannerController(
                        detectionSpeed: DetectionSpeed.normal,
                        facing: CameraFacing.back,
                        torchEnabled: false,
                      ),
                      onDetect: (capture) {
                        final barcode = capture.barcodes.firstOrNull;
                        if (barcode?.rawValue != null) {
                          cubit.onDetect(barcode!.rawValue!);
                        }
                      },
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(AppConstants.defaultPadding),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: state.isSuccess
                      ? AppColors.success.withValues(alpha: 0.1)
                      : cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: state.isSuccess ? AppColors.success : borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.isSuccess
                          ? Icons.check_circle_rounded
                          : state.isProcessing
                              ? Icons.hourglass_top_rounded
                              : Icons.info_outline_rounded,
                      color: state.isSuccess
                          ? AppColors.success
                          : state.isProcessing
                              ? AppColors.accent
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: state.isSuccess ? AppColors.success : null,
                        ),
                      ),
                    ),
                    if (state.isSuccess || state.message.contains('Error'))
                      TextButton(
                        onPressed: cubit.reset,
                        child: const Text('Scan Again'),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
