import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import 'package:intl/intl.dart';

class BookingDetails extends StatelessWidget {
  BookingDetails({
    super.key,
    required this.booking,
    required this.guest,
    required this.totalPrice,
    required this.totalNight,
  });

  final dynamic booking;
  final dynamic guest;
  final dynamic totalPrice;
  final dynamic totalNight;

  final fNumber = NumberFormat("#,##0.00", "th-TH");

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment : CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking['room'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: MaterialColors.surface)),
                    Text(' - $guest ต่อห้อง',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: MaterialColors.surface)),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('THB',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: MaterialColors.surface)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(fNumber.format(totalPrice),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: MaterialColors.surface)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(
              Icons.calendar_month,
              color: MaterialColors.surface,
              size: 30.0,
            ),
            Text('$totalNight ต่อคืน',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: MaterialColors.surface)),
            const Icon(
              Icons.person,
              color: MaterialColors.surface,
              size: 30.0,
            ),
            Text('$guest ต่อห้อง',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: MaterialColors.surface)),
          ],
        ),
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ยอดรวม',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MaterialColors.surface))
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('THB ${fNumber.format(totalPrice * totalNight)}',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MaterialColors.surface)),
                ],
              ),
            )
          ],
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
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('รวม',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MaterialColors.surface))
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('THB ${fNumber.format(totalPrice * totalNight)}',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MaterialColors.surface)),
                ],
              ),
            ),
          ],
        ),
        const Text('รวมในอัตราที่พัก',
            textAlign: TextAlign.start,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: MaterialColors.surface)),
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ภาษี',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MaterialColors.surface))
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      'THB ${fNumber.format(totalPrice * totalNight * 7 / 100)}',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MaterialColors.surface)),
                ],
              ),
            )
          ],
        ),
        Row(
           mainAxisAlignment : MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: ()=>{}, child: const Text("อัพโหลด สลิป")),
          ],
        )
      ],
    );
  }
}
