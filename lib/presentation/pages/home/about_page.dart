import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
        actions: [
          IconButton(
            onPressed: () => _launchURL(
              'https://github.com/joaocarlos-losfe/desafio_monalisa.git',
            ),
            icon: const Icon(Icons.code),
            tooltip: 'Ver código fonte',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Animate(
              effects: [
                FadeEffect(delay: 200.ms),
                ScaleEffect(delay: 200.ms),
                ScaleEffect(duration: 2000.ms, curve: Curves.easeInOut),
              ],
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Animate(
                    effects: [
                      ScaleEffect(duration: 2000.ms, curve: Curves.easeInOut),
                    ],
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_cart,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Sistema de Vendas Monalisa',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tag, size: 16, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text(
                    'Versão 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              title: 'Sobre o Aplicativo',
              content: [
                _buildInfoCard(
                  icon: Icons.info_outline,
                  title: 'Descrição',
                  text:
                      'Sistema completo de gerenciamento de vendas desenvolvido com Flutter. Permite realizar vendas, controlar estoque e visualizar histórico com gráficos.',
                ),
                _buildInfoCard(
                  icon: Icons.trending_up,
                  title: 'Funcionalidades',
                  text:
                      '• Vendas rápidas com carrinho\n• Controle automático de estoque\n• Histórico completo com gráficos\n• Relatórios detalhados\n• Busca e filtros avançados',
                ),
                _buildInfoCard(
                  icon: Icons.design_services,
                  title: 'Tecnologias',
                  text:
                      '• Flutter (Dart)\n• Material Design 3\n• SharedPreferences\n• fl_chart\n• flutter_animate',
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: 'Multiplataforma',
              content: [
                _buildPlatformRow(
                  platform: 'Android',
                  icon: Icons.android,
                  color: Colors.green,
                ),
                _buildPlatformRow(
                  platform: 'iOS',
                  icon: Icons.apple,
                  color: Colors.grey.shade800,
                ),
                _buildPlatformRow(
                  platform: 'Windows',
                  icon: Icons.computer,
                  color: Colors.blue,
                ),
                _buildPlatformRow(
                  platform: 'macOS',
                  icon: Icons.laptop_mac,
                  color: Colors.grey.shade700,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: 'Créditos',
              content: [
                _buildInfoCard(
                  icon: Icons.person,
                  title: 'Desenvolvedor',
                  text:
                      'Desenvolvido por João Carlos de Sousa Fé\nFlutter Developer',
                  onTap: () => _launchURL('mailto:joaocarlos.losfe@gmail.com'),
                ),
                _buildInfoCard(
                  icon: Icons.school,
                  title: 'Licença',
                  text: 'MIT License',
                  onTap: () =>
                      _launchURL('https://opensource.org/licenses/MIT'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Suporte
            _buildSupportSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        ...content,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String text,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Animate(
        effects: const [
          FadeEffect(),
          SlideEffect(begin: Offset(0, 0.1)),
        ],
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
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
                        text,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformRow({
    required String platform,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '• $platform',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suporte',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    _launchURL('mailto:joaocarlos.losfe@gmail.com'),
                icon: const Icon(Icons.email, size: 18),
                label: const Text('Email'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launchURL(
                  'https://github.com/joaocarlos-losfe/desafio_monalisa.git',
                ),
                icon: const Icon(Icons.bug_report, size: 18),
                label: const Text('Reportar Bug'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '© 2025 Monalisa Sistema. Todos os direitos reservados.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o link')),
        );
      }
    }
  }
}
