import 'package:flutter/material.dart';
import 'package:komunly/theme/colors.dart';
import 'package:shimmer/shimmer.dart';

Widget buildListVacia() {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            '¡Vaya! Parece que no hay nada que ver por aquí',
            style: TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget buildLoaderSmallItem() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: Card(
      color: Colors.grey[900],
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildLoaderMessage() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Shimmer.fromColors(
               baseColor: Colors.blue,
                  highlightColor: Colors.white,
              child: Container(
                width: 300,
                height: 40,
                padding: const EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildLoaderPostItem() {
  var postHeight = 400.00;
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: postHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: grey.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 15,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5).withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
        Container(
            width: double.infinity,
            height: postHeight,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: black.withOpacity(0.25))),
        Container(
          width: double.infinity,
          height: postHeight,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          radius: 20,
                          child: ClipOval(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 12,
                                width: 80,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 10,
                                width: 60,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    GestureDetector(
                      child: const Icon(
                        Icons.more_vert,
                        color: white,
                        size: 20,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      child: Container(
                        width: 70,
                        height: 27,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(27),
                            color: const Color(0xFFE5E5E5).withOpacity(0.5)),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        width: 70,
                        height: 27,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(27),
                            color: const Color(0xFFE5E5E5).withOpacity(0.5)),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        width: 70,
                        height: 27,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(27),
                            color: const Color(0xFFE5E5E5).withOpacity(0.5)),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        width: 70,
                        height: 27,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(27),
                            color: const Color(0xFFE5E5E5).withOpacity(0.5)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
