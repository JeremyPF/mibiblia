import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/side_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double fontSize = 20.0;
  bool isDarkMode = false;
  double lineHeight = 2.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const SideDrawer(),
      appBar: const PreferredSize(
        preferredSize: Size.full(80),
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
                _buildHeader(context),
                const SizedBox(height: 48),
                _buildSettingsContent(context),
                const SizedBox(height: 160),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREFERENCES',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.secondary.withOpacity(0.8),
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Settings',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 48,
              ),
        ),
      ],
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    return Column(
      children: [
        _buildSettingSection(
          context,
          'Reading Experience',
          [
            _buildSliderSetting(
              context,
              'Font Size',
              fontSize,
              14.0,
              32.0,
              (value) => setState(() => fontSize = value),
            ),
            _buildSliderSetting(
              context,
              'Line Height',
              lineHeight,
              1.5,
              3.0,
              (value) => setState(() => lineHeight = value),
            ),
            _buildSwitchSetting(
              context,
              'Dark Mode',
              isDarkMode,
              (value) => setState(() => isDarkMode = value),
            ),
          ],
        ),
        const SizedBox(height: 48),
        _buildSettingSection(
          context,
          'About',
          [
            _buildInfoItem(context, 'Version', '1.0.0'),
            _buildInfoItem(context, 'Translation', 'The Message (ES)'),
            _buildInfoItem(context, 'Purpose', 'Personal Use Only'),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 24,
              ),
        ),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }

  Widget _buildSliderSetting(
    BuildContext context,
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                    ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.secondary,
                    ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: AppTheme.secondary,
            inactiveColor: AppTheme.outlineVariant.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    BuildContext context,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                ),
          ),
          Switch(
            value: value,
            activeColor: AppTheme.secondary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: AppTheme.onSurface.withOpacity(0.6),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                ),
          ),
        ],
      ),
    );
  }
}
