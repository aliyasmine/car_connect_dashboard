String _baseUrl = 'http://192.168.43.167:3000/api/';
String imageUrl = 'http://192.168.43.167:3000/storage/';
class ApiGetUrl {
  static String getBrands = '${_baseUrl}getBrands';
  static String getCarsByBusinessUserId = '${_baseUrl}getCarsByBusinessUserId';
  static String getGears = '${_baseUrl}getGears';
  static String getColors = '${_baseUrl}getColors';
  static String getModels = '${_baseUrl}getGears';
  static String getNewestCars = '${_baseUrl}getNewestCars';
  static String getCars = '${_baseUrl}getAllCars';
  static String getUsers = '${_baseUrl}getUsers';
  static String getAllOrders = '${_baseUrl}getAllOrders';
  static String getAllReservations = '${_baseUrl}getAllReservations';
  static String getStatistics = '${_baseUrl}statistics';
}

class ApiPostUrl {
  static String getCarsByBrandId = '${_baseUrl}getCarsByBrandId';
  static String rateCar = '${_baseUrl}rateCar';
  static String addLike = '${_baseUrl}addLike';
  static String addComment = '${_baseUrl}addComment';
  static String addReport = '${_baseUrl}addReport';
  static String getUserFavorites = '${_baseUrl}getUserFavorites';
  static String addCar = '${_baseUrl}addCar';
  static String getOrderByUserId = '${_baseUrl}getOrderByUserId';
  static String changeOrderStatus = '${_baseUrl}changeOrderStatus';
  static String addOrder = '${_baseUrl}addOrder';
  static String getOrderByCompanyId = '${_baseUrl}getOrderByCompanyId';
  static String getUserPayCard = '${_baseUrl}getUserPayCard';
  static String generateOtp = '${_baseUrl}generateOTP';
  static String verifyCode = '${_baseUrl}verifyCode';
  static String getCarsByUserId = '${_baseUrl}getCarsByUserId';
  static String getCarDetails = '${_baseUrl}getCarDetails';
  static String getBusinessUser = '${_baseUrl}getBusinessUser';
  static String uploadUserIdImage = '${_baseUrl}uploadUserIdImage';
  static String addFavorite = '${_baseUrl}addFavorite';
  static String addBusinessUserProfileInfo =
      '${_baseUrl}addBusinessUserProfileInfo';
  static String loginUsingEmail = '${_baseUrl}loginUsingEmail';
  static String toggleCarAvailability = '${_baseUrl}toggleCarAvailability';
  static String getCarReports = '${_baseUrl}getCarReports';
}

class ApiDeleteUrl {}

class ApiPutUrl {}
