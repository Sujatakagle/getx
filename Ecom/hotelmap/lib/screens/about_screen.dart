import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // Repeat animation in reverse to make it jump

    // Define a Tween animation for jumping effect
    _animation = Tween<double>(begin: 0, end: -30).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material( // Using Material as the root widget instead of Scaffold
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated red location icon with jumping effect
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _animation.value), // Apply jump effect on Y axis
                    child: Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                      size: 150.0, // Adjust the size of the icon as needed
                    ),
                  );
                },
              ),
              const SizedBox(height: 10), // Provide space between the icon and the text
              // Title Text with More Style
              Text(
                "Discover the Best Hotels Around You",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Set text color directly
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              // Subtext Description with Subtle Styling
              Text(
                "This application helps users find hotels on Google Maps, explore hotel details and plan trips efficiently. Start your journey by logging in or creating an account",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600], // Set text color directly
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Custom Styled Explore Button with Dynamic Effects
              GestureDetector(
                onTap: () {
                  // Navigate to LoginScreen using route name
                  // Navigator.pushNamed(context, '/login');
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Colors.black, // Dark button color
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  child: const Text(
                    "Explore Now",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text color for button
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
