import 'package:equatable/equatable.dart';
import 'package:gep/models/updates.dart';

class AnnouncementStripState extends Equatable {
  final int currentIndex;
  final List<Updates> updates;

  const AnnouncementStripState({
    this.currentIndex = 0,
    this.updates = const [],
  });

  AnnouncementStripState copyWith({
    int? currentIndex,
    List<Updates>? updates,
  }) {
    return AnnouncementStripState(
      currentIndex: currentIndex ?? this.currentIndex,
      updates: updates ?? this.updates,
    );
  }

  Updates? get currentUpdate =>
      updates.isNotEmpty && currentIndex < updates.length
          ? updates[currentIndex]
          : null;

  @override
  List<Object?> get props => [currentIndex, updates];
}

class MarqueeState extends Equatable {
  final bool needsScroll;
  final double textWidth;

  const MarqueeState({
    this.needsScroll = false,
    this.textWidth = 0,
  });

  @override
  List<Object?> get props => [needsScroll, textWidth];
}
