import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'discover_page.dart';

class ArticleReadingPage extends StatelessWidget {
  final DiscoverArticle article;
  const ArticleReadingPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Neumorphic App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.cardBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: c.shadowDark,
                            blurRadius: 10,
                            offset: const Offset(4, 4),
                          ),
                          BoxShadow(
                            color: c.shadowLight,
                            blurRadius: 10,
                            offset: const Offset(-4, -4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: c.accent,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Статья',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Illustration Header
                    Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: c.accentGradient,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: c.shadowDark.withValues(alpha: 0.5),
                            blurRadius: 16,
                            offset: const Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          article.icon,
                          size: 72,
                          color: c.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Badges Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.tagBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: c.tagBorder),
                          ),
                          child: Text(
                            article.tag.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: c.tagText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: c.textDisabled,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${article.minutes} мин чтение',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      article.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      article.subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: c.textSecondary,
                        fontStyle: FontStyle.italic,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    Divider(color: c.border, height: 1),
                    const SizedBox(height: 20),

                    // Article Content
                    _buildContent(article.content, c),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(String content, AppColors c) {
    final paragraphs = content.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((p) {
        final trimmed = p.trim();
        if (trimmed.isEmpty) return const SizedBox.shrink();

        if (trimmed.startsWith('**') && trimmed.endsWith('**')) {
          // Section header
          final cleanText = trimmed.replaceAll('**', '');
          return Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: Text(
              cleanText,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
          );
        } else if (trimmed.contains('**')) {
          // Paragraph containing inline bold styles
          final parts = trimmed.split('**');
          final spans = <TextSpan>[];
          for (var i = 0; i < parts.length; i++) {
            final isBold = i % 2 == 1;
            spans.add(TextSpan(
              text: parts[i],
              style: GoogleFonts.montserrat(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: isBold ? c.accent : c.textSecondary,
              ),
            ));
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RichText(
              text: TextSpan(
                children: spans,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          );
        } else {
          // Regular paragraph
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              trimmed,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: c.textSecondary,
                height: 1.6,
              ),
            ),
          );
        }
      }).toList(),
    );
  }
}
