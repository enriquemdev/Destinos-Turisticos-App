import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di.dart';
import '../../../../core/router.dart';
import '../store/destination_store.dart';
import '../widgets/destination_card.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late final DestinationStore _store;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _store = sl<DestinationStore>();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      _store.setSearchQuery(_searchController.text);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _store.loadDestinations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _store.refresh();
  }

  Widget _buildListBody(BuildContext context) {
    final theme = Theme.of(context);

    if (_store.isLoading && _store.destinations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_store.errorMessage != null && _store.destinations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _store.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _store.loadDestinations(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_store.destinations.isEmpty && !_store.isLoading) {
      return Center(
        child: Text(
          'No hay destinos guardados.\nConéctate para cargar datos.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final items = _store.filteredDestinations;
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Sin coincidencias para la búsqueda.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final d = items[index];
          return DestinationCard(
            destination: d,
            onTap: () {
              context.goNamed(
                RouteNames.detail,
                pathParameters: <String, String>{'xid': d.xid},
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destinos turísticos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o categoría',
                prefixIcon: Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) => _buildListBody(context),
            ),
          ),
        ],
      ),
    );
  }
}
