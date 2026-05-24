import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/neumorphic_theme.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  static final List<_Article> _articles = [
    _Article(
      tag: 'Science',
      title: 'Why REM Sleep Is the Brain\'s Defrag Cycle',
      subtitle: 'How neurons rewrite memory during rapid eye movement phases.',
      icon: Icons.psychology_outlined,
      minutes: 4,
    ),
    _Article(
      tag: 'Optimize',
      title: 'Cold Room, Deep Sleep: Temperature & Recovery',
      subtitle: 'The science behind sleeping at 65°F and why your body craves it.',
      icon: Icons.thermostat_outlined,
      minutes: 3,
    ),
    _Article(
      tag: 'Technique',
      title: '4-7-8 Breathing: Fall Asleep in 60 Seconds',
      subtitle: 'A Navy SEAL breathing technique adapted for civilian sleep.',
      icon: Icons.air_outlined,
      minutes: 2,
    ),
    _Article(
      tag: 'Circadian',
      title: 'Light Exposure Protocols for Night Owls',
      subtitle: 'Reprogram your circadian rhythm with strategic blue light control.',
      icon: Icons.light_mode_outlined,
      minutes: 5,
    ),
    _Article(
      tag: 'Nutrition',
      title: 'Magnesium Glycinate: The Sleep Stack Primer',
      subtitle: 'Supplements that actually move the needle on sleep quality.',
      icon: Icons.science_outlined,
      minutes: 6,
    ),
    _Article(
      tag: 'Audio',
      title: 'Binaural Beats & Delta Wave Entrainment',
      subtitle: 'Tuning your brain to 0.5–4 Hz for deeper restorative sleep.',
      icon: Icons.headphones_outlined,
      minutes: 3,
    ),
  ];

  static final List<_Soundscape> _soundscapes = [
    _Soundscape('Deep Space', Icons.star_outline_rounded),
    _Soundscape('Rain', Icons.water_drop_outlined),
    _Soundscape('White Noise', Icons.graphic_eq_rounded),
    _Soundscape('Delta Wave', Icons.waves_outlined),
    _Soundscape('Forest', Icons.forest_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildFeaturedCard()),
            SliverToBoxAdapter(child: _buildSoundscapes()),
            SliverToBoxAdapter(child: _buildSectionLabel('Articles')),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _ArticleCard(article: _articles[i]),
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover',
            style: GoogleFonts.montserrat(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: NeumorphicColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Science-backed sleep insights',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: NeumorphicColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF9B72), Color(0xFFFF6030)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: NeumorphicColors.coral.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: NeumorphicColors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'FEATURED',
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: NeumorphicColors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The Sleep Optimization Guide',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: NeumorphicColors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A complete science-based roadmap to perfect sleep.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: NeumorphicColors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: NeumorphicColors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Read Now',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: NeumorphicColors.coral,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.menu_book_rounded,
                size: 64, color: NeumorphicColors.white.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundscapes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Soundscapes'),
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: _soundscapes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => _SoundscapeTile(s: _soundscapes[i]),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: NeumorphicColors.textPrimary,
        ),
      ),
    );
  }
}

// ─── Soundscape tile ────────────────────────────────────────────────────────
class _SoundscapeTile extends StatefulWidget {
  final _Soundscape s;
  const _SoundscapeTile({required this.s});
  @override
  State<_SoundscapeTile> createState() => _SoundscapeTileState();
}

class _SoundscapeTileState extends State<_SoundscapeTile> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _playing = !_playing),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 110,
        padding: const EdgeInsets.all(16),
        decoration: _playing
            ? BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF9B72), Color(0xFFFF6030)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: NeumorphicColors.coral.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              )
            : neumorphicRaised(radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              widget.s.icon,
              color: _playing ? NeumorphicColors.white : NeumorphicColors.coral,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              widget.s.name,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _playing
                    ? NeumorphicColors.white
                    : NeumorphicColors.textPrimary,
              ),
            ),
            Icon(
              _playing ? Icons.pause_circle_rounded : Icons.play_circle_outline_rounded,
              color: _playing
                  ? NeumorphicColors.white.withOpacity(0.8)
                  : NeumorphicColors.textDisabled,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Article card ────────────────────────────────────────────────────────────
class _ArticleCard extends StatelessWidget {
  final _Article article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: neumorphicRaised(radius: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: NeumorphicColors.coral.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(article.icon, color: NeumorphicColors.coral, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: NeumorphicColors.coral.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.tag,
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: NeumorphicColors.coral,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${article.minutes} min',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: NeumorphicColors.textDisabled,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  article.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: NeumorphicColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  article.subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: NeumorphicColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: NeumorphicColors.textDisabled),
        ],
      ),
    );
  }
}

class _Article {
  final String tag;
  final String title;
  final String subtitle;
  final IconData icon;
  final int minutes;
  const _Article({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.minutes,
  });
}

class _Soundscape {
  final String name;
  final IconData icon;
  const _Soundscape(this.name, this.icon);
}
