class UserSession {
  // AUTH
  static String? token;

  // USER DATA
  static Map<String, dynamic>? currentUser;

  // BASIC INFO
  static String? memberId;

  static String? email;

  static String? displayName;

  static String? firstName;

  static String? lastName;

  static String? phone;

  static String? birthDate;

  // MEMBERSHIP
  static String? membership;

  static String? membershipStatus;

  static String? joinDate;

  // CHECKIN
  static String? lastCheckin;

  // ROLE / ACCESS
  static String? role;

  // PROFILE
  static String? profileImage;

  // FLAGS
  static bool get isLoggedIn =>
      token != null && token!.isNotEmpty;

  static bool get isActiveMember =>
      membershipStatus == "Activo";

  static String get fullName {
    if (displayName != null &&
        displayName!.isNotEmpty) {
      return displayName!;
    }

    return "${firstName ?? ""} ${lastName ?? ""}"
        .trim();
  }

  // LOAD SESSION
  static void setSession(
    Map<String, dynamic> data,
  ) {
    currentUser = data;

    token = data["token"];

    memberId = data["member_id"];

    email = data["email"];

    displayName =
        data["display_name"];

    firstName = data["nombre"];

    lastName = data["apellidos"];

    phone = data["telefono"];

    birthDate =
        data["fecha_nacimiento"];

    membership =
        data["membresia"];

    membershipStatus =
        data["estado"];

    joinDate =
        data["fecha_inscripcion"];

    lastCheckin =
        data["ultimo_checkin"];

    role = data["role"];

    profileImage =
        data["profile_image"] ??
        data["picture"];
  }

  // CLEAR SESSION
  static void logout() {
    token = null;

    currentUser = null;

    memberId = null;

    email = null;

    displayName = null;

    firstName = null;

    lastName = null;

    phone = null;

    birthDate = null;

    membership = null;

    membershipStatus = null;

    joinDate = null;

    lastCheckin = null;

    role = null;

    profileImage = null;
  }
}