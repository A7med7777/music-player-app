import 'package:equatable/equatable.dart';

class Artist extends Equatable {
  const Artist({
    required this.id,
    required this.name,
    this.artworkUrl,
  });

  final String id;
  final String name;
  final String? artworkUrl;

  @override
  List<Object?> get props => [id, name, artworkUrl];
}
