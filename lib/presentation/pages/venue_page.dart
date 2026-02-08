import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../state/venue_state.dart';
import '../widgets/venue_list.dart';

class VenuePage extends ConsumerWidget {
  const VenuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(venueViewModelProvider);
    final viewModel = ref.read(venueViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Restaurants'),
      ),
      body: _buildBody(
        context: context,
        state: state,
        onToggleFavourite: viewModel.toggleFavourite,
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required VenueState state,
    required ValueChanged<String> onToggleFavourite,
  }) {
    if (state.isLoading && state.venues.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null && state.venues.isEmpty) {
      return Center(
        child: Text(state.errorMessage!),
      );
    }

    if (state.venues.isEmpty) {
      return const Center(
        child: Text('No venues nearby'),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: VenueList(
        key: ValueKey(state.currentLocation),
        venues: state.venues,
        onToggleFavourite: onToggleFavourite,
      ),
    );
  }
}
