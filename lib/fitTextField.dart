import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data.dart';

class FitTextField extends StatefulWidget {
  final String initialValue;
  final double minWidth;
  final FocusNode myFocusNode;
  final enabled;
  final tapped;
  final itemScale;
  final itemKey;
  final feedbackKey;
  const FitTextField(
      {this.itemKey,
      this.initialValue,
      this.minWidth: 30,
      this.myFocusNode,
      this.enabled,
      this.tapped,
      this.itemScale,
      this.feedbackKey});

  @override
  State<StatefulWidget> createState() => new FitTextFieldState();
}

class FitTextFieldState extends State<FitTextField> {
  TextEditingController txt = TextEditingController();

  // We will use this text style for the TextPainter used to calculate the width
  // and for the TextField so that we calculate the correct size for the text
  // we are actually displaying
  TextStyle textStyle = TextStyle(fontSize: 16);

  initState() {
    super.initState();
    // Set the text in the TextField to our initialValue
    txt.text = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<Data>(context);
    // Use TextPainter to calculate the width of our text
    TextSpan ts = new TextSpan(style: textStyle, text: txt.text);
    // List<LineMetrics> lines = tp.computeLineMetrics();
    TextPainter tp = new TextPainter(
        text: ts, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();

    // We will use this width for the container wrapping our TextField
    var textWidth = tp.width;

    // Enforce a minimum width
    if (textWidth < widget.minWidth) {
      textWidth = widget.minWidth;
    } else {
      textWidth = textWidth;
    }
 
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(3) * widget.itemScale,
        child: Container(
          key:widget.feedbackKey,
          width: textWidth,
          child: FittedBox(
            child: Container(
              width: textWidth, //TODO: autosize width still not perfect
              //decoration: new BoxDecoration(color: color),

              child: TextField(
                enabled: widget.enabled,
                //readOnly: true,
                keyboardType: TextInputType.multiline,
                autofocus: false,
                //focusNode: widget.myFocusNode,
                maxLines: null,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 0, right: -5),
                  hintText: 'Text',
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(3),
                    ),
                  ),
                ),
                style: textStyle,
                controller: txt,
                onChanged: (text) {
                  
                      dataProvider.structureMap[widget.itemKey]
                      .content = txt.text;

                  // Tells the framework to redraw the widget
                  // The widget will redraw with a new width
                  setState(() {});
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
