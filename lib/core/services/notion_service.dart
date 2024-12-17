import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotionService {
  static final String _baseUrl = 'https://api.notion.com/v1';
  static final String? _databaseId = dotenv.env['NOTION_DATABASE_ID'];
  static final String? _notionToken = dotenv.env['NOTION_API_KEY'];

  Future<void> createInquiry({
    required String title,
    required String category,
    required String content,
    required String email,
    List<String>? imagePaths,
  }) async {
    if (_databaseId == null || _notionToken == null) {
      throw NotionServiceException(
          'Notion credentials not found in environment variables');
    }

    final url = Uri.parse('$_baseUrl/pages');
    final headers = {
      'Authorization': 'Bearer $_notionToken',
      'Notion-Version': '2022-06-28',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'parent': {'database_id': _databaseId},
      'properties': {
        'Title': {
          // 노션 데이터베이스의 'Title' 속성 이름과 일치해야 함
          'title': [
            {
              'text': {'content': title}
            }
          ]
        },
        'Category': {
          // 노션 데이터베이스의 'Category' 속성 이름과 일치해야 함
          'select': {'name': category}
        },
        'Content': {
          // 노션 데이터베이스의 'Content' 속성 이름과 일치해야 함
          'rich_text': [
            {
              'text': {'content': content}
            }
          ]
        },
        'Contact Email': {
          'email': email
        }, // 노션 데이터베이스의 'Contact Email' 속성 이름과 일치해야 함
        'Status': {
          // 노션 데이터베이스의 'Status' 속성 이름과 일치해야 함
          'select': {'name': '접수됨'}
        },
        // 'Images':{'files':[]}  // 이미지는 children 속성으로 처리합니다.
        //'User ID': {'rich_text': [ {'text': {'content': userId}}]}, // userId는 현재 API에서 사용하지 않습니다.
        //'Created At': {'date': {'start': DateTime.now().toIso8601String()}}, // Created At은 노션에서 자동으로 생성되므로, 보낼 필요가 없습니다.
      },
      'children': await _uploadImages(imagePaths),
    });
    print('API 요청 헤더: $headers'); // API 호출 로그
    print('API 요청 바디: $body'); // API 호출 로그
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return;
      } else {
        final errorBody = jsonDecode(response.body);
        throw NotionServiceException(
            'Failed to create inquiry in Notion: ${errorBody['message']}');
      }
    } catch (e) {
      throw NotionServiceException('An unexpected error occurred: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _uploadImages(
      List<String>? imagePaths) async {
    List<Map<String, dynamic>> imageBlocks = [];
    if (imagePaths != null) {
      for (String imagePath in imagePaths) {
        final blockId = await _uploadNotionImageBlock(imagePath);
        imageBlocks.add({
          'type': 'image',
          'image': {
            'type': 'file',
            'file': {'id': blockId}
          },
        });
      }
    }

    return imageBlocks;
  }

  Future<String> _uploadNotionImageBlock(String imagePath) async {
    if (_notionToken == null) {
      throw NotionServiceException(
          'Notion credentials not found in environment variables');
    }
    final url = 'https://api.notion.com/v1/blocks/upload';
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll({
      'Authorization': 'Bearer $_notionToken',
      'Notion-Version': '2022-06-28',
    });
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final parsedResponse = jsonDecode(responseBody);
      final blockId = parsedResponse['id'];
      return blockId;
    } else {
      throw NotionServiceException('Failed to create Notion block');
    }
  }
}

class NotionServiceException implements Exception {
  final String message;
  NotionServiceException(this.message);

  @override
  String toString() {
    return 'NotionServiceException: $message';
  }
}
