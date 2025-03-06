import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorage {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadDeliveryProof(Uint8List image) async {
    try {
      // 1. Get authenticated user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');
      // 2. Policy-aligned file path structure
      final filePath = 
          '$userId/deliveries/${DateTime.now().toIso8601String()}.jpg';

      // 3. Secure upload with user session
      await _supabase.storage
          .from('client_signature')
          .uploadBinary(
            filePath, 
            image,
            fileOptions: FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      // 4. Get public URL
      return _supabase.storage
          .from('client_signature')
          .getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Upload failed: ${e.toString()}');
    }
  }
}