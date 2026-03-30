import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'app/splash/splash_page.dart';
import 'src/core/theme/app_theme.dart';
import 'src/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();
  runApp(const RoomahApp());

  // After first frame, plugins are registered — set Android Photo Picker per package docs.
  // See: https://pub.dev/packages/image_picker_android#photo-picker
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final impl = ImagePickerPlatform.instance;
    if (!kIsWeb && impl is ImagePickerAndroid) {
      impl.useAndroidPhotoPicker = true;
    }
  });
}

class RoomahApp extends StatelessWidget {
  const RoomahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roomah',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}
