import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:otzaria/indexing/library_watcher.dart';
import '../mocks/mock_indexing_dependencies.dart';

void main() {
  group('LibraryWatcher', () {
    late MockIndexingRepository repository;
    late MockTantivyDataProvider provider;
    late LibraryWatcher watcher;

    setUp(() {
      repository = MockIndexingRepository();
      provider = MockTantivyDataProvider();
      watcher = LibraryWatcher(repository, provider);
    });

    test('handles create event', () async {
      when(provider.deleteFileFromIndex(any)).thenAnswer((_) async {});
      when(repository.indexBook(any)).thenAnswer((_) async {});
      final event = FileSystemCreateEvent('book.txt', false);
      await watcher.handleEvent(event);
      verify(provider.deleteFileFromIndex('book.txt')).called(1);
      verify(repository.indexBook(any)).called(1);
    });

    test('handles modify event', () async {
      when(provider.deleteFileFromIndex(any)).thenAnswer((_) async {});
      when(repository.indexBook(any)).thenAnswer((_) async {});
      final event = FileSystemModifyEvent('book.txt', false, true);
      await watcher.handleEvent(event);
      verify(provider.deleteFileFromIndex('book.txt')).called(1);
      verify(repository.indexBook(any)).called(1);
    });

    test('handles delete event', () async {
      when(provider.deleteFileFromIndex(any)).thenAnswer((_) async {});
      final event = FileSystemDeleteEvent('book.txt', false);
      await watcher.handleEvent(event);
      verify(provider.deleteFileFromIndex('book.txt')).called(1);
      verifyNever(repository.indexBook(any));
    });
  });
}
