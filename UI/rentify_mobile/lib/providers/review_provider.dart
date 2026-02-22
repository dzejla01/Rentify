import 'dart:convert';
import 'package:rentify_mobile/models/review.dart';

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