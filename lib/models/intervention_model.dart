class InterventionModel {
  String? phoneNumberCitizen;
  String? phoneNumberIntervenant;
  String? stat;
  InterventionModel({this.phoneNumberCitizen,this.phoneNumberIntervenant,this.stat});

  InterventionModel.fromJson(Map<String,dynamic> json){
    phoneNumberCitizen = json['phoneNumberCitizen'];
    phoneNumberIntervenant = json['phoneNumberIntervenant'];
    stat = json['stat'];

  }
}