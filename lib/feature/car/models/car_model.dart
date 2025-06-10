class CarModel {
  final int id;
  final String desc;
  final String price;
  final int available;
  final int rent;
  final String killo;
  final String ownerShipImageUrl;
  final int colorId;
  final int gearId;
  final int brandId;
  final int modelId;
  final int userId;
  final List<CarImage> images;
  final String createdAt;


  CarModel({
    required this.id,
    required this.desc,
    required this.price,
    required this.available,
    required this.rent,
    required this.killo,
    required this.ownerShipImageUrl,
    required this.colorId,
    required this.gearId,
    required this.brandId,
    required this.modelId,
    required this.userId,
    required this.images,
    required this.createdAt,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['car']['id'],
      desc: json['car']['desc'],
      price: json['car']['price'],
      available: json['car']['available'],
      rent: json['car']['rent'],
      killo: json['car']['killo'],
      ownerShipImageUrl: json['car']['ownerShipImageUrl'],
      colorId: json['car']['colorId'],
      gearId: json['car']['gearId'],
      brandId: json['car']['brandId'],
      modelId: json['car']['modelId'],
      userId: json['car']['userId'],
      images: (json['images'] as List)
          .map((image) => CarImage.fromJson(image))
          .toList(),
      createdAt: json['car']['created_at'],
    );
  }
}

class CarImage {
  final int id;
  final String imageUrl;
  final int carId;

  CarImage({
    required this.id,
    required this.imageUrl,
    required this.carId,
  });

  factory CarImage.fromJson(Map<String, dynamic> json) {
    return CarImage(
      id: json['id'],
      imageUrl: json['imageUrl'],
      carId: json['carId'],
    );
  }
} 