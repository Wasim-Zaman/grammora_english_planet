import '../../models/banner.dart';
import '../../models/paginated_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BannerService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'banners';

  Stream<List<BannerModel>> getBannersStream() {
    return _supabase.from(_table).stream(primaryKey: ['id']).map((rows) {
      return rows
          .map((row) => BannerModel.fromMap(_mapRow(row), row['id'].toString()))
          .toList();
    });
  }

  Future<List<BannerModel>> getBanners() async {
    final data = await _supabase.from(_table).select().order('id', ascending: false);
    return (data as List)
        .map((row) => BannerModel.fromMap(_mapRow(row as Map<String, dynamic>), row['id'].toString()))
        .toList();
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
        .map((row) => BannerModel.fromMap(_mapRow(row), row['id'].toString()))
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
    return BannerModel.fromMap(_mapRow(data), data['id'].toString());
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
