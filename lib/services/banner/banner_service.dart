import 'package:gep/models/banner.dart';
import 'package:gep/models/paginated_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BannerService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'banners';

  Stream<List<BannerModel>> getBannersStream() {
    return _supabase.from(_table).stream(primaryKey: ['id']).map((rows) {
      return rows
          .map((row) => BannerModel.fromMap(_mapRow(row), row['id'] as String))
          .toList();
    });
  }

  Future<PaginatedResult<BannerModel>> getBannersPaginated({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize;

    var query = _supabase.from(_table).select();
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('title', '%$searchQuery%');
    }

    final data = await query.order('id', ascending: false).range(from, to);

    final hasMore = data.length > pageSize;
    final items = data
        .take(pageSize)
        .map((row) => BannerModel.fromMap(_mapRow(row), row['id'] as String))
        .toList();

    return PaginatedResult(items: items, hasMore: hasMore);
  }

  Future<void> addBanner(BannerModel banner) async {
    await _supabase.from(_table).insert(_toRow(banner));
  }

  Future<void> updateBanner(String id, BannerModel banner) async {
    await _supabase.from(_table).update(_toRow(banner)).eq('id', id);
  }

  Future<void> deleteBanner(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }

  Future<BannerModel> getBanner(String id) async {
    final data = await _supabase.from(_table).select().eq('id', id).single();
    if (data.isEmpty) {
      throw Exception('Banner not found');
    }
    return BannerModel.fromMap(_mapRow(data), data['id'] as String);
  }

  Map<String, dynamic> _toRow(BannerModel banner) => {
        'title': banner.title,
        'image_url': banner.imageUrl,
      };

  Map<String, dynamic> _mapRow(Map<String, dynamic> row) => {
        'title': row['title'],
        'imageUrl': row['image_url'],
      };
}
