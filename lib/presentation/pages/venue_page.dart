import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:restaurant_finder/presentation/bloc/venue_bloc.dart';
import 'package:restaurant_finder/presentation/bloc/venue_event.dart';
import 'package:restaurant_finder/presentation/state/venue_state.dart';
import 'package:restaurant_finder/presentation/widgets/venue_list.dart';

class VenuePage extends StatelessWidget {
  const VenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Restaurants')),
      body: BlocBuilder<VenueBloc, VenueState>(
        builder: (context, state) {
          return _buildBody(
            context: context,
            state: state,
            onToggleFavourite: (venueId) =>
                context.read<VenueBloc>().add(ToggleFavouriteVenue(venueId)),
          );
        },
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required VenueState state,
    required ValueChanged<String> onToggleFavourite,
  }) {
    if (state.isLoading && state.venues.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.venues.isEmpty) {
      return Center(child: Text(state.errorMessage!));
    }

    if (state.venues.isEmpty) {
      return const Center(child: Text('No venues nearby'));
    }

    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation);

        return ClipRect(
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: VenueList(
        key: ValueKey(state.currentLocation),
        venues: state.venues,
        onToggleFavourite: onToggleFavourite,
      ),
    );
  }
}
