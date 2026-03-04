import 'package:flutter/material.dart';
import 'package:gymplanner_mobile/common/color_extension.dart';
import 'package:gymplanner_mobile/common_widget/on_boarding_page.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int selectPage = 0;
  PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        selectPage = controller.page?.round() ?? 0;
      });
    });
  }

  List pageArr = [
    {
      "title":"Track Your Progress",
      "subtitle":"Don't worry if you have trouble determining your goals, We can help you determine your goals and track your goals",
      "image":"assets/img/Onboarding - 1.png"
    },
    {
      "title":"Get Burn", 
      "subtitle":"Let’s keep burning, to achive yours goals, it hurts only temporarily, if you give up now you will be in pain forever", 
      "image":"assets/img/Onboarding - 2.png"
    },
    {
      "title":"Eat Well", 
      "subtitle":"Let's start a healthy lifestyle with us, we can determine your diet every day. healthy eating is fun", 
      "image":"assets/img/Onboarding - 3.png"
    },
    {
      "title":"Improve Sleep\nQuality", 
      "subtitle":"Improve the quality of your sleep with us, good quality sleep can bring a good mood in the morning", 
      "image":"assets/img/Onboarding - 4.png"
    }
  ];

  @override
  Widget build(BuildContext context) {
    // var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(
            controller: controller,
            itemCount: pageArr.length,
            itemBuilder: (context, index) {
              var p0bj = pageArr[index] as Map? ?? {};
              return OnBoardingPage(p0bj: p0bj,);

          }),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  // padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  margin: const EdgeInsets.only(bottom: 30, right: 30),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: TColor.primaryColor1,
                    borderRadius: BorderRadius.circular(35)
                  ),
                  child: IconButton(
                    onPressed: (){
                      if(pageArr.length - 1 == selectPage){
                      controller.jumpToPage(selectPage + 1);
                      } else {
                        controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                      }
                    },
                    icon: Icon(Icons.navigate_next, color: TColor.white, size: 35,)
                  ),
                ),

                // CircularProgressIndicator(
                //   value: (selectPage + 1) / pageArr.length,
                //   color: TColor.primaryColor1,
                //   backgroundColor: TColor.gray.withOpacity(0.5),
                // ),

              ],
            ),
          )
        ],
      )
    );
  }
}