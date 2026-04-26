import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_player_app/features/favorites/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:music_player_app/features/library/presentation/widgets/track_row.dart';
import 'package:music_player_app/shared/widgets/empty_state.dart';
import 'package:music_player_app/shared/widgets/error_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          Consumer<FavoritesViewModel>(
            builder: (_, vm, __) {
              if (vm.tracks.isEmpty) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'play_all') vm.playAll();
                  if (v == 'shuffle') vm.playAll(shuffle: true);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'play_all', child: Text('Play all')),
                  PopupMenuItem(value: 'shuffle', child: Text('Shuffle all')),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoritesViewModel>(
        builder: (context, vm, _) {
          if (vm.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.failure != null) {
            return const ErrorState(message: 'Could not load favorites');
          }
          if (vm.tracks.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_outline,
              message: 'No liked songs yet.\nTap ♡ on any track to like it.',
            );
          }
          return ListView.builder(
            itemCount: vm.tracks.length,
            itemBuilder: (_, i) => TrackRow(
              track: vm.tracks[i],
              onTap: () => vm.playAll(),
            ),
          );
        },
      ),
    );
  }
}
