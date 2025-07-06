import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:otzaria/data/data_providers/tantivy_data_provider.dart';
import 'package:otzaria/indexing/repository/indexing_repository.dart';
import 'package:otzaria/models/books.dart';
import 'package:otzaria/utils/text_manipulation.dart';

/// Watches the library directory for file changes and updates the search index.
class LibraryWatcher {
  final IndexingRepository _repository;
  final TantivyDataProvider _dataProvider;
  StreamSubscription<FileSystemEvent>? _subscription;

  LibraryWatcher(this._repository, this._dataProvider);

  /// Start watching the library directory recursively.
  void start() {
    final path = Settings.getValue<String>('key-library-path') ?? '.';
    _subscription?.cancel();
    _subscription = Directory(path).watch(recursive: true).listen(handleEvent);
  }

  /// Stop watching the directory.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Handle a single file system [event].
  @visibleForTesting
  Future<void> handleEvent(FileSystemEvent event) async {
    final filePath = event.path;

    if (event is FileSystemModifyEvent || event is FileSystemCreateEvent) {
      if (FileSystemEntity.isDirectorySync(filePath)) return;
      final lower = filePath.toLowerCase();
      if (!(lower.endsWith('.txt') ||
          lower.endsWith('.docx') ||
          lower.endsWith('.pdf'))) {
        return;
      }
      await _dataProvider.deleteFileFromIndex(filePath);
      final title = getTitleFromPath(filePath);
      Book? book;
      if (lower.endsWith('.pdf')) {
        book = PdfBook(title: title, path: filePath, topics: '');
      } else {
        book = TextBook(title: title, topics: '');
      }
      await _repository.indexBook(book);
    } else if (event is FileSystemDeleteEvent) {
      await _dataProvider.deleteFileFromIndex(filePath);
    }
  }
}
