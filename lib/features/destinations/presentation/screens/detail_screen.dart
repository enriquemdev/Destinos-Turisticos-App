import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.xid});

  final String xid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail: $xid')),
      body: const Center(child: Text('Detail Screen')),
    );
  }
}
