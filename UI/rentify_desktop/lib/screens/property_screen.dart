import 'package:flutter/material.dart';
import 'package:rentify_desktop/screens/base_screen.dart';

class PropertyScreen extends StatefulWidget {
  const PropertyScreen({super.key});

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: "Moje nekretnine", 
      child: Container()
    );
  }
}