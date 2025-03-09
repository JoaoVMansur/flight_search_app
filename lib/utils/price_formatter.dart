import 'package:intl/intl.dart';

class PriceFormatter {
  static String formatValue(num value, bool isMiles) {
    if (isMiles) {
      return '${NumberFormat("#,###").format(value.round())} milhas';
    } else {
      return 'R\$ ${NumberFormat("##0.00").format(value)}';
    }
  }

  static String formatBagagem(Map<String, dynamic> bagagem) {
    if (bagagem.isEmpty) return 'Não incluso';

    try {
      final entries = bagagem.entries.first;
      return '${entries.value}x ${entries.key}';
    } catch (e) {
      return 'Não incluso';
    }
  }
}
