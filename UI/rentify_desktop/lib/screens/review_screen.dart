import 'package:flutter/material.dart';
import 'package:rentify_desktop/screens/base_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: "Recenzije", 
      child: Container()
    );
  }
}