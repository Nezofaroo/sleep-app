import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  static final List<_Article> _articles = [
    _Article('Science',   'Why REM Sleep Is the Brain\'s Defrag Cycle',        'How neurons rewrite memory during rapid eye movement phases.',          Icons.psychology_outlined,   4),
    _Article('Optimize',  'Cold Room, Deep Sleep: Temperature & Recovery',     'The science behind sleeping at 65°F and why your body craves it.',      Icons.thermostat_outlined,   3),
    _Article('Technique', '4-7-8 Breathing: Fall Asleep in 60 Seconds',       'A Navy SEAL breathing technique adapted for civilian sleep.',           Icons.air_outlined,          2),
    _Article('Circadian', 'Light Exposure Protocols for Night Owls',           'Reprogram your circadian rhythm with strategic blue light control.',    Icons.light_mode_outlined,   5),
    _Article('Nutrition', 'Magnesium Glycinate: The Sleep Stack Primer',       'Supplements that actually move the needle on sleep quality.',           Icons.science_outlined,      6),
    _Article('Audio',     'Binaural Beats & Delta Wave Entrainment',           'Tuning your brain to 0.5–4 Hz for deeper restorative sleep.',          Icons.headphones_outlined,   3),
  ];

  static final List<_Soundscape> _soundscapes = [
    _Soundscape('Deep Space',  Icons.star_outline_rounded),
    _Soundscape('Rain',        Icons.water_drop_outlined),
    _Soundscape('White Noise', Icons.graphic_eq_rounded),
    _Soundscape('Delta Wave',  Icons.waves_outlined),
    _Soundscape('Forest',      Icons.forest_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(c)),
            SliverToBoxAdapter(child: _buildFeaturedCard(c)),
            SliverToBoxAdapter(child: _buildSoundscapes(c)),
            SliverToBoxAdapter(child: _sectionLabel('Articles', c)),
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

  Widget _buildHeader(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Discover',
            style: GoogleFonts.montserrat(
                fontSize: 26, fontWeight: FontWeight.w800, color: c.textPrimary)),
        const SizedBox(height: 4),
        Text('Science-backed sleep insights',
            style: GoogleFonts.montserrat(fontSize: 14, color: c.textSecondary)),
      ]),
    );
  }

  Widget _buildFeaturedCard(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: c.accentGradient),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: c.accent.withValues(alpha: 0.35),
                blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('FEATURED',
                      style: GoogleFonts.montserrat(
                          fontSize: 9, fontWeight: FontWeight.w700,
                          color: c.white, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 12),
                Text('The Sleep Optimization Guide',
                    style: GoogleFonts.montserrat(
                        fontSize: 18, fontWeight: FontWeight.w800,
                        color: c.white, height: 1.2)),
                const SizedBox(height: 8),
                Text('A complete science-based roadmap to perfect sleep.',
                    style: GoogleFonts.montserrat(
                        fontSize: 12, color: c.white.withValues(alpha: 0.85))),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: c.white, borderRadius: BorderRadius.circular(30)),
                  child: Text('Read Now',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.w700, color: c.accent)),
                ),
              ]),
            ),
            const SizedBox(width: 16),
            Icon(Icons.menu_book_rounded, size: 64,
                color: c.white.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundscapes(AppColors c) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Soundscapes', c),
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
    ]);
  }

  Widget _sectionLabel(String label, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      child: Text(label,
          style: GoogleFonts.montserrat(
              fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary)),
    );
  }
}

class _SoundscapeTile extends StatefulWidget {
  final _Soundscape s;
  const _SoundscapeTile({required this.s});
  @override State<_SoundscapeTile> createState() => _SoundscapeTileState();
}

class _SoundscapeTileState extends State<_SoundscapeTile> {
  bool _playing = false;
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: () => setState(() => _playing = !_playing),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 110,
        padding: const EdgeInsets.all(16),
        decoration: _playing
            ? BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: c.accentGradient),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: c.accent.withValues(alpha: 0.4),
                      blurRadius: 12, offset: const Offset(0, 6))
                ])
            : c.cardRaised(radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(widget.s.icon, color: _playing ? c.white : c.accent, size: 24),
            const SizedBox(height: 8),
            Text(widget.s.name,
                style: GoogleFonts.montserrat(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: _playing ? c.white : c.textPrimary)),
            Icon(_playing ? Icons.pause_circle_rounded : Icons.play_circle_outline_rounded,
                color: _playing ? c.white.withValues(alpha: 0.8) : c.textDisabled,
                size: 18),
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
    final c = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: c.cardRaised(radius: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: c.iconBadge(radius: 12),
            child: Icon(article.icon, color: c.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: c.tagDecoration(radius: 6),
                  child: Text(article.tag,
                      style: GoogleFonts.montserrat(
                          fontSize: 9, fontWeight: FontWeight.w700, color: c.tagText)),
                ),
                const SizedBox(width: 8),
                Text('${article.minutes} min',
                    style: GoogleFonts.montserrat(fontSize: 11, color: c.textDisabled)),
              ]),
              const SizedBox(height: 7),
              Text(article.title,
                  style: GoogleFonts.montserrat(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: c.textPrimary, height: 1.2)),
              const SizedBox(height: 4),
              Text(article.subtitle,
                  style: GoogleFonts.montserrat(
                      fontSize: 12, color: c.textSecondary, height: 1.35)),
            ]),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: const Color(0xFFBEBECB)),
        ],
      ),
    );
  }
}

class _Article {
  final String tag; final String title; final String subtitle;
  final IconData icon; final int minutes;
  const _Article(this.tag, this.title, this.subtitle, this.icon, this.minutes);
}
class _Soundscape {
  final String name; final IconData icon;
  const _Soundscape(this.name, this.icon);
}
