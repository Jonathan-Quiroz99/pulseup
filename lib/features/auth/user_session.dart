class UserSession {
  static Map<String, dynamic>? currentUser;
  static String? token;
  
  static void logout() {
    currentUser = null;
    token = null;
  }
  
  static bool get isLoggedIn => token != null;
}