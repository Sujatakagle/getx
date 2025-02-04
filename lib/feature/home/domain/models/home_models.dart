

class Chargerdetails {
  String? sId;
  String? chargerId;
  String? model;
  String? type;
  bool? wifiModule;
  bool? bluetoothModule;
  String? vendor;
  String? chargerModel;
  String? chargerType;
  int? gunConnector;
  int? maxCurrent;
  int? maxPower;
  int? socketCount;
  String? ip;
  String? lat;
  String? long;
  String? shortDescription;
  int? chargerAccessibility;
  String? superadminCommission;
  String? resellerCommission;
  String? clientCommission;
  int? assignedResellerId;
  String? assignedResellerDate;
  int? assignedClientId;
  String? assignedClientDate;
  int? assignedAssociationId;
  String? assignedAssociationDate;
  int? financeId;
  String? wifiUsername;
  String? wifiPassword;
  String? createdBy;
  String? createdDate;
  String? modifiedBy;
  String? modifiedDate;
  List<Status>? status;
  String? address;
  String? landmark;
  String? unitPrice;

  Chargerdetails({
    this.sId,
    this.chargerId,
    this.model,
    this.type,
    this.wifiModule,
    this.bluetoothModule,
    this.vendor,
    this.chargerModel,
    this.chargerType,
    this.gunConnector,
    this.maxCurrent,
    this.maxPower,
    this.socketCount,
    this.ip,
    this.lat,
    this.long,
    this.shortDescription,
    this.chargerAccessibility,
    this.superadminCommission,
    this.resellerCommission,
    this.clientCommission,
    this.assignedResellerId,
    this.assignedResellerDate,
    this.assignedClientId,
    this.assignedClientDate,
    this.assignedAssociationId,
    this.assignedAssociationDate,
    this.financeId,
    this.wifiUsername,
    this.wifiPassword,
    this.createdBy,
    this.createdDate,
    this.modifiedBy,
    this.modifiedDate,
    this.status,
    this.address,
    this.landmark,
    this.unitPrice,
  });

  // JSON Parsing
  factory Chargerdetails.fromJson(Map<String, dynamic> json) {
    return Chargerdetails(
      sId: json['_id'],
      chargerId: json['charger_id'],
      model: json['model'],
      type: json['type'],
      wifiModule: json['wifi_module'],
      bluetoothModule: json['bluetooth_module'],
      vendor: json['vendor'],
      chargerModel: json['charger_model'],
      chargerType: json['charger_type'],
      gunConnector: json['gun_connector'],
      maxCurrent: json['max_current'],
      maxPower: json['max_power'],
      socketCount: json['socket_count'],
      ip: json['ip'],
      lat: json['lat'],
      long: json['long'],
      shortDescription: json['short_description'],
      chargerAccessibility: json['charger_accessibility'],
      superadminCommission: json['superadmin_commission'],
      resellerCommission: json['reseller_commission'],
      clientCommission: json['client_commission'],
      assignedResellerId: json['assigned_reseller_id'],
      assignedResellerDate: json['assigned_reseller_date'],
      assignedClientId: json['assigned_client_id'],
      assignedClientDate: json['assigned_client_date'],
      assignedAssociationId: json['assigned_association_id'],
      assignedAssociationDate: json['assigned_association_date'],
      financeId: json['finance_id'],
      wifiUsername: json['wifi_username'],
      wifiPassword: json['wifi_password'],
      createdBy: json['created_by'],
      createdDate: json['created_date'],
      modifiedBy: json['modified_by'],
      modifiedDate: json['modified_date'],
      status: (json['status'] as List?)?.map((e) => Status.fromJson(e)).toList(),
      address: json['address'],
      landmark: json['landmark'],
      unitPrice: json['unit_price'],
    );
  }

  // Convert Object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'charger_id': chargerId,
      'model': model,
      'type': type,
      'wifi_module': wifiModule,
      'bluetooth_module': bluetoothModule,
      'vendor': vendor,
      'charger_model': chargerModel,
      'charger_type': chargerType,
      'gun_connector': gunConnector,
      'max_current': maxCurrent,
      'max_power': maxPower,
      'socket_count': socketCount,
      'ip': ip,
      'lat': lat,
      'long': long,
      'short_description': shortDescription,
      'charger_accessibility': chargerAccessibility,
      'superadmin_commission': superadminCommission,
      'reseller_commission': resellerCommission,
      'client_commission': clientCommission,
      'assigned_reseller_id': assignedResellerId,
      'assigned_reseller_date': assignedResellerDate,
      'assigned_client_id': assignedClientId,
      'assigned_client_date': assignedClientDate,
      'assigned_association_id': assignedAssociationId,
      'assigned_association_date': assignedAssociationDate,
      'finance_id': financeId,
      'wifi_username': wifiUsername,
      'wifi_password': wifiPassword,
      'created_by': createdBy,
      'created_date': createdDate,
      'modified_by': modifiedBy,
      'modified_date': modifiedDate,
      'status': status?.map((e) => e.toJson()).toList(),
      'address': address,
      'landmark': landmark,
      'unit_price': unitPrice,
    };
  }
}

class Status {
  String? sId;
  String? chargerId;
  int? connectorId;
  int? connectorType;
  String? chargerStatus;
  String? timestamp;
  String? clientIp;
  String? errorCode;
  String? createdDate;
  String? modifiedDate;

  Status({
    this.sId,
    this.chargerId,
    this.connectorId,
    this.connectorType,
    this.chargerStatus,
    this.timestamp,
    this.clientIp,
    this.errorCode,
    this.createdDate,
    this.modifiedDate,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      sId: json['_id'],
      chargerId: json['charger_id'],
      connectorId: json['connector_id'],
      connectorType: json['connector_type'],
      chargerStatus: json['charger_status'],
      timestamp: json['timestamp'],
      clientIp: json['client_ip'],
      errorCode: json['error_code'],
      createdDate: json['created_date'],
      modifiedDate: json['modified_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'charger_id': chargerId,
      'connector_id': connectorId,
      'connector_type': connectorType,
      'charger_status': chargerStatus,
      'timestamp': timestamp,
      'client_ip': clientIp,
      'error_code': errorCode,
      'created_date': createdDate,
      'modified_date': modifiedDate,
    };
  }
}