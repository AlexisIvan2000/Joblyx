class SearchHistoryItem {
  final String id;
  final String query;
  final String city;
  final String province;
  final int totalJobs;
  final DateTime createdAt;
  final Map<String, dynamic>? results;

  SearchHistoryItem({
    required this.id,
    required this.query,
    required this.city,
    required this.province,
    required this.totalJobs,
    required this.createdAt,
    this.results,
  });

  factory SearchHistoryItem.fromMap(Map<String, dynamic> data) {
    return SearchHistoryItem(
      id: data['id'],
      query: data['query'],
      city: data['city'],
      province: data['province'],
      totalJobs: data['total_jobs'] ?? 0,
      createdAt: DateTime.parse(data['created_at']),
      results: data['results'],
    );
  }

  String get location => '$city, $province';
}
