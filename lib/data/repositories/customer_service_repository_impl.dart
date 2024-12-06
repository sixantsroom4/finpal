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
    required List<String> imagePaths,
  }) async {
    try {
      // Firestore에 문의 저장
      final docRef = await _firestore.collection('inquiries').add({
        'userId': userId,
        'title': title,
        'category': category,
        'content': content,
        'contactEmail': contactEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // 이미지 업로드
      final imageUrls = await Future.wait(
        imagePaths.map((path) => _uploadImage(path, docRef.id)),
      );

      // 문서 업데이트
      await docRef.update({'imageUrls': imageUrls});

      // 사용자에게 확인 이메일 전송
      await _sendConfirmationEmail(
        contactEmail,
        title,
        content,
        category,
        imageUrls,
        userId,
      );
    } catch (e) {
      throw CustomerServiceException('문의 제출에 실패했습니다: ${e.toString()}');
    }
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

  Future<String> _uploadImage(String path, String documentId) async {
    final ref = _storage
        .ref('inquiries/$documentId/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(File(path));
    return await ref.getDownloadURL();
  }
}
