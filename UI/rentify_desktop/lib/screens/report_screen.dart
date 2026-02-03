import 'package:flutter/material.dart';
import 'package:rentify_desktop/screens/base_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: "Izvjestaji", 
      child: Container()
    );
  }
}