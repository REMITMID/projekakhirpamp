import 'package:flutter/material.dart';
import '../../data/reservation_repository.dart';
import '../../domain/models/reservation_model.dart';

class ReservationProvider extends ChangeNotifier {
  final ReservationRepository _repository = ReservationRepository();
  List<ReservationModel> _reservations = [];
  bool _isLoading = false;
  bool _isGridView = false;

  List<ReservationModel> get reservations => _reservations;
  bool get isLoading => _isLoading;
  bool get isGridView => _isGridView;

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  Future<void> loadReservations() async {
    _isLoading = true;
    notifyListeners();
    try {
      _reservations = await _repository.fetchReservations();
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReservation(ReservationModel reservation) async {
    await _repository.addReservation(reservation);
    await loadReservations();
  }

  Future<void> updateReservation(ReservationModel reservation) async {
    await _repository.updateReservation(reservation);
    await loadReservations();
  }

  Future<void> deleteReservation(String id) async {
    await _repository.deleteReservation(id);
    await loadReservations();
  }
}