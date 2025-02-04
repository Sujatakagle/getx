class UserModel {
  String? sId;              // Backend's _id
  String? fullName;
  String? email;
  String? password;
  String? phoneNumber;
  String? address;
  String? city;
  String? state;
  int? profileProgress;
  String? id;               // This can still be used for any additional identifiers
  String? updatedOn;
  String? createdOn;
  String? profileImage;     // New field for profile image URL or path

  // Constructor
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
    this.profileImage,
  });

  // From JSON method
  UserModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'] ?? '';  // Map _id from backend to sId
    fullName = json['fullName'] ?? '';
    email = json['email'] ?? '';
    password = json['password']; // Allow null
    phoneNumber = json['phoneNumber'] ?? '';
    address = json['address'] ?? '';
    city = json['city'] ?? '';
    state = json['state'] ?? '';
    profileProgress = json['profileProgress'] ?? 0; // Default to 0
    id = json['id'] ?? '';   // Use id for any other identifiers (not backend's _id)
    updatedOn = json['updatedOn'] ?? '';
    createdOn = json['createdOn'] ?? '';
    profileImage = json['profileImage'] ?? '';
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      '_id': sId,              // Send sId as _id to the backend
      'fullName': fullName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'state': state,
      'profileProgress': profileProgress,
      'id': id,                // Include any other identifiers if needed
      'updatedOn': updatedOn,
      'createdOn': createdOn,
      'profileImage': profileImage,
    };
  }
}
