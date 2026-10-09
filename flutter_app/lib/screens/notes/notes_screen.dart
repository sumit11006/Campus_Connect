import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/note_provider.dart';
import '../../providers/auth_provider.dart';
import '../../design_system/app_card.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUploadSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
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
              'Upload Note / Resource',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
            ),
            const SizedBox(height: 20),
            const Text(
              '📎 File upload requires file picker integration.\nFor now, provide a public PDF URL below.',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteState = ref.watch(noteProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes & Resources'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(noteProvider.notifier).fetchNotes(),
          ),
        ],
      ),
      floatingActionButton: (authState.isAuthenticated && 
          ['faculty', 'clubAdmin', 'admin'].contains(authState.user?.role))
          ? FloatingActionButton.extended(
              heroTag: 'fab_notes',
              onPressed: () => _showUploadSheet(context),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by subject (e.g. Physics, CS)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(noteProvider.notifier).fetchNotes();
                  },
                ),
              ),
              onSubmitted: (val) =>
                  ref.read(noteProvider.notifier).fetchNotes(subject: val.trim()),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: noteState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : noteState.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(noteState.error!),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  ref.read(noteProvider.notifier).fetchNotes(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : noteState.notes.isEmpty
                        ? const Center(
                            child: Text('No notes found. Be the first to upload!'))
                        : RefreshIndicator(
                            onRefresh: () =>
                                ref.read(noteProvider.notifier).fetchNotes(),
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: noteState.notes.length,
                              itemBuilder: (context, index) {
                                final note = noteState.notes[index];
                                final fullPdfUrl =
                                    note.fileUrl.startsWith('http')
                                        ? note.fileUrl
                                        : '${AppConstants.uploadBaseUrl}${note.fileUrl}';

                                return AppCard(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('PDF URL: $fullPdfUrl')),
                                    );
                                  },
                                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.errorContainer,
                                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                      ),
                                      child: Icon(Icons.picture_as_pdf,
                                          color: theme.colorScheme.error),
                                    ),
                                    title: Text(
                                      note.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 2),
                                        Text('Subject: ${note.subject}'),
                                        Text(
                                          'By ${note.uploaderName}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                    trailing: IconButton(
                                      tooltip: 'Open PDF',
                                      icon: Icon(Icons.open_in_new,
                                          color: theme.colorScheme.primary),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'PDF URL: $fullPdfUrl'),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
