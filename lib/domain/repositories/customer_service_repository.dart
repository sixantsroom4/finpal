abstract class CustomerServiceRepository {
  Future<void> submitInquiry({
    required String userId,
    required String title,
    required String category,
    required String content,
    required String contactEmail,
    List<String>? imagePaths,
  });
}
