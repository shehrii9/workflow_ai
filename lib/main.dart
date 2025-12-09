import 'package:flutter/material.dart';
import 'package:workflow_ai/app.dart';
import 'package:workflow_ai/core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await StorageService.init();
  
  runApp(const App());
}
