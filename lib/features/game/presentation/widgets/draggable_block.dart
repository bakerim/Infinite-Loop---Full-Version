import 'dart:math';
import 'package:flutter/material.dart';
import 'package:infinite_loop/features/game/domain/block_model.dart';

class DraggableBlock extends StatelessWidget {
  final BlockModel shape;
  final VoidCallback onDragEnd;

  const DraggableBlock({Key? key, required this.shape, required this.onDragEnd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    // 1. ŞEKLİN GERÇEK BOYUTLARINI HESAPLA
    // Artık 3x3 sabit değil, şekil neyse o kadar alan kaplayacak.
    int maxR = shape.positions.map((p) => p.x).reduce(max);
    int maxC = shape.positions.map((p) => p.y).reduce(max);
    
    // Grid boyutları (Index 0'dan başladığı için +1 ekliyoruz)
    int gridRows = maxR + 1;
    int gridCols = maxC + 1;

    // --- ÖLÇÜ AYARLARI ---
    // Feedback (Sürüklenen): 34px (Gridle aynı)
    // Menü: Eğer şekil çok büyükse (örn 5 birim), menüye sığsın diye küçültüyoruz.
    double menuCellSize = (gridRows > 3 || gridCols > 3) ? 14 : 20; 
    
    Widget _buildShapeUi(bool isFeedback) {
      double cellSize = isFeedback ? 34 : menuCellSize; 
      double margin = isFeedback ? 2 : 1;
      
      // Toplam genişlik ve yükseklik (Merkez hesabı için lazım)
      double totalWidth = (cellSize + (margin * 2)) * gridCols;
      double totalHeight = (cellSize + (margin * 2)) * gridRows;

      return Container(
        // Sınırları şeklin tam boyutuna göre çiziyoruz
        width: totalWidth,
        height: totalHeight,
        alignment: Alignment.center,
        
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(gridRows, (r) { 
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(gridCols, (c) {
                // Şekil verisini kontrol et
                bool exists = shape.positions.any((p) => p.x == r && p.y == c);
                
                if (!exists) {
                  return SizedBox(
                    width: cellSize + (margin * 2), 
                    height: cellSize + (margin * 2)
                  );
                }
                
                return Container(
                  width: cellSize, 
                  height: cellSize,
                  margin: EdgeInsets.all(margin),
                  decoration: BoxDecoration(
                    color: shape.color,
                    borderRadius: BorderRadius.circular(isFeedback ? 8 : 4),
                    boxShadow: isFeedback ? [
                      BoxShadow(color: shape.color.withOpacity(0.8), blurRadius: 20, spreadRadius: 2)
                    ] : [],
                  ),
                );
              }),
            );
          }),
        ),
      );
    }

    return Draggable<BlockModel>(
      data: shape,

      // --- DİNAMİK MERKEZLEME (SORUN ÇÖZÜCÜ) ---
      // Eskiden sabit 57px diyorduk. Şimdi şeklin genişliği neyse
      // tam onun yarısını alıyoruz. Böylece kayma imkansız hale geliyor.
      dragAnchorStrategy: (draggable, context, position) {
        double cellSize = 34.0;
        double margin = 2.0;
        double totalWidth = (cellSize + (margin * 2)) * gridCols;
        double totalHeight = (cellSize + (margin * 2)) * gridRows;
        
        // Parmağın altına gelecek nokta: Şeklin tam göbeği
        return Offset(totalWidth / 2, totalHeight / 2);
      },

      // Sürüklenen Görsel (Parmağın biraz yukarısında dursun ki görelim)
      feedback: Transform.translate(
        offset: const Offset(0, -80), // Sniper modu: Parmağın 80px yukarısında
        child: Material(
          color: Colors.transparent,
          child: _buildShapeUi(true),
        ),
      ),
      
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildShapeUi(false),
      ),
      
      child: _buildShapeUi(false),
      
      onDragEnd: (details) => onDragEnd(),
    );
  }
}