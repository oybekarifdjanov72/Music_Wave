import 'package:flutter_bloc/flutter_bloc.dart';

/// Trivial cubit holding which of the 4 bottom-nav tabs is active. Kept
/// separate from each screen's own cubit so switching tabs never resets
/// Home/Search/Playlists/Profile state (they all live in an IndexedStack).
class NavCubit extends Cubit<int> {
  NavCubit() : super(0);

  void changeTab(int index) => emit(index);
}
