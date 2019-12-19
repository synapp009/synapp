import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'arrow.dart';
import 'data.dart';

class ArrowWidget extends StatelessWidget {
  Key originKey;
  Key targetKey;
  ArrowWidget(this.originKey, this.targetKey);

  var width;
  var top;
  var left;
  var size;
  var sector;

  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<Data>(context);
    var itemScale = dataProvider.structureMap[originKey].scale;
    var stackScale = dataProvider.stackScale;
    var itemPosition = (dataProvider.getPositionOfRenderBox(originKey) -
            dataProvider.stackOffset) /
        stackScale;
    var itemSize = dataProvider.structureMap[originKey].size * itemScale;

    Size connectedSizeCalculator() {
      //print('$originKey, has ${arrow.target} and ${arrow.origin}');

      var targetPosition = (dataProvider.getPositionOfRenderBox(targetKey) -
              dataProvider.stackOffset) /
          stackScale;
      var width = targetPosition.dx - itemPosition.dx;
      var height = targetPosition.dy - itemPosition.dy;
      var tempSize;
      return tempSize = Size(width, height);
    }

    // print('$originKey, has ${arrow.size}');
    Offset cartesianPosition() {
      var dy;
      var dx;
      var arrow;
      dataProvider.arrowMap[originKey].forEach((Arrow k) => {
            if (k.target == targetKey) {arrow = k}
          });

      if (arrow.size.height > 0 && arrow.size.width > 0) {
        //X2
        sector = 2;
        dy = itemPosition.dy + (itemSize.height / 2);
        dx = itemPosition.dx + (itemSize.width / 2);
      } else if (arrow.size.height < 0 && arrow.size.width > 0) {
        //X1
        sector = 1;
        dy = (itemPosition.dy + itemSize.height / 2) + arrow.size.height;
        dx = itemPosition.dx + itemSize.width / 2;
      } else if (arrow.size.height > 0 && arrow.size.width < 0) {
        //X3
        sector = 3;
        dy = itemPosition.dy + itemSize.height / 2;
        dx = itemPosition.dx + itemSize.width / 2 + arrow.size.width;
      } else {
        //X4
        sector = 4;
        dy = (itemPosition.dy + itemSize.height / 2) + arrow.size.height;
        dx = itemPosition.dx + itemSize.width / 2 + arrow.size.width;
      }
      var tempOffset = Offset(dx, dy);

      return tempOffset;
    }

    return Positioned(
      top: cartesianPosition().dy,
      left: cartesianPosition().dx,
      child: CustomPaint(
        size: connectedSizeCalculator(),
        foregroundPainter: MyPainter(sector),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  int sector;
  MyPainter(this.sector);
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Path path = Path();
    // TODO: do operations here

    if (sector == 1 || sector == 3) {
      path.moveTo(0, size.height); //.lineTo( 0,size.height);

      path.lineTo(size.width, 0);
    } else {
      path.lineTo(size.width, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
