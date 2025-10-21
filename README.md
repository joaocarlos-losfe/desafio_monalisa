# Desafio Monalisa - Sistema de Vendas

## Descrição

O desafio consiste em um aplicativo de gerenciamento de vendas desenvolvido com **Flutter**, projetado para ser uma solução completa e multiplataforma para vendas, controle de estoque e visualização de histórico de vendas. O aplicativo permite adicionar produtos ao carrinho, atualizar estoques, consultar históricos de vendas com filtros e gráficos, importar dados de produtos e histórico de vendas, e oferece uma interface responsiva que se adapta a dispositivos móveis, tablets e desktops.

### Principais Funcionalidades
- **Página de Vendas**:
  - Pesquisa de produtos por código de barras, nome ou descrição.
  - Filtro por marca para segmentação de produtos.
  - Adição e remoção de itens no carrinho com verificação de estoque.
  - Paginação para navegação eficiente em grandes listas de produtos.
  - Finalização de vendas com atualização automática do estoque e registro no histórico.
  - Visualização de detalhes do produto em um diálogo.
- **Página de Histórico**:
  - Exibição de vendas passadas com detalhes como data, total, itens e forma de pagamento.
  - Pesquisa no histórico por data, produto ou valor.
  - Estatísticas com total de vendas, valor acumulado e itens vendidos.
  - Gráfico de vendas dos últimos 7 dias para análise visual.
- **Página de Importação de Dados**:
  - Importação de arquivos JSON contendo produtos.
  - Suporte para atualizar ou adicionar produtos ao arquivo `produtos.json` no disco.
  - Interface simples com botão para selecionar arquivos JSON.
- **Página de Ajuda**:
  - Guia detalhado com dicas para usar as funcionalidades do app.
  - Explicações sobre busca, filtros, carrinho, estoque, paginação e temas.
- **Página Sobre**:
  - Informações sobre o aplicativo, incluindo versão, tecnologias utilizadas e suporte multiplataforma.
  - Links para contato com o desenvolvedor e visualização do código-fonte.

- **Responsividade e Tema**:
  - Interface adaptativa para mobile (1 coluna), tablet (2 colunas) e desktop (3 colunas).
  - Suporte a temas claro e escuro, sincronizado com as configurações do sistema.
  - Animações suaves para melhorar a experiência do usuário.

## Como Executar

### Pré-requisitos
- **Flutter SDK**: Versão 3.9.0 ou superior.
- **Dart**: Incluído com o Flutter.
- **Ambiente de Desenvolvimento**: Visual Studio Code, Android Studio ou outro IDE compatível.
- **Dispositivo ou Emulador (via coódigo) **: Android, iOS, Windows ou macOS.
- **Executaveis disponiveis na pasta /executaveis**: Android (.apk), macOS (.app).

### Passos para Configuração
1. **Clone o Repositório**:
   ```bash
   git clone https://github.com/joaocarlos-losfe/desafio_monalisa.git
   cd desafio_monalisa
   ```

2. **Instale as Dependências**:
   Execute o comando abaixo para instalar todos os pacotes listados no `pubspec.yaml`:
   ```bash
   flutter pub get
   ```

3. **Verifique os Arquivos de Ativos**:
   - Certifique-se de que os arquivos `assets/dataset/produtos.json` e `assets/dataset/formasPagamento.json` estão presentes no diretório `assets/dataset/`.
   - O arquivo `produtos.json` contém a lista inicial de produtos com campos como `CodigoBarras`, `SaldoEstoque`, etc.
   - O arquivo `formasPagamento.json` contém as formas de pagamento disponíveis.

4. **Execute o Aplicativo**:
   - Para rodar em um emulador ou dispositivo conectado:
     ```bash
     flutter run
     ```
   - Para rodar no seu dispositivo:
     ```bash
     flutter run -d macos
     ```

5. **Teste o Aplicativo**:
   - Navegue pela **Página de Vendas** para adicionar produtos ao carrinho e finalizar vendas.
   - Consulte o **Histórico** para ver vendas passadas e gráficos.
   - Use a **Página de Importação de Dados** para importar produtos a partir de arquivos JSON.
   - Explore a **Página de Ajuda** para entender as funcionalidades.
   - Consulte a **Página Sobre** para informações do projeto e suporte.

### Estrutura do Projeto
- **`lib/`**: Contém o código-fonte do aplicativo.
  - `data/model/`: Modelos de dados como `Product`, `Sale`, e `ProductPagination`.
  - `services/`: Serviços como `ProductService` (gerenciamento de produtos) e `PaymentMethodService` (formas de pagamento).
  - `/presentation/pages/`: Arquivos de telas como `SalePage`, `HistoryPage`, `HelpPage`, `AboutPage`, e `ImportDataPage`.
  - `/presentation/theme/`: Arquivos de tema `AppTheme.dark`, `AppTheme.light`.
  - `/presentation/widgets/`: Widgets globais `desktop_layout_widget` e `mobile_layout_widget`.
- **`assets/`**:
  - `images/logo.png`: Logotipo do aplicativo.
  - `dataset/produtos.json`: Dados iniciais dos produtos.
  - `dataset/formasPagamento.json`: Lista de formas de pagamento.
- **`pubspec.yaml`**: Configuração do projeto e dependências.

## Dependências Utilizadas

- **`flutter: sdk: flutter`**:
  - Framework principal para construção do aplicativo. Fornece widgets, temas (Material Design 3) e ferramentas para criar interfaces multiplataforma.
- **`file_picker: ^10.3.3`**:
  - Permite selecionar arquivos JSON do sistema para importação de produtos ou histórico de vendas na **Página de Importação de Dados**. Garante uma interface nativa para escolha de arquivos em diferentes plataformas.
- **`fl_chart: ^1.1.1`**:
  - Biblioteca para criar gráficos interativos. Usada na Página de Histórico para exibir um gráfico de vendas dos últimos 7 dias.
- **`flutter_animate: ^4.5.2`**:
  - Adiciona animações suaves a widgets, como transições de fade e slide. Usada nas telas (ex.: `SalePage`, `HelpPage`, `AboutPage`, `ImportDataPage`) para melhorar a experiência visual.
- **`path_provider: ^2.1.5`**:
  - Fornece acesso a diretórios do sistema (ex.: documentos do aplicativo) para salvar e ler o arquivo `produtos.json` no disco, garantindo persistência de dados para produtos.
- **`shared_preferences: ^2.5.3`**:
  - Armazena dados simples, como o histórico de vendas (`sales_history`), localmente no dispositivo. Usado na **Página de Importação de Dados** para importar e atualizar o histórico de vendas.
- **`url_launcher: ^6.3.2`**:
  - Permite abrir links externos, como e-mails e URLs. Usado na Página Sobre para links de suporte e licença.


## Motivação dos Pacotes
Os pacotes foram escolhidos para atender às necessidades do sistema de vendas, garantindo:
- **Funcionalidade**: `file_picker` e `path_provider` suportam importação e gerenciamento de dados persistentes; `shared_preferences` armazena o histórico de vendas.
- **Visualização de Dados**: `fl_chart` oferece gráficos para análise de vendas.
- **Experiência do Usuário**: `flutter_animate` melhora a interface com animações suaves; 



## Sobre
- **Email**: [joaocarlos.losfe@gmail.com](mailto:joaocarlos.losfe@gmail.com)
- **Desenvolvedor**: João Carlos de Sousa Fé ([joaocarlos.losfe@gmail.com](mailto:joaocarlos.losfe@gmail.com))

© 2025 Monalisa Sistema. Todos os direitos reservados.