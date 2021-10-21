import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sunmi_printer/flutter_sunmi_printer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void _print() async {
    // Test regular text
    SunmiPrinter.hr();
    SunmiPrinter.text(
      'Test Sunmi Printer',
      styles: SunmiStyles(align: SunmiAlign.center),
    );
    SunmiPrinter.hr();

    // Test align
    SunmiPrinter.text(
      'left',
      styles: SunmiStyles(bold: true, underline: true),
    );
    SunmiPrinter.text(
      'center',
      styles:
          SunmiStyles(bold: true, underline: true, align: SunmiAlign.center),
    );
    SunmiPrinter.text(
      'right',
      styles: SunmiStyles(bold: true, underline: true, align: SunmiAlign.right),
    );

    // Test text size
    SunmiPrinter.text('Extra small text',
        styles: SunmiStyles(size: SunmiSize.xs));
    SunmiPrinter.text('Medium text', styles: SunmiStyles(size: SunmiSize.md));
    SunmiPrinter.text('Large text', styles: SunmiStyles(size: SunmiSize.lg));
    SunmiPrinter.text('Extra large text',
        styles: SunmiStyles(size: SunmiSize.xl));

    // Test row
    SunmiPrinter.row(
      cols: [
        SunmiCol(text: 'col1', width: 4),
        SunmiCol(text: 'col2', width: 4, align: SunmiAlign.center),
        SunmiCol(text: 'col3', width: 4, align: SunmiAlign.right),
      ],
    );

    // Test image
    ByteData bytes = await rootBundle.load('assets/rabbit_black.jpg');
    final buffer = bytes.buffer;
    final imgData = base64.encode(Uint8List.view(buffer));
    SunmiPrinter.image(imgData);

    SunmiPrinter.emptyLines(3);

    // 切纸
    SunmiPrinter.cutPaper();
  }

  void _customPrint() async {
    // await SunmiPrinter.niceHr();
    // ByteData bytes = await rootBundle.load('assets/rabbit_black.jpg');
    // final buffer = bytes.buffer;
    // final imgData = base64.encode(Uint8List.view(buffer));
    // await SunmiPrinter.image(imgData);
    final double scale = 1;
    await SunmiPrinter.niceHr();
    await SunmiPrinter.printCustomText(PrinterCustomText(
        text: TextSpan(
            text: "Cliente: ",
            style: TextStyle(
                fontSize: scale * 12,
                fontWeight: FontWeight.w400,
                color: Colors.black),
            children: [
              TextSpan(
                text: "Ali Buenaño",
                style: TextStyle(
                    fontSize: scale * 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              )
            ]),
        textAlign: TextAlign.left));
    await SunmiPrinter.printCustomText(PrinterCustomText(
        text: TextSpan(
          text: "ID 1651859",
          style: TextStyle(
              fontSize: scale * 16,
              fontWeight: FontWeight.w700,
              color: Colors.black),
        ),
        textAlign: TextAlign.left));
    await SunmiPrinter.printCustomText(PrinterCustomText(
        text: TextSpan(
          text: "ID 1651859",
          style: TextStyle(
              fontSize: scale * 16,
              fontWeight: FontWeight.w700,
              color: Colors.black),
        ),
        textAlign: TextAlign.right));
    await SunmiPrinter.printCustomText(PrinterCustomText(
        text: TextSpan(
            text: "Dirección:",
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black),
            children: [
              TextSpan(
                text: "Manzana 130407 99-10, Las Lajas, Panamá",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              )
            ]),
        textAlign: TextAlign.left));
    SunmiPrinter.printWidgets([
      SunmiPrinter.columnLayoutText([
        SunmiCustomTextColumn(
            flex: 2,
            text: PrinterCustomText(
                text: TextSpan(
                  text: "2x Coca cola",
                  style: TextStyle(
                      fontSize: scale * 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black),
                ),
                textAlign: TextAlign.left)),
        SunmiCustomTextColumn(
            flex: 2,
            text: PrinterCustomText(
                text: TextSpan(
                  text: "\$ 2.00",
                  style: TextStyle(
                      fontSize: scale * 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                textAlign: TextAlign.right))
      ], 10),
      SunmiPrinter.customText(PrinterCustomText(
          text: TextSpan(
            text: "•Bebida: Soda",
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          textAlign: TextAlign.left)),
    ]);

    await SunmiPrinter.emptyLines(2);
    SunmiPrinter.cutPaper();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test Sunmi Printer'),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 50),
            Center(
              child: Column(
                children: [
                  RaisedButton(
                    onPressed: _print,
                    child: const Text('Print demo',
                        style: TextStyle(fontSize: 20)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    onPressed: _customPrint,
                    child: const Text('Print demo 2',
                        style: TextStyle(fontSize: 20)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    onPressed: () {
                      SunmiPrinter.emptyLines(1);
                    },
                    child: const Text('Empty Line',
                        style: TextStyle(fontSize: 20)),
                  ),
                  RaisedButton(
                    onPressed: () {
                      SunmiPrinter.cutPaper();
                    },
                    child: const Text('Crop', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
