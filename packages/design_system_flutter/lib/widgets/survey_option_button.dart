import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SurveyOptionButton extends StatelessWidget {
  const SurveyOptionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.optionIndex,
    required this.optionCount,
  });

  final String text;
  final VoidCallback onPressed;
  final int optionIndex;
  final int optionCount;

  @override
  Widget build(BuildContext context) {
    final surveyOptionColors = Theme.of(context).extension<SurveyOptionColors>();
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: color.withOpacity(0.8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
