import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/models/track_model.dart';
import '../../../core/repositories/music_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/toast_util.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/track_tile.dart';
import '../cubit/playlists_cubit.dart';

/// Search-and-add sheet opened from inside a playlist detail screen.
class AddSongsToPlaylistSheet extends StatefulWidget {
  const AddSongsToPlaylistSheet({super.key, required this.playlistId, required this.playlistName});

  final String playlistId;
  final String playlistName;

  static Future<void> show(BuildContext context, {required String playlistId, required String playlistName}) {
    final cubit = context.read<PlaylistsCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: AddSongsToPlaylistSheet(playlistId: playlistId, playlistName: playlistName),
      ),
    );
  }

  @override
  State<AddSongsToPlaylistSheet> createState() => _AddSongsToPlaylistSheetState();
}

class _AddSongsToPlaylistSheetState extends State<AddSongsToPlaylistSheet> {
  final MusicRepository _repository = getIt<MusicRepository>();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  List<Track> _results = const [];
  bool _loading = false;
  String? _error;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInitialTracks();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadInitialTracks() async {
    setState(() => _loading = true);
    final result = await _repository.getChartTracks(limit: 20);
    if (!mounted) return;
    result.when(
      success: (tracks) => setState(() {
        _results = tracks;
        _loading = false;
      }),
      failure: (_) => setState(() => _loading = false),
    );
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(value));
  }

  Future<void> _search(String raw) async {
    final query = raw.trim();
    if (query.isEmpty) {
      _loadInitialTracks();
      return;
    }
    if (query == _lastQuery) return;

    setState(() {
      _loading = true;
      _error = null;
      _lastQuery = query;
    });

    final result = await _repository.searchTracks(query: query, limit: 20);
    if (!mounted || query != _lastQuery) return;

    result.when(
      success: (page) => setState(() {
        _results = page.items;
        _loading = false;
      }),
      failure: (failure) => setState(() {
        _error = failure.message;
        _loading = false;
      }),
    );
  }

  Future<void> _addTrack(Track track) async {
    final cubit = context.read<PlaylistsCubit>();
    final playlist = cubit.state.findById(widget.playlistId);
    if (playlist != null && playlist.containsTrack(track.id)) {
      ToastUtil.info(context, 'Already in ${widget.playlistName}');
      return;
    }
    await cubit.addTrack(widget.playlistId, track);
    if (!mounted) return;
    ToastUtil.success(context, 'Added to ${widget.playlistName}');
    setState(() {}); // Refresh list check states
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.78,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add songs to ${widget.playlistName}', style: AppTextStyles.sectionTitle),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: false,
                onChanged: _onQueryChanged,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Search songs or pick from chart below',
                  hintStyle: AppTextStyles.bodyMuted,
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.cyanAccent),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const AppLoader()
                  : _error != null
                      ? ErrorView(message: _error!, onRetry: () => _search(_controller.text))
                      : _results.isEmpty
                          ? EmptyView(
                              message: _controller.text.trim().isEmpty
                                  ? 'Search for a song to add'
                                  : 'No songs found',
                              icon: Icons.search_rounded,
                            )
                          : ListView.builder(
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final track = _results[index];
                                return TrackTile(
                                  track: track,
                                  onTap: () => _addTrack(track),
                                  onMore: () => _addTrack(track),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
