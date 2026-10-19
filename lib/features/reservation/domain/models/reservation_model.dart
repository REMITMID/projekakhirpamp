class ReservationModel {
  final String? id;
  final String memberName;
  final String bookTitle;
  final String reservationDate;
  final String pickupDeadline;
  final String status;

  ReservationModel({
    this.id,
    required this.memberName,
    required this.bookTitle,
    required this.reservationDate,
    required this.pickupDeadline,
    required this.status,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id']?.toString(),
      memberName: json['member_name'] ?? '',
      bookTitle: json['book_title'] ?? '',
      reservationDate: json['reservation_date'] ?? '',
      pickupDeadline: json['pickup_deadline'] ?? '',
      status: json['status'] ?? 'Menunggu',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'member_name': memberName,
      'book_title': bookTitle,
      'reservation_date': reservationDate,
      'pickup_deadline': pickupDeadline,
      'status': status,
    };
  }
}