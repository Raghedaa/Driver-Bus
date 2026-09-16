class PassengerModel {
  final int? id;
  final int? ticketId;
  final String name;
  final String? phoneNumber;
  final String? gender;
  final String? imageUrl;
  final List<int> seatNumbers;
  final String status;
  final String? pnrCode;
  final String? paymentMethod;
  final double? totalPrice;
  final String? currency;
  final String? createdAt;

  PassengerModel({
    this.id,
    this.ticketId,
    required this.name,
    this.phoneNumber,
    this.gender,
    this.imageUrl,
    required this.seatNumbers,
    required this.status,
    this.pnrCode,
    this.paymentMethod,
    this.totalPrice,
    this.currency,
    this.createdAt,
  });

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    final passengerData = json['passenger'] as Map<String, dynamic>? ?? {};
    final paymentSummary = json['payment_summary'] as Map<String, dynamic>?;

    List<int> seats = [];
    if (json['seat_numbers'] != null) {
      seats = List<int>.from(
        json['seat_numbers'].map(
          (s) => s is int ? s : int.tryParse(s.toString()) ?? 0,
        ),
      );
    }

    double? price;
    if (paymentSummary != null && paymentSummary['final_paid'] != null) {
      price = double.tryParse(paymentSummary['final_paid'].toString());
    } else if (json['total_price'] != null) {
      price = double.tryParse(json['total_price'].toString());
    }

    return PassengerModel(
      ticketId: json['id'],
      id: passengerData['id'],
      name: passengerData['name'] ?? 'Unknown',
      phoneNumber: passengerData['phone_number'],
      gender: passengerData['gender'],
      imageUrl: passengerData['image_url'],
      seatNumbers: seats,
      status: json['status'] ?? 'pending',
      pnrCode: json['pnr_code'],
      paymentMethod: json['payment_method'] ?? paymentSummary?['method'],
      totalPrice: price,
      currency: paymentSummary?['currency'] as String?,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'name': name,
      'phone_number': phoneNumber,
      'gender': gender,
      'image_url': imageUrl,
      'seat_numbers': seatNumbers,
      'status': status,
      'pnr_code': pnrCode,
      'payment_method': paymentMethod,
      'total_price': totalPrice,
      'currency': currency,
      'created_at': createdAt,
    };
  }

  String get seatNumbersFormatted => seatNumbers.join(', ');
  bool get isPaid => status.toLowerCase() == 'confirmed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  String get totalPriceFormatted {
    if (totalPrice == null) {
      return paymentMethodFormatted;
    }
    final curr = currency ?? 'SYP';
    return '${totalPrice!.toStringAsFixed(curr == 'USD' ? 2 : 0)} $curr';
  }

  String get paymentMethodFormatted {
    if (paymentMethod == null) return 'N/A';
    switch (paymentMethod) {
      case 'cash':
        return 'Cash';
      case 'wallet':
        return 'Wallet';
      case 'credit_card':
        return 'Card';
      default:
        return 'Online';
    }
  }

  String get genderFormatted {
    if (gender == null) return 'N/A';
    return gender == 'male' ? 'Male' : 'Female';
  }

  PassengerModel copyWith({
    int? id,
    int? ticketId,
    String? name,
    String? phoneNumber,
    String? gender,
    String? imageUrl,
    List<int>? seatNumbers,
    String? status,
    String? pnrCode,
    String? paymentMethod,
    double? totalPrice,
    String? currency,
    String? createdAt,
  }) {
    return PassengerModel(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      imageUrl: imageUrl ?? this.imageUrl,
      seatNumbers: seatNumbers ?? this.seatNumbers,
      status: status ?? this.status,
      pnrCode: pnrCode ?? this.pnrCode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
