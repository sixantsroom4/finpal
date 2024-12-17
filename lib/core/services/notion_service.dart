import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class NotionService {
  static final String _baseUrl = 'https://api.notion.com/v1';
  static final String? _databaseId = dotenv.env['NOTION_DATABASE_ID'];
  static final String? _notionToken = dotenv.env['NOTION_API_KEY'];

  Future<void> createInquiry({
    required String title,
    required String category,
    required String content,
    required String email,
    required String userId,
    List<String>? imagePaths,
  }) async {
    if (_databaseId == null || _notionToken == null) {
      throw NotionServiceException('Notion credentials not found');
    }

    try {
      // 1. 먼저 페이지 생성
      final createPageUrl = Uri.parse('$_baseUrl/pages');
      final pageResponse = await http.post(
        createPageUrl,
        headers: {
          'Authorization': 'Bearer $_notionToken',
          'Notion-Version': '2022-06-28',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'parent': {'database_id': _databaseId},
          'properties': {
            'Title': {
              'title': [
                {
                  'text': {'content': title}
                }
              ]
            },
            'Category': {
              'select': {'name': category}
            },
            'Content': {
              'rich_text': [
                {
                  'text': {'content': content}
                }
              ]
            },
            'Contact Email': {'email': email},
            'Status': {
              'select': {'name': 'New'}
            },
            'Created At': {
              'date': {
                'start': DateTime.now().toIso8601String(),
              }
            },
            'User ID': {
              'rich_text': [
                {
                  'text': {'content': userId}
                }
              ]
            },
          },
        }),
      );

      if (pageResponse.statusCode != 200) {
        throw NotionServiceException(
            'Failed to create page: ${pageResponse.body}');
      }

      // 2. 생성된 페이지 ID 가져오기
      final pageId = jsonDecode(pageResponse.body)['id'];

      // 3. 이미지가 있다면 이미지 블록 추가
      if (imagePaths != null && imagePaths.isNotEmpty) {
        final appendUrl = Uri.parse('$_baseUrl/blocks/$pageId/children');

        for (String imagePath in imagePaths) {
          // 이미지를 외부 URL로 변환 (Firebase Storage URL 사용)
          final imageUrl = await _uploadImageToFirebase(imagePath);

          await http.patch(
            appendUrl,
            headers: {
              'Authorization': 'Bearer $_notionToken',
              'Notion-Version': '2022-06-28',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'children': [
                {
                  'type': 'image',
                  'image': {
                    'type': 'external',
                    'external': {'url': imageUrl}
                  }
                }
              ]
            }),
          );
        }
      }
    } catch (e) {
      throw NotionServiceException('Failed to create inquiry: $e');
    }
  }

  // Firebase Storage에 이미지 업로드하고 URL 반환
  Future<String> _uploadImageToFirebase(String imagePath) async {
    try {
      final file = File(imagePath);
      final storageRef = FirebaseStorage.instance.ref().child(
          'notion_images/${DateTime.now().millisecondsSinceEpoch}_${path.basename(imagePath)}');

      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      throw NotionServiceException('Failed to upload image: $e');
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
