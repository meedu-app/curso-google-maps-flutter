import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_maps/models/place.dart';

class MyCustomMarker extends CustomPainter {
  final Place place;
  final int duration;

  MyCustomMarker(this.place, this.duration);

  void _buildMiniRect(Canvas canvas, Paint paint, double size) {
    paint.color = Colors.black;
    final rect = Rect.fromLTWH(0, 0, size, size);
    canvas.drawRect(rect, paint);
  }

  void _buildParagraph({
    @required Canvas canvas,
    @required List<String> texts,
    @required double width,
    @required Offset offset,
    Color color = Colors.black,
    double fontSize = 18,
    String fontFamily,
    TextAlign textAlign = TextAlign.left,
  }) {
    final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        maxLines: 2,
        textAlign: textAlign,
      ),
    );
    builder.pushStyle(
      ui.TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: fontFamily,
      ),
    );

    builder.addText(texts[0]);

    if (texts.length > 1) {
      builder.pushStyle(ui.TextStyle(
        fontWeight: FontWeight.bold,
      ));
      builder.addText(texts[1]);
    }

    final ui.Paragraph paragraph = builder.build();

    paragraph.layout(ui.ParagraphConstraints(width: width));
    canvas.drawParagraph(
      paragraph,
      Offset(offset.dx, offset.dy - paragraph.height / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    paint.color = Colors.white;

    final height = size.height - 15;

    final RRect rrect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      height,
      Radius.circular(0),
    );
    canvas.drawRRect(rrect, paint);

    final rect = Rect.fromLTWH(size.width / 2 - 2.5, height, 5, 15);

    canvas.drawRect(rect, paint);

    _buildMiniRect(canvas, paint, height);

    if (this.duration == null) {
      _buildParagraph(
        canvas: canvas,
        texts: [String.fromCharCode(Icons.gps_fixed.codePoint)],
        width: height,
        fontSize: 40,
        textAlign: TextAlign.center,
        offset: Offset(0, height / 2),
        color: Colors.white,
        fontFamily: Icons.gps_fixed.fontFamily,
      );
    } else {
      _buildParagraph(
        canvas: canvas,
        texts: ["${this.duration}\n", "MIN"],
        width: height,
        fontSize: 20,
        textAlign: TextAlign.center,
        offset: Offset(0, height / 2),
        color: Colors.white,
      );
    }

    _buildParagraph(
      canvas: canvas,
      texts: [this.place.title],
      width: size.width - height - 20,
      offset: Offset(height + 10, height / 2),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
