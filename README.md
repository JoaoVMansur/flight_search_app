# Aplicativo de Busca de Voos

Um aplicativo simples desenvolvido em Flutter que permite aos usuários buscar voos com uma interface limpa e intuitiva.

## 📱 Funcionalidades

- **Seleção de Tipo de Viagem**: Escolha entre voos somente de ida ou ida e volta
- **Seleção de Aeroportos**: Busque e selecione aeroportos de origem e destino com autocompletar
- **Seleção de Datas**: Escolha datas de ida e volta com interface de calendário
- **Gerenciamento de Passageiros**: Configure o número de adultos, crianças e bebês (até 9 passageiros no total)
- **Filtragem por Companhia Aérea**: Selecione companhias aéreas preferidas para sua busca

## ⚙️ Instalação

1. Clone o repositório:

   ```
   git clone git@github.com:JoaoVMansur/flight_search_app.git
   ```

2. Navegue até o diretório do projeto:

   ```
   cd flight_search_app
   ```

3. Instale as dependências:

   ```
   flutter pub get
   ```

4. Execute o aplicativo:
   ```
   flutter run
   ```

## 🌐 API

O aplicativo se conecta a uma mock API para obter dados de aeroportos. A API está configurada para acessar `https://buscamilhas.mock.gralmeidan.dev`. A mock API utilizada está disponível neste link: https://github.com/gralmeidan/busca-mock-api

## 📱 Compatibilidade

O aplicativo foi testado em um Pixel 8, portanto é recomendado utilizá-lo neste dispositivo para a melhor experiência possível.

## 🔧 Estrutura do Projeto

- `lib/`: Código fonte principal
  - `screens/`: Telas do aplicativo
    - `busca_voos.dart`: Implementação da tela de busca de voos
    - `resultado_busca.dart`: Implementacao da tela de resultado da busca
