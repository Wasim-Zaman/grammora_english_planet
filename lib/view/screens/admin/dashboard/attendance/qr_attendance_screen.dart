import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/models/shift/shift.dart';
import 'package:gep/services/attendance/attendance_service.dart';
import 'package:gep/services/shifts/shifts_service.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QrAttendanceScreen extends StatefulWidget {
  const QrAttendanceScreen({super.key});

  @override
  State<QrAttendanceScreen> createState() => _QrAttendanceScreenState();
}

class _QrAttendanceScreenState extends State<QrAttendanceScreen> {
  final GlobalKey _qrKey = GlobalKey();
  List<Shift> _shifts = [];
  Shift? _selectedShift;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _qrToken;

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  Future<void> _loadShifts() async {
    final shifts = await ShiftsService().getAllShifts();
    setState(() {
      _shifts = shifts;
      if (shifts.isNotEmpty) _selectedShift = shifts.first;
    });
  }

  Future<void> _generateQr() async {
    if (_selectedShift == null) return;
    setState(() => _isLoading = true);
    try {
      final qr = await AttendanceService().generateQrCode(
        _selectedShift!.id,
        _selectedDate,
      );
      setState(() {
        _qrToken = qr.token;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _shareQr() async {
    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/qr_attendance.png');
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text:
              'Attendance QR for ${_selectedShift?.name} on ${_selectedDate.toString().split(" ").first}',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return AppScaffold(
      title: 'Attendance QR',
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Shift Selector
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Shift',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _shifts.map((shift) {
                    final selected = _selectedShift?.id == shift.id;
                    return ChoiceChip(
                      label: Text(shift.name),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedShift = shift),
                      selectedColor: AppColors.accent.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: selected ? AppColors.accent : null,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Date Selector
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: ListTile(
              leading: Icon(Icons.calendar_today_rounded,
                  color: theme.colorScheme.primary),
              title: const Text('Date'),
              subtitle: Text(
                _selectedDate.toString().split(' ').first,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(DateTime.now().year),
                  lastDate: DateTime(DateTime.now().year + 5, 12, 31),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          AppButton(
            label: _isLoading ? 'Generating…' : 'Generate QR Code',
            icon: const Icon(Icons.qr_code_rounded),
            onPressed: _isLoading || _selectedShift == null
                ? null
                : _generateQr,
          ),
          const SizedBox(height: 24),

          if (_qrToken != null) ...[
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    RepaintBoundary(
                      key: _qrKey,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            QrImageView(
                              data: _qrToken!,
                              size: 220,
                              version: QrVersions.auto,
                              gapless: true,
                              embeddedImage: const AssetImage(
                                'assets/icons/splash_logo.png',
                              ),
                              embeddedImageStyle: const QrEmbeddedImageStyle(
                                size: Size(48, 48),
                              ),
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Colors.black,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedShift?.name ?? '',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              _selectedDate.toString().split(' ').first,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Share QR',
                      icon: const Icon(Icons.share_rounded),
                      expanded: false,
                      onPressed: _shareQr,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
