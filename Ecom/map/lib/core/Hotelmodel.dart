class HotelModel {
  String? name;
  String? city;
  String? address;
  double? rating;
  List<PriceDetails>? priceDetails;
  Coordinates? coordinates;
  String? image;
  String? createdBy;
  String? id;  // Replacing `sId` with `id`

  HotelModel({
    this.name,
    this.city,
    this.address,
    this.rating,
    this.priceDetails,
    this.coordinates,
    this.image,
    this.createdBy,
    this.id,  // Replacing `sId` with `id`
  });

  HotelModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    city = json['city'];
    address = json['address'];
    rating = json['rating'];
    if (json['priceDetails'] != null) {
      priceDetails = <PriceDetails>[];
      json['priceDetails'].forEach((v) {
        priceDetails!.add(new PriceDetails.fromJson(v));
      });
    }
    coordinates = json['coordinates'] != null
        ? new Coordinates.fromJson(json['coordinates'])
        : null;
    image = json['image'];
    createdBy = json['createdBy'];
    id = json['_id'];  // Replacing `sId` with `id`
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['city'] = this.city;
    data['address'] = this.address;
    data['rating'] = this.rating;
    if (this.priceDetails != null) {
      data['priceDetails'] = this.priceDetails!.map((v) => v.toJson()).toList();
    }
    if (this.coordinates != null) {
      data['coordinates'] = this.coordinates!.toJson();
    }
    data['image'] = this.image;
    data['createdBy'] = this.createdBy;
    data['_id'] = this.id;  // Replacing `sId` with `id`
    return data;
  }
}

class PriceDetails {
  String? type;
  int? price;
  String? id;  // Replacing `sId` with `id`

  PriceDetails({this.type, this.price, this.id});

  PriceDetails.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    price = json['price'];
    id = json['_id'];  // Replacing `sId` with `id`
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['price'] = this.price;
    data['_id'] = this.id;  // Replacing `sId` with `id`
    return data;
  }
}

class Coordinates {
  String? type;
  List<double>? coordinates;

  Coordinates({this.type, this.coordinates});

  Coordinates.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}
