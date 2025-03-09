import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/date_formatter.dart';

class ConnectionDetail extends StatelessWidget {
  final Map<String, dynamic> connection;
  final int index;
  final int total;
  final Color accentColor;
  final Color textSecondaryColor;

  const ConnectionDetail({
    Key? key,
    required this.connection,
    required this.index,
    required this.total,
    required this.accentColor,
    required this.textSecondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final embarque = connection['EmbarqueCompleto'] ?? connection['Embarque'];
    final desembarque =
        connection['DesembarqueCompleto'] ?? connection['Desembarque'];

    late DateTime embarqueDateTime;
    late DateTime desembarqueDateTime;

    try {
      embarqueDateTime = DateFormatter.parseDateTime(embarque);
      desembarqueDateTime = DateFormatter.parseDateTime(desembarque);
    } catch (e) {
      embarqueDateTime = DateTime.now();
      desembarqueDateTime = DateTime.now();
    }

    final duracao = connection['Duracao'] ?? '00:00';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${connection['Origem']} → ${connection['Destino']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                'Voo: ${connection['NumeroVoo'] ?? 'N/A'}',
                style: TextStyle(color: textSecondaryColor, fontSize: 12),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Partida: ${DateFormat('HH:mm').format(embarqueDateTime)}',
                      style: TextStyle(fontSize: 12, color: textSecondaryColor),
                    ),
                    const Spacer(),
                    Text(
                      'Duração: ${DateFormatter.formatDuration(duracao)}',
                      style: TextStyle(fontSize: 12, color: textSecondaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Chegada: ${DateFormat('HH:mm').format(desembarqueDateTime)}',
                  style: TextStyle(fontSize: 12, color: textSecondaryColor),
                ),
                if (index < total - 1) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Tempo de conexão: ${_calculateConnectionTime(desembarqueDateTime, index + 1 < total)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const Divider(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateConnectionTime(DateTime arrival, bool hasNextConnection) {
    if (!hasNextConnection) return '';
    return "Conexão";
  }
}
