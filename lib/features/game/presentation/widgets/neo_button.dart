import 'package:flutter/material.dart';

class NeoButton extends StatefulWidget {
  final String? text;       // Yazı (START GAME vb.)
  final IconData? icon;     // İkon (Pause, Settings vb.)
  final Color color;        // Butonun ana rengi
  final VoidCallback onTap; // Tıklama fonksiyonu
  final double width;       // Genişlik (Varsayılan full)

  const NeoButton({
    Key? key,
    this.text,
    this.icon,
    required this.color,
    required this.onTap,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  _NeoButtonState createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Tıklama animasyonu hızı (100ms)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1, // %10 küçülme oranı
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward(); // Basınca küçül
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse(); // Bırakınca eski haline dön
    widget.onTap();        // İşlemi yap
  }

  void _onTapCancel() {
    _controller.reverse(); // Vazgeçerse eski haline dön
  }

  @override
  Widget build(BuildContext context) {
    double scale = 1.0 - _controller.value;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: widget.text != null ? widget.width : null,
          padding: widget.text != null 
              ? const EdgeInsets.symmetric(vertical: 16) // Büyük buton
              : const EdgeInsets.all(12),               // Küçük ikon buton
          
          decoration: BoxDecoration(
            color: const Color(0xFF24263A),
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                widget.color.withOpacity(0.8), 
                widget.color.withOpacity(0.4)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.5),
                // Basınca gölge azalır ve buton aşağı iniyormuş gibi görünür
                blurRadius: _controller.value > 0.05 ? 5 : 15,
                offset: _controller.value > 0.05 ? const Offset(0, 2) : const Offset(0, 6),
              )
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1
            )
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Sadece ikon varsa
    if (widget.text == null && widget.icon != null) {
      return Icon(widget.icon, color: Colors.white, size: 24);
    }
    
    // Yazı varsa
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.text == "PLAY AGAIN") ...[
           const Icon(Icons.refresh, color: Colors.white, size: 20),
           const SizedBox(width: 8),
        ],
        Text(
          widget.text ?? "",
          style: const TextStyle( // GoogleFonts kullanıyorsan burayı güncellemen gerekmez, Theme'den alır
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}