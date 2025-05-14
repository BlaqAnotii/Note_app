import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_template/resources/colors.dart';
import 'package:flutter_template/services/app_cache.dart';
import 'package:flutter_template/services/locator.dart';
import 'package:flutter_template/services/model/note_model.dart';
import 'package:flutter_template/services/navigation_service.dart';
import 'package:flutter_template/utils/filter.dart';
import 'package:flutter_template/utils/snack_message.dart';
import 'package:flutter_template/utils/widget_extensions.dart';
import 'package:flutter_template/views/home/note.dart';
import 'package:intl/intl.dart';

import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/home.vm.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  TextEditingController searchController = TextEditingController();

  final List<String> cat = [
    'All',
    'Important',
    'Lecture Notes',
    'To-do lists',
    'Shopping lists',
    'Diary',
  ];

  final List<DateTime> dates = List.generate(
    14,
    (index) => DateTime.now().add(Duration(days: index)),
  );

  String selectedCat = 'All';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    loadNotes();
    selectedDate = dates[0];
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString('notes');
    if (notesJson != null) {
      final List list = jsonDecode(notesJson);
      notes = list.map((e) => Note.fromJson(e)).toList();
      applyFilters();
    }
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notes.map((e) => e.toJson()).toList();
    await prefs.setString('notes', jsonEncode(jsonList));
  }

  void deleteNote(int index) async {
    notes.removeAt(index);
    applyFilters();
    await saveNotes();
  }

  void applyFilters() {
    final query = searchController.text.trim().toLowerCase();
    filteredNotes = notes.where((note) {
      final matchQuery = note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.category.toLowerCase().contains(query);

      final matchCat =
          selectedCat == 'All' || note.category == selectedCat;

      final matchDate = selectedDate == null ||
          (note.updatedAt.year == selectedDate!.year &&
              note.updatedAt.month == selectedDate!.month &&
              note.updatedAt.day == selectedDate!.day);

      return matchQuery && matchCat && matchDate;
    }).toList();

    setState(() {});
  }

  void filterNotes(String query) {
    applyFilters();
  }

  void addOrEditNote({Note? note, int? index}) async {
    final result = await navigationService.push(
      NoteEditorScreen(note: note),
    );
    if (result != null && result is Note) {
      if (index != null) {
        notes[index] = result;
      } else {
        notes.add(result);
      }
      applyFilters();
      await saveNotes();
    }
  }

  void onMenuTap(String cat) {
    setState(() {
      selectedCat = cat;
    });
    applyFilters();
  }

  Widget buildMenuItem(String title, BuildContext context) {
    bool isSelected = selectedCat == title;
    return GestureDetector(
      onTap: () => onMenuTap(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 52, 59, 58)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey,
            width: 0.3,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: isSelected ? Colors.white : Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        toolbarHeight: 50,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "2023 May",
          style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins'),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: Icon(Icons.more_vert),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7),
            child: TextFormField(
              controller: searchController,
              onChanged: filterNotes,
              decoration: InputDecoration(
                fillColor: const Color(0xffd9e8fc),
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
                hintText: 'Search for notes',
                hintStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey),
                prefixIcon:
                    const Icon(Iconsax.search_normal_1, color: AppColors.grey),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 13, right: 13),
        child: Column(
          children: [
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final isSelected = date.day == selectedDate?.day &&
                      date.month == selectedDate?.month &&
                      date.year == selectedDate?.year;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                      });
                      applyFilters();
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 16),
                      decoration: BoxDecoration(
                          color: isSelected
                              ? const Color.fromARGB(255, 52, 59, 58)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected ? Colors.transparent : Colors.grey,
                            width: 0.3,
                          )),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat.E().format(date),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 23),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: cat
                    .map((cats) => Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6),
                          child: buildMenuItem(cats, context),
                        ))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: filteredNotes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 2,
                ),
                itemBuilder: (_, index) {
                  final note = filteredNotes[index];
                  return GestureDetector(
                    onTap: () => addOrEditNote(note: note, index: index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.black),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(note.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(note.category,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.amberAccent)),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              note.content.length > 60
                                  ? note.content.substring(0, 60) + '...'
                                  : note.content,
                              style:
                                  const TextStyle(color: Colors.white70),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 10),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(side: BorderSide.none),
        onPressed: () => addOrEditNote(),
        backgroundColor: const Color.fromARGB(255, 52, 59, 58),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
