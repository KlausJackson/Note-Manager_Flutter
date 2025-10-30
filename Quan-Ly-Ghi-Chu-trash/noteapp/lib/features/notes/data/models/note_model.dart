import 'package:hive/hive.dart';
import 'package:noteapp/features/notes/data/models/block_model.dart';
import 'package:noteapp/features/notes/domain/entities/note.dart';

part 'note_model.g.dart';

@HiveType(typeId: 1)
class NoteModel extends Note {
  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<BlockModel> body;

  @HiveField(3)
  final bool isPinned;

  @HiveField(4)
  final List<String> tagUUIDs;

  @HiveField(5)
  final bool isDeleted;

  @HiveField(6)
  final DateTime updatedAt;

  NoteModel({
    required this.uuid,
    required this.title,
    required this.body,
    required this.isPinned,
    required this.tagUUIDs,
    required this.isDeleted,
    required this.updatedAt,
  }) : super(
         uuid: uuid,
         title: title,
         body: body,
         isPinned: isPinned,
         tagUUIDs: tagUUIDs,
         isDeleted: isDeleted,
         updatedAt: updatedAt,
       );

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      uuid: json['uuid'],
      title: json['title'] ?? '',
      body: (json['body'] as List)
          .map((blockJson) => BlockModel.fromJson(blockJson))
          .toList(),
      isPinned: json['isPinned'] ?? false,
      tagUUIDs: List<String>.from(json['tagUUIDs'] ?? []),
      isDeleted: json['isDeleted'] ?? false,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'title': title,
      'body': body.map((b) => b.toJson()).toList(),
      'isPinned': isPinned,
      'tagUUIDs': tagUUIDs,
      'isDeleted': isDeleted,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
