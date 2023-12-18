import 'package:gsheets/gsheets.dart';
import 'package:ts_one/app/modules/cc/pilotadministrator/attendance_confircc/controllers/trainingCardsFields.dart';

class TrainingCardSheetsApi {
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "dev-iaa-ts1",
  "private_key_id": "0ea1da99562b84391ac4e03c7b2a618c806391bf",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCzU1pNyVYu1RtB\ntDEDaFclNER5/Jrr2A9R+OGfFcKGCxM3dlPhpn0nCzAhsGHYnaBkAeCKdRZvOvpc\n3sYZbiHPSwvrOGGljdqbDAMzqF/NgCRl422zLxAxhd8rKNARW+JQseIQqI05nr5H\niykGdH6Xs1MGQfwEP5ca55s2OSAzyPfFioVEUIPSoV5IEIHxXNUBGtmRGiXb4Fo9\nIBogLHEGwwEFQcbwct/B0ygIdZUmNKc/acRaFQCnOEAZ8fF7J/4/bSHK2LTBDVFc\nshdzMyz4YNZmknFUGCOD1A4CEwJSze6eJ8AHkQkUfmEwyAMQYZgn0/HTJI6rkht3\nqW4cSCZZAgMBAAECggEAPCLMKkDF63+gm9iLBTsE2l+cRRI+e6+hd5pQQzKfYKcv\nIw7F02qrFqBMXEfTkDpP8qmkfJoGU3fCRMmaQiXqJaNjlFZ8fHHFKPCO1FB3DCmY\nSyjI/Wlfc1QTAly15dRb4Ta9+lsjvPpskf5rXBRN7Z5/zZ3sHxqaGDYqGTVwBJ0j\n7TnmI9Yoymx3QfE29+zvPq/n/eRsfduuR9H36GWG5gcYAytz5yfVcEuq3eEMU3yO\n1TgvIeWm9Qag6kZ/wv/1f+s+aAZ2HxthgNztK+PBFSb0vHen+GDNceEr09i01mjP\nkvvjfJZ8lVY7KUSKqq0Onl1R3CECz5QHoN9JJrRxtwKBgQD0qzBqqph8fILiRZGy\njECdx8xh3+bIHTVb7PT2Ip3nZAtvjl15U9gb+o8vyPk3ORUyKom867iA3rR7FqjJ\nE6/rD+M3rMAYABjmpKG5X9OVXOw2NVu9hVr/aAMXEh8sWc7CZytCmV/9pLXnpYcm\nSquUlQptE9BWx8kA/8jfXEr54wKBgQC7oXNh2aiZWjdebJgQjEdXaxPtUxzYeTyD\ngt1fwOYugTMBKZmekOUwuSQHO6MVWG8ZRb1Lq+zLO587KBbpnTkoIvSsSowpWP5t\nYjSO60ZrrUboVjQ70XqUO5vgCtwPPvFkm0LLIWsIm7GFmZWOylas2lZiZa9yxVJD\n6HzmiA8DkwKBgGWkgJavjG2a5FzP/fko3uctS7EVbTCRQcuQoytlsiegnkeX4yk2\nNb9Z1gZJ/Y59flq65UHAw4N2AZBpF3GBZkHG9eP5NkxCLhYTKsRyFNomIlNa02Pm\ndKlKMo5xDtZD8Os+JPCj+wbKWG+FiqHTv3gYep5Z7uE+Wji6Cl8QXm11AoGATkvt\nLiP56yRufoSqYB1pl90jD6HjI6JT0j1Fy7NfWoCnnBCT/ktQmKhplGsafsnMcqtb\ndrxjr9tNcw4joZDuTQVpPIxPOOHeKh8U957OYBiKwmFWoq+jiz/kp/VgJyyI5waz\nNLjZRVpTFgElG9Trnm3uJllwgWA+GABoPnsAaOkCgYAiAVPGDz7RqaCppnkMiEce\nHbgocANA1/5ExuDzbA5ZDQ8lnbC0oMkA9eqc2+QLAXrDcYTco/UMPiVdnvpMET0o\no0QFPVI25mkpad49RK9gipPEIJ1nr4nBWByJfYZ4pRrDvNWOlCjUYRLIJQpGtwTC\nacVvh2tJrzoX8hOFo93/wA==\n-----END PRIVATE KEY-----\n",
  "client_email": "gsheets@dev-iaa-ts1.iam.gserviceaccount.com",
  "client_id": "115327518243585760765",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40dev-iaa-ts1.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}

  ''';
  static final _spreadsheetId = '12hRVA-Aktm_VcJjZTECbTisxTSIUZw4RnA1Ml_WDPIU';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _trainingCardSheet;

  static Future init() async{
    try{
      final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
      _trainingCardSheet = await _getWorkSheet(spreadsheet, title : 'TrainingCards');

      final firstRow = TrainingCardsFields.getFields();
      _trainingCardSheet!.values.insertRow(1, firstRow);
    } catch(e){
      print('Init Error: $e');
    }

  }


  static Future<Worksheet> _getWorkSheet(
      Spreadsheet spreadsheet, {
        required String title,
  }) async {
   try{
     return await spreadsheet.addWorksheet(title);
   } catch (e) {
     return spreadsheet.worksheetByTitle(title)!;
   }
  }


  static Future<int> getRowCount() async {
   if(_trainingCardSheet == null) return 0;

   final lastRow = await _trainingCardSheet!.values.lastRow();
   return lastRow == null ? 0 : int.tryParse(lastRow.first) ?? 0 ;
  }

  static Future<List<TrainingCards>> getAll()  async{
    if(_trainingCardSheet == null) return <TrainingCards>[];


    final trainingCards = await _trainingCardSheet!.values.map.allRows();
    return trainingCards == null ? <TrainingCards>[] : trainingCards.map(TrainingCards.fromJson).toList();

  }

  static Future<TrainingCards?> getById(int id) async {
    if(_trainingCardSheet == null) return null;
    
    final json = await _trainingCardSheet!.values.map.rowByKey(id, fromColumn: 1 );
    return json == null ? null : TrainingCards.fromJson(json) ;
  }

  static Future insert(List<Map<String, dynamic>> rowList) async{
     if(_trainingCardSheet == null) return;

      _trainingCardSheet!.values.map.appendRows(rowList);
  }

  static Future<bool> update(
      int id,
      Map<String, dynamic> trainingCard,
      ) async {

    if(_trainingCardSheet == null) return false;

    return _trainingCardSheet!.values.map.insertRowByKey(id, trainingCard);
  }

  static Future<bool> updateCell({
    required int id,
    required String key,
    required dynamic value,
}) async {
    if (_trainingCardSheet == null) return false;

    return _trainingCardSheet!.values.insertValueByKeys(value, columnKey: key, rowKey: id);
  }
}