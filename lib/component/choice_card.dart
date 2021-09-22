import 'package:animate_do/animate_do.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChoiceCard extends StatelessWidget {
  final String imageUrl;
  final bool isOdd;
  const ChoiceCard({Key? key, required this.imageUrl, required this.isOdd})
      : super(key: key);

  Future<String> _getImageDownloadUrl() {
    final FirebaseStorage storage = FirebaseStorage.instance;
    return storage.refFromURL(imageUrl).getDownloadURL();
  }

  Widget _buildImageWidget(BuildContext context, AsyncSnapshot snapshot) {
    return FractionallySizedBox(
      alignment: Alignment.center,
      widthFactor: 1,
      heightFactor: 1,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: MediaQuery.of(context).size.height * 3 / 4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(snapshot.data), fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: _getImageDownloadUrl(),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError)
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              else
                return isOdd
                    ? ElasticInLeft(
                        child: _buildImageWidget(context, snapshot),
                      )
                    : ElasticInRight(
                        child: _buildImageWidget(context, snapshot),
                      );
          }
        });
  }
}
