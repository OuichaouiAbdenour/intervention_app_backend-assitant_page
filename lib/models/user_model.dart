class UserModel {
  String? email;
  String? firstName;
  String? gender;
  String? image;
  String? lastName;
  String? password;
  String? userType;
  String? registrationNumber;
  String? username;
  String? citizenPhoneNumber;
  String? stat;
  UserModel({this.email,this.firstName,this.gender,this.image,this.lastName,this.password,this.username,this.userType});

  UserModel.fromJson(Map<String,dynamic> json){
    email = json['email'];
    firstName = json['firstName'];
    gender = json['gender'];
    image = json['image'];
    lastName = json['lastName'];
    password = json['password'];
    userType = json['userType'];
    registrationNumber = json['registrationNumber'];
    username = json['username'];
    stat=json['occupee'];
    citizenPhoneNumber=json['citizenPhoneNumber'];
  }
}