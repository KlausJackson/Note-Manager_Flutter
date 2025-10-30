import 'package:flutter/material.dart';
import 'package:noteapp/features/notes/presentation/widgets/pagination.dart';
import 'package:noteapp/features/notes/presentation/widgets/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/features/notes/presentation/provider/note_provider.dart';
import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/presentation/widgets/note_card.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  late NoteProvider _noteProvider;

  // --- State Variables (mirror NotesPage) ---
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _noteProvider.getTrashedNotes();
    });
  }

  @override
  void dispose() {
    _noteProvider.removeListener(_handleNoteChanges);
    super.dispose();
  }

  void _handleNoteChanges() {
    final message = _noteProvider.popMessage;
    if (message != null && mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _onSearchParametersChanged(Map<String, dynamic> params) {
    setState(() {
      _query = params['query'];
      _sortBy = params['sortBy'];
      _isDescending = params['isDescending'];
      _currentPage = 1;
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _currentPage = 1;
    });
    await _noteProvider.getTrashedNotes();
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
  }

  void _onPageSizeChanged(int newSize) {
    setState(() {
      _pageSize = newSize;
      _currentPage = 1;
    });
  }

  List<Note> _applyFilterSort(List<Note> source) {
    var list = List<Note>.from(source);
    // filter
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((n) {
        final titleMatch = n.title.toLowerCase().contains(q);
        final bodyMatch = n.body.any((b) => b.text.toLowerCase().contains(q));
        return titleMatch || bodyMatch;
      }).toList();
    }

    // sort
    list.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'title':
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case 'updatedAt':
        default:
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
      }
      return _isDescending ? -comparison : comparison;
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, _) {
        final filtered = _applyFilterSort(provider.trashedNotes);

        // pagination slice
        final totalItems = filtered.length;
        final startIndex = (_currentPage - 1) * _pageSize;
        final endIndex = (startIndex + _pageSize > totalItems)
            ? totalItems
            : startIndex + _pageSize;
        final pageItems = (startIndex < totalItems)
            ? filtered.sublist(startIndex, endIndex)
            : <Note>[];

        return Stack(
          children: [
            Column(
              children: [
                // Search bar
                SearchBarFilter(onSearchChanged: _onSearchParametersChanged),

                // Body
                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (provider.status == NoteStatus.loading &&
                          provider.trashedNotes.isEmpty) {
                        return const Center(
                          key: ValueKey('loading'),
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (filtered.isEmpty) {
                        return Center(
                          key: const ValueKey('empty'),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text('Không có ghi chú trong thùng rác'),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        key: const ValueKey('list'),
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          itemCount: pageItems.length,
                          itemBuilder: (context, index) {
                            final note = pageItems[index];
                            return Dismissible(
                              key: ValueKey(note.uuid),
                              background: Container(
                                color: Colors.green,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 16),
                                child: const Icon(Icons.restore),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(Icons.delete_forever),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  await provider.restoreNote(note);
                                  return false;
                                } else {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Xóa vĩnh viễn'),
                                      content: const Text(
                                        'Bạn có muốn xõa vĩnh viễn ghi chú này không?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text('Có'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: const Text('Không'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await provider.permanentlyDeleteNote(
                                        note,
                                      );
                                      return true;
                                    } catch (e) {
                                      // show error and keep the item in the list
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Không thể xóa ghi chú: $e',
                                            ),
                                          ),
                                        );
                                      }
                                      return false;
                                    }
                                  }
                                  return false;
                                }
                              },
                              onDismissed: (direction) {},
                              child: NoteCard(note: note),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Pagination
                Pagination(
                  currentPage: _currentPage,
                  pageSize: _pageSize,
                  totalItems: totalItems,
                  onPageChanged: _onPageChanged,
                  onPageSizeChanged: _onPageSizeChanged,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
