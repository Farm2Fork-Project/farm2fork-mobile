import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/features/profile/data/models/user_profile.dart';

enum AvatarSource { gallery, camera }

/// Picks a photo and returns it cropped square and compressed, or null when
/// the user backs out. Kept behind an interface so screens can be tested
/// without the camera/gallery/cropper plugins.
abstract class AvatarPhotoSource {
  Future<AvatarUpload?> pick(AvatarSource source, {required String cropTitle});
}

/// Square, 512 px, JPEG quality 85: about 40 KB, which is what the backend
/// recommends (it keeps at most 1024 px and 5 MB).
const avatarExportSize = 512;
const avatarJpegQuality = 85;

class DeviceAvatarPhotoSource implements AvatarPhotoSource {
  DeviceAvatarPhotoSource({ImagePicker? picker, ImageCropper? cropper})
    : _picker = picker ?? ImagePicker(),
      _cropper = cropper ?? ImageCropper();

  final ImagePicker _picker;
  final ImageCropper _cropper;

  @override
  Future<AvatarUpload?> pick(
    AvatarSource source, {
    required String cropTitle,
  }) async {
    final picked = await _picker.pickImage(
      source: source == AvatarSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      // Decode no more than the cropper needs; avoids huge camera originals.
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (picked == null) return null;

    final cropped = await _cropper.cropImage(
      sourcePath: picked.path,
      maxWidth: avatarExportSize,
      maxHeight: avatarExportSize,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: avatarJpegQuality,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: cropTitle,
          toolbarColor: AppColors.primaryGreen,
          toolbarWidgetColor: AppColors.white,
          statusBarLight: false,
          activeControlsWidgetColor: AppColors.primaryGreen,
          cropStyle: CropStyle.circle,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: cropTitle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
          cropStyle: CropStyle.circle,
        ),
      ],
    );
    if (cropped == null) return null;
    return AvatarUpload(bytes: await cropped.readAsBytes());
  }
}

final avatarPhotoSourceProvider = Provider<AvatarPhotoSource>(
  (ref) => DeviceAvatarPhotoSource(),
);
