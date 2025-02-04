class UserModel {
  String? sId;
  String? fullName;
  String? email;
  String? password;
  String? phoneNumber;
  String? address;
  String? city;
  String? state;
  int? profileProgress;
  String? id;
  String? updatedOn;
  String? createdOn;
  String? profileImage; // New field for profile image URL or path

  // Constructor with named parameters
  UserModel({
    this.sId,
    this.fullName,
    this.email,
    this.password,
    this.phoneNumber,
    this.address,
    this.city,
    this.state,
    this.profileProgress,
    this.id,
    this.updatedOn,
    this.createdOn,
    this.profileImage, // Adding profile image to the constructor
  });

  // Named constructor to create UserModel from a JSON response
  UserModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    email = json['email'];
    password = json['password'];
    phoneNumber = json['phoneNumber'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    profileProgress = json['profileProgress'];
    id = json['id'];
    updatedOn = json['updatedOn'];
    createdOn = json['createdOn'];
    profileImage = json['profileImage']; // Deserialize the profile image field
  }

  // Method to convert UserModel to a JSON map for API request
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = this.sId;
    data['fullName'] = this.fullName;
    data['email'] = this.email;
    data['password'] = this.password;
    data['phoneNumber'] = this.phoneNumber;
    data['address'] = this.address;
    data['city'] = this.city;
    data['state'] = this.state;
    data['profileProgress'] = this.profileProgress;
    data['id'] = this.id;
    data['updatedOn'] = this.updatedOn;
    data['createdOn'] = this.createdOn;
    data['profileImage'] = this.profileImage; // Serialize the profile image field
    return data;
  }
}
