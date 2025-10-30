class Block {
  final String type;
  final String text;
  final bool checked;

  Block({required this.type, required this.text, required this.checked});

  Block copyWith({String? type, String? text, bool? checked}) {
    return Block(
      type: type ?? this.type,
      text: text ?? this.text,
      checked: checked ?? this.checked,
    );
  }
}
