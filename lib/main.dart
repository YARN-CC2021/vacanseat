import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'app.dart';

Future main() async {
  await DotEnv.load(fileName: '.env');
  runApp(MyApp());
}
