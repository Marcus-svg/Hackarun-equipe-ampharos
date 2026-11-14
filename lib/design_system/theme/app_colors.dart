import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color gold = Color(0xFFC59B43);

  // Variante escura do dourado para uso em TEXTO sobre fundos claros (branco
  // ou cream). O dourado da marca tem contraste ~2,6:1 no branco, abaixo do
  // minimo WCAG AA (4,5:1); este tom atinge ~6,2:1 no branco e ~5,6:1 no
  // cream. Use `gold` para preenchimentos/bordas/ícones decorativos e
  // `goldText` para rotulos e links.
  static const Color goldText = Color(0xFF7A5C18);

  static const Color cream = Color(0xFFF7F2E7);
  static const Color lightCream = Color(0xFFFAF8F5);
  static const Color darkBg = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimary = Color(0xFF1D1D1D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);

  // Fundos suaves dos avisos de sucesso/erro (mesmo tom do Material 50).
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color errorBg = Color(0xFFFFEBEE);
}
