import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../core/di.dart';
import '../../data/models/destination_model.dart';
import '../store/destination_store.dart';
import '../widgets/destination_detail_loaded_view.dart';

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
    _store.clearSelectedDestination();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final destination = _store.selectedDestination;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              destination?.name ?? 'Detalle',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: _buildBody(context, destination),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, Destination? destination) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (widget.xid.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Identificador de destino no válido.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    if (_store.isLoading && destination == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_store.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: scheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _store.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _store.loadDestinationById(widget.xid),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (destination == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.travel_explore_outlined,
                size: 48,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontró el destino.\n'
                'Puede no estar guardado o no hay conexión para cargarlo.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _store.loadDestinationById(widget.xid),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return DestinationDetailLoadedView(destination: destination);
  }
}
