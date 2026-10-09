import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/lost_found_provider.dart';
import '../../design_system/app_card.dart';
import '../../design_system/app_button.dart';

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
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: AppTheme.spacingLg,
            right: AppTheme.spacingLg,
            top: AppTheme.spacingLg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report Item',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Lost')),
                      selected: selectedType == 'lost',
                      onSelected: (_) =>
                          setSheetState(() => selectedType = 'lost'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Found')),
                      selected: selectedType == 'found',
                      onSelected: (_) =>
                          setSheetState(() => selectedType = 'found'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextField(
                controller: itemNameCtrl,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(
                    labelText: 'Location (e.g. Library 2nd Floor)'),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              SizedBox(
                width: double.infinity,
                child: AppButton.primary(
                  text: 'Submit Report',
                  isLoading: isSubmitting,
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
                    
                    setSheetState(() {
                      isSubmitting = true;
                    });
                    
                    final messenger = ScaffoldMessenger.of(context);
                    final success = await ref
                        .read(lostFoundProvider.notifier)
                        .reportItem(
                          type: selectedType,
                          itemName: itemNameCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          location: locationCtrl.text.trim(),
                        );
                    
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                    
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Item reported successfully!'
                            : 'Failed to report item. Try again.'),
                      ),
                    );
                  },
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
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          labelStyle: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.search_off_rounded), text: 'Lost Items'),
            Tab(icon: Icon(Icons.check_circle_outline_rounded), text: 'Found Items'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_lostfound',
        onPressed: () => _showReportSheet(context),
        backgroundColor: theme.colorScheme.primary,
        icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        label: Text(
          'Report',
          style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      body: lfState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : lfState.error != null
              ? _buildErrorState(theme)
              : lfState.items.isEmpty
                  ? _buildEmptyState(theme, _currentType)
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(lostFoundProvider.notifier)
                          .fetchItems(type: _currentType),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        itemCount: lfState.items.length,
                        separatorBuilder: (ctx, index) => const SizedBox(height: AppTheme.spacingMd),
                        itemBuilder: (context, index) {
                          final item = lfState.items[index];
                          String imgUrl = '';
                          if (item.imageUrl.isNotEmpty) {
                            imgUrl = item.imageUrl.startsWith('http')
                                ? item.imageUrl
                                : '${AppConstants.uploadBaseUrl}${item.imageUrl}';
                          }

                          return AppCard(
                            padding: const EdgeInsets.all(AppTheme.spacingMd),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image or icon placeholder
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  child: imgUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: imgUrl,
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                          placeholder: (c, u) => _buildIconPlaceholder(theme, item.type),
                                          errorWidget: (c, u, e) => _buildIconPlaceholder(theme, item.type),
                                        )
                                      : _buildIconPlaceholder(theme, item.type),
                                ),
                                const SizedBox(width: AppTheme.spacingMd),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.itemName,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: AppTheme.spacingXs),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: item.type == 'lost'
                                                  ? theme.colorScheme.errorContainer.withValues(alpha: 0.5)
                                                  : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                              border: Border.all(
                                                color: item.type == 'lost'
                                                    ? theme.colorScheme.error.withValues(alpha: 0.2)
                                                    : theme.colorScheme.primary.withValues(alpha: 0.2),
                                              ),
                                            ),
                                            child: Text(
                                              item.type.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.5,
                                                color: item.type == 'lost'
                                                    ? theme.colorScheme.error
                                                    : theme.colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppTheme.spacingSm),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_rounded,
                                              size: 14,
                                              color: theme.colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              item.location,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppTheme.spacingXs),
                                      Text(
                                        item.description,
                                        style: theme.textTheme.bodyMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: AppTheme.spacingMd),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 8,
                                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                            child: Icon(Icons.person_rounded, size: 10, color: theme.colorScheme.onSurfaceVariant),
                                          ),
                                          const SizedBox(width: AppTheme.spacingXs),
                                          Text(
                                            'Reported by ${item.reporterName}',
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'lost' ? Icons.search_off_rounded : Icons.check_circle_outline_rounded,
            size: 64,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No $type items found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            type == 'lost' ? 'No items have been reported lost.' : 'No items have been found yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Oops! Something went wrong.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            AppButton.primary(
              text: 'Try Again',
              icon: Icons.refresh_rounded,
              onPressed: () => ref.read(lostFoundProvider.notifier).fetchItems(type: _currentType),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconPlaceholder(ThemeData theme, String type) {
    return Container(
      width: 72,
      height: 72,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        type == 'lost' ? Icons.search_off_rounded : Icons.check_circle_outline_rounded,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        size: 32,
      ),
    );
  }
}
