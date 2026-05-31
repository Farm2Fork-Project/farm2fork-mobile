import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/app/app.dart';
import 'package:farm2fork_mobile/app/bootstrap.dart';

void main() async {
  await bootstrap();
  runApp(const ProviderScope(child: Farm2ForkApp()));
}
