import 'package:flutter/material.dart';
import '../models/religion.dart';
import '../models/chatbot_session.dart';
import '../services/api_service.dart';

class SpiritualGuidanceScreen extends StatefulWidget {
  final Religion religion;
  
  const SpiritualGuidanceScreen({
    super.key,
    required this.religion,
  });

  @override
  State<SpiritualGuidanceScreen> createState() => _SpiritualGuidanceScreenState();
}

class _SpiritualGuidanceScreenState extends State<SpiritualGuidanceScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      content: '''
Welcome to your ${widget.religion.name} spiritual guidance session! 

I'm here to provide you with personalized spiritual advice, answer your questions, and help you deepen your understanding of ${widget.religion.name}.

You can ask me about:
• Personal spiritual challenges
• Religious practices and rituals
• Ethical dilemmas
• Scriptural interpretations
• Community and relationships
• Modern applications of ${widget.religion.name} teachings

What's on your mind today?
      ''',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
      _error = null;
    });

    _scrollToBottom();

    try {
      // TODO: Replace with actual API call when backend is ready
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate mock response for now
      final response = _generateMockResponse(message);
      
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _error = 'Failed to get response: ${e.toString()}';
        _isTyping = false;
      });
    }
  }

  String _generateMockResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('prayer') || lowerMessage.contains('worship')) {
      return '''
In ${widget.religion.name}, prayer and worship are fundamental practices that connect us to the divine. 

**Key aspects of prayer in ${widget.religion.name}:**
• Regular daily prayers help maintain spiritual discipline
• Prayer is not just asking for things, but also expressing gratitude
• The intention (niyyah) behind prayer is as important as the act itself
• Prayer can be done individually or in community

**Practical tips:**
1. Set aside specific times each day for prayer
2. Create a peaceful, clean space for worship
3. Focus on the meaning of the words you're saying
4. Be consistent and patient with your practice

Remember, prayer is a conversation with the divine. Approach it with sincerity and an open heart.
      ''';
    } else if (lowerMessage.contains('stress') || lowerMessage.contains('anxiety') || lowerMessage.contains('worry')) {
      return '''
${widget.religion.name} offers many teachings to help with stress and anxiety:

**Spiritual approaches to managing stress:**
• **Trust in Divine Plan**: Remember that everything happens for a reason
• **Gratitude Practice**: Focus on blessings rather than problems
• **Mindfulness**: Be present in the moment, not dwelling on past or future
• **Community Support**: Connect with your religious community

**Practical exercises:**
1. **Breathing Meditation**: Take deep breaths while reciting sacred phrases
2. **Gratitude Journal**: Write down 3 things you're grateful for each day
3. **Service to Others**: Helping others can shift focus from your own worries
4. **Nature Connection**: Spend time in nature to feel closer to creation

**Remember**: It's okay to seek professional help alongside spiritual practices. ${widget.religion.name} encourages taking care of both body and soul.
      ''';
    } else if (lowerMessage.contains('family') || lowerMessage.contains('relationship')) {
      return '''
${widget.religion.name} places great emphasis on family and relationships:

**Core principles for healthy relationships:**
• **Respect**: Treat others as you wish to be treated
• **Patience**: Relationships require time and understanding
• **Forgiveness**: Let go of grudges and practice forgiveness
• **Communication**: Speak with kindness and listen with empathy

**Family values in ${widget.religion.name}:**
• Honor and care for parents and elders
• Raise children with love and spiritual guidance
• Maintain harmony in the household
• Support family members in times of need

**Practical advice:**
1. Spend quality time together regularly
2. Practice active listening without judgment
3. Express love and appreciation openly
4. Work through conflicts with patience and understanding
5. Include spiritual practices in family life

Remember, strong families are the foundation of strong communities.
      ''';
    } else if (lowerMessage.contains('work') || lowerMessage.contains('career') || lowerMessage.contains('job')) {
      return '''
${widget.religion.name} provides excellent guidance for work and career:

**Ethical work principles:**
• **Honesty**: Be truthful in all business dealings
• **Excellence**: Do your best work as a form of worship
• **Fairness**: Treat employees and colleagues justly
• **Service**: View work as serving others and society

**Balancing work and spirituality:**
• Start your day with prayer or meditation
• Take breaks for spiritual reflection
• Maintain work-life balance
• Use your skills to help others

**Career guidance:**
• Choose work that aligns with your values
• Avoid jobs that harm others or the environment
• Continue learning and growing professionally
• Use your success to help those in need

**Remember**: Your work is part of your spiritual journey. Approach it with intention and purpose.
      ''';
    } else {
      return '''
Thank you for sharing your thoughts about "${userMessage}".

In ${widget.religion.name}, we believe that every question and challenge is an opportunity for spiritual growth. Your inquiry shows a desire to deepen your understanding and practice.

**Some general guidance:**
• Take time to reflect on your question deeply
• Consult sacred texts and trusted spiritual leaders
• Discuss with members of your community
• Trust your intuition while staying grounded in tradition

**Remember**: Spiritual growth is a journey, not a destination. Be patient with yourself and trust the process.

Is there a specific aspect of this topic you'd like to explore further?
      ''';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/Spiritual Guidance Service Logo Spirit Guide.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Spiritual Guidance - ${widget.religion.name}'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          
          // Error message
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask for spiritual guidance...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    onPressed: _isTyping ? null : _sendMessage,
                    icon: _isTyping
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? const Color(0xFF8B5CF6)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 0),
                  bottomRight: Radius.circular(message.isUser ? 0 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.isUser ? Colors.white : const Color(0xFF1F2937),
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Thinking...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Spiritual Guidance Help'),
        content: Text(
          'This is your personal spiritual guidance session. You can ask questions about:\n\n'
          '• Personal challenges and struggles\n'
          '• Religious practices and rituals\n'
          '• Ethical dilemmas\n'
          '• Scriptural interpretations\n'
          '• Family and relationships\n'
          '• Work and career guidance\n'
          '• Modern applications of religious teachings\n\n'
          'The guidance is based on ${widget.religion.name} teachings and principles.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final int id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
} 