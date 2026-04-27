import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyTokenService {
  static Future<String> getClientCredentialsToken({
    required String clientId,
    required String clientSecret,
  }) async {
    final credentials =
        base64Encode(utf8.encode('$clientId:$clientSecret'));
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );
    if (response.statusCode != 200) {
      throw Exception('Spotify auth failed (${response.statusCode}): ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['access_token'] as String;
  }

  /// Returns the 30-second preview URL for the best matching track, or null
  /// if Spotify does not provide a preview for this track/region.
  static Future<String?> getPreviewUrl({
    required String token,
    required String trackName,
    required String artistName,
  }) async {
    final q = Uri.encodeComponent('track:$trackName artist:$artistName');
    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/search?q=$q&type=track&limit=5&market=US',),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['tracks']['items'] as List).cast<Map<String, dynamic>>();
    for (final item in items) {
      final preview = item['preview_url'] as String?;
      if (preview != null) return preview;
    }
    return null;
  }
}
