import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gep/services/notes/notes_service.dart';
import 'package:gep/services/storage/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://nwttrwoysaatmkgsfazl.supabase.co',
      publishableKey: 'sb_publishable_hbevrdMSxmpcJALZ79Yrow_l1lmqstA',
    );
  });

  test('verify notes upload to supabase storage and notes service insertion', () async {
    final storageService = StorageService();
    final notesService = NotesService();

    // 1. Create a dummy test PDF file
    final tempDir = Directory.systemTemp.createTempSync('notes_test_');
    final dummyPdf = File('${tempDir.path}/test_upload.pdf');
    await dummyPdf.writeAsBytes([0x25, 0x50, 0x44, 0x46, 0x2D]); // %PDF-

    final testCategory = 'Tenses';
    final testTitle = 'Test Unit Note ${DateTime.now().millisecondsSinceEpoch}';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = 'notes/$testCategory/$fileName';

    try {
      // 2. Upload via StorageService with content type
      final downloadUrl = await storageService.uploadFile(
        filePath,
        dummyPdf,
        contentType: 'application/pdf',
      );
      expect(downloadUrl, contains('notes/Tenses/'));
      print('Uploaded downloadUrl: $downloadUrl');

      // 3. Add Note via NotesService
      await notesService.addNote(testCategory, testTitle, downloadUrl);
      print('Added note record to DB');

      // 4. Retrieve and verify
      final notesResult = await notesService.getNotesPaginated(
        category: testCategory,
        page: 0,
        pageSize: 10,
        searchQuery: testTitle,
      );
      expect(notesResult.items.isNotEmpty, isTrue);
      final addedNote = notesResult.items.firstWhere((n) => n.title == testTitle);
      expect(addedNote.title, equals(testTitle));
      expect(addedNote.url, equals(downloadUrl));
      print('Verified note in DB: id=${addedNote.id}, title=${addedNote.title}');

      // 5. Clean up from DB and Storage
      await notesService.deleteNote(testCategory, addedNote.id);
      await storageService.deleteFile(downloadUrl);
      print('Cleaned up test note from DB and Storage');
    } finally {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    }
  });

  test('verify NotesService.addNote rejects empty category or title', () async {
    final notesService = NotesService();
    expect(
      () => notesService.addNote('', 'Title', 'https://example.com/file.pdf'),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => notesService.addNote('   ', 'Title', 'https://example.com/file.pdf'),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => notesService.addNote('Category', '', 'https://example.com/file.pdf'),
      throwsA(isA<ArgumentError>()),
    );
  });
}
