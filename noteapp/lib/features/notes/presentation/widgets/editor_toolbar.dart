import 'package:flutter/material.dart';

class EditorToolbar extends StatelessWidget {
  final VoidCallback onAddTextBlock;
  final VoidCallback onAddChecklistBlock;

  const EditorToolbar({
    super.key,
    required this.onAddTextBlock,
    required this.onAddChecklistBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.shade700)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            tooltip: 'Thêm văn bản',
            onPressed: onAddTextBlock,
          ),
          IconButton(
            icon: const Icon(Icons.check_box_outlined),
            tooltip: 'Thêm checklist',
            onPressed: onAddChecklistBlock,
          ),
        ],
      ),
    );
  }
}
