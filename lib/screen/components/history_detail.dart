import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";

class HistoryDetail extends StatelessWidget {
  const HistoryDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'โรงแรม อิมม์ ท่าแพ เชียงใหม่ ตั้งอยู่ข้าง ประตูท่าแพ\n'
          'อันเก่าแก่ซึ่งเป็นสถานที่สำคัญที่โดดเด่นที่สุดของ'
          'เชียงใหม่\nและเป็นโรงแรมที่พร้อมให้แขกได้สำรวจมรดกอันยาวนานและวัฒนธรรมดั้งเดิมของเชียงใหม่ และยิ่งไปกว่านั้นโรงแรมแห่งนี้ยังเป็นจุดเริ่มต้นที่'
          'สมบูรณ์แบบสำหรับการผสมผสานของร้านค้า ร้านอาหารที่หลากหลายของเมืองเชียงใหม่ สถานบันเทิงยามค่ำคืนที่มีชีวิตชีวา ตลาดกลางคืนในตำนาน และตลาดถนนคนเดินในวันหยุดสุดสัปดาห์',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MaterialColors.secondary,
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        const Text(
          'ที่เป็นที่รู้จักกันคนเชียงใหม่หากอยากดื่มด่ำกับประวัติศาสตร์ที่น่าสนใจ'
          'ของเมืองเชียงใหม่ เพียงก้าวออกไปนอกโรงแรม และผ่านประตูท่าแพ จะเห็นสถานที่ที่เก่าแก่ที่สุดแห่งหนึ่ง และเมืองนี้มีลักษณะคล้ายสวนสนุกแห่งประวัติศาสตร์ ที่เต็มไปด้วยซากโบราณสถานสถาปัตยกรรม'
          'อันงดงาม และศิลปะชาติพันธุ์ที่แท้จริงความเป็นมาเล็กน้อย: ประตูท่าแพ เป็นประตูสู่วัฒนธรรมการค้าขายที่คึกคักของเชียงใหม่ ซึ่งยังคงมีอยู่จนถึงทุกวันนี้ ด้วยตลาดที่เฟื่องฟู และที่ใดที่มีการค้าขาย ก็มีสถานบันเทิงร้านอาหาร และสปาทุกประเภทอย่างหลีกเลี่ยงไม่ได้​',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MaterialColors.secondary,
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        const Text(
          '​ยิ่งไปกว่านั้นเมืองนี้ยังมีชื่อเสียงในเรื่องของเทศกาลต่างๆ เช่น เทศกาลดอกไม้ลานตาในเดือนกุมภาพันธ์, เทศกาลสงกรานต์ในเดือนเมษายน และเทศกาลลอยกระทงในเดือนพฤศจิกายน'
          'เดินเล่นไปยังวัดพระสิงห์ เพื่อเยี่ยมชม“ หอไตร” อันงดงามที่ประดิษฐาน“ พระพุทธสิหิงค์” ซึ่งเป็นพระพุทธรูปศักดิ์สิทธิ์ที่สุดของเมือง เดินเล่นไปตามถนนคนเดินในช่วงสุดสัปดาห์ที่คึกคักของถนนวัวลาย และถนนราชดำเนิน แหล่งรวบรวมสิ่งประดิษฐ์ทางภาคเหนือแท้ๆ ที่ประดิษฐ์ขึ้นอย่างประณีต เสื้อผ้าชาวเขา ภาพวาด ของตกแต่ง อาหาร และเครื่องดื่ม สไตล์ล้านนา น่ารับประทาน และของที่ระลึกอื่น ๆ อีกมากมาย ของเชียงใหม่สมัยโบราณ และสมัยใหม่ คุณจะได้รับความบันเทิงจากศิลปินสมัครเล่นที่แสดงดนตรี และการเต้นรำพื้นบ้านแบบดั้งเดิม และทันสมัยมากขึ้น',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MaterialColors.secondary,
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        const Text(
          'เย็นวันอาทิตย์กลับมาที่ถนนคนเดินท่าแพ ซึ่งมีผู้ขายแผงลอย เสนองานหัตถกรรมท้องถิ่นมากมาย และศิลปินฝีมือดีวาดภาพบุคคลอย่างรวดเร็ว',
         textAlign: TextAlign.center,
          style: TextStyle(
            color: MaterialColors.secondary,
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        const Text(
          'สำหรับสิ่งนี้และอื่น ๆ อีกมากมายคุณจะไม่สามารถอยู่ที่ไหนดีไปกว่า อิมม์ โฮเทล ท่าแพ เชียงใหม่',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MaterialColors.secondary,
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset("assets/images/image53.png",height: 100, ),
                ],
              ),
            ),
              Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset("assets/images/image54.png",height: 100,),
                ],
              ),
            ),
              Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset("assets/images/image55.png",height: 100,),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
