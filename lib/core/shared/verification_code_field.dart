import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_color.dart';

class VerificationCodeField extends StatefulWidget {
  final int length;
  final Function(String)? onCompleted;
  final TextEditingController? controller;
  const VerificationCodeField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.controller,
  });

  @override
  State<VerificationCodeField> createState() => _VerificationCodeFieldState();
}

class _VerificationCodeFieldState extends State<VerificationCodeField> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    focusNodes = List.generate(widget.length, (index) => FocusNode());

    if (widget.controller != null) {
      widget.controller!.addListener(() {
        if (widget.controller!.text.isEmpty) {
          if (mounted) {
            setState(() {
              for (var controller in controllers) {
                controller.clear();
              }
            });
            focusNodes[0].requestFocus();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    for (var i = 0; i < widget.length; i++) {
      controllers[i].dispose();
      focusNodes[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        widget.length,
        (index) => SizedBox(
          width: 45.w,
          height: 55.h,
          child: Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: AppColor.primaryGreen,
                selectionHandleColor: AppColor.primaryGreen,
              ),
            ),
            child: TextFormField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              autofocus: index == 0,
              cursorColor: AppColor.primaryGreen,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              textInputAction: index == widget.length - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: context.fillColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(
                    color: AppColor.primaryGreen,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  if (index < widget.length - 1) {
                    focusNodes[index + 1].requestFocus();
                  } else {
                    focusNodes[index].unfocus();
                    String fullCode = controllers.map((e) => e.text).join();
                    if (widget.onCompleted != null)
                      widget.onCompleted!(fullCode);
                  }
                } else if (value.isEmpty && index > 0) {
                  focusNodes[index - 1].requestFocus();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
