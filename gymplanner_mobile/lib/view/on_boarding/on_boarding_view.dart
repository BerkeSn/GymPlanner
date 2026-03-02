import 'package:flutter/material.dart';
import 'package:gymplanner_mobile/common/color_extension.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemBuilder: (context, index) {
            return SizedBox(
              width: media.width,
              height: media.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/img/Onboarding - 1.png", 
                    width: media.width, 
                    fit: BoxFit.cover
                    ),
                ],
              ),
            );
          })
        ],
      )
    );
  }
}