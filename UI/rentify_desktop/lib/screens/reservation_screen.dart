import 'package:flutter/material.dart';
import 'package:rentify_desktop/screens/base_screen.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: "Rezervacije", 
      child: Container()
    );
  }
}