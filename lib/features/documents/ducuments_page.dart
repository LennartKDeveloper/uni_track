import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_track/features/documents/utils/full_screen_page.dart';
import 'package:uni_track/features/documents/utils/gallery_item.dart';
import 'package:uni_track/features/documents/data/image_page_hander.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<GalleryItem> _items = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedItems = await ImagePageHandler.loadItems();
    setState(() {
      _items = loadedItems;
      _isLoading = false;
    });
  }

  Future<void> _addNewImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    if (!mounted) return;

    String? title =
        await _showTitleDialog(); // Code ausgelagert in Hilfsmethode

    if (title == null || title.isEmpty) {
      title = "Unbenannt";
    }

    setState(() {
      _items.add(GalleryItem(imagePath: image.path, title: title!));
    });
    await ImagePageHandler.saveItems(_items);
  }

  // Hilfsmethode für den Dialog (wird hier und in Detailansicht genutzt,
  // hier aber lokal dupliziert oder man könnte es global machen)
  Future<String?> _showTitleDialog([String? currentTitle]) {
    String tempTitle = currentTitle ?? "";
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            currentTitle == null ? 'Bildtitel eingeben' : 'Titel bearbeiten',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          content: TextFormField(
            initialValue: tempTitle,
            autofocus: true,
            decoration: const InputDecoration(hintText: "z.B. Urlaub 2023"),
            onChanged: (val) => tempTitle = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempTitle),
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(int index) async {
    setState(() {
      _items.removeAt(index);
    });
    await ImagePageHandler.saveItems(_items);
  }

  // Öffnet Detailansicht und übergibt Callback zum Speichern von Änderungen
  void _openFullScreen(GalleryItem item, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImagePage(
          item: item,
          onTitleChanged: (newTitle) async {
            // Callback: Wenn Titel im Detail geändert wird
            setState(() {
              _items[index] = item.copyWith(title: newTitle);
            });
            await ImagePageHandler.saveItems(_items);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _items.isEmpty
                        ? Center(
                            child: Text(
                              "Keine Bilder vorhanden.\nDrücke + um eines hinzuzufügen.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 10.0,
                                ),
                                child: _buildImageCard(item, index),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewImage,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildImageCard(GalleryItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openFullScreen(item, index), // Index übergeben!
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 200,
                  child: Image.file(
                    File(item.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.displayMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () => _deleteItem(index),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
