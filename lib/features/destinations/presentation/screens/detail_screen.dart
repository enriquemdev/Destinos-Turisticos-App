import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di.dart';
import '../store/destination_store.dart';
import '../widgets/destination_detail_loaded_view.dart';
import '../widgets/detail_hero_image.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.xid});

  final String xid;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final DestinationStore _store;

  @override
  void initState() {
    super.initState();
    _store = sl<DestinationStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.xid.isNotEmpty) {
        _store.loadDestinationById(widget.xid);
      }
    });
  }

  @override
  void dispose() {
    // Defer store cleanup to avoid triggering Observer rebuild during dispose
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _store.clearSelectedDestination();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final destination = _store.selectedDestination;
        final scheme = Theme.of(context).colorScheme;
        final theme = Theme.of(context);

        if (widget.xid.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalle')),
            body: const Center(child: Text('Identificador no válido.')),
          );
        }

        if (_store.isLoading && destination == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (_store.errorMessage != null && destination == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 56, color: scheme.error),
                    const SizedBox(height: 16),
                    Text(
                      _store.errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _store.loadDestinationById(widget.xid),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (destination == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.travel_explore_outlined,
                        size: 56,
                        color: scheme.onSurface.withAlpha(60)),
                    const SizedBox(height: 16),
                    Text(
                      'Destino no encontrado.\nConéctate para cargarlo.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurface.withAlpha(120),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _store.loadDestinationById(widget.xid),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Main detail view
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                backgroundColor: scheme.surface,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    destination.name,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        const Shadow(blurRadius: 8, color: Colors.black54),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Hero(
                    tag: 'destination_image_${destination.xid}',
                    child: DetailHeroBackground(imageUrl: destination.imageUrl),
                  ),
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: DestinationDetailLoadedView(
                  destination: destination,
                  store: _store,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
