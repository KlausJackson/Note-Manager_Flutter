import 'package:flutter/material.dart';
import 'package:noteapp/features/notes/presentation/widgets/edit_body.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/domain/entities/block.dart';
import 'package:noteapp/features/notes/presentation/provider/note_provider.dart';
import 'package:noteapp/presentation/widgets/show_dialogs.dart';

class NoteEditPage extends StatefulWidget {
  // If a note is passed in -> edit mode.
  // If it's null -> create mode.
  final Note? note;
  const NoteEditPage({super.key, this.note});
  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late TextEditingController _titleController;
  // Each block in the body has its own controller.
  late List<TextEditingController> _bodyControllers;
  late List<Block> _bodyBlocks;

  late Note _originalNote; // snapshot
  bool _isChanged = false; // Tracks if there are unsaved changes

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      // --- EDIT MODE ---
      _originalNote = widget.note!;
      _titleController = TextEditingController(text: _originalNote.title);
      _bodyBlocks = List<Block>.from(
        _originalNote.body.map((b) => b.copyWith()),
      ); // Create a mutable copy
    } else {
      // --- CREATE MODE ---
      _originalNote = Note(
        uuid: const Uuid().v4(),
        isPinned: false,
        title: '',
        body: [Block(type: 'text', text: '', checked: false)],
        isDeleted: false,
        tagUUIDs: [],
        updatedAt: DateTime.now(),
      );
      _titleController = TextEditingController();
      // Start with one empty text block.
      _bodyBlocks = [Block(type: 'text', text: '', checked: false)];
      _isChanged = true; // New note, always "changed"
    }

    // Create a TextEditingController for each block.
    _bodyControllers = _bodyBlocks
        .map((block) => TextEditingController(text: block.text))
        .toList();

    _titleController.addListener(_checkForChanges);
    for (var controller in _bodyControllers) {
      controller.addListener(_checkForChanges);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _bodyControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _checkForChanges() {
    bool hasChanges = false;

    // Compare title and body with the original note.
    if (_titleController.text != _originalNote.title) hasChanges = true;
    for (int i = 0; i < _bodyControllers.length; i++) {
      // INDEX OUT OF RANGE CHECKS
      if (_bodyControllers.length != _originalNote.body.length) {
        hasChanges = true;
        break;
      } // number of blocks changed
      if (i >= _originalNote.body.length) {
        hasChanges = true;
        break;
      } // extra blocks added

      // COMPARE CONTENT
      if (_bodyControllers[i].text != _originalNote.body[i].text) {
        hasChanges = true;
      } // text changed
      if (_bodyBlocks[i].checked != _originalNote.body[i].checked) {
        hasChanges = true;
      } // checkbox state changed
    }

    // If has changedes state differs, update it.
    if (hasChanges != _isChanged) {
      setState(() {
        _isChanged = hasChanges;
      });
    }
  } // called on every keystroke

  void _saveNote() {
    for (int i = 0; i < _bodyBlocks.length; i++) {
      _bodyBlocks[i] = Block(
        type: _bodyBlocks[i].type,
        text: _bodyControllers[i].text,
        checked: _bodyBlocks[i].checked,
      );
    } // Update _bodyBlocks with text from controllers.

    final noteToSave = Note(
      uuid: _originalNote.uuid,
      title: _titleController.text.trim(),
      body: _bodyBlocks,
      isPinned: false,
      isDeleted: false,
      tagUUIDs: [],
      updatedAt: DateTime.now(),
    );

    final provider = context.read<NoteProvider>();
    if (widget.note != null) {
      provider.updateNote(noteToSave);
    } else {
      provider.createNote(noteToSave);
    }
    setState(() {
      _isChanged = false;
      _originalNote = noteToSave;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu.')));
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Chưa cập nhật';
    final formatted =
        '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    return formatted;
  }

  void _deleteNote() {
    if (widget.note != null) {
      ShowDialogs.showConfirmationDialog(
        context: context,
        title: 'Xóa ghi chú?',
        message: 'Bạn có chắc chắn muốn xóa ghi chú này không?',
        confirmText: 'Xóa',
        onConfirm: () {
          context.read<NoteProvider>().deleteNote(widget.note!.uuid);
          Navigator.of(context).pop(true);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isReadOnly = widget.note?.isDeleted ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 32.0,
          children: [
            Text(
              widget.note != null ? 'Chỉnh sửa ghi chú' : 'Tạo ghi chú',
              style: const TextStyle(fontSize: 16),
            ),
            if (widget.note != null) // Show last updated time in edit mode
              Text(
                _formatDateTime(widget.note?.updatedAt),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        actions: [
          // --- DELETE BUTTON (only shown in edit mode and when not read-only) ---
          if (widget.note != null && !isReadOnly)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Xóa',
              onPressed: _deleteNote,
            ),
          // --- SAVE BUTTON (hidden/disabled when read-only) ---
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Lưu',
            onPressed: (!isReadOnly && _isChanged) ? _saveNote : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0),
        child: Column(
          children: [
            // --- TITLE FIELD ---
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'TIêu đề.....',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              enabled: !isReadOnly,
            ),

            const SizedBox(height: 5),
            const Divider(height: 1),
            const SizedBox(height: 5),
            // --- DYNAMIC BODY BLOCKS ---
            Expanded(
              child: NoteBodyEditor(
                initialBlocks: _bodyBlocks,
                bodyControllers: _bodyControllers,
                onChanged: _checkForChanges,
                readOnly: isReadOnly,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
