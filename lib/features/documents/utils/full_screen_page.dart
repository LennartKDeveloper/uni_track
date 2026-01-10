import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uni_track/features/documents/utils/gallery_item.dart';

class FullScreenImagePage extends StatefulWidget {
  final GalleryItem item;
  final Function(String newTitle) onTitleChanged;

  const FullScreenImagePage({
    super.key,
    required this.item,
    required this.onTitleChanged,
  });

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  late String _currentTitle;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.item.title;
  }

  Future<void> _editTitle() async {
    String? newTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        String tempVal = _currentTitle;
        return AlertDialog(
          title: const Text('Titel bearbeiten'),
          content: TextFormField(
            initialValue: _currentTitle,
            autofocus: true,
            onChanged: (val) => tempVal = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempVal),
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );

    if (newTitle != null && newTitle.trim().isNotEmpty) {
      setState(() {
        _currentTitle = newTitle;
      });
      
      widget.onTitleChanged(newTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                File(widget.item.imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surface.withOpacity(0.6),
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Center(
              child: InkWell(
                onTap: _editTitle,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  child: Text(
                    _currentTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
