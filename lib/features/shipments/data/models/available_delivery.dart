class AvailableDelivery {
  const AvailableDelivery({
    required this.orderId,
    required this.pickupCity,
    required this.pickupProvince,
    required this.deliveryCity,
    required this.deliveryProvince,
    required this.itemCount,
    required this.createdAt,
  });

  final String orderId;
  final String pickupCity;
  final String pickupProvince;
  final String deliveryCity;
  final String deliveryProvince;
  final int itemCount;
  final DateTime createdAt;
}
