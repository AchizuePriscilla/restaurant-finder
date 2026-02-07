import 'package:equatable/equatable.dart';

class Venue extends Equatable {
  const Venue({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.isFavourite,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final bool isFavourite;

  Venue copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    bool? isFavourite,
  }) {
    return Venue(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  @override
  List<Object?> get props => [id, name, description, imageUrl, isFavourite];
}
