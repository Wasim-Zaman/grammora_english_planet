import 'dart:developer';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String bucket = 'app-storage';

  Future<String> uploadFile(
    String path,
    File file, {
    String? contentType,
  }) async {
    final mimeType = contentType ?? _inferContentType(path);
    await _supabase.storage.from(bucket).upload(
          path,
          file,
          fileOptions: FileOptions(
            upsert: true,
            contentType: mimeType,
          ),
        );
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }

  static String? _inferContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    return null;
  }


  Future<void> deleteFolder(String folderPath) async {
    try {
      final files =
          await _supabase.storage.from(bucket).list(path: folderPath);
      final paths = files.map((f) => '$folderPath/${f.name}').toList();
      if (paths.isNotEmpty) {
        await _supabase.storage.from(bucket).remove(paths);
      }
    } catch (e) {
      log('Error deleting folder: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final path = _extractPathFromUrl(fileUrl);
      if (path == null || path.isEmpty) return;
      await _supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      log('Error deleting file: $e');
      rethrow;
    }
  }

  // Public URL format: https://<ref>.supabase.co/storage/v1/object/public/<bucket>/<path>
  String? _extractPathFromUrl(String fileUrl) {
    final uri = Uri.tryParse(fileUrl);
    if (uri == null) return null;

    final segments = uri.pathSegments;
    final publicIndex = segments.indexOf('public');
    if (publicIndex == -1 || publicIndex + 2 >= segments.length) return null;

    return segments.sublist(publicIndex + 2).join('/');
  }
}
