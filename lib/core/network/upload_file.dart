import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

/// Picked photo -> multipart part. The backend checks the real file type.
Future<MultipartFile> multipartFromXFile(XFile file) async {
  final name = file.name.isEmpty ? 'photo.jpg' : file.name;
  final lower = name.toLowerCase();
  final mime = lower.endsWith('.png')
      ? 'image/png'
      : lower.endsWith('.webp')
      ? 'image/webp'
      : lower.endsWith('.pdf')
      ? 'application/pdf'
      : 'image/jpeg';
  return MultipartFile.fromBytes(
    await file.readAsBytes(),
    filename: name,
    contentType: DioMediaType.parse(mime),
  );
}
