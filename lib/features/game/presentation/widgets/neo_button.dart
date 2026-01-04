import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class NeoButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final Color color; // Ana renk (Cyan veya Magenta)
  final double width;
  final double height;
  final VoidCallback onTap;
  final bool isPrimary; // Dolgulu mu (Start Game) yoksa çizgili mi (Settings)?

  const NeoButton({
    Key? key,
    this.text,
    this.icon,
    required this.color,
    this.width = 60,
    this.height = 50,
    required this.onTap,
    this.isPrimary = false, // Varsayılan: Çizgili (Settings gibi)
  }) : super(key: key);

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    HapticFeedback.lightImpact();
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.isPrimary ? widget.color : Colors.transparent, // Dolgu ayarı
              borderRadius: BorderRadius.circular(16),
              border: widget.isPrimary 
                  ? null 
                  : Border.all(color: widget.color.withOpacity(0.5), width: 2),
              boxShadow: widget.isPrimary
                  ? [
                      BoxShadow(color: widget.color.withOpacity(0.6), blurRadius: 20, spreadRadius: 1), // Neon Parlama
                      BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
                    ]
                  : [
                       BoxShadow(color: widget.color.withOpacity(0.1), blurRadius: 10, spreadRadius: 0)
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: widget.isPrimary ? Colors.black : widget.color, size: 24),
                  if (widget.text != null) const SizedBox(width: 8),
                ],
                if (widget.text != null)
                  Text(
                    widget.text!,
                    style: GoogleFonts.orbitron(
                      color: widget.isPrimary ? Colors.black : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}