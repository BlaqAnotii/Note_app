import 'package:flutter/material.dart';
import 'package:flutter_template/services/model/note_model.dart';
import 'package:flutter_template/views/home/category_list.dart';
import 'package:icons_plus/icons_plus.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final VoidCallback? onDelete;

  const NoteEditorScreen({super.key, this.note, this.onDelete});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String selectedCategory = 'Uncategorized';
bool isPinned = false;

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      selectedCategory = widget.note!.category;
     isPinned = widget.note!.isPinned;  // initialize pin state

    }
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      print('Empty note discarded');
      Navigator.pop(context);
      return;
    }

    final now = DateTime.now();

    final newNote = Note(
      title: title,
      content: content,
      category: selectedCategory,
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
        isPinned: isPinned,  // save pinned state here

    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note saved successfully'),
        backgroundColor: Color.fromARGB(255, 52, 59, 58),
        duration: Duration(seconds: 5),
      ),
    );

    print('Note saved: ${newNote.title}');
    Navigator.pop(context, newNote);
  }

  void _openCategorySelector() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CategorySelector(
          allCategories: const [
            "Important",
            "Lecture notes",
            "To-do lists",
            "Shopping list",
            "Diary",
            "Retrospective 2023",
          ],
          initiallySelected: selectedCategory == 'Uncategorized'
              ? []
              : selectedCategory.split(', '),
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedCategory = result.isEmpty ? 'Uncategorized' : result.join(', ');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$selectedCategory selected'),
          backgroundColor: const Color.fromARGB(255, 52, 59, 58),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _applyFormatting(String type) {
    final selection = _contentController.selection;
    final text = _contentController.text;

    if (!selection.isValid || selection.isCollapsed) return;

    final selectedText = selection.textInside(text);
    String formatted = selectedText;

    switch (type) {
      case 'bold':
        formatted = '**$selectedText**';
        break;
      case 'italic':
        formatted = '*$selectedText*';
        break;
      case 'underline':
        formatted = '~~$selectedText~~';
        break;
      case 'clear':
        formatted = selectedText.replaceAll(RegExp(r'[*_]+'), '');
        break;
    }

    final newText = selection.textBefore(text) + formatted + selection.textAfter(text);

    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + formatted.length),
    );
  }

  void _deleteNote() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (shouldDelete == true) {
  widget.onDelete?.call(); // delete from parent list
  Navigator.pop(context, 'deleted'); // pass 'deleted' result back
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Note deleted'),
      backgroundColor: Color.fromARGB(255, 52, 59, 58),
      duration: Duration(seconds: 5),
    ),
  );
}

  }



  // Add this method to check if there are unsaved changes
bool get _hasUnsavedChanges {
  final title = _titleController.text.trim();
  final content = _contentController.text.trim();

  // If editing existing note: compare with original values
  if (widget.note != null) {
    return title != widget.note!.title || content != widget.note!.content || selectedCategory != widget.note!.category;
  } else {
    // If new note, check if anything typed
    return title.isNotEmpty || content.isNotEmpty || selectedCategory != 'Uncategorized';
  }
}

void _discardChanges() async {
  if (!_hasUnsavedChanges) {
    Navigator.pop(context);
    return;
  }

  final shouldDiscard = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Discard Changes'),
      content: const Text('Are you sure you want to discard your changes?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Discard')),
      ],
    ),
  );

  if (shouldDiscard == true) {
    Navigator.pop(context);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black87),
    onPressed: _discardChanges,
  ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.folder_add_outline),
            onPressed: _openCategorySelector,
          ),
          widget.note == null
          ?
          IconButton(
            icon: 
               Icon(isPinned ?Bootstrap.pin_angle_fill : Bootstrap.pin_angle, color: isPinned ? Colors.grey : Colors.black, ),
              
            onPressed: (){
              setState(() {
      isPinned = !isPinned;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPinned ? 'Note pinned' : 'Note unpinned'),
        backgroundColor: const Color.fromARGB(255, 52, 59, 58),
        duration: const Duration(seconds: 2),
      ),
    );
  
            }
          ) : IconButton(
            icon: 
                 const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteNote,
          ) ,
          IconButton(
            icon: const Icon(Iconsax.export_1_outline),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: 'Start writing...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 16,
            right: 16,
            child: Card(
              elevation: 6,
              color: const Color.fromARGB(255, 52, 59, 58),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.format_bold), onPressed: () => _applyFormatting('bold')),
                    IconButton(icon: const Icon(Icons.format_italic), onPressed: () => _applyFormatting('italic')),
                    IconButton(icon: const Icon(Icons.format_underline), onPressed: () => _applyFormatting('underline')),
                    IconButton(icon: const Icon(Icons.format_clear), onPressed: () => _applyFormatting('clear')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
