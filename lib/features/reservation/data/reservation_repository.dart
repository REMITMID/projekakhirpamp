import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/reservation_model.dart';

class ReservationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ReservationModel>> fetchReservations() async {
    final response = await _client
        .from('reservations')
        .select()
        .order('created_at', ascending: false);
    return (response as List)
        .map((e) => ReservationModel.fromJson(e))
        .toList();
  }

  Future<void> addReservation(ReservationModel reservation) async {
    await _client.from('reservations').insert(reservation.toJson());
  }

  Future<void> updateReservation(ReservationModel reservation) async {
    await _client
        .from('reservations')
        .update(reservation.toJson())
        .eq('id', reservation.id!);
  }

  Future<void> deleteReservation(String id) async {
    await _client.from('reservations').delete().eq('id', id);
  }
}