import 'package:flutter/material.dart';
import '../models/religion.dart';

class ReligionSelector extends StatelessWidget {
  final List<Religion> religions;
  final String mode;
  final Function(Religion) onReligionSelected;

  const ReligionSelector({
    super.key,
    required this.religions,
    required this.mode,
    required this.onReligionSelected,
  });

  @override
  Widget build(BuildContext context) {
    String modeTitle = '';
    String modeDescription = '';
    
    switch (mode) {
      case 'comprehensive':
        modeTitle = 'Choose Religion for Comprehensive Course';
        modeDescription = 'Select a religion to start a complete structured course with 100+ chapters.';
        break;
      case 'custom':
        modeTitle = 'Choose Religion for Custom Lesson';
        modeDescription = 'Select a religion to create a personalized lesson on any topic.';
        break;

    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  modeTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  modeDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Religion List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: religions.length,
              itemBuilder: (context, index) {
                final religion = religions[index];
                return _buildReligionCard(context, religion);
              },
            ),
          ),

          // Bottom padding
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReligionCard(BuildContext context, Religion religion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onReligionSelected(religion),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Religion Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _getReligionImage(religion.name),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Religion Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        religion.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      if (religion.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          religion.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getReligionColor(String religionName) {
    switch (religionName.toLowerCase()) {
      case 'islam':
        return const Color(0xFF10B981); // Green
      case 'christianity':
        return const Color(0xFF3B82F6); // Blue
      case 'judaism':
        return const Color(0xFF8B5CF6); // Purple
      case 'buddhism':
        return const Color(0xFFF59E0B); // Orange
      case 'hinduism':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _getReligionImage(String religionName) {
    switch (religionName.toLowerCase()) {
      case 'islam':
        return 'assets/images/religions/islam .jpg';
      case 'christianity':
        return 'assets/images/religions/Christian cross.jpg';
      case 'judaism':
        return 'assets/images/religions/hindu Symbol.jpg'; // Using hindu symbol as placeholder for judaism
      case 'buddhism':
        return 'assets/images/religions/hindu Symbol.jpg'; // Using hindu symbol as placeholder for buddhism
      case 'hinduism':
        return 'assets/images/religions/hindu Symbol.jpg';
      default:
        return 'assets/images/religions/hindu Symbol.jpg';
    }
  }

  IconData _getReligionIcon(String religionName) {
    switch (religionName.toLowerCase()) {
      case 'islam':
        return Icons.mosque;
      case 'christianity':
        return Icons.church;
      case 'judaism':
        return Icons.star; // Using star instead of star_of_david
      case 'buddhism':
        return Icons.self_improvement;
      case 'hinduism':
        return Icons.auto_awesome;
      default:
        return Icons.auto_awesome;
    }
  }
} 