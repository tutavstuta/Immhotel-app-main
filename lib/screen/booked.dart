import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/services/get_booking.dart";

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
                  child: Expanded(
                    child: Column(
                      children: [
                        Center(child: Image.asset("assets/images/logo1.png")),
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
                              SizedBox(child: BookingList(bookings: bookings)),
                            ],
                          ),
                        ),
                      ],
                    ),
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
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (BuildContext context, int index) {
            return Booking(booking: bookings[index]);
          },
        ),
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
    return Center(
        child: ListTile(
      title: Row(
        children: [
          Text(promotion['title'],
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 242, 8, 0))),
          Text(promotion['description'],
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: MaterialColors.surface)),
        ],
      ),
      subtitle: Row(
        children: [
          Text(booking['room'],
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: MaterialColors.surface)),
          Text('- $guest ต่อห้อง',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: MaterialColors.surface)),
        ],
      ),
    ));
  }
}
