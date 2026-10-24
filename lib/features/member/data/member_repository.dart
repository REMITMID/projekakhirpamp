import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/member_model.dart';

class MemberRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<MemberModel>> fetchMembers() async {
    final response = await _client
        .from('members')
        .select()
        .order('created_at', ascending: false);
    return response.map(MemberModel.fromJson).toList();
  }

  Future<MemberModel> addMember(MemberModel member) async {
    final response = await _client
        .from('members')
        .insert(member.toJson())
        .select()
        .single();
    return MemberModel.fromJson(response);
  }

  Future<void> deleteMember(String id) async {
    // Returning one row also verifies that RLS allowed the deletion.
    await _client.from('members').delete().eq('id', id).select('id').single();
  }

  Future<MemberModel> updateMember(MemberModel member) async {
    final id = member.id;
    if (id == null || id.isEmpty) {
      throw ArgumentError('ID anggota wajib tersedia untuk memperbarui data.');
    }
    final response = await _client
        .from('members')
        .update(member.toJson())
        .eq('id', id)
        .select()
        .single();
    return MemberModel.fromJson(response);
  }
}
