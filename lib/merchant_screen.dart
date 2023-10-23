import 'dart:io';

import 'package:auropay_payments_sandbox/auropay_payments.dart';
import 'package:auropay_payments_sandbox/models/auropay_builder.dart';
import 'package:auropay_payments_sandbox/models/auropay_response.dart';
import 'package:auropay_payments_sandbox/models/auropay_theme.dart';
import 'package:auropay_payments_sandbox/models/country_enum.dart';
import 'package:auropay_flutter/keys.dart' as keys;
import 'package:flutter/material.dart';

const appColor = Color(0xff0363af);

class MerchantScreen extends StatefulWidget {
  const MerchantScreen({super.key});

  @override
  State<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends State<MerchantScreen> {
  String selectedTheme = 'Default';
  String selectedMerchantId = idList[0];

  static const idList = [
    'Shreyabhoir',
    'Shaunak',
    'Paul',
    'Crossbow',
  ];

  static const themes = ['Default', 'Theme 1', 'Theme 2', 'Theme 3'];

  final _auropay = AuropayPayments();

  bool _isShowLoader = false;
  PaymentStatus _paymentStatus = PaymentStatus.init;
  AuropayResponse? auropayResponse;

  Future<void> _startPayment(CustomerProfile customerProfile, double amount,
      {bool showPaymentForm = false, bool responseDetail = false}) async {
    setState(() {
      _isShowLoader = true;
    });

    final builder = Platform.isAndroid
        ? AuropayBuilder(
            subDomainId: selectedMerchantId.toLowerCase(),
            accessKey: keys.accessKey,
            secretKey: keys.secretKey,
            customerProfile: customerProfile)
        : AuropayBuilder(
            subDomainId: selectedMerchantId.toLowerCase(),
            accessKey: keys.accessKey,
            secretKey: keys.secretKey,
            customerProfile: customerProfile);

    builder
        .setAutoContrast(true)
        .setCountry(Country.IN)
        .setShowReceipt(true)
        .askForCustomerDetail(showPaymentForm)
        .getDetailedResponse(responseDetail);

    if (selectedTheme != themes[0]) {
      builder.setTheme(getTheme(selectedTheme));
    }

    try {
      debugPrint("auroPay call :: ");
      auropayResponse = await _auropay.doPayment(builder: builder, amount: amount);
      debugPrint("auroPay response :: ${auropayResponse.toString()}");

      setState(() {
        _paymentStatus = ResponseType.success == auropayResponse?.type
            ? PaymentStatus.success
            : PaymentStatus.failed;
        _isShowLoader = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_paymentStatus == PaymentStatus.success
                ? 'Payment Success'
                : 'Payment Failed')));
      });
    } on Exception catch (e) {
      debugPrint('auroPay response :: $e');
      setState(() {
        _isShowLoader = false;
        _paymentStatus = PaymentStatus.failed;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Payment Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text('UatAuropay',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.normal, fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Merchant ID: $selectedMerchantId'.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.normal, fontSize: 12)),
            ),
            PopupMenuButton<String>(
                child: Container(
                    height: 36,
                    width: 36,
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.more_vert)),
                itemBuilder: (context) => [
                      if (selectedMerchantId != idList[0])
                        PopupMenuItem<String>(
                            value: idList[0], child: Text('Merchant ID: ${idList[0]}')),
                      if (selectedMerchantId != idList[1])
                        PopupMenuItem<String>(
                            value: idList[1], child: Text('Merchant ID: ${idList[1]}')),
                      if (selectedMerchantId != idList[2])
                        PopupMenuItem<String>(
                            value: idList[2], child: Text('Merchant ID: ${idList[2]}')),
                      if (selectedMerchantId != idList[3])
                        PopupMenuItem<String>(
                            value: idList[3], child: Text('Merchant ID: ${idList[3]}')),
                    ],
                onSelected: (value) {
                  setState(() {
                    selectedMerchantId = value;
                  });
                }),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // search box and theme dropdown
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                          label: Text('Search'),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 2)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: DropdownButtonFormField<String>(
                    isDense: true,
                    decoration: const InputDecoration(
                        label: Text('SDK Theme'),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 2)),
                    value: selectedTheme,
                    items: themes
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          selectedTheme = value;
                          FocusScope.of(context).requestFocus(FocusNode());
                        });
                      }
                    },
                  ))
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),

            // your check list
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Checklist',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text('Add New', style: TextStyle(color: appColor)),
                ],
              ),
            ),

            ChecklistTile(
              title: 'UPPCL',
              category: 'Electricity',
              due: 'Bill due in 10 days',
              amount: 10.00,
              image: 'assets/images/img_uppcl.png',
              onTap: () {
                final customerProfile = CustomerProfile(
                    title: "UPPCL",
                    firstName: "UP",
                    middleName: "",
                    lastName: "State",
                    phone: "9909678987",
                    email: "jio.mncpay@yopmail.com",);
                _startPayment(customerProfile, 10.00);
              },
            ),
            ChecklistTile(
              title: 'Airtel',
              category: 'Broadband',
              due: 'New Bill',
              amount: 20.00,
              image: 'assets/images/img_airtel.png',
              onTap: () {
                final customerProfile = CustomerProfile(
                    title: "Airtel",
                    firstName: "Airtel",
                    middleName: "",
                    lastName: "Fiber",
                    phone: "9909678987",
                    email: "jio.mncpay@yopmail.com");
                _startPayment(customerProfile, 20.00,  showPaymentForm: true);
              },
            ),
            ChecklistTile(
              title: 'Jio',
              category: 'Jio Postpaid',
              due: 'Over Due',
              amount: 30.00,
              image: 'assets/images/img_jio.png',
              onTap: () {
                final customerProfile = CustomerProfile(
                    title: "Jio",
                    firstName: "Jio",
                    middleName: "",
                    lastName: "Postpaid",
                    phone: "9909678987",
                    email: "jio.mncpay@yopmail.com");
                _startPayment(customerProfile, 30.00, responseDetail: true);
              },
            ),

            Container(
              width: double.infinity,
              height: 52,
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: OutlinedButton(
                  style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(1),
                      backgroundColor: const MaterialStatePropertyAll(Colors.white),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)))),
                  onPressed: () {},
                  child: const Text(
                    'VIEW ALL',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.normal, color: appColor),
                  )),
            ),

            // Payment categories
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: Text(
                'Payments Categories',
                style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),

            GridView.count(
              shrinkWrap: true,
              padding: const EdgeInsets.all(10),
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: MediaQuery.sizeOf(context).width * 0.01,
              mainAxisSpacing: MediaQuery.sizeOf(context).width * 0.01,
              children: const [
                CategoryTile(category: 'Mobile Recharge', icon: Icons.smartphone),
                CategoryTile(category: 'DTH/Cable TV', icon: Icons.live_tv),
                CategoryTile(category: 'Electricity\n', icon: Icons.bolt),
                CategoryTile(category: 'FASTTag recharge', icon: Icons.directions_car),
                CategoryTile(category: 'Google Play\n', icon: Icons.play_arrow_rounded),
                CategoryTile(category: 'Credit card Payment', icon: Icons.credit_card)
              ],
            )
          ],
        ),
      ),
    );
  }

  AuropayTheme getTheme(String selectedTheme) {
    switch (selectedTheme) {
      case 'Theme 1':
        return AuropayTheme(
            primaryColor: const Color(0xff236C6C),
            colorOnPrimary: Colors.black,
            colorOnSecondary: Colors.redAccent,
            secondaryColor: Colors.white);
      case 'Theme 2':
        return AuropayTheme(
            primaryColor: const Color(0xff2D2D2D),
            colorOnPrimary: Colors.black,
            colorOnSecondary: Colors.redAccent,
            secondaryColor: Colors.white);
      case 'Theme 3':
        return AuropayTheme(
            primaryColor: Colors.deepPurple,
            colorOnPrimary: Colors.white,
            colorOnSecondary: Colors.green,
            secondaryColor: Colors.blueAccent);
      default:
        return AuropayTheme(
            primaryColor: Colors.black54,
            colorOnPrimary: Colors.white70,
            colorOnSecondary: Colors.yellow,
            secondaryColor: Colors.deepOrangeAccent);
    }
  }
}

class ChecklistTile extends StatelessWidget {
  const ChecklistTile(
      {super.key,
      required this.title,
      required this.category,
      required this.due,
      required this.amount,
      required this.image,
      this.onTap});

  final String title;
  final String category;
  final String due;
  final double amount;
  final void Function()? onTap;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.asset(image, height: 52, width: 52),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: MediaQuery.sizeOf(context).width * 0.01),
                  Text(category,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  SizedBox(height: MediaQuery.sizeOf(context).width * 0.01),
                  Text(due, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          Container(
            width: 100,
            height: 52,
            margin: const EdgeInsets.fromLTRB(14, 0, 0, 14),
            child: OutlinedButton(
                style: ButtonStyle(
                    elevation: const MaterialStatePropertyAll(1),
                    backgroundColor: const MaterialStatePropertyAll(Colors.white),
                    shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)))),
                onPressed: onTap,
                child: Text(
                  '₹ ${amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, color: appColor),
                )),
          ),
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category, required this.icon});

  final String category;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: box.minHeight * 0.5,
                  color: appColor,
                ),
                Text(
                  category,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: box.minHeight * 0.15),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum PaymentStatus { init, success, failed }
