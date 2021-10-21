/*
 * flutter_sunmi_printer
 * Created by Andrey U.
 * 
 * Copyright (c) 2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sunmi_printer/src/enums.dart';
import 'sunmi_col.dart';
import 'sunmi_styles.dart';

class SunmiPrinter {
  static const String RESET = "reset";
  // static const String START_PRINT = "startPrint";
  // static const String STOP_PRINT = "stopPrint";
  // static const String IS_PRINTING = "isPrinting";
  static const String BOLD_ON = "boldOn";
  static const String BOLD_OFF = "boldOff";
  static const String UNDERLINE_ON = "underlineOn";
  static const String UNDERLINE_OFF = "underlineOff";
  static const String EMPTY_LINES = "emptyLines";
  static const String PRINT_TEXT = "printText";
  static const String PRINT_ROW = "printRow";
  static const String PRINT_IMAGE = "printImage";
  static const String CUT_PAPER = "cutPaper";
  static const double paperWidth = 400;

  static const MethodChannel _channel =
      const MethodChannel('flutter_sunmi_printer');

  static Future<void> reset() async {
    await _channel.invokeMethod(RESET);
  }

  // static Future<void> startPrint() async {
  //   await _channel.invokeMethod(START_PRINT);
  // }

  // static Future<void> stopPrint() async {
  //   await _channel.invokeMethod(STOP_PRINT);
  // }

  // static Future<void> isPrinting() async {
  //   await _channel.invokeMethod(IS_PRINTING);
  // }

  /// Print [text] with [styles] and skip [linesAfter] after
  static Future<void> text(
    String text, {
    SunmiStyles styles = const SunmiStyles(),
    int linesAfter = 0,
  }) async {
    await _channel.invokeMethod(PRINT_TEXT, {
      "text": text,
      "bold": styles.bold,
      "underline": styles.underline,
      "align": styles.align.value,
      "size": styles.size.value,
      "linesAfter": linesAfter,
    });
  }

  /// Skip [n] lines
  static Future<void> emptyLines(int n) async {
    if (n > 0) {
      await _channel.invokeMethod(EMPTY_LINES, {"n": n});
    }
  }

  /// Print horizontal full width separator
  static Future<void> hr({
    String ch = '-',
    int len = 31,
    linesAfter = 0,
  }) async {
    await text(List.filled(len, ch[0]).join(), linesAfter: linesAfter);
  }

  /// Print a row.
  ///
  /// A row contains up to 12 columns. A column has a width between 1 and 12.
  /// Total width of columns in one row must be equal to 12.
  static Future<void> row({
    required List<SunmiCol> cols,
    bool bold: false,
    bool underline: false,
    SunmiSize textSize: SunmiSize.md,
    int linesAfter: 0,
  }) async {
    final isSumValid = cols.fold(0, (int sum, col) => sum + col.width) == 12;
    if (!isSumValid) {
      throw Exception('Total columns width must be equal to 12');
    }

    final colsJson = List<Map<String, String>>.from(
        cols.map<Map<String, String>>((SunmiCol col) => col.toJson()));

    await _channel.invokeMethod(PRINT_ROW, {
      "cols": json.encode(colsJson),
      "bold": bold,
      "underline": underline,
      "textSize": textSize.value,
      "linesAfter": linesAfter,
    });
  }

  static Future<void> boldOn() async {
    await _channel.invokeMethod(BOLD_ON);
  }

  static Future<void> boldOff() async {
    await _channel.invokeMethod(BOLD_OFF);
  }

  static Future<void> underlineOn() async {
    await _channel.invokeMethod(UNDERLINE_ON);
  }

  static Future<void> underlineOff() async {
    await _channel.invokeMethod(UNDERLINE_OFF);
  }

  static Future<void> image(
    String base64, {
    SunmiAlign align: SunmiAlign.center,
  }) async {
    await _channel.invokeMethod(PRINT_IMAGE, {
      "base64": base64,
      "align": align.value,
    });
  }

  static Future<void> cutPaper() async {
    await _channel.invokeMethod(CUT_PAPER);
  }

  //CUSTOM TEXT STYLE
  static Future<void> niceHr() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    final paintBackground = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFFFFF);
    canvas.drawRect(const Rect.fromLTWH(0, 0, paperWidth, 12), paintBackground);
    final linePaint = Paint()
      ..strokeWidth = 5
      ..color = Colors.black;

    canvas.drawLine(const Offset(0, 5), const Offset(paperWidth, 5), linePaint);

    final picture = recorder.endRecording();
    await _printImage(picture, 10);
  }

  static Future<void> _printImage(Picture picture, int height) async {
    final img = await (await picture.toImage(paperWidth.toInt(), height + 1))
        .toByteData(format: ImageByteFormat.png);

    Uint8List imageUint8List =
        img!.buffer.asUint8List(img.offsetInBytes, img.lengthInBytes);

    List<int> imageListInt = imageUint8List.cast<int>();
    String imageString = base64.encode(imageListInt);
    image(imageString);
  }

  static Future<void> printCustomText(PrinterCustomText customPrint) async {
    final TextPainter textPainter = TextPainter(
        text: customPrint.text,
        textAlign: customPrint.textAlign,
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: paperWidth);
    final height = textPainter.height;

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paintBackground = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, paperWidth, height + 1), paintBackground);

    textPainter.paint(canvas, const Offset(0, 0));

    final picture = recorder.endRecording();
    _printImage(picture, height.toInt());
  }

  static Future<void> printColumnLayoutText(
      List<SunmiCustomTextColumn> columns, int padding) async {
    assert(columns.isNotEmpty);
    final List<TextPainter> painters = [];
    final int sumFlexs =
        columns.map((e) => e.flex).toList().reduce((a, b) => a + b);
    int maxHeight = 0;
    for (var column in columns) {
      final width =
          column.flex * (paperWidth - padding * columns.length - 1) / sumFlexs;
      final paint = TextPainter(
          text: column.text.text,
          textAlign: column.text.textAlign,
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: width, minWidth: width);
      painters.add(paint);
      if (maxHeight < paint.height) maxHeight = paint.height.toInt();
    }

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paintBackground = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, paperWidth, maxHeight + 1), paintBackground);
    double actualPadding = 0;
    for (int i = 0; i < painters.length; i++) {
      painters[i].paint(
          canvas,
          Offset(
              actualPadding + i * padding,
              _getVerticalPosition(
                  columns[i].align, painters[i].height, maxHeight.toDouble())));
      actualPadding += columns[i].flex *
          (paperWidth - padding * columns.length - 1) /
          sumFlexs;
    }

    final picture = recorder.endRecording();
    _printImage(picture, maxHeight);
  }

  static double _getVerticalPosition(
      SunmiColAlign align, double height, double totalHeight) {
    switch (align) {
      case SunmiColAlign.top:
        return 0;
      case SunmiColAlign.center:
        return (totalHeight / 2) - (height / 2);
      case SunmiColAlign.bottom:
        return totalHeight - height;
    }
  }
}

class PrinterCustomText {
  final TextSpan text;
  final TextAlign textAlign;
  PrinterCustomText({
    required this.text,
    required this.textAlign,
  });
}

class SunmiCustomTextColumn {
  final PrinterCustomText text;
  final int flex;
  final SunmiColAlign align;
  SunmiCustomTextColumn(
      {required this.text, this.flex = 1, this.align = SunmiColAlign.top});
}

enum SunmiColAlign { top, center, bottom }
