import 'dart:io';

import 'package:finpal/core/errors/exceptions.dart';
import 'package:finpal/domain/repositories/customer_service_repository.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CustomerServiceRepositoryImpl implements CustomerServiceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CustomerServiceRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  final String _adminEmail = 'jaejin00417@gmail.com';

  @override
  Future<void> submitInquiry({
    required String userId,
    required String title,
    required String category,
    required String content,
    required String contactEmail,
    List<String>? imagePaths,
  }) async {
    try {
      debugPrint('문의 저장 시작...');

      // Firebase에 문의 저장
      await _firestore.collection('customer_inquiries').add({
        'userId': userId,
        'title': title,
        'category': category,
        'content': content,
        'contactEmail': contactEmail,
        'status': '접수됨',
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrls': await _uploadImages(imagePaths),
      }).then((value) => debugPrint('문의가 성공적으로 저장됨: ${value.id}'));
    } catch (e) {
      debugPrint('문의 저장 실패: $e');
      throw ServerException(message: '문의 제출에 실패했습니다: $e');
    }
  }

  Future<List<String>> _uploadImages(List<String>? imagePaths) async {
    if (imagePaths == null || imagePaths.isEmpty) return [];

    List<String> imageUrls = [];
    for (String path in imagePaths) {
      final ref = _storage.ref().child(
          'customer_inquiries/${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}');
      await ref.putFile(File(path));
      final url = await ref.getDownloadURL();
      imageUrls.add(url);
    }
    return imageUrls;
  }

  Future<void> _sendConfirmationEmail(
    String email,
    String title,
    String content,
    String category,
    List<String> imageUrls,
    String userId,
  ) async {
    try {
      // Cloud Functions를 통해 이메일 전송
      await _firestore.collection('mail').add({
        'to': email,
        'template': {
          'name': 'inquiry_confirmation',
          'data': {
            'title': title,
            'content': content,
            'category': category,
            'imageUrls': imageUrls,
            'userId': userId,
            'timestamp': FieldValue.serverTimestamp(),
            'status': 'pending',
          },
        },
      });

      debugPrint('메일 전송 요청이 성공적으로 등록되었습니다.');
    } catch (e) {
      debugPrint('메일 전송 요청 중 오류 발생: $e');
      throw CustomerServiceException('메일 전송 요청에 실패했습니다: ${e.toString()}');
    }
  }
}
