import 'package:noteapp/features/notes/domain/entities/block.dart';
import 'package:hive/hive.dart';

part 'block_model.g.dart';

@HiveType(typeId: 2)
class BlockModel extends Block {
  @HiveField(0)
  final String type;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final bool checked;

  BlockModel({required this.type, required this.text, required this.checked})
    : super(type: type, text: text, checked: checked);

  factory BlockModel.fromJson(Map<String, dynamic> json) {
    return BlockModel(
      type: json['type'],
      text:
          json['data']['text'] ?? '', // Default to empty string if not present
      checked:
          json['data']['checked'] ?? false, // Default to false if not present
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': {'text': text, 'checked': checked},
    };
  }
}
