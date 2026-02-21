import 'dart:convert';
import 'package:rentify_desktop/models/review.dart';
import 'package:rentify_desktop/models/user.dart';
import '../utils/session.dart';
import 'package:http/http.dart' as http;

import 'base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super("Review");

  @override
  Review fromJson(dynamic data) {
    return Review.fromJson(data);
  }
}