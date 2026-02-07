import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/venue_state.dart';
import '../viewmodels/venue_view_model.dart';

export 'dependencies.dart';

final venueViewModelProvider =
    NotifierProvider<VenueViewModel, VenueState>(VenueViewModel.new);
