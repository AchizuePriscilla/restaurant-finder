import 'package:flutter/material.dart';

import '../../domain/entities/venue.dart';

class VenueCard extends StatelessWidget {
  const VenueCard({
    super.key,
    required this.venue,
    required this.onToggleFavourite,
  });

  final Venue venue;
  final ValueChanged<String> onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VenueImage(imageUrl: venue.imageUrl, name: venue.name),
          ListTile(
            title: Text(
              venue.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              venue.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              onPressed: () => onToggleFavourite(venue.id),
              icon: Icon(
                venue.isFavourite ? Icons.favorite : Icons.favorite_border,
                color: venue.isFavourite ? Colors.red : null,
              ),
              tooltip: venue.isFavourite ? 'Remove favourite' : 'Add favourite',
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueImage extends StatelessWidget {
  const _VenueImage({
    required this.imageUrl,
    required this.name,
  });

  final String imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _PlaceholderImage(name: name);
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _PlaceholderImage(name: name),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(
          Icons.restaurant,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          semanticLabel: name,
        ),
      ),
    );
  }
}
