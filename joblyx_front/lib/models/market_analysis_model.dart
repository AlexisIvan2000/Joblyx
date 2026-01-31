class SkillInfo {
  final String name;
  final int count;
  final double percentage;
  final String category;

  SkillInfo({
    required this.name,
    required this.count,
    required this.percentage,
    required this.category,
  });

  factory SkillInfo.fromMap(Map<String, dynamic> data) {
    return SkillInfo(
      name: data['name'],
      count: data['count'],
      percentage: (data['percentage'] as num).toDouble(),
      category: data['category'],
    );
  }
}

class MarketAnalysisResult {
  final String query;
  final String location;
  final int totalJobsAnalyzed;
  final List<SkillInfo> topSkills;
  final String? message;
  final bool fromCache;

  MarketAnalysisResult({
    required this.query,
    required this.location,
    required this.totalJobsAnalyzed,
    required this.topSkills,
    this.message,
    this.fromCache = false,
  });

  factory MarketAnalysisResult.fromMap(Map<String, dynamic> data) {
    return MarketAnalysisResult(
      query: data['query'],
      location: data['location'],
      totalJobsAnalyzed: data['total_jobs_analyzed'],
      topSkills: (data['top_skills'] as List)
          .map((s) => SkillInfo.fromMap(s))
          .toList(),
      message: data['message'],
      fromCache: data['from_cache'] ?? false,
    );
  }
}
