// data/datasources/remote/ocr_remote_data_source.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/errors/exceptions.dart';

abstract class OCRRemoteDataSource {
  Future<Map<String, dynamic>> processReceiptImage(String imagePath);
}

class OCRRemoteDataSourceImpl implements OCRRemoteDataSource {
  final String apiKey;

  OCRRemoteDataSourceImpl({required this.apiKey});

  @override
  Future<Map<String, dynamic>> processReceiptImage(String imagePath) async {
    try {
      debugPrint('===== OCR 처리 시작 =====');
      debugPrint('처리할 이미지: $imagePath');

      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final url = Uri.parse(
        'https://vision.googleapis.com/v1/images:annotate?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'TEXT_DETECTION', 'maxResults': 1}
              ],
            }
          ],
        }),
      );

      if (response.statusCode != 200) {
        throw ServerException('Google Vision API 호출 실패: ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);
      final text = jsonResponse['responses'][0]['fullTextAnnotation']['text'];
      debugPrint('OCR 결과 텍스트:\n$text');

      // 텍스트 파싱
      final result = _parseReceiptText(text);
      debugPrint('파싱 결과: ${json.encode(result)}');

      return result;
    } catch (e) {
      debugPrint('OCR 처리 실패: $e');
      throw ServerException('영수증 처리 실패: ${e.toString()}');
    }
  }

  Map<String, dynamic> _parseReceiptText(String text) {
    final lines = text.split('\n');
    String merchantName = '미확인 가맹점';
    double totalAmount = 0.0;
    DateTime? date;
    final items = <Map<String, dynamic>>[];

    for (final line in lines) {
      // 가맹점명 추출 (첫 번째 줄로 가정)
      if (merchantName == '미확인 가맹점' && line.isNotEmpty) {
        merchantName = line;
        continue;
      }

      // 날짜 추출
      if (date == null) {
        final dateMatch = RegExp(r'\d{4}[-/.]\d{2}[-/.]\d{2}').firstMatch(line);
        if (dateMatch != null) {
          date = DateTime.parse(dateMatch.group(0)!.replaceAll('/', '-'));
          continue;
        }
      }

      // 금액 추출
      final amountMatch =
          RegExp(r'합계[:\s]*(\d{1,3}(,\d{3})*원?)').firstMatch(line);
      if (amountMatch != null) {
        final amountStr = amountMatch
            .group(1)!
            .replaceAll(',', '')
            .replaceAll('원', '')
            .trim();
        totalAmount = double.parse(amountStr);
        continue;
      }

      // 품목 추출
      final itemMatch = RegExp(r'(\d+)\s*개\s*(\d+)\s*원').firstMatch(line);
      if (itemMatch != null) {
        final quantity = int.parse(itemMatch.group(1)!);
        final price = int.parse(itemMatch.group(2)!);
        final itemTotal = quantity * price;
        items.add({
          'name': '미확인 품목',
          'quantity': quantity,
          'price': price,
          'totalPrice': itemTotal,
        });
        continue;
      }
    }

    return {
      'items': items,
      'totalAmount': totalAmount,
      'merchantName': merchantName,
      'date': date?.toIso8601String(),
    };
  }
}
