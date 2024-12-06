// import 'dart:convert';
// import 'package:dartz/dartz.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

// class AuthService {
//   Future<Either<Failure, void>> revokeAppleSignIn() async {
//     try {
//       final appleCredential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//       );

//       final String authCode = appleCredential.authorizationCode;
//       final String privateKey = dotenv.env['APPLE_PRIVATE_KEY']!;

//       final String teamId = dotenv.env['APPLE_TEAM_ID']!;
//       final String clientId = dotenv.env['APPLE_BUNDLE_ID']!;
//       final String keyId = dotenv.env['APPLE_KEY_ID']!;

//       final String clientSecret = createJwt(
//         teamId: teamId,
//         clientId: clientId,
//         keyId: keyId,
//         privateKey: privateKey,
//       );

//       final accessToken = (await requestAppleTokens(
//         authCode,
//         clientSecret,
//         clientId,
//       ))['access_token'] as String;

//       await revokeAppleToken(
//         clientId: clientId,
//         clientSecret: clientSecret,
//         token: accessToken,
//         tokenTypeHint: 'access_token',
//       );

//       return right(null);
//     } catch (e) {
//       return left(Failure('회원 탈퇴 처리 중 오류가 발생했습니다: $e'));
//     }
//   }

//   String createJwt({
//     required String teamId,
//     required String clientId,
//     required String keyId,
//     required String privateKey,
//   }) {
//     final jwt = JWT(
//       {
//         'iss': teamId,
//         'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
//         'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600,
//         'aud': 'https://appleid.apple.com',
//         'sub': clientId,
//       },
//       header: {
//         'kid': keyId,
//         'alg': 'ES256',
//       },
//     );

    

//   Future<Map<String, dynamic>> requestAppleTokens(
//     String authorizationCode,
//     String clientSecret,
//     String clientId,
//   ) async {
//     final response = await http.post(
//       Uri.parse('https://appleid.apple.com/auth/token'),
//       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       body: {
//         'client_id': clientId,
//         'client_secret': clientSecret,
//         'code': authorizationCode,
//         'grant_type': 'authorization_code',
//       },
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('토큰 요청 실패: ${response.body}');
//     }
//   }

//   Future<Either<Failure, void>> revokeAppleToken({
//     required String clientId,
//     required String clientSecret,
//     required String token,
//     required String tokenTypeHint,
//   }) async {
//     final url = Uri.parse('https://appleid.apple.com/auth/revoke');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       body: {
//         'client_id': clientId,
//         'client_secret': clientSecret,
//         'token': token,
//         'token_type_hint': tokenTypeHint,
//       },
//     );

    