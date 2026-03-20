import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di.dart';
import '../../../../core/router.dart';
import '../../data/models/destination_model.dart';
import '../store/destination_store.dart';
import '../widgets/destination_card.dart';
import '../widgets/destination_skeleton.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late final DestinationStore _store;
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _store = sl<DestinationStore>();
    _searchController = TextEditingController();
    _scrollController = ScrollController();

    _searchController.addListener(() {
      _store.setSearchQuery(_searchController.text);
    });

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_store.destinations.isEmpty) {
        _store.loadDestinations();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _store.fetchMoreItems();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.refresh_rounded, color: scheme.primary),
              const SizedBox(width: 10),
              Text(
                'Recargar datos',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Text(
            '¿Deseas borrar los destinos guardados y comenzar desde cero? '
            'Se descargarán destinos nuevos si hay conexión.',
            style: GoogleFonts.inter(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Cancelar',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'Borrar y recargar',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _store.refresh();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _store.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🇳🇮 Nicaragua',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Destinos\nTurísticos',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // ── Search bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Observer(
                builder: (_) => TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar destinos…',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: scheme.onSurface.withAlpha(100),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: scheme.onSurface.withAlpha(130),
                    ),
                    suffixIcon: _store.isSearchActive
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: _clearSearch,
                          )
                        : null,
                  ),
                  textInputAction: TextInputAction.search,
                ),
              ),
            ),

            // ── AI search button (visible when query is non-empty) ────────────
            Observer(
              builder: (_) {
                if (!_store.isSearchActive) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          _store.isSearchingWithAi ? null : _store.searchWithAi,
                      icon: _store.isSearchingWithAi
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: Text(
                        _store.isSearchingWithAi
                            ? 'Buscando con IA…'
                            : 'Buscar con IA',
                        style:
                            GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // ── Body ──────────────────────────────────────────────────────────
            Expanded(
              child: Observer(
                builder: (_) => _buildBody(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Initial loading
    if (_store.isLoading && _store.destinations.isEmpty) {
      return const DestinationListSkeleton();
    }

    // Gemini search loading
    if (_store.isSearchingWithAi) {
      return const DestinationListSkeleton(count: 3);
    }

    // Error
    if (_store.errorMessage != null && _store.destinations.isEmpty) {
      return _ErrorState(
        message: _store.errorMessage!,
        onRetry: _store.loadDestinations,
        scheme: scheme,
        theme: theme,
      );
    }

    // Empty (no data yet)
    if (_store.destinations.isEmpty && !_store.isLoading) {
      return _EmptyState(scheme: scheme, theme: theme);
    }

    final items = _store.displayedDestinations;

    // No local results for query
    if (items.isEmpty && _store.isSearchActive) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.travel_explore_rounded,
                size: 56, color: scheme.onSurface.withAlpha(60)),
            const SizedBox(height: 16),
            Text(
              'No hay resultados locales para\n"${_store.searchQuery}"',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurface.withAlpha(100),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Prueba con "Buscar con IA" para\nencontrar más destinos.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withAlpha(70),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show total count hint when filtering
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: scheme.primary,
      child: AnimationLimiter(
        child: ListView.separated(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          itemCount: items.length +
              (!_store.isSearchActive && _store.hasMorePages ? 1 : 0),
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            // Loading more indicator at the end (only in non-search mode)
            if (index == items.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: _store.isLoadingMore
                      ? CircularProgressIndicator(color: scheme.primary)
                      : const SizedBox.shrink(),
                ),
              );
            }

            final destination = items[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 40,
                child: FadeInAnimation(
                  child: _DestinationCardItem(
                    destination: destination,
                    onTap: () => _navigateToDetail(context, destination),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Destination destination) {
    context.pushNamed(
      RouteNames.detail,
      pathParameters: {'xid': destination.xid},
    );
  }
}

class _DestinationCardItem extends StatelessWidget {
  const _DestinationCardItem({
    required this.destination,
    required this.onTap,
  });

  final Destination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DestinationCard(destination: destination, onTap: onTap);
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.scheme,
    required this.theme,
  });

  final String message;
  final VoidCallback onRetry;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: scheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scheme, required this.theme});

  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.travel_explore_rounded,
              size: 72, color: scheme.onSurface.withAlpha(50)),
          const SizedBox(height: 20),
          Text(
            'Sin destinos guardados',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Conéctate a internet para cargar\nlos mejores destinos de Nicaragua.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withAlpha(120),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
