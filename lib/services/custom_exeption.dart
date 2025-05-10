class CustomException implements Exception {
  late final String message;
  final String? hiddenMessage;

  CustomException({Object? message, this.hiddenMessage}) {
    if (message == null) {
      this.message = 'Unimplemented Error';
    } else if (message is List) {
      this.message = message.join('\n');
    } else {
      this.message = message.toString();
    }
  }

  @override
  String toString() {
    return message;
  }
}
