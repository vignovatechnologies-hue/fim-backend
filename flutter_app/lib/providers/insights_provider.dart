import 'package:flutter/material.dart';
import '../services/insights_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class InsightsProvider extends ChangeNotifier {
  final InsightsService _insightsService;

  List<dynamic> _insights = [];
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  InsightsProvider(this._insightsService);

  List<dynamic> get insights => _insights;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAiAnalysis() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _insights = await _insightsService.getAiAnalysis();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isSending = true;
    notifyListeners();

    try {
      final reply = await _insightsService.askAi(text.trim());
      _messages.add(ChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isSending = false;
      notifyListeners();
    } catch (e) {
      _messages.add(ChatMessage(
        text: 'Sorry, I encountered an error communicating with Gemini AI. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isSending = false;
      notifyListeners();
    }
  }
}
