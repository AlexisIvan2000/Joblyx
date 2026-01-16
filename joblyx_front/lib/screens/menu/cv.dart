import 'package:flutter/material.dart';

class CvScreen extends StatelessWidget {
  const CvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Curriculum Vitae'),
      ),
      body: Center(
        child: Text('CV Screen Content Here'),
      ),
    );
  }
}