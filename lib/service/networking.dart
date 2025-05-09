import 'package:http/http.dart' as http;
import "dart:convert";
//
class NetworkHelper{
  NetworkHelper(this.url);
  final String url;
  //TODO : getData
}
Future<http.Response> fetchAlbum() {
  return http.get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=32.5556&lon=35.85&appid=aa82b0bddbd9261224f665479d913946'));
}

