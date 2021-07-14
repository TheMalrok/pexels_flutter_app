import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hexcolor/hexcolor.dart';
import 'package:pexels_flutter_app/fullscreen.dart';

class Wallpaper extends StatefulWidget {
  @override
  State<Wallpaper> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Wallpaper> {
  List images = [];
  int page = 1;
  ScrollController _scrollController = ScrollController();

  @override
  initState() {
    super.initState();
    fetchapi();
    _scrollController.addListener(() {
      //Scroll controller loads more elements when you scroll to bottom
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  _getMoreData() async {
    //loading more images from pexels.com
    setState(() {
      page = page + 1;
    });
    String url =
        'https://api.pexels.com/v1/curated?per_page=39&page=' + page.toString();
    await http.get(Uri.parse(url), headers: {
      'Authorization':
          '563492ad6f917000010000011de017adc2f943dabebf5c135b813bb3'
    }).then((value) {
      Map result = jsonDecode(value.body);
      setState(() {
        images.addAll(result['photos']);
      });
    });
  }

  fetchapi() async {
    // documentation of pexel API https://www.pexels.com/pl-pl/api/documentation/
    await http.get(Uri.parse('https://api.pexels.com/v1/curated?per_page=39'),
        headers: {
          'Authorization':
              '563492ad6f917000010000011de017adc2f943dabebf5c135b813bb3'
        }).then((value) {
      Map result = jsonDecode(value.body);
      setState(() {
        images = result['photos'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
                controller: _scrollController,
                itemCount: images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    childAspectRatio: 2 / 3,
                    mainAxisSpacing: 2),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          //pushing to next screen direct link to an image in bigger size to show it on FullScreen
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullScreen(
                                  imageurl: images[index]['src']['large'])));
                    },
                    child: Container(
                      color: HexColor(images[index]['avg_color']),
                      child: Image.network(images[index]['src']['tiny'],
                          fit: BoxFit.cover),
                    ),
                  );
                }),
          ),
        ],
      ),
    ));
  }
}
