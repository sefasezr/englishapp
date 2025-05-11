import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final List<Map<String, String>> fullChatHistory = [];
  final GeminiService _geminiService = GeminiService();
  final ScrollController _scrollController = ScrollController();

  final Color lightTeal = Color(0xFF80CBC4);
  final Color mediumBlue = Color(0xFF3F51B5);
  final Color lightOrangeBrown = Color(0xFFFFAB91);
  final Color darkBrown = Color(0xFF795548);

  @override
  void initState() {
    super.initState();
    messages.add({
      'sender': 'bot',
      'message':
          'Merhaba! Ben Sparky! 🦊 Sana İngilizce kelimeleri eğlenceli şekilde öğretmek için buradayım. Hadi başlayalım! 🎉',
    });
    fullChatHistory.add({
      'role': 'user',
      'parts':
          "Sen bir asistan olarak ilkokul öğrencileriyle konuşuyorsun. Yanıtlarını Türkçe ver ve basit, anlaşılır cümleler kullan. Eğlenceli ve öğretici bir dil kullanarak kısa açıklamalar yap. sen bir ingilizce kelime öğretme uygulamasının botu gibi davran. Senin adın Sparky. Kısa ve eğlenceli yanıtlar ver. Öğrencinin sorularına yanıt ver ve kelimeleri öğretmeye çalış. Öğrenciye sorular sorarak onunla etkileşimde bulun. Öğrenciye kelimeleri öğretirken eğlenceli bir dil kullan.",
    });
  }

  void sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({'sender': 'user', 'message': userMessage});
      fullChatHistory.add({'role': 'user', 'parts': userMessage});
    });

    _controller.clear();

    final response = await _geminiService.getChatResponse(fullChatHistory);

    setState(() {
      messages.add({'sender': 'bot', 'message': response});
      fullChatHistory.add({'role': 'model', 'parts': response});

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightTeal,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Sparky",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 5),
                Image.asset('assets/images/logo.png', height: 30),
              ],
            ),
            centerTitle: true,
            backgroundColor: mediumBlue,
            elevation: 2,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['sender'] == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? mediumBlue : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          !isUser
                              ? Border.all(color: mediumBlue.withOpacity(0.5))
                              : null,
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(
                        fontSize: 16,
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Mesajınızı yazın...",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: sendMessage,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: lightOrangeBrown,
                    child: Icon(Icons.send, color: darkBrown, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
