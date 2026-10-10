import 'package:equatable/equatable.dart';

enum SplashDestination { checking, unauthenticated, needsArtistSelection, authenticated }

class SplashState extends Equatable {
  const SplashState({this.destination = SplashDestination.checking});

  final SplashDestination destination;

  @override
  List<Object?> get props => [destination];
}
