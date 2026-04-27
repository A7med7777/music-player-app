import 'package:equatable/equatable.dart';

class Playlist extends Equatable {
  const Playlist({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.trackIds,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerUid;
  final String name;
  final List<String> trackIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get trackCount => trackIds.length;

  Playlist copyWith({
    String? id,
    String? ownerUid,
    String? name,
    List<String>? trackIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Playlist(
    id: id ?? this.id,
    ownerUid: ownerUid ?? this.ownerUid,
    name: name ?? this.name,
    trackIds: trackIds ?? this.trackIds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    ownerUid,
    name,
    trackIds,
    createdAt,
    updatedAt,
  ];
}
