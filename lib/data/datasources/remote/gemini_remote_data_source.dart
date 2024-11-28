import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as genai;
import '../../../core/errors/exceptions.dart' as app_exceptions;

abstract class GeminiRemoteDataSource {
  Future<Map<String, dynamic>> processReceiptImage(String imagePath);
  Future<String> formatReceiptData(Map<String, dynamic> receiptData);
}

class GeminiRemoteDataSourceImpl implements GeminiRemoteDataSource {
  final genai.GenerativeModel proModel;
  final genai.GenerativeModel flashModel;

  GeminiRemoteDataSourceImpl({
    required String apiKey,
    required genai.GenerativeModel model,
  })  : proModel = genai.GenerativeModel(
          model: 'gemini-1.5-pro',
          apiKey: apiKey,
        ),
        flashModel = genai.GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );

  @override
  Future<Map<String, dynamic>> processReceiptImage(String imagePath) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();

      final prompt = '''
      영수증을 분석하여 다음 형식의 JSON으로 응답해주세요.
      모든 금액은 영수증에 표시된 그대로의 숫자만 추출해주세요:
      {
        "merchantName": "상점명",
        "date": "YYYY-MM-DD HH:mm:ss",
        "items": [
          {
            "name": "상품명",
            "price": 숫자(통화 기호 제외),
            "quantity": 숫자,
            "totalPrice": 숫자(통화 기호 제외)
          }
        ],
        "totalAmount": 숫자(통화 기호 제외)
      }
      다른 설명은 제외하고 JSON 형식으로만 응답해주세요.
      ''';

      final response = await proModel.generateContent([
        genai.Content.multi(
            [genai.TextPart(prompt), genai.DataPart('image/jpeg', imageBytes)])
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw app_exceptions.ServerException('OCR 결과가 비어있습니다.');
      }

      // JSON 문자열 정제
      final cleanedJson =
          response.text!.replaceAll('```json', '').replaceAll('```', '').trim();

      return jsonDecode(cleanedJson) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('영수증 처리 실패: $e');
      throw app_exceptions.ServerException('영수증 처리 실패: ${e.toString()}');
    }
  }

  @override
  Future<String> formatReceiptData(Map<String, dynamic> receiptData) async {
    try {
      final prompt = '''
      다음 영수증 데이터를 보기 좋게 포맷팅하여 반환하세요:
      ${jsonEncode(receiptData)}
      ''';

      final response = await flashModel.generateContent([
        genai.Content.text(prompt),
      ]);

      final formattedText = response.text;
      if (formattedText == null || formattedText.isEmpty) {
        throw app_exceptions.ServerException('포맷팅된 데이터가 비어있습니다.');
      }

      return formattedText;
    } catch (e) {
      throw app_exceptions.ServerException('데이터 포맷팅 실패: $e');
    }
  }
}
