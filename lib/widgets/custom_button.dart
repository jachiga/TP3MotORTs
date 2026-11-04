import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
final String text;
final VoidCallback? onPressed;
final bool isLoading;
final bool isSecondary;
final Widget? icon;

const CustomButton({
super.key,
required this.text,
required this.onPressed,
this.isLoading = false,
this.isSecondary = false,
this.icon,
});

@override
Widget build(BuildContext context) {
const primaryColor = Color(0xFF00D2A0); // Teal vibrante de la imagen
const secondaryBgColor = Color(0xFF131D2A);
const borderColor = Color(0xFF233348);

return SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton(
    onPressed: isLoading ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: isSecondary ? secondaryBgColor : primaryColor,
      foregroundColor: isSecondary ? Colors.white : const Color(0xFF0B111A),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isSecondary
            ? const BorderSide(color: borderColor, width: 1.5)
            : BorderSide.none,
      ),
    ),
    child: isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: isSecondary ? primaryColor : const Color(0xFF0B111A),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 10),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSecondary ? Colors.white : const Color(0xFF0B111A),
                ),
              ),
            ],
          ),
  ),
);


}
}