import 'package:flutter/material.dart';
import 'package:gymplanner_mobile/common/color_extension.dart';

class OnBoardingPage extends StatelessWidget {
  final Map p0bj;
  const OnBoardingPage({super.key, required this.p0bj });

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return SizedBox(
      width: media.width,
      height: media.height,
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Image.asset(
            p0bj["image"] ?? "",
            width: media.width,
            fit: BoxFit.cover,
          ),

          SizedBox(height: media.height * 0.05),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Text(
              p0bj["title"] ?? "",
              style: TextStyle(
                color: TColor.black,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Text(
              p0bj["subtitle"] ?? "",
              style: TextStyle(
                color: TColor.gray,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
                    Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            child: IconButton(
              onPressed: () {},
              color: Colors.red,
              icon: Icon(
                Icons.navigate_next,
                color: TColor.white,
                size: 30,
              ),
            ),
          )
        ],
      ),
    );
  }
}