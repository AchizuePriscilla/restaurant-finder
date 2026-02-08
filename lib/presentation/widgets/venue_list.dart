import 'package:flutter/material.dart';

import '../../domain/entities/venue.dart';
import 'venue_card.dart';

class VenueList extends StatelessWidget {
  const VenueList({
    super.key,
    required this.venues,
    required this.onToggleFavourite,
  });

  final List<Venue> venues;
  final ValueChanged<String> onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: venues.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final venue = venues[index];
        return VenueCard(
          venue: venue,
          onToggleFavourite: onToggleFavourite,
        );
      },
    );
  }
}
