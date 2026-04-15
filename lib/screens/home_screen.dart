import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/side_drawer.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const SideDrawer(),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: TopAppBar(opacity: 0.85),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 128),
                _buildWelcomeSection(context),
                const SizedBox(height: 48),
                _buildQuickAccessSection(context),
                const SizedBox(height: 160),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BIENVENIDO',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.secondary.withOpacity(0.8),
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'MiBiblia',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 56,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          'Tu compañera personal para la lectura y estudio de las Escrituras.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 20,
                color: AppTheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCESO RÁPIDO',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.secondary.withOpacity(0.8),
              ),
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          context,
          'Contenido Pendiente',
          'Para agregar contenido bíblico, consulta el archivo INSTRUCCIONES_CONTENIDO.md',
          Icons.info_outline,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          'Nota Legal',
          'Asegúrate de usar solo traducciones con licencias apropiadas o de dominio público.',
          Icons.gavel,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        border: Border(
          left: BorderSide(
            color: AppTheme.secondary.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.secondary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: AppTheme.onSurface.withOpacity(0.7),
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
