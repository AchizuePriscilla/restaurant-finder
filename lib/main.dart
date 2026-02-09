import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'di/app_di.dart';
import 'presentation/bloc/venue_bloc.dart';
import 'presentation/pages/venue_page.dart';
import 'presentation/bloc/venue_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  final di = AppDi.create(sharedPreferences: sharedPreferences);

  runApp(MainApp(di: di));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.di});

  final AppDi di;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void dispose() {
    widget.di.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              VenueBloc(
                locationProvider: widget.di.locationProvider,
                getVenuesForLocation: widget.di.getVenuesForLocation,
                applyFavouritesToVenues: widget.di.applyFavouritesToVenues,
                toggleFavouriteUseCase: widget.di.toggleFavourite,
              )..add(const LocationObservingStarted()),
        ),
      ],
      child: const MaterialApp(home: VenuePage()),
    );
  }
}
