import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_player_app/core/theme/app_tokens.dart';
import 'package:music_player_app/features/library/domain/repositories/library_repository.dart';
import 'package:music_player_app/features/library/presentation/viewmodels/library_viewmodel.dart';
import 'package:music_player_app/features/library/presentation/widgets/track_row.dart';
import 'package:music_player_app/shared/widgets/empty_state.dart';
import 'package:music_player_app/shared/widgets/error_state.dart';
import 'package:music_player_app/shared/widgets/offline_indicator.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          actions: [
            Consumer<LibraryViewModel>(
              builder: (_, vm, __) => PopupMenuButton<TrackSort>(
                onSelected: vm.changeSort,
                icon: const Icon(Icons.sort),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: TrackSort.title,
                    child: Text('By title'),
                  ),
                  PopupMenuItem(
                    value: TrackSort.artist,
                    child: Text('By artist'),
                  ),
                  PopupMenuItem(
                    value: TrackSort.album,
                    child: Text('By album'),
                  ),
                  PopupMenuItem(
                    value: TrackSort.recentlyAdded,
                    child: Text('Recently added'),
                  ),
                ],
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Songs'),
              Tab(text: 'Albums'),
              Tab(text: 'Artists'),
            ],
          ),
        ),
        body: Column(
          children: [
            const OfflineIndicator(message: 'You are offline. Showing cached library.'),
            Expanded(
              child: TabBarView(
                children: [
                  _SongsTab(),
                  _AlbumsTab(),
                  _ArtistsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SongsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryViewModel>(
      builder: (_, vm, __) {
        if (vm.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.failure != null) {
          return ErrorState(
            message: 'Could not load songs',
            onRetry: () => vm.changeSort(vm.sort),
          );
        }
        if (vm.tracks.isEmpty) {
          return const EmptyState(
            icon: Icons.music_off,
            message: 'No songs yet',
          );
        }
        return ListView.builder(
          itemCount: vm.tracks.length,
          itemBuilder: (_, i) => TrackRow(
            track: vm.tracks[i],
            onTap: () => vm.playTrack(vm.tracks[i].id, indexInList: i),
          ),
        );
      },
    );
  }
}

class _AlbumsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Consumer<LibraryViewModel>(
      builder: (_, vm, __) {
        if (vm.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.albums.isEmpty) {
          return const EmptyState(
            icon: Icons.album_outlined,
            message: 'No albums yet',
          );
        }
        return GridView.builder(
          padding: EdgeInsets.all(tokens.spacing8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
          ),
          itemCount: vm.albums.length,
          itemBuilder: (_, i) {
            final album = vm.albums[i];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: album.artworkUrl != null
                          ? Image.network(album.artworkUrl!, fit: BoxFit.cover)
                          : Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.album, size: 48),
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(tokens.spacing8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          Text(
                            album.primaryArtistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ArtistsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Consumer<LibraryViewModel>(
      builder: (_, vm, __) {
        if (vm.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.artists.isEmpty) {
          return const EmptyState(
            icon: Icons.people_outline,
            message: 'No artists yet',
          );
        }
        return ListView.builder(
          itemCount: vm.artists.length,
          itemBuilder: (_, i) {
            final artist = vm.artists[i];
            return ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: tokens.spacing16,
                vertical: tokens.spacing4,
              ),
              leading: CircleAvatar(
                backgroundImage: artist.artworkUrl != null
                    ? NetworkImage(artist.artworkUrl!)
                    : null,
                child: artist.artworkUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(artist.name),
              onTap: () {},
            );
          },
        );
      },
    );
  }
}
