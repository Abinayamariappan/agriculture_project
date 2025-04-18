import 'dart:typed_data';

class Product {
  final int? id;
  final int? farmerId; // Optional: For admin-added products
  final String name;
  final String category;
  final double price;
  final double minKg;
  final double totalKg;
  final String description;
  final Uint8List? image; // Nullable for products without image
  final String status;

  Product({
    this.id,
    this.farmerId,
    required this.name,
    required this.category,
    required this.price,
    required this.minKg,
    required this.totalKg,
    required this.description,
    this.image,
    required this.status,
  });

  /// Create a Product object from a map (from SQLite)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      farmerId: map['farmer_id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      minKg: map['min_kg'],
      totalKg: map['total_kg'],
      description: map['description'],
      image: map['image'],
      status: map['status'],
    );
  }

  /// Convert a Product object into a map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'name': name,
      'category': category,
      'price': price,
      'min_kg': minKg,
      'total_kg': totalKg,
      'description': description,
      'image': image,
      'status': status,
    };
  }

  /// Helper to create a modified copy of a product
  Product copyWith({
    int? id,
    int? farmerId,
    String? name,
    String? category,
    double? price,
    double? minKg,
    double? totalKg,
    String? description,
    Uint8List? image,
    String? status,
  }) {
    return Product(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      minKg: minKg ?? this.minKg,
      totalKg: totalKg ?? this.totalKg,
      description: description ?? this.description,
      image: image ?? this.image,
      status: status ?? this.status,
    );
  }
}
