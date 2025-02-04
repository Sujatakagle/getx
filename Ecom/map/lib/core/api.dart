class Api {
  static const String baseUrl = 'http://192.168.1.2:6386';  // Base URL for API

  // Endpoints
  static const String signup = '/api/auth/signup';
  static const String signin = '/api/auth/signin';
  static const String searchHotels = '/api/hotels/search'; // Endpoint for hotel search

  // Combine base URL and endpoint
  static String get signupUrl => baseUrl + signup;
  static String get signinUrl => baseUrl + signin;

  // Add a method to generate hotel search URL with city parameter
  static String getSearchHotelsUrl(String city) {
    return '$baseUrl$searchHotels?city=$city';
  }
}