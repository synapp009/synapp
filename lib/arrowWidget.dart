import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data.dart';

class ArrowWidget extends StatelessWidget {
  Key itemKey;
  ArrowWidget(this.itemKey);

  var width;
  var top;
  var left;

  var size;
  var sector;
  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<Data>(context);
    var itemScale = dataProvider.structureMap[itemKey].scale;
    var stackScale = dataProvider.stackScale;
    var itemPosition = (dataProvider.getPositionOfRenderBox(itemKey) -
            dataProvider.stackOffset) /
        stackScale;
    var itemSize = dataProvider.structureMap[itemKey].size * itemScale;

    Offset cartesianPosition() {
      var dy;
      var dx;
      Offset tempOffset;

      if (dataProvider.arrowMap[itemKey].size.height > 0 &&
          dataProvider.arrowMap[itemKey].size.width > 0) {
        //X2
        sector = 2;
        dy = itemPosition.dy + (itemSize.height / 2);
        dx = itemPosition.dx + (itemSize.width / 2);
      } else if (dataProvider.arrowMap[itemKey].size.height < 0 &&
          dataProvider.arrowMap[itemKey].size.width > 0) {
        //X1
        sector = 1;
        dy = (itemPosition.dy + itemSize.height / 2) +
            dataProvider.arrowMap[itemKey].size.height;
        dx = itemPosition.dx + itemSize.width / 2;
      } else if (dataProvider.arrowMap[itemKey].size.height > 0 &&
          dataProvider.arrowMap[itemKey].size.width < 0) {
        //X3
        sector = 3;
        dy = itemPosition.dy + itemSize.height / 2;
        dx = itemPosition.dx +
            itemSize.width / 2 +
            dataProvider.arrowMap[itemKey].size.width;
      } else {
        //X4
        sector = 4;
        dy = (itemPosition.dy + itemSize.height / 2) +
            dataProvider.arrowMap[itemKey].size.height;
        dx = itemPosition.dx +
            itemSize.width / 2 +
            dataProvider.arrowMap[itemKey].size.width;
      }

      return tempOffset = Offset(dx, dy);
    }

    return Positioned(
      top: cartesianPosition().dy,
      left: cartesianPosition().dx,
      child: Container(
        width: (dataProvider.arrowMap[itemKey].size.width + (itemScale - 1/itemScale)*itemSize.width).abs(),
        height: dataProvider.arrowMap[itemKey].size.height.abs(),
        color: Colors.green,
        child: CustomPaint(
          size: Size(
            dataProvider.arrowMap[itemKey].size.width,
            dataProvider.arrowMap[itemKey].size.height,
          ),
          foregroundPainter: MyPainter(sector),
        ),
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
