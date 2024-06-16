import 'package:flutter/material.dart';
import 'package:komunly/theme/colors.dart';

class PremiumUser extends StatefulWidget {
  final String username;
  final double fontSize;
  const PremiumUser({Key? key, required this.username, required this.fontSize}) : super(key: key);

  @override
  State<PremiumUser> createState() => _PremiumUserState();
}

class _PremiumUserState extends State<PremiumUser>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _animationController.repeat(reverse: true);

    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ShaderMask(
        child: Text(
          widget.username,
          style: TextStyle(
              fontSize: widget.fontSize, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        shaderCallback: (rect) {
          return LinearGradient(stops: [
            _animation.value - 0.5,
            _animation.value,
            _animation.value + 0.5
          ], colors: [
            primary,
            white,
             primary,
          ]).createShader(rect);
        },
      ),
    );
  }
}
