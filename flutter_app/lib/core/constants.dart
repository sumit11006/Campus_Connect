/// App-wide constants for CampusConnect
class AppConstants {
  AppConstants._();

  // API Configuration
  // Use 10.0.2.2 for Android emulator to reach host localhost
  // Use localhost for web/desktop
  static const String apiBaseUrl = 'http://10.0.2.2:5000/api';
  static const String uploadBaseUrl = 'http://10.0.2.2:5000';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // App Info
  static const String appName = 'CampusConnect';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;

  // Roles
  static const String roleStudent = 'student';
  static const String roleFaculty = 'faculty';
  static const String roleClubAdmin = 'clubAdmin';
  static const String roleAdmin = 'admin';
}
