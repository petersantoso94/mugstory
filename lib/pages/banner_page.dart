import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mugstory/pages/home_page.dart';

class BannerPage extends StatelessWidget {
  BannerPage({Key? key}) : super(key: key);
  final List<String> imgList = ['images/banner-1.jpg', 'images/banner-2.jpg'];

  Widget buildCarousel(BuildContext context) {
    return CarouselSlider(
      items: imgList
          .map(
            (item) => Container(
              child: Center(
                child: Image.asset(
                  item,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          )
          .toList(),
      options: CarouselOptions(
          viewportFraction: 1,
          height: MediaQuery.of(context).size.height,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      },
      child: buildCarousel(context),
    );
  }
}
