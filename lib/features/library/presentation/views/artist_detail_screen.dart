import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:music_player_app/features/library/domain/entities/album.dart';
import 'package:music_player_app/features/library/domain/entities/artist.dart';
import 'package:music_player_app/features/library/presentation/viewmodels/library_viewmodel.dart';
import 'package:provider/provider.dart';

class ArtistDetailScreen extends StatelessWidget {
  const ArtistDetailScreen({super.key, required this.artist});
  final Artist artist;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<LibraryViewModel>();
    final albums = vm.albums
        .where((a) => a.primaryArtistId == artist.id)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(artist.name),
              background: artist.artworkUrl != null
                  ? Image.network(artist.artworkUrl!, fit: BoxFit.cover)
                  : Container(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: const Icon(Icons.person, size: 80),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Albums',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          if (albums.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No albums')),
            )
          else
            SliverList.builder(
              itemCount: albums.length,
              itemBuilder: (_, i) {
                final album = albums[i];
                return _AlbumTile(album: album);
              },
            ),
        ],
      ),
    );
  }
}

class _AlbumTile extends StatelessWidget {
  const _AlbumTile({required this.album});
  final Album album;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: album.artworkUrl != null
            ? Image.network(
                album.artworkUrl!,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              )
            : Container(
                width: 52,
                height: 52,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.album),
              ),
      ),
      title: Text(album.title),
      subtitle: Text(
        album.releaseYear != null
            ? '${album.releaseYear}  •  ${album.trackCount} songs'
            : '${album.trackCount} songs',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/library/album/${album.id}', extra: album),
    );
  }
}
