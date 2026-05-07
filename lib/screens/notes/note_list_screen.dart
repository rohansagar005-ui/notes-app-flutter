import 'package:flutter/material.dart';
import '../../models/note.dart';
import '../../services/note_service.dart';
import '../../services/auth_service.dart';
import '../../services/connectivity_service.dart';
import '../../widgets/offline_banner.dart';
import 'note_edit_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final _noteService = NoteService();
  final _authService = AuthService();
  final _connectivityService = ConnectivityService();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _loading = true;
  bool _isOffline = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadNotes();
    _connectivityService.startMonitoring((isOnline) {
      if (mounted) {
        setState(() => _isOffline = !isOnline);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _connectivityService.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await _connectivityService.checkConnectivity();
    if (mounted) setState(() => _isOffline = !isOnline);
  }

  Future<void> _loadNotes() async {
    setState(() => _loading = true);
    try {
      final notes = await _noteService.getNotes();
      if (mounted) {
        setState(() {
          _notes = notes;
          _filteredNotes = notes;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notes: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  void _filterNotes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = _notes;
      } else {
        _filteredNotes = _notes
            .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _deleteNote(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _noteService.deleteNote(note.id);
        _loadNotes();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete note: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isOffline) const OfflineBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes by title...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
              ),
              onChanged: _filterNotes,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredNotes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_add_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _notes.isEmpty
                                  ? 'No notes yet. Tap + to create one!'
                                  : 'No notes match your search.',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNotes,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = _filteredNotes[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  note.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      note.content,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _timeAgo(note.updatedAt),
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red[400],
                                  ),
                                  onPressed: () => _deleteNote(note),
                                ),
                                onTap: () async {
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          NoteEditScreen(note: note),
                                    ),
                                  );
                                  if (result == true) _loadNotes();
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const NoteEditScreen()),
          );
          if (result == true) _loadNotes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
