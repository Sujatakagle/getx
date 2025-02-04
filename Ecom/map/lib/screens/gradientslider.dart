import 'package:flutter/material.dart';

class GradientSlider extends StatefulWidget {
  final double value;
  final Function(double) onChanged;
  final Gradient gradient;
  final double min;
  final double max;

  GradientSlider({
    required this.value,
    required this.onChanged,
    required this.gradient,
    this.min = 50.0,
    this.max = 10000.0,
  });

  @override
  _GradientSliderState createState() => _GradientSliderState();
}

class _GradientSliderState extends State<GradientSlider> {
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 3.0, // Keep track thin
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 10, // Slightly smaller thumb for a more minimalistic look
          elevation: 6, // Slight elevation for visibility
        ),
        activeTrackColor: Colors.transparent, // Transparent active track color
        inactiveTrackColor: Colors.transparent, // Transparent inactive track color
        thumbColor: Colors.white, // White thumb for better contrast
        overlayColor: Colors.blueAccent.withOpacity(0.2), // Subtle overlay color
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: Colors.blueAccent,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      child: Stack(
        children: [
          // Custom Gradient for the active track
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 6.0, // Slider line height
                decoration: BoxDecoration(
                  gradient: widget.gradient, // Apply gradient only to the slider line
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Actual slider on top of the gradient line
          Slider(
            value: widget.value,
            min: widget.min,
            max: widget.max,
            divisions: 199,
            label: "${(widget.value / 1000).toStringAsFixed(1)} km",
            onChanged: (double newValue) {
              widget.onChanged(newValue); // Call the onChanged callback for value updates
            },
          ),
        ],
      ),
    );
  }
}



