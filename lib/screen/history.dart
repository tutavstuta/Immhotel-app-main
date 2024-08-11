import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/widgets/appbar.dart";
import 'package:imm_hotel_app/screen/components/history_detail.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
   Widget build(BuildContext context) {
    return Scaffold(
            appBar:const AppBarHome(),
            backgroundColor: MaterialColors.secondaryBackgroundColor,
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      color: MaterialColors.primaryBackgroundColor,
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 73,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(300),
                            topRight: Radius.circular(300),
                          ),
                          child: SizedBox(
                            child: Container(
                              alignment: Alignment.center,
                              color: MaterialColors.secondaryBackgroundColor,
                              child: const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  "ประวัติโรงแรม",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: MaterialColors.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: HistoryDetail(),
                      ),
                    )
                    
                  ],
                ),
              ),
            ),
          );
  }
}