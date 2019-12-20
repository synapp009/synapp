import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'arrow.dart';
import 'data.dart';

class ArrowWidget extends StatefulWidget {
  final originKey;
  final targetKey;

  ArrowWidget(this.originKey, this.targetKey);
  @override
  _ArrowWidgetState createState() => _ArrowWidgetState();
}

class _ArrowWidgetState extends State<ArrowWidget> {
  var width;
  var top;
  var left;
  var size;
  var sector;

  @override
  Widget build(BuildContext context) {
    Arrow tempArrow;
    var dataProvider = Provider.of<Data>(context);
    dataProvider.arrowMap[widget.originKey].forEach((Arrow k) => {
          if (k.target == widget.targetKey) {tempArrow = k}
        });

    var itemScale = dataProvider.structureMap[widget.originKey].scale;
    var stackScale = dataProvider.stackScale;
    var itemPosition = Offset(
        (dataProvider.getPositionOfRenderBox(widget.originKey).dx -
                dataProvider.stackOffset.dx) /
            stackScale,
        (dataProvider.getPositionOfRenderBox(widget.originKey).dy -
                dataProvider.stackOffset.dy) /
            stackScale);
    var itemSize = dataProvider.structureMap[widget.originKey].size * itemScale;

    Size connectedSizeCalculator(tempOriginKey, tempTargetKey) {
      //sets correct Size for arrow Paint canvas xy 2d coordinate system
      //a)from origin to pointer b)from origin to target c)when moving: from feedback to target

      if (tempTargetKey == null) {
        return Size(tempArrow.size.width.abs(), tempArrow.size.height.abs());
      }
      var targetPosition;
      var originPosition;
      var width;
      var height;
      if (dataProvider.actualFeedbackKey != null) {
    //b) origin to target and c) feedback to target
        GlobalKey tempKey = dataProvider.actualFeedbackKey;
        RenderBox tempBox = tempKey.currentContext.findRenderObject();
        var feedbackBoxSize = tempBox.size;

        targetPosition = (dataProvider.getPositionOfRenderBox(tempTargetKey) -
                dataProvider.stackOffset) /
            stackScale;
        originPosition = (dataProvider
                    .getPositionOfRenderBox(dataProvider.actualFeedbackKey) -
                dataProvider.stackOffset) /
            stackScale;

        width = ((originPosition.dx + feedbackBoxSize.width / 2) -
            (targetPosition.dx +
                dataProvider.structureMap[tempTargetKey].size.width / 2));
        height = ((originPosition.dy + feedbackBoxSize.height) -
            (targetPosition.dy +
                dataProvider.structureMap[tempTargetKey].size.height));
      } else {
        //a)from origin to pointer
        targetPosition = (dataProvider.getPositionOfRenderBox(tempTargetKey) -
                dataProvider.stackOffset) /
            stackScale;
        originPosition = (dataProvider.getPositionOfRenderBox(tempOriginKey) -
                dataProvider.stackOffset) /
            stackScale;

        width = ((originPosition.dx +
                dataProvider.structureMap[tempOriginKey].size.width / 2) -
            (targetPosition.dx +
                dataProvider.structureMap[tempTargetKey].size.width / 2));
        height = ((originPosition.dy +
                dataProvider.structureMap[tempOriginKey].size.height) -
            (targetPosition.dy +
                dataProvider.structureMap[tempTargetKey].size.height));
      }

      var tempSize;

      //tempArrow.size = Size(width, height);
      return tempSize = Size(width, height);
    }

    Offset cartesianPosition(tempOriginKey, tempTargetKey) {
      //calculate the position of the arrow (top-left) in respective to cartesian system

      var dy;
      var dx;

      var tempSize;
      if (tempTargetKey == null) {
        tempSize = tempArrow.size;
      } else {
        tempSize = connectedSizeCalculator(tempOriginKey, tempTargetKey);
        tempSize = Size(-tempSize.width, -tempSize.height);
      }

      if (dataProvider.actualFeedbackKey != null) {
        itemPosition =
            dataProvider.getPositionOfRenderBox(dataProvider.actualFeedbackKey);

        GlobalKey tempKey = dataProvider.actualFeedbackKey;
        RenderBox tempBox = tempKey.currentContext.findRenderObject();
        itemSize = tempBox.size;
      }

      if (tempSize.height > 0 && tempSize.width > 0) {
        //X2

        sector = 2;
        dy = itemPosition.dy + (itemSize.height / 2);
        dx = itemPosition.dx + (itemSize.width / 2);
      } else if (tempSize.height < 0 && tempSize.width > 0) {
        //X1

        sector = 1;
        dy = (itemPosition.dy + itemSize.height / 2) + tempSize.height;
        dx = itemPosition.dx + itemSize.width / 2;
      } else if (tempSize.height > 0 && tempSize.width < 0) {
        //X3

        sector = 3;
        dy = itemPosition.dy + itemSize.height / 2;
        dx = itemPosition.dx + itemSize.width / 2 + tempSize.width;
      } else {
        //X4

        sector = 4;
        dy = (itemPosition.dy + itemSize.height / 2) + tempSize.height;
        dx = itemPosition.dx + itemSize.width / 2 + tempSize.width;
      }
      var tempOffset = Offset(dx, dy);
      return tempOffset;
    }

    //dataProvider.arrowMap[originKey].forEach((f)=>{if(f.target == null){nullItemSize = f.size}});

    return Positioned(
      top: cartesianPosition(widget.originKey, widget.targetKey).dy,
      left: cartesianPosition(widget.originKey, widget.targetKey).dx,
      child: CustomPaint(
        size: //Size(tempArrow.size.width.abs(), tempArrow.size.height.abs()),
            Size(
                connectedSizeCalculator(widget.originKey, widget.targetKey)
                    .width
                    .abs(),
                connectedSizeCalculator(widget.originKey, widget.targetKey)
                    .height
                    .abs()),
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
