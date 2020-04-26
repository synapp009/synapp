import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../core/models/arrowModel.dart';
import '../../core/models/projectModel.dart';

class ArrowWidget extends StatelessWidget {
  final GlobalKey originKey;
  final GlobalKey targetKey;

  ArrowWidget(this.originKey, this.targetKey);
  @override
  Widget build(BuildContext context) {
    var sector;
    Arrow tempArrow;
    var projectProvider = Provider.of<Project>(context);

    var originId = projectProvider.getIdFromKey(originKey);
    var targetId = projectProvider.getIdFromKey(targetKey);
    double originScale = projectProvider.appletMap[originId].scale;
    double targetScale = projectProvider.appletMap[targetId].scale;
    var stackScale = projectProvider.stackScale;

    tempArrow = projectProvider.appletMap[originId].arrowMap[targetId];
   

    return Positioned(
      top: tempArrow.position.dy,
      left: tempArrow.position.dx,
      child: Transform.translate(
        offset: Offset(0, -50),
        child: Transform.rotate(
          alignment: Alignment.centerLeft,
          angle: tempArrow.angle.radians,
          child: CustomPaint(
            size: Size(tempArrow.size, 100),
            foregroundPainter:
                ArrowPainter(sector, originScale, targetScale, stackScale),
          ),
        ),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  ArrowPainter(
      this.sector, this.originScale, this.targetScale, this.stackScale);
  TextSpan textSpan;
  TextPainter textPainter;
  int sector;
  double originScale;
  double targetScale;
  var stackScale;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey[900]
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.0 * targetScale;

    Paint paintArrow = Paint()
      ..color = Colors.grey[900]
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.5 * targetScale;

    Path path = Path();
    Path pathArrow = Path();
    canvas.drawCircle(Offset(0, size.height / 2), 3 * originScale,
        paint..color = Colors.grey[900]);
    canvas.drawCircle(Offset(size.width, size.height / 2), 3 * targetScale,
        paint..color = Colors.grey[900]);
    path.moveTo(0, (size.height / 2) - (1 * originScale));
    path.lineTo(size.width, (size.height / 2) - (1 * targetScale));
    path.lineTo(size.width, (size.height / 2) + (1 * targetScale));
    path.lineTo(0, (size.height / 2) + (1 * originScale));
    path.lineTo(0, (size.height / 2) - (1 * originScale));

    path.close();
    canvas.drawPath(path, paint..color = Colors.grey[900]);

    /* pathArrow.moveTo(size.width - 0.1 * targetScale, (size.height / 2));
    pathArrow.lineTo(size.width, (size.height / 2));
    pathArrow = ArrowPath.make(tipLength: 7 * targetScale, path: pathArrow);
    canvas.drawPath(pathArrow, paintArrow..color = Colors.black);*/

    //Text of the arrow
    textSpan = TextSpan(
        //text: '...',
        style: TextStyle(color: Colors.grey[900], fontSize: 16 / stackScale));
    textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: size.width);
    textPainter.paint(canvas, Offset(0, (size.height / 2)));
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) => true;
}
