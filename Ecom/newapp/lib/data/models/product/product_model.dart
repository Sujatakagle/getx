class ProductModel {
  String? chargerId;
  String? chargerType;
  int? maxCurrent;
  double? price;
  List<String>? images;
  String? brand;
  String? chargingSpeed;
  List<String>? compatibility;
  String? warranty;
  Connector? connector; // New field to handle connector type and details
  bool? installationIncluded;
  int? stockAvailability;
  String? description;
  String? sId;
  String? category; // New field for category reference
  double? averageRating; // New field for average rating

  ProductModel({
    this.chargerId,
    this.chargerType,
    this.maxCurrent,
    this.price,
    this.images,
    this.brand,
    this.chargingSpeed,
    this.compatibility,
    this.warranty,
    this.connector, // Connector in constructor
    this.installationIncluded,
    this.stockAvailability,
    this.description,
    this.sId,
    this.category, // Category in constructor
    this.averageRating, // Average rating in constructor
  });

  // Factory constructor for creating an instance from a JSON object
  ProductModel.fromJson(Map<String, dynamic> json) {
    chargerId = json['chargerId'];
    chargerType = json['chargerType'];
    maxCurrent = int.tryParse(json['maxCurrent'].toString()) ?? 0;
    price = double.tryParse(json['price'].toString()) ?? 0.0;
    images = List<String>.from(json['images'] ?? []);
    brand = json['brand'];
    chargingSpeed = json['chargingSpeed'];
    compatibility = List<String>.from(json['compatibility'] ?? []);
    warranty = json['warranty'];
    connector = json['connector'] != null
        ? Connector.fromJson(json['connector'])
        : null; // Parsing connector data
    installationIncluded = json['installationIncluded'] ?? false;
    stockAvailability = int.tryParse(json['stockAvailability'].toString()) ?? 0;
    description = json['description'];
    sId = json['_id'];
    category = json['category']; // Parsing category field
    averageRating = json['averageRating'] != null
        ? double.tryParse(json['averageRating'].toString()) ?? 0.0
        : 0.0; // Parsing averageRating field
  }

  // Method for converting the instance into a JSON object
  Map<String, dynamic> toJson() {
    return {
      'chargerId': chargerId,
      'chargerType': chargerType,
      'maxCurrent': maxCurrent,
      'price': price,
      'images': images,
      'brand': brand,
      'chargingSpeed': chargingSpeed,
      'compatibility': compatibility,
      'warranty': warranty,
      'connector': connector?.toJson(), // Adding connector to JSON
      'installationIncluded': installationIncluded,
      'stockAvailability': stockAvailability,
      'description': description,
      '_id': sId,
      'category': category, // Adding category to JSON
      'averageRating': averageRating, // Adding averageRating to JSON
    };
  }
}

// Connector class to handle 'type' and 'details'
class Connector {
  String? type;
  String? details;

  Connector({this.type, this.details});

  // Factory constructor to create a Connector instance from a JSON object
  factory Connector.fromJson(Map<String, dynamic> json) {
    return Connector(
      type: json['type'],
      details: json['details'],
    );
  }

  // Method to convert the Connector instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'details': details,
    };
  }
}
