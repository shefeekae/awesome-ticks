class PartsModel {
  String? identifier;
  String? name;
  String? domain;
  String? partReference;
  int? unitCost;
  int? quantity;
  int? totalCost;
  String? typename;

  PartsModel(
      {this.identifier,
      this.name,
      this.domain,
      this.partReference,
      this.unitCost,
      this.quantity});

  PartsModel.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    name = json['name'];
    domain = json['domain'];
    partReference = json['partReference'];
    unitCost = json['unitCost'];
    quantity = json['quantity'];
    totalCost = json['totalCost'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['identifier'] = this.identifier;
    data['name'] = this.name;
    data['domain'] = this.domain;
    data['partReference'] = this.partReference;
    data['unitCost'] = this.unitCost;
    data['quantity'] = this.quantity;
    data['totalCost'] = totalCost;
    return data;
  }
}
