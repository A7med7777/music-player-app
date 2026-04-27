import 'package:equatable/equatable.dart';

class LikedTrack extends Equatable {
  const LikedTrack({
    required this.trackId,
    required this.likedAt,
  });

  final String trackId;
  final DateTime likedAt;

  @override
  List<Object> get props => [trackId, likedAt];
}
