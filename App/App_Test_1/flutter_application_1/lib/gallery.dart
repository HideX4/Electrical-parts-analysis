import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/main_2.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String selectedCategory = "ALL";
  List<Map<String, String>> allImages = [];

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  Future<void> _loadSavedImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedImages = prefs.getStringList('saved_images') ?? [];

    List<Map<String, String>> loaded =
        savedImages.map((str) {
          final map =
              str
                  .replaceAll(RegExp(r'^\{|\}$'), '') // remove curly braces
                  .split(', ')
                  .map((e) => e.split(':'))
                  .where((pair) => pair.length == 2)
                  .map((pair) => MapEntry(pair[0].trim(), pair[1].trim()))
                  .toList();
          return Map.fromEntries(map);
        }).toList();

    setState(() {
      allImages = loaded;
    });
  }

  Future<void> _deleteImage(String pathToDelete) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedImages = prefs.getStringList('saved_images') ?? [];

    savedImages.removeWhere((item) => item.contains(pathToDelete));

    final file = File(pathToDelete);
    if (await file.exists()) {
      await file.delete();
    }

    await prefs.setStringList('saved_images', savedImages);
    _loadSavedImages();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Image deleted")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        title: IconButton(
          icon: Icon(Icons.home, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        centerTitle: true,
        actions: [Icon(Icons.settings, color: Colors.black)],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          SizedBox(height: 10),
          _buildGalleryTitle(),
          _buildCategoryFilters(),
          _buildImageGrid(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildGalleryTitle() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text("Gallery", style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    List<String> categories = ["ALL", "RESISTOR", "CAPACITOR", "TRANSISTOR"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            categories.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ChoiceChip(
                  label: Text(category),
                  selected: selectedCategory == category,
                  selectedColor: Colors.black,
                  backgroundColor: Colors.grey[300],
                  labelStyle: TextStyle(
                    color:
                        selectedCategory == category
                            ? Colors.white
                            : Colors.black,
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildImageGrid() {
    List<Map<String, String>> filteredImages =
        selectedCategory == "ALL"
            ? allImages
            : allImages
                .where((img) => img['label'] == selectedCategory)
                .toList();

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child:
            filteredImages.isEmpty
                ? Center(
                  child: Text(
                    "No images saved yet.",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                )
                : GridView.builder(
                  itemCount: filteredImages.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Image.file(
                            File(filteredImages[index]['path']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed:
                                () => _deleteImage(
                                  filteredImages[index]['path']!,
                                ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(12),
      color: Colors.black87,
      width: double.infinity,
      child: Text(
        "CompanyName @ 202X. All rights reserved.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[300],
        child: Column(
          children: [
            SizedBox(height: 50),
            _buildDrawerButton("Gallery", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GalleryScreen()),
              );
            }),
            _buildDrawerButton("Components list", () {}),
            _buildDrawerButton("About", () {}),
            _buildDrawerButton("Projects", () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.black),
            ),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
