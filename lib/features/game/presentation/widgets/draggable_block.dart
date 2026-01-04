import 'package:flutter/material.dart';
import '../../domain/block_model.dart';

class DraggableBlock extends StatelessWidget {
  final BlockModel shape;
  final VoidCallback onDragEnd;

  const DraggableBlock({Key? key, required this.shape, required this.onDragEnd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Boyutları hesapla
    int maxX = 0; int maxY = 0;
    for (var p in shape.positions) { if (p.x > maxX) maxX = p.x; if (p.y > maxY) maxY = p.y; }
    
    // Grid hücresi boyutu (GamePage ile uyumlu olmalı)
    double cellSize = 32.0; 
    
    return Draggable<BlockModel>(
      data: shape,
      dragAnchorStrategy: pointerDragAnchorStrategy, // Dokunduğun yerden tutar
      
      // GHOST SHAPE (Sürüklenen Hayalet Şekil)
      feedback: Transform.translate(
        // İŞTE ÇÖZÜM: Şekli parmağın 80px YUKARISINA görsel olarak itiyoruz.
        // Böylece parmak altta kalıyor, şekil üstte görünüyor.
        // Ama kod tarafında parmak nereye değerse orası seçiliyor.
        offset: const Offset(0, -90), 
        child: Material(
          color: Colors.transparent,
          child: Transform.scale(
            scale: 1.1, // Sürüklerken %10 büyüsün
            child: Opacity(
              opacity: 0.9,
              child: _buildShapeUi(cellSize),
            ),
          ),
        ),
      ),
      
      childWhenDragging: Opacity(
        opacity: 0.2,
        child: _buildShapeUi(20), // Sürüklenirken yerinde kalan soluk kopya
      ),
      
      onDragEnd: (details) => onDragEnd(),
      
      // Menu'deki duruşu
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(10), // Tutma kolaylığı
        child: _buildShapeUi(18), // Menüde biraz daha küçük (18px)
      ),
    );
  }

  Widget _buildShapeUi(double cellSize) {
    int maxX = 0; int maxY = 0;
    for (var p in shape.positions) { if (p.x > maxX) maxX = p.x; if (p.y > maxY) maxY = p.y; }

    return SizedBox(
      width: (maxY + 1) * cellSize,
      height: (maxX + 1) * cellSize,
      child: Stack(
        children: shape.positions.map((p) {
          return Positioned(
            left: p.y * cellSize,
            top: p.x * cellSize,
            child: Container(
              width: cellSize - 2,
              height: cellSize - 2,
              decoration: BoxDecoration(
                color: shape.color,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [BoxShadow(color: shape.color.withOpacity(0.8), blurRadius: 8, spreadRadius: 0)], // Parlama
                border: Border.all(color: Colors.white30, width: 1),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}