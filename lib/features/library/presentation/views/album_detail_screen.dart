import 'package:flutter/material.dart';
import 'package:music_player_app/core/di/injection.dart';
import 'package:music_player_app/features/library/domain/entities/album.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';
import 'package:music_player_app/features/library/domain/repositories/library_repository.dart';
import 'package:music_player_app/features/now_playing/domain/repositories/playback_repository.dart';

class AlbumDetailScreen extends StatefulWidget {
  const AlbumDetailScreen({super.key, required this.album});
  final Album album;

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  late Future<List<Track>> _tracksFuture;

  @override
  void initState() {
    super.initState();
    _tracksFuture = sl<LibraryRepository>()
        .getTracksOfAlbum(widget.album.id)
        .then((r) => r.fold((_) => <Track>[], (t) => t));
  }

  Future<void> _play(List<Track> tracks, int index) async {
    if (tracks.isEmpty) return;
    await sl<PlaybackRepository>().playTrack(
      tracks[index].id,
      queue: tracks.map((t) => t.id).toList(),
      startIndex: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    final album = widget.album;
    return Scaffold(
      body: FutureBuilder<List<Track>>(
        future: _tracksFuture,
        builder: (context, snap) {
          final tracks = snap.data ?? [];
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(album.title),
                  background: album.artworkUrl != null
                      ? Image.network(album.artworkUrl!, fit: BoxFit.cover)
                      : Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Icon(Icons.album, size: 80),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              album.primaryArtistName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (album.releaseYear != null)
                              Text(
                                '${album.releaseYear}  •  ${album.trackCount} songs',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      if (tracks.isNotEmpty)
                        FilledButton.icon(
                          onPressed: () => _play(tracks, 0),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play'),
                        ),
                    ],
                  ),
                ),
              ),
              if (snap.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (tracks.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No tracks')),
                )
              else
                SliverList.builder(
                  itemCount: tracks.length,
                  itemBuilder: (_, i) {
                    final t = tracks[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text(t.title),
                      subtitle: Text(t.artistName),
                      trailing: const Icon(Icons.play_arrow_outlined),
                      onTap: () => _play(tracks, i),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
