class Flight {
  final String id;
  final String companhia;
  final String origem;
  final String destino;
  final String embarque;
  final String desembarque;
  final String duracao;
  final int numeroConexoes;
  final String sentido;
  final String numeroVoo;
  final List<Map<String, dynamic>> valor;
  final List<Map<String, dynamic>> milhas;
  final Map<String, dynamic>? passageiros;
  final List<Map<String, dynamic>>? conexoes;
  final String? aeronave;

  Flight({
    required this.id,
    required this.companhia,
    required this.origem,
    required this.destino,
    required this.embarque,
    required this.desembarque,
    required this.duracao,
    required this.numeroConexoes,
    required this.sentido,
    required this.numeroVoo,
    required this.valor,
    required this.milhas,
    this.passageiros,
    this.conexoes,
    this.aeronave,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['Id'] ?? json['NumeroVoo'] ?? '',
      companhia: json['Companhia'] ?? '',
      origem: json['Origem'] ?? '',
      destino: json['Destino'] ?? '',
      embarque: json['Embarque'] ?? '',
      desembarque: json['Desembarque'] ?? '',
      duracao: json['Duracao'] ?? '00:00',
      numeroConexoes: json['NumeroConexoes'] ?? 0,
      sentido: json['Sentido'] ?? '',
      numeroVoo: json['NumeroVoo'] ?? '',
      valor: List<Map<String, dynamic>>.from(json['Valor'] ?? []),
      milhas: List<Map<String, dynamic>>.from(json['Milhas'] ?? []),
      passageiros:
          json['Passageiros'] != null
              ? Map<String, dynamic>.from(json['Passageiros'])
              : null,
      conexoes:
          json['Conexoes'] != null
              ? List<Map<String, dynamic>>.from(json['Conexoes'])
              : null,
      aeronave: json['Aeronave'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Companhia': companhia,
      'Origem': origem,
      'Destino': destino,
      'Embarque': embarque,
      'Desembarque': desembarque,
      'Duracao': duracao,
      'NumeroConexoes': numeroConexoes,
      'Sentido': sentido,
      'NumeroVoo': numeroVoo,
      'Valor': valor,
      'Milhas': milhas,
      'Passageiros': passageiros,
      'Conexoes': conexoes,
      'Aeronave': aeronave,
    };
  }

  Map<String, dynamic> getPriceInfo(String fareType, bool showMiles) {
    final List<Map<String, dynamic>> priceList = showMiles ? milhas : valor;

    if (priceList.isEmpty) return {};

    try {
      return priceList.firstWhere(
        (price) =>
            price['TipoValor'] == fareType || price['TipoMilhas'] == fareType,
        orElse: () => priceList.first,
      );
    } catch (e) {
      return priceList.first;
    }
  }

  double calculateTotalPrice(String fareType, bool showMiles) {
    final priceInfo = getPriceInfo(fareType, showMiles);
    if (priceInfo.isEmpty) return 0.0;

    num adultPrice = priceInfo['Adulto'] ?? 0.0;
    num childPrice = priceInfo['Crianca'] ?? 0.0;
    num boardingFee = priceInfo['TaxaEmbarque'] ?? 0.0;

    int adultCount = 1;
    int childCount = 0;

    if (passageiros != null) {
      adultCount = passageiros!['Adultos'] ?? 1;
      childCount = passageiros!['Criancas'] ?? 0;
    } else if (priceInfo.containsKey('NumeroAdultos') ||
        priceInfo.containsKey('NumeroCriancas')) {
      adultCount = priceInfo['NumeroAdultos'] ?? 1;
      childCount = priceInfo['NumeroCriancas'] ?? 0;
    }

    adultPrice =
        adultPrice is int ? adultPrice.toDouble() : adultPrice as double;
    childPrice =
        childPrice is int ? childPrice.toDouble() : childPrice as double;
    boardingFee =
        boardingFee is int ? boardingFee.toDouble() : boardingFee as double;

    final fareTotal = (adultPrice * adultCount) + (childPrice * childCount);

    final totalBoardingFee = boardingFee * (adultCount + childCount);

    return fareTotal + totalBoardingFee;
  }

  Map<String, dynamic> getBaggageInfo(
    String fareType,
    bool showMiles,
    bool isHandBaggage,
  ) {
    final priceInfo = getPriceInfo(fareType, showMiles);
    if (priceInfo.isEmpty) return {};

    final Map<String, dynamic> limiteBagagem =
        priceInfo.containsKey('LimiteBagagem')
            ? Map<String, dynamic>.from(priceInfo['LimiteBagagem'] ?? {})
            : {};

    if (isHandBaggage) {
      return limiteBagagem.containsKey('BagagemMao')
          ? Map<String, dynamic>.from(limiteBagagem['BagagemMao'] ?? {})
          : {};
    } else {
      return limiteBagagem.containsKey('BagagemDespachada')
          ? Map<String, dynamic>.from(limiteBagagem['BagagemDespachada'] ?? {})
          : {};
    }
  }
}
