class CustomerInquiry {
  final String id;
  final String userId;
  final String title;
  final String category;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;

  CustomerInquiry({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.content,
    required this.imageUrls,
    required this.createdAt,
  });
}
