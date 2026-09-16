import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'admins';
  final String _adminId = 'admin';

  static const String _isAdminLoggedInKey = 'isAdminLoggedIn';

  /// Signs in admin using email or phone number along with password.
  /// The [identifier] can be either an email address or a phone number.
  Future<bool> signInAdmin(String identifier, String password) async {
    try {
      var adminData = await _supabase
          .from(_table)
          .select()
          .eq('id', _adminId)
          .maybeSingle();

      // Create admin record if it doesn't exist
      if (adminData == null) {
        await _supabase.from(_table).insert({
          'id': _adminId,
          'email': dotenv.env['ADMIN_EMAIL'],
          'phone_number': dotenv.env['ADMIN_PHONE_NUMBER'],
          'password': dotenv.env['ADMIN_PASSWORD'],
        });
        adminData = await _supabase
            .from(_table)
            .select()
            .eq('id', _adminId)
            .single();
      }

      final trimmedIdentifier = identifier.trim();
      final matchesEmail = adminData['email'] == trimmedIdentifier;
      final matchesPhone = adminData['phone_number'] == trimmedIdentifier;

      return (matchesEmail || matchesPhone) &&
          adminData['password'] == password;
    } catch (e) {
      log('Error signing in admin: $e');
      return false;
    }
  }

  Future<bool> isAdminLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAdminLoggedInKey) ?? false;
  }

  Future<void> setAdminLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAdminLoggedInKey, value);
  }
}
