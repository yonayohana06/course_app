import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/course_model.dart';

abstract class CourseDataSource {
  Future<List<CourseModel>> getCourses();
}

class LocalCourseDataSource implements CourseDataSource {
  final String assetPath;
  final Future<String> Function(String path)? customLoader;

  const LocalCourseDataSource({
    this.assetPath = 'assets/data/courses_mock.json',
    this.customLoader,
  });

  @override
  Future<List<CourseModel>> getCourses() async {
    final String jsonString = customLoader != null
        ? await customLoader!(assetPath)
        : await rootBundle.loadString(assetPath);

    final Map<String, dynamic> decoded =
        json.decode(jsonString) as Map<String, dynamic>;
    final List<dynamic> data = decoded['data'] as List<dynamic>? ?? [];

    return data
        .map((item) => CourseModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
