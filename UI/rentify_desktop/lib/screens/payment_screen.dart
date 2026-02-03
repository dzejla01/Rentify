import 'package:flutter/material.dart';
import 'package:rentify_desktop/screens/base_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: "Zahtjevi plaćanja", 
      child: Container()
    );
  }
}