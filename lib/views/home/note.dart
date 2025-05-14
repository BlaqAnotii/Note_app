import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_template/services/model/note_model.dart';
import 'dart:convert';

import 'package:flutter_template/views/home/category_list.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  late quill.QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();

  String selectedCategory = 'Uncategorized';
  bool _showToolbar = false;

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      selectedCategory = widget.note!.category;
      _quillController = quill.QuillController(
        document: quill.Document.fromJson(jsonDecode(widget.note!.content)),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _quillController = quill.QuillController.basic();
    }

    _editorFocusNode.addListener(() {
      setState(() {
        _showToolbar = _editorFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = jsonEncode(_quillController.document.toDelta().toJson());

    if (title.isEmpty && _quillController.document.isEmpty()) {
      Navigator.pop(context); // Prevent saving empty notes
      return;
    }

    final now = DateTime.now();

    final newNote = Note(
      title: title,
      content: content,
      category: selectedCategory,
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
    );

    Navigator.pop(context, newNote);
  }

  void _openCategorySelector() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => const CategorySelectorSheet(),
    );

    if (result != null) {
      setState(() {
        selectedCategory = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Note"),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          IconButton(icon: const Icon(Icons.category_outlined), onPressed: _openCategorySelector),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveNote,
        child: const Icon(Icons.save),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(12, 80, 12, 12),
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              quill.QuillEditor(
                controller: _quillController,
                focusNode: _editorFocusNode,
                scrollController: ScrollController(),
                scrollable: true,
                padding: const EdgeInsets.only(bottom: 100),
                autoFocus: false,
                readOnly: false,
                expands: false,
                placeholder: 'Start writing...',
              ),
            ],
          ),
          if (_showToolbar)
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                padding: const EdgeInsets.all(6),
                child: quill.QuillToolbar.basic(
                  controller: _quillController,
                  multiRowsDisplay: false,
                  showCodeBlock: false,
                  showQuote: false,
                  
                  showColorButton: true,
                  showBackgroundColorButton: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
