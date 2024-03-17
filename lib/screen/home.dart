import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import 'package:carousel_slider/carousel_slider.dart';
import "package:imm_hotel_app/constants/server.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin<Home> {
  static const List<Destination> allDestinations = <Destination>[
    Destination(0, 'หน้าแรก', Icons.home, Colors.grey),
    Destination(1, 'ห้องพัก', Icons.bed, Colors.grey),
    Destination(2, 'ประวัติโรงแรม', Icons.menu_book, Colors.grey),
    Destination(3, 'จอง', Icons.history, Colors.grey),
  ];

  late final List<GlobalKey<NavigatorState>> navigatorKeys;
  late final List<GlobalKey> destinationKeys;
  late final List<AnimationController> destinationFaders;
  late final List<Widget> destinationViews;
  int selectedIndex = 0;

  AnimationController buildFaderController() {
    final AnimationController controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    controller.addStatusListener(
      (AnimationStatus status) {
        if (status == AnimationStatus.dismissed) {
          setState(() {}); // Rebuild unselected destinations offstage.
        }
      },
    );
    return controller;
  }

  @override
  void initState() {
    super.initState();

    navigatorKeys = List<GlobalKey<NavigatorState>>.generate(
      allDestinations.length,
      (int index) => GlobalKey(),
    ).toList();

    destinationFaders = List<AnimationController>.generate(
      allDestinations.length,
      (int index) => buildFaderController(),
    ).toList();
    destinationFaders[selectedIndex].value = 1.0;

    final CurveTween tween = CurveTween(curve: Curves.fastOutSlowIn);
    destinationViews = allDestinations.map<Widget>(
      (Destination destination) {
        return FadeTransition(
          opacity: destinationFaders[destination.index].drive(tween),
          child: DestinationView(
            destination: destination,
            navigatorKey: navigatorKeys[destination.index],
          ),
        );
      },
    ).toList();
  }

  @override
  void dispose() {
    for (final AnimationController controller in destinationFaders) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPop: () {
        final NavigatorState navigator =
            navigatorKeys[selectedIndex].currentState!;
        navigator.pop();
      },
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Stack(
            fit: StackFit.expand,
            children: allDestinations.map(
              (Destination destination) {
                final int index = destination.index;
                final Widget view = destinationViews[index];
                if (index == selectedIndex) {
                  destinationFaders[index].forward();
                  return Offstage(offstage: false, child: view);
                } else {
                  destinationFaders[index].reverse();
                  if (destinationFaders[index].isAnimating) {
                    return IgnorePointer(child: view);
                  }
                  return Offstage(child: view);
                }
              },
            ).toList(),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          destinations: allDestinations.map<NavigationDestination>(
            (Destination destination) {
              return NavigationDestination(
                icon: Icon(destination.icon, color: MaterialColors.onSurface),
                label: destination.title,
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}

class Destination {
  const Destination(this.index, this.title, this.icon, this.color);
  final int index;
  final String title;
  final IconData icon;
  final MaterialColor color;
}

class RootPage extends StatelessWidget {
  RootPage({super.key, required this.destination});

  final Destination destination;
  final List<String> images = [
    '${ServerConstant.imagehost}/images/slider1.jpg',

    // Add more image URLs here
  ];

  Widget _buildDialog(BuildContext context) {
    return AlertDialog(
      title: Text('${destination.title} AlertDialog'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle headlineSmall = Theme.of(context).textTheme.headlineSmall!;
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: destination.color,
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
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                              child: Image.asset("assets/images/promotion1.png",
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
                              child: Image.asset("assets/images/promotion2.png",
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

              // ElevatedButton(
              //   style: buttonStyle,
              //   onPressed: () {
              //     Navigator.pushNamed(context, '/list');
              //   },
              //   child: const Text('Push /list'),
              // ),
              // const SizedBox(height: 16),
              // ElevatedButton(
              //   style: buttonStyle,
              //   onPressed: () {
              //     showDialog<void>(
              //       context: context,
              //       useRootNavigator: false,
              //       builder: _buildDialog,
              //     );
              //   },
              //   child: const Text('Local Dialog'),
              // ),
              // const SizedBox(height: 16),
              // ElevatedButton(
              //   style: buttonStyle,
              //   onPressed: () {
              //     showDialog<void>(
              //       context: context,
              //       useRootNavigator:
              //           true, // ignore: avoid_redundant_argument_values
              //       builder: _buildDialog,
              //     );
              //   },
              //   child: const Text('Root Dialog'),
              // ),
              // const SizedBox(height: 16),
              // Builder(
              //   builder: (BuildContext context) {
              //     return ElevatedButton(
              //       style: buttonStyle,
              //       onPressed: () {
              //         showBottomSheet(
              //           context: context,
              //           builder: (BuildContext context) {
              //             return Container(
              //               padding: const EdgeInsets.all(16),
              //               width: double.infinity,
              //               child: Text(
              //                 '${destination.title} BottomSheet\n'
              //                 'Tap the back button to dismiss',
              //                 style: headlineSmall,
              //                 softWrap: true,
              //                 textAlign: TextAlign.center,
              //               ),
              //             );
              //           },
              //         );
              //       },
              //       child: const Text('Local BottomSheet'),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListPage extends StatelessWidget {
  const ListPage({super.key, required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    const int itemCount = 20;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ButtonStyle buttonStyle = OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: colorScheme.onSurface.withOpacity(0.12),
        ),
      ),
      foregroundColor: destination.color,
      fixedSize: const Size.fromHeight(64),
      textStyle: Theme.of(context).textTheme.headlineSmall,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('imm hotel'),
        backgroundColor: destination.color,
        foregroundColor: Colors.white,
      ),
      backgroundColor: MaterialColors.secondaryBackgroundColor,
      body: SizedBox.expand(
        child: ListView.builder(
          itemCount: itemCount,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: OutlinedButton(
                style: buttonStyle.copyWith(
                  backgroundColor: const MaterialStatePropertyAll<Color>(
                    MaterialColors.secondaryBackgroundColor,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/text');
                },
                child: Text('Push /text [$index]'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TextPage extends StatefulWidget {
  const TextPage({super.key, required this.destination});

  final Destination destination;

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: 'Sample Text');
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.destination.title} TextPage - /list/text'),
        backgroundColor: widget.destination.color,
        foregroundColor: Colors.white,
      ),
      backgroundColor: widget.destination.color[50],
      body: Container(
        padding: const EdgeInsets.all(32.0),
        alignment: Alignment.center,
        child: TextField(
          controller: textController,
          style: theme.primaryTextTheme.headlineMedium?.copyWith(
            color: widget.destination.color,
          ),
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: widget.destination.color,
                width: 3.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DestinationView extends StatefulWidget {
  const DestinationView({
    super.key,
    required this.destination,
    required this.navigatorKey,
  });

  final Destination destination;
  final Key navigatorKey;

  @override
  State<DestinationView> createState() => _DestinationViewState();
}

class _DestinationViewState extends State<DestinationView> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) {
            switch (settings.name) {
              case '/':
                return RootPage(destination: widget.destination);
              case '/list':
                return ListPage(destination: widget.destination);
              case '/text':
                return TextPage(destination: widget.destination);
            }
            assert(false);
            return const SizedBox();
          },
        );
      },
    );
  }
}
