import 'package:flutter/material.dart';
import 'package:noteapp/features/notes/domain/entities/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          note.title.isNotEmpty ? note.title : 'Không có tiêu đề',
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          // Show a preview of the body's first text block
          note.body.isNotEmpty ? note.body.first.text : 'Không có nội dung',
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // Prevent overflow
        ),
        onTap: () {
          // Navigate to the Note Edit page
          Navigator.of(context).pushNamed('/notes/edit', arguments: note);
        },
      ),
    );
  }
}
