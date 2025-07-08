import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/duolingo_theme.dart';

class MarkdownWidget extends StatelessWidget {
  final String data;
  final bool selectable;
  final EdgeInsets? padding;

  const MarkdownWidget({
    super.key,
    required this.data,
    this.selectable = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: MarkdownBody(
        data: data,
        selectable: selectable,
        styleSheet: MarkdownStyleSheet(
          // Headers
          h1: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: DuolingoTheme.textPrimary,
            height: 1.3,
          ),
          h2: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.textPrimary,
            height: 1.3,
          ),
          h3: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.textPrimary,
            height: 1.3,
          ),
          h4: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.textPrimary,
            height: 1.3,
          ),
          h5: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.textPrimary,
            height: 1.3,
          ),
          h6: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.textPrimary,
            height: 1.3,
          ),
          
          // Body text
          p: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: DuolingoTheme.textPrimary,
            height: 1.5,
          ),
          
          // Lists
          listBullet: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: DuolingoTheme.textPrimary,
            height: 1.5,
          ),
          
          // Emphasis
          strong: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.textPrimary,
            height: 1.5,
          ),
          em: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            color: DuolingoTheme.textPrimary,
            height: 1.5,
          ),
          
          // Code
          code: GoogleFonts.sourceCodePro(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: DuolingoTheme.secondary,
            backgroundColor: DuolingoTheme.surfaceVariant,
          ),
          codeblockDecoration: BoxDecoration(
            color: DuolingoTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: DuolingoTheme.border),
          ),
          
          // Links
          a: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: DuolingoTheme.secondary,
            decoration: TextDecoration.underline,
            height: 1.5,
          ),
          
          // Blockquotes
          blockquote: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: DuolingoTheme.textSecondary,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
          blockquoteDecoration: BoxDecoration(
            color: DuolingoTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: DuolingoTheme.primary,
                width: 4,
              ),
            ),
          ),
          
          // Tables
          tableHead: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.textPrimary,
          ),
          tableBody: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: DuolingoTheme.textPrimary,
          ),
          
          // Padding and spacing
          h1Padding: const EdgeInsets.only(bottom: 16),
          h2Padding: const EdgeInsets.only(bottom: 12),
          h3Padding: const EdgeInsets.only(bottom: 8),
          h4Padding: const EdgeInsets.only(bottom: 8),
          h5Padding: const EdgeInsets.only(bottom: 4),
          h6Padding: const EdgeInsets.only(bottom: 4),
          pPadding: const EdgeInsets.only(bottom: 12),
          listIndent: 24,
          blockquotePadding: const EdgeInsets.all(16),
          codeblockPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

// Custom widget for sacred text quotes with special styling
class SacredTextQuoteWidget extends StatelessWidget {
  final String quote;
  final String citation;
  final String religion;

  const SacredTextQuoteWidget({
    super.key,
    required this.quote,
    required this.citation,
    required this.religion,
  });

  @override
  Widget build(BuildContext context) {
    Color accentColor = DuolingoTheme.primary;
    
    // Use different colors for different religions
    switch (religion.toLowerCase()) {
      case 'islam':
        accentColor = DuolingoTheme.primary;
        break;
      case 'christianity':
        accentColor = DuolingoTheme.secondary;
        break;
      case 'hinduism':
        accentColor = DuolingoTheme.tertiary;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote icon
          Icon(
            Icons.format_quote,
            color: accentColor,
            size: 24,
          ),
          const SizedBox(height: 12),
          
          // Quote text
          Text(
            quote,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: DuolingoTheme.textPrimary,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Citation
          Text(
            citation,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for spiritual practices with icons
class SpiritualPracticeWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const SpiritualPracticeWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DuolingoTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DuolingoTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DuolingoTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: DuolingoTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DuolingoTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: DuolingoTheme.textSecondary,
                    height: 1.4,
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