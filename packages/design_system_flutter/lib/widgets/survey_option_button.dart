import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SurveyOptionButton extends StatelessWidget {
  const SurveyOptionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.optionIndex,
    required this.optionCount,
    this.selected = false,
  });

  final String text;
  final VoidCallback onPressed;
  final int optionIndex;
  final int optionCount;
  final bool selected;

  Color _darken(Color color, [double amount = 0.12]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final surveyOptionColors =
        Theme.of(context).extension<SurveyOptionColors>();
    if (surveyOptionColors == null) {
      // Fallback or error handling
      return ElevatedButton(onPressed: onPressed, child: Text(text));
    }

    // Determine the color based on the option index.
    // This is a simple example. You might want a more sophisticated way
    // to map indices to colors, especially if the number of options
    // doesn't match the number of colors in the palette.
    final colorIndex = optionIndex % surveyOptionColors.palette.length;
    final color = surveyOptionColors.palette[colorIndex];
    final bottomRightColor = _darken(color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: selected
                ? const BorderSide(color: Colors.white, width: 2)
                : BorderSide.none,
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, bottomRightColor],
            ),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
