import "package:carousel_slider_plus/carousel_slider_plus.dart";
import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/constants/server.dart";
import "package:imm_hotel_app/widgets/appbar.dart";
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> getPromotions() async {
  final response = await http.get(
    Uri.parse('${ServerConstant.server}/news'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
  ).catchError((error) => throw Exception('Error: $error'));

  if (response.statusCode == 200) {
    Map<String, dynamic> promoData = jsonDecode(response.body);
    return promoData['data'];
  } else {
    throw Exception('Failed to get promotion list');
  }
}

class Landing extends StatelessWidget {
  Landing({super.key});

  final List<String> images = [
    '${ServerConstant.imagehost}/images/slider1.jpg',
    '${ServerConstant.imagehost}/images/slider2.jpg',
    '${ServerConstant.imagehost}/images/slider3.jpg',
    '${ServerConstant.imagehost}/images/slider4.jpg',
    '${ServerConstant.imagehost}/images/slider5.jpg',
    // Add more image URLs here
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sliderHeight = screenWidth * 9 / 16; // อัตราส่วน 16:9

    final TextStyle headlineSmall = Theme.of(context).textTheme.headlineSmall!;
    ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      visualDensity: VisualDensity.comfortable,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      textStyle: headlineSmall,
    );

    return Scaffold(
      appBar: const AppBarHome(),
      backgroundColor: MaterialColors.primaryBackgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              CarouselSlider(
                items: images.map((url) {
                  return Container(
                    width: screenWidth,
                    height: sliderHeight,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: screenWidth,
                      height: sliderHeight,
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: sliderHeight, // ใช้ค่าที่คำนวณจากขนาดหน้าจอ
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 1,
                ),
              ),
              Container(
                color: MaterialColors.primaryBackgroundColor,
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('อิมม์ โฮเทล ท่าแพ เชียงใหม่​',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.normal)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('หัวใจและจิตวิญญาณของเชียงใหม่',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: MaterialColors.secondaryBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image.asset("assets/images/ament1.jpg", height: 52),
                            const Text('ส่วนลดเพิ่มเติม ​สำหรับสมาชิก',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: MaterialColors.secondary)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image.asset("assets/images/ament2.jpg", height: 52),
                            const Text('ฟรีอินเตอร์เน็ต',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: MaterialColors.secondary)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image.asset("assets/images/ament3.jpg", height: 52),
                            const Text('เช็คอิน 14:00 น. เช็คเอาท์ 12:00 น.',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: MaterialColors.secondary)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image.asset("assets/images/ament4.jpg", height: 52),
                            const Text(
                                'เด็กอายุ 0-11 พักฟรี 2 ท่าน (ไม่เสริมเตียง)',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: MaterialColors.secondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const SizedBox(
                  child: Text(
                "โปรโมชั่น",
                style: TextStyle(fontSize: 20),
              )),
              const SizedBox(
                height: 15,
              ),
              Container(
                color: MaterialColors.secondaryBackgroundColor,
                child: FutureBuilder<List<dynamic>>(
                  future: getPromotions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('ไม่พบโปรโมชั่น'));
                    } else {
                      final promotions = snapshot.data!;
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: promotions.take(2).map((promo) => Container(
                          width: MediaQuery.of(context).size.width / 2 - 24,
                          alignment: Alignment.topCenter,
                          color: MaterialColors.secondaryBackgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    '${ServerConstant.server}/${promo['image']}',
                                    fit: BoxFit.fill, // ยืดเต็มพื้นที่คอลัมน์
                                    width: double.infinity,
                                    height: 200, // กำหนดความสูงคงที่
                                    alignment: Alignment.center,
                                  ),
                                ),
                                Text(
                                  promo['title'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: MaterialColors.secondary,
                                  ),
                                ),
                                Text(
                                  promo['description'],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                    color: MaterialColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )).toList(),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

