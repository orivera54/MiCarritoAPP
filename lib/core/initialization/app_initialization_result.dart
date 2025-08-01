class AppInitializationResult {
  final bool isFirstRun;
  final bool needsOnboarding;
  final bool success;
  final String? error;
  final Map<String, dynamic> metadata;

  AppInitializationResult({
    required this.isFirstRun,
    required this.needsOnboarding,
    required this.success,
    this.error,
    this.metadata = const {},
  });

  @override
  String toString() {
    return 'AppInitializationResult('
        'isFirstRun: $isFirstRun, '
        'needsOnboarding: $needsOnboarding, '
        'success: $success, '
        'error: $error, '
        'metadata: $metadata'
        ')';
  }
}