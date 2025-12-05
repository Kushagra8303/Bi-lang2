import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> translateText(String text, String targetLang) async {
  final apiKey = "YOUR_MURF_API_KEY";

  final response = await http.post(
    Uri.parse("https://api.murf.ai/translate/text"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    },
    body: jsonEncode({
      "texts": [text],
      "target_language": targetLang,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['translations'][0]['translated_text'];
  } else {
    print("Translation failed: ${response.body}");
    return text; // fallback to original
  }
}
