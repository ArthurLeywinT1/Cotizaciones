import 'package:intl/intl.dart';

class Formatters {
  static final _moneda = NumberFormat('#,##0.00', 'en_US');
  static final _unitario = NumberFormat('#,##0.0000', 'en_US');

  /// Convierte cualquier número (int, double, num) a formato 1,000.00
  static String numero(num? valor) {
    if (valor == null) return '0.00';
    return _moneda.format(valor);
  }

  /// Convierte a formato de moneda con símbolo: $1,000.00
  static String moneda(num? valor) {
    if (valor == null) return '\$0.00';
    return '\$${_moneda.format(valor)}';
  }

  /// Convierte a formato unitario con 4 decimales: $1,000.0000
  static String unitario(num? valor) {
    if (valor == null) return '\$0.0000';
    return '\$${_unitario.format(valor)}';
  }
} 