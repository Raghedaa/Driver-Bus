import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_color.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool obscure;
  final VoidCallback? onIconTap;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.obscure = false,
    this.onIconTap,
    this.validator,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColor.primaryGreen,
          selectionColor: AppColor.primaryGreen.withOpacity(0.3),
          selectionHandleColor: AppColor.primaryGreen,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        cursorColor: AppColor.primaryGreen,
        style: TextStyle(color: context.black, fontSize: 16.sp),
        decoration: InputDecoration(
          counterText: "",
          labelText: label,
          labelStyle: TextStyle(color: context.grey, fontSize: 14.sp),
          floatingLabelStyle: const TextStyle(color: AppColor.primaryGreen),
          hintText: hint,
          hintStyle: TextStyle(color: context.grey, fontSize: 13.sp),
          prefixIcon: Icon(icon, color: context.grey, size: 22.sp),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility : Icons.visibility_off,
                    size: 20.sp,
                    color: obscure ? context.grey : AppColor.primaryGreen,
                  ),
                  onPressed: onIconTap,
                )
              : null,
          filled: true,
          fillColor: context.cardColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(
              color: AppColor.primaryGreen,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColor.error, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColor.error, width: 1.5),
          ),
        ),
      ),
    );
  }
}
