import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajuda e Dicas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo à Ajuda!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aqui você encontra explicações sobre as principais funções do app e dicas para usá-lo de forma eficiente.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Página de Vendas',
              content: [
                _buildTip(
                  'Pesquisa de Produtos',
                  'Use o campo de busca para filtrar produtos por código ou nome. A busca é automática após digitar.',
                ),
                _buildTip(
                  'Filtro por Marca',
                  'Selecione uma marca no dropdown para ver apenas produtos daquela marca. "Todas" mostra tudo.',
                ),
                _buildTip(
                  'Adicionar ao Carrinho',
                  'Clique no ícone "+" no card do produto para adicionar ao carrinho. Use "-" para remover. O estoque é verificado automaticamente.',
                ),
                _buildTip(
                  'Visualizar Carrinho',
                  'Quando houver itens no carrinho, um botão aparece no topo. Clique para ver detalhes e ajustar quantidades.',
                ),
                _buildTip(
                  'Finalizar Venda',
                  'No diálogo do carrinho, clique em "Finalizar" para processar a venda, atualizar o estoque e salvar no histórico.',
                ),
                _buildTip(
                  'Paginação',
                  'Use as setas na parte inferior para navegar entre páginas de produtos.',
                ),
                _buildTip(
                  'Detalhes do Produto',
                  'Toque no card do produto para ver mais detalhes como descrição completa e estoque.',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Página de Histórico',
              content: [
                _buildTip(
                  'Visualizar Vendas',
                  'Veja todas as vendas registradas, com data, total e itens. Expanda cada card para detalhes.',
                ),
                _buildTip(
                  'Pesquisa no Histórico',
                  'Use o campo de busca para filtrar por data, produto ou valor.',
                ),
                _buildTip(
                  'Estatísticas',
                  'No topo, veja o número total de vendas, valor total e itens vendidos. Há também um gráfico de vendas dos últimos 7 dias.',
                ),
                _buildTip(
                  'Gráfico de Vendas',
                  'O gráfico mostra o total de vendas diárias. Toque nas linhas para ver valores exatos.',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Dicas Gerais',
              content: [
                _buildTip(
                  'Sem Estoque',
                  'Produtos sem estoque mostram um ícone de bloqueio e não podem ser adicionados ao carrinho.',
                ),
                _buildTip(
                  'Relatório de Venda',
                  'Após finalizar uma venda, um snackbar aparece com opção para ver o relatório detalhado.',
                ),
                _buildTip(
                  'Armazenamento Local',
                  'O histórico de vendas é salvo localmente via SharedPreferences. Limpar dados do app pode apagá-lo.',
                ),
                _buildTip(
                  'Desempenho',
                  'Para grandes listas de produtos, use a paginação para evitar lentidão. A busca otimiza a carga.',
                ),
                _buildTip(
                  'Tema e Responsividade',
                  'O app se adapta a temas claro/escuro e tamanhos de tela (mobile, tablet, desktop).',
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSection(
              title: 'Visual',
              content: [
                _buildTip(
                  'Tema Automático',
                  'O sistema muda automaticamente o tema de acordo com as configurações atuais do seu sistema operacional (claro/escuro).',
                ),
                _buildTip(
                  'Responsivo',
                  'O app se adapta automaticamente ao tamanho da tela: Mobile (1 coluna), Tablet (2 colunas) e Desktop (3 colunas).',
                ),
                _buildTip(
                  'Layout Adaptativo',
                  'Cards e diálogos se reorganizam para melhor visualização em telas pequenas ou grandes.',
                ),
                _buildTip(
                  'Animações Suaves',
                  'Transições e efeitos visuais melhoram a experiência do usuário.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> content}) {
    return Animate(
      effects: const [
        FadeEffect(),
        SlideEffect(begin: Offset(0, 0.2)),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...content,
        ],
      ),
    );
  }

  Widget _buildTip(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Theme.of(context).colorScheme.secondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
