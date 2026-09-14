import 'dart:developer';

import 'package:gep/models/note.dart';
import 'package:gep/models/paginated_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _categoriesTable = 'note_categories';
  final String _notesTable = 'notes';

  Future<List<String>> getCategories() async {
    try {
      final data = await _supabase.from(_categoriesTable).select('id');
      return data.map<String>((row) => row['id'] as String).toList();
    } catch (e) {
      log('Error getting categories: $e');
      return [];
    }
  }

  /// Creates a category if it doesn't already exist.
  ///
  /// Uses `upsert` with `ignoreDuplicates: true` so calling this
  /// repeatedly with the same [category] is a safe no-op instead of
  /// throwing a duplicate-key error.
  Future<void> addCategory(String category) async {
    final trimmedCategory = category.trim();
    try {
      await _supabase
          .from(_categoriesTable)
          .upsert(
            {
              'id': trimmedCategory,
              'created_at': DateTime.now().toIso8601String(),
            },
            onConflict: 'id',
            ignoreDuplicates: true,
          );
    } catch (e) {
      log('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String category) async {
    try {
      // Delete all notes in the category
      await _supabase.from(_notesTable).delete().eq('category_id', category);

      // Delete the category itself
      await _supabase.from(_categoriesTable).delete().eq('id', category);
    } catch (e) {
      log('Error deleting category: $e');
      rethrow;
    }
  }

  Stream<List<String>> getCategoriesStream() {
    return _supabase
        .from(_categoriesTable)
        .stream(primaryKey: ['id'])
        .map((rows) => rows.map((row) => row['id'] as String).toList());
  }

  /// Fetch a paginated slice of categories ordered by newest first.
  ///
  /// [page] is zero-based. Returns at most [pageSize] items plus a
  /// [hasMore] flag determined by requesting one extra row.
  ///
  /// Optionally filter by [searchQuery] using a case-insensitive
  /// partial match on the category id (name).
  Future<PaginatedResult<String>> getCategoriesPaginated({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    try {
      final from = page * pageSize;
      final to = from + pageSize; // fetch one extra to detect hasMore

      var query = _supabase.from(_categoriesTable).select('id');

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('id', '%$searchQuery%');
      }

      final data = await query
          .order('created_at', ascending: false)
          .range(from, to);

      final hasMore = data.length > pageSize;
      final items = data
          .take(pageSize)
          .map<String>((row) => row['id'] as String)
          .toList();

      return PaginatedResult(items: items, hasMore: hasMore);
    } catch (e) {
      log('Error fetching paginated categories: $e');
      rethrow;
    }
  }

  /// Inserts a note under [category].
  ///
  /// Ensures the category row exists first (via upsert) so this can
  /// never fail with a foreign key violation (23503) even if the
  /// category wasn't explicitly created beforehand, or was created
  /// with different casing/whitespace.
  Future<void> addNote(String category, String title, String url) async {
    final trimmedCategory = category.trim();
    if (trimmedCategory.isEmpty) {
      throw ArgumentError('Category cannot be empty');
    }
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }

    await _supabase
        .from(_categoriesTable)
        .upsert(
          {
            'id': trimmedCategory,
            'created_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'id',
          ignoreDuplicates: true,
        );

    await _supabase.from(_notesTable).insert({
      'category_id': trimmedCategory,
      'title': trimmedTitle,
      'url': url,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteNote(String category, String noteId) async {
    await _supabase.from(_notesTable).delete().eq('id', noteId);
  }

  Stream<List<Note>> getNotesStream(String category) {
    return _supabase
        .from(_notesTable)
        .stream(primaryKey: ['id'])
        .eq('category_id', category)
        .map((rows) {
          final notes = rows
              .map(
                (row) => Note.fromMap(row['id'] as String, {
                  'title': row['title'],
                  'url': row['url'],
                  'timestamp': row['timestamp'],
                  'accessGranted': row['access_granted'] ?? false,
                }),
              )
              .toList();
          notes.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return notes;
        });
  }

  Future<PaginatedResult<Note>> getNotesPaginated({
    required String category,
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    try {
      final from = page * pageSize;
      final to = from + pageSize;

      var query = _supabase
          .from(_notesTable)
          .select()
          .eq('category_id', category);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%');
      }

      final data = await query
          .order('timestamp', ascending: false)
          .range(from, to);

      final hasMore = data.length > pageSize;
      final items = data
          .take(pageSize)
          .map(
            (row) => Note.fromMap(row['id'] as String, {
              'title': row['title'],
              'url': row['url'],
              'timestamp': row['timestamp'],
              'accessGranted': row['access_granted'] ?? false,
            }),
          )
          .toList();

      return PaginatedResult(items: items, hasMore: hasMore);
    } catch (e) {
      log('Error fetching paginated notes: $e');
      rethrow;
    }
  }
}
