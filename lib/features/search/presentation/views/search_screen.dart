import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_player_app/core/theme/app_tokens.dart';
import 'package:music_player_app/features/library/presentation/widgets/track_row.dart';
import 'package:music_player_app/features/search/presentation/viewmodels/search_viewmodel.dart';
import 'package:music_player_app/shared/widgets/empty_state.dart';
import 'package:music_player_app/shared/widgets/error_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Search songs, albums, artists…',
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      context.read<SearchViewModel>().onQueryChanged('');
                    },
                  )
                : null,
          ),
          onChanged: context.read<SearchViewModel>().onQueryChanged,
        ),
      ),
      body: Consumer<SearchViewModel>(
        builder: (context, vm, _) {
          if (!vm.hasQuery) {
            return _RecentQueries(vm: vm, tokens: tokens);
          }
          if (vm.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.failure != null) {
            return const ErrorState(message: 'Search failed. Try again.');
          }
          final r = vm.results;
          if (r == null || r.isEmpty) {
            return EmptyState(
              icon: Icons.search_off,
              message: 'No results for "${vm.query}"',
            );
          }
          return ListView(
            children: [
              if (r.tracks.isNotEmpty) ...[
                _SectionHeader(title: 'Songs', tokens: tokens),
                ...r.tracks.map(
                  (t) => TrackRow(
                    track: t,
                    onTap: () => vm.playTrack(t.id),
                  ),
                ),
              ],
              if (r.albums.isNotEmpty) ...[
                _SectionHeader(title: 'Albums', tokens: tokens),
                ...r.albums.map(
                  (a) => ListTile(
                    leading: a.artworkUrl != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(tokens.radiusSmall),
                            child: Image.network(
                              a.artworkUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.album),
                    title: Text(a.title),
                    subtitle: Text(a.primaryArtistName),
                  ),
                ),
              ],
              if (r.artists.isNotEmpty) ...[
                _SectionHeader(title: 'Artists', tokens: tokens),
                ...r.artists.map(
                  (a) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: a.artworkUrl != null
                          ? NetworkImage(a.artworkUrl!)
                          : null,
                      child: a.artworkUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(a.name),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _RecentQueries extends StatelessWidget {
  const _RecentQueries({required this.vm, required this.tokens});
  final SearchViewModel vm;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    if (vm.recentQueries.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        message: 'Search for songs, albums, or artists',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.spacing16,
            tokens.spacing16,
            tokens.spacing8,
            0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent searches',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextButton(
                onPressed: vm.clearRecent,
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: vm.recentQueries.length,
            itemBuilder: (_, i) {
              final q = vm.recentQueries[i];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(q.query),
                onTap: () => vm.onQueryChanged(q.query),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.tokens});
  final String title;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing16,
        tokens.spacing16,
        tokens.spacing16,
        tokens.spacing8,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
