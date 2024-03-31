import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/screen/components/home/destination.dart";


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
