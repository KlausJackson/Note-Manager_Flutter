import 'package:noteapp/features/notes/domain/entities/block.dart';

class Note {
  final String uuid;
  final String title;
  final List<Block> body;
  final bool isPinned;
  final List<String> tagUUIDs;
  final bool isDeleted;
  final DateTime updatedAt;

  Note({
    required this.uuid,
    required this.title,
    required this.body,
    required this.isPinned,
    required this.tagUUIDs,
    required this.isDeleted,
    required this.updatedAt,
  });
}