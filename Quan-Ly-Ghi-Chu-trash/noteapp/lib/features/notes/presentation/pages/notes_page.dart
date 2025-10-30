import 'package:flutter/material.dart';
import 'package:noteapp/features/notes/presentation/widgets/pagination.dart';
import 'package:noteapp/features/notes/presentation/widgets/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/features/notes/presentation/provider/note_provider.dart';
import 'package:noteapp/features/notes/presentation/widgets/note_card.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late NoteProvider _noteProvider;

  // --- State Variables ---
  String _query = '';
  String _sortBy = 'updatedAt';
  bool _isDescending = true;
  int _currentPage = 1;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _noteProvider = Provider.of<NoteProvider>(context, listen: false);
    _noteProvider.addListener(_handleNoteChanges);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNotes();
    });
  }

  @override
  void dispose() {
    _noteProvider.removeListener(_handleNoteChanges);
    super.dispose();
  }

  void _onSearchParametersChanged(Map<String, dynamic> params) {
    setState(() {
      _query = params['query'];
      _sortBy = params['sortBy'];
      _isDescending = params['isDescending'];
      _currentPage = 1; // Always reset to page 1 on a new search
    });
    _fetchNotes();
  }

  void _handleNoteChanges() {
    final message = _noteProvider.popMessage;
    if (message != null && mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  } // show message

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
    _fetchNotes();
  }

  void _onPageSizeChanged(int newSize) {
    setState(() {
      _pageSize = newSize;
      _currentPage = 1;
    });
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final sortOrder = _isDescending ? 1 : 0;
    if (mounted) {
      await context.read<NoteProvider>().getNotes(
        _query,
        _sortBy,
        sortOrder,
        _currentPage,
        _pageSize,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, _) {
        // Use Stack to layer the Floating Action Button on top of the content.
        return Stack(
          children: [
            Column(
              children: [
                // --- SearchBar ---
                SearchBarFilter(
                  onSearchChanged: _onSearchParametersChanged,
                ),

                // --- Notes List ---
                Expanded(child: _buildBody(provider)), // fill the remaining space.

                // --- Pagination ---
                Pagination(
                  currentPage: _currentPage,
                  pageSize: _pageSize,
                  totalItems: provider.totalNotes,
                  onPageChanged: _onPageChanged,
                  onPageSizeChanged: _onPageSizeChanged,
                ),
              ],
            ),

            // --- Floating Action Button ---
            // Positioned places the button in the bottom-right corner.
            Positioned(
              bottom: 80, // leave space above pagination
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/notes/create');
                },
                tooltip: 'Create Note',
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(NoteProvider provider) {
    if (provider.status == NoteStatus.loading && provider.notes.isEmpty) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    } // show loading indicator when first load

    if (provider.notes.isEmpty) {
      return Center(
        key: const ValueKey('empty'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_add_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Không có ghi chú.\nNhấn vào nút + để tạo một ghi chú.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // pull-to-refresh : perform sync data with server
    return RefreshIndicator(
      key: const ValueKey('list'),
      onRefresh: () async {
        setState(() {
          _currentPage = 1;
        });
        await context.read<NoteProvider>().performSync();
      },
      child: ListView.builder(
        itemCount: provider.notes.length,
        itemBuilder: (context, index) {
          final note = provider.notes[index];
          return NoteCard(note: note);
        },
      ),
    );
  }
}
