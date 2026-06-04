class UploadedKycFile {
  final String name;
  final String path;
  final bool isImage;
  final int? size; // bytes

  const UploadedKycFile({
    required this.name,
    required this.path,
    required this.isImage,
    this.size,
  });

  String get sizeLabel {
    if (size == null) return '';
    if (size! < 1024) return '${size}B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)}KB';
    return '${(size! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
