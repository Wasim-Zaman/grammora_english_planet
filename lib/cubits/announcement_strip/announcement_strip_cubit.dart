import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/services/updates/updates_services.dart';
import 'announcement_strip_state.dart';

class AnnouncementStripCubit extends Cubit<AnnouncementStripState> {
  final UpdatesServices _updatesServices;
  StreamSubscription? _subscription;
  Timer? _timer;

  AnnouncementStripCubit({UpdatesServices? updatesServices})
      : _updatesServices = updatesServices ?? UpdatesServices(),
        super(const AnnouncementStripState()) {
    _init();
  }

  void _init() {
    _subscription = _updatesServices.getUpdatesStream().listen((updates) {
      final newIndex = state.currentIndex >= updates.length ? 0 : state.currentIndex;
      emit(state.copyWith(updates: updates, currentIndex: newIndex));
      _startCycling(updates.length);
    });
  }

  void _startCycling(int itemCount) {
    _timer?.cancel();
    if (itemCount <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (state.updates.isEmpty) return;
      emit(state.copyWith(
        currentIndex: (state.currentIndex + 1) % state.updates.length,
      ));
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _subscription?.cancel();
    return super.close();
  }
}

class MarqueeCubit extends Cubit<MarqueeState> {
  MarqueeCubit() : super(const MarqueeState());

  void updateMeasurement({
    required bool needsScroll,
    required double textWidth,
  }) {
    if (state.needsScroll != needsScroll || state.textWidth != textWidth) {
      emit(MarqueeState(needsScroll: needsScroll, textWidth: textWidth));
    }
  }
}
