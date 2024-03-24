class SalahApis {
  static DateTime today = DateTime.now();

  static String salahTimesApi(
          {required String latitude, required String longitude}) =>
      "https://salah.com/get?lg=$longitude&lt=$latitude";

  static String alAdhanSalahTimesApi(
          {required String latitude, required String longitude}) =>
      'https://api.aladhan.com/v1/calendar/${today.year}/${today.month}?latitude=$latitude&longitude=$longitude';

  static String qiblaDirectionApi(
          {required String latitude, required String longitude}) =>
      "http://api.aladhan.com/v1/qibla/$latitude/$longitude";
}
