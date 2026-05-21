import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/cyberpunk_theme.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  static final List<_Article> _articles = [
    _Article(
      tag: 'SCIENCE',
      tagColor: CyberpunkColors.neonCyan,
      title: 'Why REM Sleep Is the Brain\'s Defrag Cycle',
      subtitle: 'How your neurons rewrite memory during rapid eye movement phases.',
      icon: Icons.psychology_outlined,
      readMinutes: 4,
    ),
    _Article(
      tag: 'OPTIMIZE',
      tagColor: CyberpunkColors.neonGreen,
      title: 'Cold Room, Deep Sleep: Temperature & Recovery',
      subtitle: 'The science behind sleeping at 65°F and why your body craves it.',
      icon: Icons.thermostat_outlined,
      readMinutes: 3,
    ),
    _Article(
      tag: 'HACK',
      tagColor: CyberpunkColors.neonYellow,
      title: '4-7-8 Breathing: Fall Asleep in 60 Seconds',
      subtitle: 'A Navy SEAL technique adapted for civilian sleep optimization.',
      icon: Icons.air_outlined,
      readMinutes: 2,
    ),
    _Article(
      tag: 'CIRCADIAN',
      tagColor: CyberpunkColors.neonPurple,
      title: 'Light Exposure Protocols for Night Owls',
      subtitle: 'Reprogram your circadian rhythm with strategic blue light control.',
      icon: Icons.light_mode_outlined,
      readMinutes: 5,
    ),
    _Article(
      tag: 'NUTRITION',
      tagColor: CyberpunkColors.neonPink,
      title: 'Magnesium Glycinate: The Sleep Stack Primer',
      subtitle: 'Biohacker-approved supplements that actually move the needle on sleep.',
      icon: Icons.science_outlined,
      readMinutes: 6,
    ),
    _Article(
      tag: 'AUDIO',
      tagColor: CyberpunkColors.neonCyan,
      title: 'Binaural Beats & Delta Wave Entrainment',
      subtitle: 'Tuning your brain to 0.5–4 Hz for deeper, restorative sleep.',
      icon: Icons.headphones_outlined,
      readMinutes: 3,
    ),
  ];

  static final List<_Soundscape> _soundscapes = [
    _Soundscape('DEEP SPACE', Icons.star_outline, CyberpunkColors.neonPurple),
    _Soundscape('RAIN PROTOCOL', Icons.water_drop_outlined, CyberpunkColors.neonCyan),
    _Soundscape('WHITE NOISE', Icons.graphic_eq, CyberpunkColors.neonGreen),
    _Soundscape('DELTA WAVE', Icons.waves_outlined, CyberpunkColors.neonYellow),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberpunkColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSoundscapeSection()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'KNOWLEDGE BASE',
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        color: CyberpunkColors.textSecondary,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Divider(color: CyberpunkColors.textDisabled.withOpacity(0.3))),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ArticleCard(article: _articles[index]),
                  childCount: _articles.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DISCOVER',
            style: GoogleFonts.orbitron(
              fontSize: 12,
              color: CyberpunkColors.neonCyan,
              letterSpacing: 4,
              shadows: neonGlow(CyberpunkColors.neonCyan),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sleep Intelligence Hub',
            style: GoogleFonts.rajdhani(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: CyberpunkColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Biohack your rest. Optimize your recovery.',
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: CyberpunkColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundscapeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                'SOUNDSCAPES',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  color: CyberpunkColors.textSecondary,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Divider(color: CyberpunkColors.textDisabled.withOpacity(0.3))),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: _soundscapes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _SoundscapeCard(soundscape: _soundscapes[i]),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _SoundscapeCard extends StatefulWidget {
  final _Soundscape soundscape;
  const _SoundscapeCard({required this.soundscape});

  @override
  State<_SoundscapeCard> createState() => _SoundscapeCardState();
}

class _SoundscapeCardState extends State<_SoundscapeCard> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.soundscape.color;
    return GestureDetector(
      onTap: () => setState(() => _playing = !_playing),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: cyberpunkCardDecoration(
          borderColor: _playing ? color : color.withOpacity(0.3),
          glowRadius: _playing ? 12 : 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(widget.soundscape.icon, color: color, size: 20),
                Icon(
                  _playing ? Icons.pause_circle_filled : Icons.play_circle_outline,
                  color: color,
                  size: 20,
                ),
              ],
            ),
            Text(
              widget.soundscape.name,
              style: GoogleFonts.orbitron(
                fontSize: 10,
                color: _playing ? color : CyberpunkColors.textSecondary,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
                shadows: _playing ? neonGlow(color) : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final _Article article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: cyberpunkCardDecoration(
        borderColor: article.tagColor.withOpacity(0.4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: article.tagColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: article.tagColor.withOpacity(0.3)),
            ),
            child: Icon(article.icon, color: article.tagColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: article.tagColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: article.tagColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        article.tag,
                        style: GoogleFonts.orbitron(
                          fontSize: 8,
                          color: article.tagColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${article.readMinutes} min read',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: CyberpunkColors.textDisabled,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  article.title,
                  style: GoogleFonts.rajdhani(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: CyberpunkColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  article.subtitle,
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    color: CyberpunkColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, color: CyberpunkColors.textDisabled, size: 14),
        ],
      ),
    );
  }
}

class _Article {
  final String tag;
  final Color tagColor;
  final String title;
  final String subtitle;
  final IconData icon;
  final int readMinutes;
  const _Article({
    required this.tag,
    required this.tagColor,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.readMinutes,
  });
}

class _Soundscape {
  final String name;
  final IconData icon;
  final Color color;
  const _Soundscape(this.name, this.icon, this.color);
}
