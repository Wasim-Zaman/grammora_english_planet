import '../../models/about_me.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AboutMeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'about_me';
  final String _docId = 'admin';

  Future<AboutMe> getAboutMeData() async {
    final data =
        await _supabase.from(_table).select().eq('id', _docId).maybeSingle();
    if (data != null) {
      return AboutMe.fromMap(_mapRow(data));
    }
    return AboutMe();
  }

  Future<void> updateAboutMeData(AboutMe aboutMe) async {
    await _supabase.from(_table).upsert({
      'id': _docId,
      ..._toRow(aboutMe),
    });
  }

  Stream<AboutMe> getAboutMeStream() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('id', _docId)
        .map((rows) {
      if (rows.isNotEmpty) {
        return AboutMe.fromMap(_mapRow(rows.first));
      }
      return AboutMe();
    });
  }

  Map<String, dynamic> _toRow(AboutMe aboutMe) => {
        'profile_image_url': aboutMe.profileImageUrl,
        'latitude': aboutMe.latitude,
        'longitude': aboutMe.longitude,
        'youtube_channel_link': aboutMe.youtubeChannelLink,
        'resume_url': aboutMe.resumeUrl,
      };

  Map<String, dynamic> _mapRow(Map<String, dynamic> row) => {
        'profileImageUrl': row['profile_image_url'],
        'latitude': row['latitude'] ?? 0.0,
        'longitude': row['longitude'] ?? 0.0,
        'youtubeChannelLink': row['youtube_channel_link'] ?? '',
        'resumeUrl': row['resume_url'],
      };
}
