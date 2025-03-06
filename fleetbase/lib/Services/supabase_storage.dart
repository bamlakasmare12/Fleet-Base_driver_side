import 'package:supabase/supabase.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
class SupabaseStorage {
   final SupabaseClient _supabase = Supabase.instance.client;
  final String tokenadmin =
      'eyJhbGciOiJIUzI1NiIsImtpZCI6IkN5UFJXbUZCRUlOcDNrK0ciLCJ0eXAiOiJKV1QifQ.eyJhYWwiOiJhYWwxIiwiYW1yIjpbeyJtZXRob2QiOiJwYXNzd29yZCIsInRpbWVzdGFtcCI6MTczOTI2NzEzOH1dLCJhcHBfbWV0YWRhdGEiOnsicHJvdmlkZXIiOiJlbWFpbCIsInByb3ZpZGVycyI6WyJlbWFpbCJdfSwiYXVkIjoiYXV0aGVudGljYXRlZCIsImVtYWlsIjoieWFwaXI4OTk2NEBrdmVnZy5jb20iLCJleHAiOjE3NDAxNjQ0NzYsImlhdCI6MTc0MDE2MDg3NiwiaXNfYW5vbnltb3VzIjpmYWxzZSwiaXNzIjoiaHR0cHM6Ly9oeG9wbHZxcWJrc2Fma3ptaXhndi5zdXBhYmFzZS5jby9hdXRoL3YxIiwib3JnYW5pemF0aW9uX2lkIjpudWxsLCJwaG9uZSI6IiIsInJvbGUiOiJhdXRoZW50aWNhdGVkIiwic2Vzc2lvbl9pZCI6ImZjZWRkNDUwLWM4NjgtNDc2My1iNzNlLWY0NGJjMTVhNThkZCIsInN1YiI6ImZmNzAzYzBjLTdhNWEtNDQwOC1hNWIxLWMzNWYwNTFiYTA5YSIsInVzZXJfbWV0YWRhdGEiOnsiZW1haWwiOiJ5YXBpcjg5OTY0QGt2ZWdnLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpbWFnZSI6IiIsIm5hbWUiOiJFdHN1YiIsIm9yZ2FuaXphdGlvbiI6IlN1cHBseSBhdCBsbGMiLCJvcmdhbml6YXRpb25faWQiOjc4LCJwaG9uZV92ZXJpZmllZCI6ZmFsc2UsInJvbGUiOiJhZG1pbiIsInN1YiI6ImZmNzAzYzBjLTdhNWEtNDQwOC1hNWIxLWMzNWYwNTFiYTA5YSJ9LCJ1c2VyX3JvbGUiOiJhZG1pbiJ9.mcmxG4v_UBVDGGED9ptp8lehLWMNrm1pVThfBs_lRsw';
  

  Future<String?> uploadDeliveryProof(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final filePath = 'deliveries/${DateTime.now().toIso8601String()}.jpg';

      await _supabase.storage
          .from('client_signature')
          .upload(filePath, bytes as File, fileOptions: FileOptions(contentType: 'image/jpeg'));

      return _supabase.storage
          .from('client_signature')
          .getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }
}