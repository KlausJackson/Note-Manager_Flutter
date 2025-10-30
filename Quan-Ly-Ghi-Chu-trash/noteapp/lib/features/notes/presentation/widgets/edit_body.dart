import 'package:flutter/material.dart';
import 'package:noteapp/features/notes/domain/entities/block.dart';
import 'package:noteapp/features/notes/presentation/widgets/editor_toolbar.dart';

class NoteBodyEditor extends StatefulWidget {
  final List<Block> initialBlocks;
  final List<TextEditingController> bodyControllers;
  final VoidCallback onChanged;
  final bool readOnly;

  const NoteBodyEditor({
    super.key,
    required this.initialBlocks,
    required this.bodyControllers,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  State<NoteBodyEditor> createState() => _NoteBodyEditorState();
}

class _NoteBodyEditorState extends State<NoteBodyEditor> {
  late List<Block> _bodyBlocks;
  late List<FocusNode> _bodyFocusNodes;
  int _currentFocusIndex = -1;

  @override
  void initState() {
    super.initState();
    _bodyBlocks = widget.initialBlocks;
    _bodyFocusNodes = List.generate(widget.bodyControllers.length, (index) {
      final node = FocusNode();
      node.addListener(() {
        if (node.hasFocus) {
          setState(() {
            _currentFocusIndex = index;
          });
        }
      });
      return node;
    });
  }

  @override
  void dispose() {
    for (var node in _bodyFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _addBlock(String type) {
    if (widget.readOnly) return;
    final insertIndex = _currentFocusIndex != -1
        ? _currentFocusIndex +
              1 // Insert after the focused block
        : _bodyBlocks.length; // at the end if none focused

    setState(() {
      final newBlock = Block(type: type, text: '', checked: false);
      _bodyBlocks.insert(insertIndex, newBlock);
      final newController = TextEditingController();
      newController.addListener(widget.onChanged);
      widget.bodyControllers.insert(insertIndex, newController);
      
      final newNode = FocusNode();
      newNode.addListener(() {
        if (newNode.hasFocus) {
          setState(() => _currentFocusIndex = insertIndex);
        }
      });
      _bodyFocusNodes.insert(insertIndex, newNode);
    });
    widget.onChanged(); // notify parent of change
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_bodyFocusNodes[insertIndex]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _bodyBlocks.length,
            itemBuilder: (context, index) {
              if (_bodyBlocks[index].type == 'checklist') {
                return _buildChecklistBlock(index);
              }
              return _buildTextBlock(index);
            },
          ),
        ),
        if (!widget.readOnly)
          EditorToolbar(
            onAddTextBlock: () => _addBlock('text'),
            onAddChecklistBlock: () => _addBlock('checklist'),
          ),
      ],
    );
  }

  // The builder helpers now live inside this widget's state.
  Widget _buildTextBlock(int index) {
    return TextField(
      controller: widget.bodyControllers[index],
      focusNode: _bodyFocusNodes[index],
      decoration: const InputDecoration(
        hintText: 'Nội dung.....',
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.multiline,
      maxLines: null, // Allows the field to expand vertically
      enabled: !widget.readOnly,
    );
  }

  Widget _buildChecklistBlock(int index) {
    return Row(
      children: [
        Checkbox(
          value: _bodyBlocks[index].checked,
          onChanged: widget.readOnly
              ? null
              : (bool? newValue) {
                  setState(() {
                    _bodyBlocks[index] = Block(
                      type: 'checklist',
                      text: _bodyBlocks[index].text,
                      checked: newValue ?? false,
                    );
                  });
                  widget.onChanged(); // notify parent of change
                },
        ),
        Expanded(
          child: TextField(
            controller: widget.bodyControllers[index],
            focusNode: _bodyFocusNodes[index],
            decoration: const InputDecoration(
              hintText: 'Nội dung.....',
              border: InputBorder.none,
            ),
            style: TextStyle(
              decoration: _bodyBlocks[index].checked
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
            onSubmitted: widget.readOnly ? null : (value) => _addBlock('checklist'),
            enabled: !widget.readOnly,
          ),
        ),
      ],
    );
  }
}
