import 'dart:ui';

import 'package:devicelocale/devicelocale.dart';
import 'package:dio/dio.dart';
import './models/enviroment.dart';

class BackendServiceStore {
  static Future<List> getPlaces(String input) async {
    await Future.delayed(Duration(milliseconds: 777));

    try {
      String baseUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';

      String type = 'establishment';

      List<Locale> languageLocales =
          await Devicelocale.preferredLanguagesAsLocales;
      Locale languageCode = languageLocales.first;
      String lang = languageCode.languageCode.toString();

      String request =
          '$baseUrl?input=$input&key=${Enviroment.googleApiKey}&type=$type&language=$lang';

      Response response = await Dio().get(request);
      if (response.statusCode == 200) {
        final List predictions = await response.data['predictions'];
        return await List.generate(predictions.length, (index) {
          return {
            'description': predictions[index]['description'],
            'name': predictions[index]['structured_formatting']['main_text'],
            'id': predictions[index]['place_id']
          };
        });
      } else {
        print('Error to fetch data from Google...');
      }
    } catch (e) {
      print(e);
    }
    print("3");
    return [];
  }
}
