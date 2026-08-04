import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/lost_found_provider.dart';

class LostFoundScreen extends ConsumerStatefulWidget {
  const LostFoundScreen({super.key});

  @override
  ConsumerState<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends ConsumerState<LostFoundScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentType = 'lost';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final t = _tabController.index == 0 ? 'lost' : 'found';
        setState(() => _currentType = t);
        ref.read(lostFoundProvider.notifier).fetchItems(type: t);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lostFoundProvider.notifier).fetchItems(type: 'lost');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showReportSheet(BuildContext context) {
    final itemNameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    String selectedType = _currentType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report Item',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Lost'),
                      selected: selectedType == 'lost',
                      onSelected: (_) =>
                          setSheetState(() => selectedType = 'lost'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Found'),
                      selected: selectedType == 'found',
                      onSelected: (_) =>
                          setSheetState(() => selectedType = 'found'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: itemNameCtrl,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(
                    labelText: 'Location (e.g. Library 2nd Floor)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (itemNameCtrl.text.trim().isEmpty ||
                        locationCtrl.text.trim().isEmpty ||
                        descCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill in all fields.')),
                      );
                      return;
                    }
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx);
                    final success = await ref
                        .read(lostFoundProvider.notifier)
                        .reportItem(
                          type: selectedType,
                          itemName: itemNameCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          location: locationCtrl.text.trim(),
                        );
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Item reported successfully!'
                            : 'Failed to report item. Try again.'),
                      ),
                    );
                  },
                  child: const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lfState = ref.watch(lostFoundProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.search_off), text: 'Lost Items'),
            Tab(icon: Icon(Icons.check_circle_outline), text: 'Found Items'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_lostfound',
        onPressed: () => _showReportSheet(context),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Report'),
      ),
      body: lfState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : lfState.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(lfState.error!),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(lostFoundProvider.notifier)
                            .fetchItems(type: _currentType),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : lfState.items.isEmpty
                  ? const Center(child: Text('No items reported yet.'))
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(lostFoundProvider.notifier)
                          .fetchItems(type: _currentType),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: lfState.items.length,
                        itemBuilder: (context, index) {
                          final item = lfState.items[index];
                          String imgUrl = '';
                          if (item.imageUrl.isNotEmpty) {
                            imgUrl = item.imageUrl.startsWith('http')
                                ? item.imageUrl
                                : '${AppConstants.uploadBaseUrl}${item.imageUrl}';
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image or icon placeholder
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: imgUrl.isNotEmpty
                                        ? Image.network(
                                            imgUrl,
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                            errorBuilder: (e, o, s) =>
                                                _buildIconPlaceholder(
                                                    theme, item.type),
                                          )
                                        : _buildIconPlaceholder(
                                            theme, item.type),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.itemName,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: item.type == 'lost'
                                                    ? Colors.red[100]
                                                    : Colors.green[100],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                item.type.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: item.type == 'lost'
                                                      ? Colors.red[700]
                                                      : Colors.green[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                size: 14,
                                                color: theme
                                                    .colorScheme.primary),
                                            const SizedBox(width: 4),
                                            Text(item.location,
                                                style:
                                                    theme.textTheme.bodySmall),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(item.description,
                                            style:
                                                theme.textTheme.bodyMedium),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Reported by ${item.reporterName}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: theme
                                                      .colorScheme.secondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildIconPlaceholder(ThemeData theme, String type) {
    return Container(
      width: 64,
      height: 64,
      color: theme.colorScheme.primaryContainer,
      child: Icon(
        type == 'lost' ? Icons.search_off : Icons.check_circle_outline,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
