import 'package:flutter/material.dart';

import 'merchant_screen.dart';

class MerchantApp extends StatelessWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent)),
      home: const MerchantScreen(),
    );
  }
}
