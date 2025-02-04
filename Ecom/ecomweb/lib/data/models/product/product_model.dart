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
  String? connectorType;
  bool? installationIncluded;
  int? stockAvailability;
  String? description;
  String? sId;

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
    this.connectorType,
    this.installationIncluded,
    this.stockAvailability,
    this.description,
    this.sId,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    chargerId = json['chargerId'];
    chargerType = json['chargerType'];
    maxCurrent = json['maxCurrent'];
    price = json['price'];
    images = List<String>.from(json['images']);
    brand = json['brand'];
    chargingSpeed = json['chargingSpeed'];
    compatibility = List<String>.from(json['compatibility']);
    warranty = json['warranty'];
    connectorType = json['connectorType'];
    installationIncluded = json['installationIncluded'];
    stockAvailability = json['stockAvailability'];
    description = json['description'];
    sId = json['_id'];
  }

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
      'connectorType': connectorType,
      'installationIncluded': installationIncluded,
      'stockAvailability': stockAvailability,
      'description': description,
      '_id': sId,
    };
  }
}
