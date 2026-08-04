import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/club_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/club_card.dart';
import 'club_detail_screen.dart';
import 'create_club_screen.dart';

class ClubsListScreen extends ConsumerWidget {
  const ClubsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clubListProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Clubs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(clubListProvider.notifier).fetchClubs(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.error}'),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(clubListProvider.notifier).fetchClubs(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : state.clubs.isEmpty
                  ? const Center(
                      child: Text('No campus clubs found. Be the first to create one!'),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(clubListProvider.notifier).fetchClubs(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.clubs.length,
                        itemBuilder: (context, index) {
                          final club = state.clubs[index];
                          return ClubCard(
                            club: club,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ClubDetailScreen(clubId: club.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_clubs',
        onPressed: () {
          if (!authState.isAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please log in to create a club.')),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateClubScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Club'),
      ),
    );
  }
}
