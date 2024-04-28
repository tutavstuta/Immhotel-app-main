import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import 'package:carousel_slider/carousel_slider.dart';
import "package:imm_hotel_app/constants/server.dart";
import "package:imm_hotel_app/screen/components/home/destination.dart";

class Landing extends StatelessWidget {
  Landing({super.key});


  final List<String> images = [
    '${ServerConstant.imagehost}/images/slider1.jpg',

    // Add more image URLs here
  ];


  @override
  Widget build(BuildContext context) {
    final TextStyle headlineSmall = Theme.of(context).textTheme.headlineSmall!;
    ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      visualDensity: VisualDensity.comfortable,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      textStyle: headlineSmall,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leadingWidth: 150,
        leading: Image.asset(
          'assets/images/logo.jpg',
        ),
        backgroundColor: MaterialColors.primaryBackgroundColor,
        foregroundColor: Colors.white,
        toolbarHeight: 80,
        actions: <Widget>[
          IconButton(
            icon:
                const Icon(Icons.account_circle, color: Colors.white, size: 40),
            onPressed: () {
              // Handle the icon button press
            },
          ),
          // Add more icons as needed
        ],
      ),
      backgroundColor: MaterialColors.primaryBackgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              CarouselSlider(
                items: images.map((url) {
                  return Image.network(url, fit: BoxFit.cover);
                }).toList(),
                options: CarouselOptions(
                  height: 217, // Set your desired height
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction:
                      1, // Show a fraction of the next and previous images
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
                          Text('หัวใจและจิตวิญญาณของเชียงใหม',
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
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.topCenter,
                          color: MaterialColors.secondaryBackgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        15), // Adjust the radius as needed
                                  ),
                                  child: Image.asset(
                                      "assets/images/promotion1.png",
                                      height: 100),
                                ),
                                const Text('Best Flexible Rates',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: MaterialColors.secondary)),
                                const Text(
                                    'เพื่อความสะดวกสบายสูงสุดในการเลือกวันพักผ่อน หรือทริปสุดพิเศษของคุณ เพียงเลือกโปรโมชั่นแบบเปลี่ยนแปลงได้ รับสิทธิพิเศษ',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal,
                                        color: MaterialColors.secondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: MaterialColors.secondaryBackgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        15), // Adjust the radius as needed
                                  ),
                                  child: Image.asset(
                                      "assets/images/promotion2.png",
                                      height: 100),
                                ),
                                const Text('Best Prepaid Rates',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: MaterialColors.secondary)),
                                const Text(
                                    'วางแผนทริปล่วงหน้ากับเรา เพื่อราคาดีที่สุดสำหรับทริปสุดพิเศษของคุณ',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal,
                                        color: MaterialColors.secondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}

