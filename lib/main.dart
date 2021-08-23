import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qr Digital',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Qr Digital'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title = 'a'}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _text = '';
  TextEditingController _controller = TextEditingController();

  void setText(String text) {
    setState(() {
      _text = text;
    });
  }

  _launchURL() async {
    if (await canLaunch(_text)) {
      await launch(_text);
    } else {
      throw 'Could not launch $_text';
    }
  }

  Future<void> downloadImage(Uint8List data) async {
    try {
      // we get the bytes from the body
      // and encode them to base64

      // then we create and AnchorElement with the html package
      final a = html.AnchorElement(
          href: 'data:image/jpeg;base64,${base64Encode(data)}');

      // set the name of the file we want the image to get
      // downloaded to
      a.download = 'download.jpg';

      // and we click the AnchorElement which downloads the image
      a.click();
      // finally we remove the AnchorElement
      a.remove();
    } catch (e) {
      print(e);
    }
  }

  Future<Uint8List> _getWidgetImage() async {
    ByteData image = await QrPainter(
          data: '$_text',
          gapless: true,
          version: QrVersions.auto,
          color: Colors.black,
          embeddedImageStyle: QrEmbeddedImageStyle(size: Size(12, 12)),
          emptyColor: Colors.white,
        ).toImageData(400, format: ImageByteFormat.png) ??
        ByteData(0);

    var pngBytes = image.buffer.asUint8List();

    return pngBytes;
  }

  _onTapGenetare() {
    setText(_controller.text);
  }

  Key? _renderObjectKey;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _onTapGenetare(),
                    autofocus: true,
                  ),
                ),
                ElevatedButton(onPressed: _onTapGenetare, child: Text('Gerar')),
              ],
            ),
            _text == ""
                ? Container(
                    height: 200,
                    width: 200,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    child: Icon(Icons.broken_image_outlined),
                  )
                : RepaintBoundary(
                    key: _renderObjectKey,
                    child: QrImage(
                      data: '$_text',
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
            _text == ""
                ? Container()
                : ElevatedButton(
                    onPressed: () async {
                      Uint8List a = await _getWidgetImage();
                      downloadImage(a);
                    },
                    child: Text('Download')),
            InkWell(
              onTap: () => _launchURL(),
              child: Text(
                '$_text',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
