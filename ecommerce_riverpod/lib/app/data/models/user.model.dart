class UserModel {
  bool? success;
  String? message;
  Data? data;

  UserModel({this.success, this.message, this.data});

  // Convenient direct getters
  User? get user => data?.user;
  String? get name => user?.name;
  String? get email => user?.email;
  String? get avatarUrl => user?.avatarUrl;
  String? get phone => user?.phone;
  String? get token => data?.token;
  List<String>? get roles => user?.roles;
  bool get isAdmin =>
      roles?.any((r) => r.toLowerCase().contains('admin')) == true;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    Data? parsedData;

    if (json['data'] != null) {
      if (json['data'] is Map<String, dynamic>) {
        parsedData = Data.fromJson(json['data'] as Map<String, dynamic>);
      }
    } else if (json['user'] != null) {
      parsedData = Data.fromJson(json);
    } else if (json['email'] != null || json['name'] != null || json['id'] != null) {
      parsedData = Data(user: User.fromJson(json));
    }

    return UserModel(
      success: json['success'] as bool? ?? true,
      message: json['message']?.toString(),
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class Data {
  String? token;
  User? user;

  Data({this.token, this.user});

  factory Data.fromJson(Map<String, dynamic> json) {
    final token = json['token']?.toString();
    User? parsedUser;

    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      parsedUser = User.fromJson(json['user'] as Map<String, dynamic>);
    } else if (json.containsKey('email') || json.containsKey('name') || json.containsKey('id')) {
      parsedUser = User.fromJson(json);
    }

    return Data(
      token: token,
      user: parsedUser,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['token'] = token;
    if (user != null) {
      map['user'] = user!.toJson();
    }
    return map;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? avatarUrl;
  bool? isActive;
  List<String>? roles;
  String? emailVerifiedAt;
  String? createdAt;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    this.isActive,
    this.roles,
    this.emailVerifiedAt,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ??
          json['full_name']?.toString() ??
          json['username']?.toString() ??
          (json['first_name'] != null
              ? '${json['first_name']} ${json['last_name'] ?? ''}'.trim()
              : null),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      avatarUrl: json['avatar_url']?.toString() ?? json['avatar']?.toString() ?? json['image']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      roles: () {
        if (json['roles'] is List) {
          return (json['roles'] as List).map((e) {
            if (e is Map && e['name'] != null) return e['name'].toString();
            return e.toString();
          }).toList();
        }
        if (json['role'] != null) {
          if (json['role'] is String) return [json['role'].toString()];
          if (json['role'] is Map && json['role']['name'] != null) {
            return [json['role']['name'].toString()];
          }
        }
        if (json['is_admin'] == true ||
            json['is_admin'] == 1 ||
            json['isAdmin'] == true) {
          return ['admin'];
        }
        return null;
      }(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['phone'] = phone;
    map['avatar_url'] = avatarUrl;
    map['is_active'] = isActive;
    map['roles'] = roles;
    map['email_verified_at'] = emailVerifiedAt;
    map['created_at'] = createdAt;
    return map;
  }
}

