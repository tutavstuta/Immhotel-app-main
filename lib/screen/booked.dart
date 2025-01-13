import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/services/get_booking.dart";
import 'components/bookingdetails.dart';

class Booked extends StatefulWidget {
  const Booked({super.key});

  @override
  State<Booked> createState() => _BookedState();
}

class _BookedState extends State<Booked> {
  late Future<List<dynamic>> bookings;
  @override
  void initState() {
    super.initState();
    bookings = getbooking();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: bookings,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<dynamic> bookings = snapshot.data!;

            return Scaffold(
                appBar: AppBar(
                  backgroundColor: MaterialColors.primaryBackgroundColor,
                  foregroundColor: Colors.white,
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.account_circle,
                          color: Colors.white, size: 40),
                      onPressed: () {
                        // Handle the icon button press
                      },
                    ),
                    // Add more icons as needed
                  ],
                ),
                backgroundColor: MaterialColors.primaryBackgroundColor,
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(child: Image.asset("assets/images/logo3.png")),
                      Container(
                        padding: const EdgeInsets.fromLTRB(50, 50, 50, 50),
                        decoration: const BoxDecoration(
                          color: MaterialColors.primary,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "การจองของคุณ",
                              style: TextStyle(
                                  color: MaterialColors.label, fontSize: 25),
                              textAlign: TextAlign.start,
                            ),
                            BookingList(bookings: bookings),
                          ],
                        ),
                      ),
                    ],
                  ),
                ));
          }
        });
  }
}

class BookingList extends StatelessWidget {
  const BookingList({super.key, required this.bookings});
  final dynamic bookings;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (BuildContext context, int index) {
                return Booking(booking: bookings[index]);
              },
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border.fromBorderSide(
                  BorderSide(width: 0.5, color: Colors.grey)),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text('เลขที่บัญชีในการชำระค่าห้องพัก',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: MaterialColors.surface)),
          const SizedBox(
            height: 10,
          ),
          const Text('xx-xx-xxx-xxxxx',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: MaterialColors.surface)),
        ],
      ),
    );
  }
}

class Booking extends StatelessWidget {
  const Booking({super.key, required this.booking});
  final dynamic booking;
  @override
  Widget build(BuildContext context) {
    var promotion = booking['promotion'];
    var guest = booking['num_guess'];
    var totalPrice = booking['total_price'];
    var totalNight = booking['total_nigths'];
    return Center(
        child: ListTile(
      title: Column(
        children: [
          Column(
            children: [
              Text(promotion['title'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 242, 8, 0))),
              Text(promotion['description'],
                 style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: MaterialColors.surface)),
            ],
          ),
        ],
      ),
      subtitle: BookingDetails(
          booking: booking,
          guest: guest,
          totalPrice: totalPrice,
          totalNight: totalNight),
    ));
  }
}
