import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:arrow_path/arrow_path.dart';

import 'arrow.dart';
import 'data.dart';

class ArrowWidget extends StatelessWidget {
  final GlobalKey originKey;
  final GlobalKey targetKey;

  ArrowWidget(this.originKey, this.targetKey);

  @override
  Widget build(BuildContext context) {

    var sector;
    Arrow tempArrow;
    var dataProvider = Provider.of<Data>(context);
    dataProvider.arrowMap[originKey].forEach((Arrow k) => {
          if (k.target == targetKey) {tempArrow = k}
        });


   
    return Positioned(
      top: tempArrow.position.dy,
      //dataProvider.centerOfRenderBox(originKey).dy,
      left: tempArrow.position.dx,
      //dataProvider.centerOfRenderBox(originKey).dx,
      child: Transform.rotate(
        alignment: Alignment.centerLeft,
        angle: tempArrow.angle.radians,
        child: CustomPaint(
          size: Size(tempArrow.size, 2),
          foregroundPainter: ArrowPainter(sector),
        ),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  TextSpan textSpan;
  TextPainter textPainter;
  int sector;
  ArrowPainter(this.sector);
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;

    Path path = Path();
    // TODO: do operations here

    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, 0); //.lineTo( 0,size.height);

    path = ArrowPath.make(path: path);

    canvas.drawPath(path, paint..color = Colors.blue);
    textSpan =
        TextSpan(text: 'Single arrow', style: TextStyle(color: Colors.blue));
    textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: size.width);
    textPainter.paint(canvas, Offset(0, size.height * 0.06));
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) => true;
}
