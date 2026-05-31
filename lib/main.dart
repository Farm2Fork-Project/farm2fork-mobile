import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Farm2Fork/app/app.dart';
import 'package:Farm2Fork/app/bootstrap.dart';

void main() async {
  await bootstrap();
  runApp(
    const ProviderScope(
      child: Farm2ForkApp(),
    ),
  );
}
