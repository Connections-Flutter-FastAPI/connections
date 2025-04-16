// lib/services/websocket_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../app_constants.dart';
import '../models/chat_message_data.dart';

class WebSocketService {
  final String wsBaseUrl = AppConstants.baseUrl.replaceFirst('http', 'ws');
  WebSocketChannel? _channel;
  StreamController<ChatMessageData> _messageStreamController = StreamController.broadcast();
  Timer? _reconnectTimer;
  bool _isManuallyDisconnected = false;

  Stream<ChatMessageData> get messages => _messageStreamController.stream;

  // Store connection details for reconnection
  String? _currentRoomType;
  int? _currentRoomId;
  String? _currentToken;

  WebSocketService() {
     print("WebSocketService Initialized");
  }

  void connect(String roomType, int roomId, String? token) {
    // Store details for potential reconnection
    _currentRoomType = roomType;
    _currentRoomId = roomId;
    _currentToken = token;
    _isManuallyDisconnected = false; // Reset manual disconnect flag

    _connectInternal(); // Perform the actual connection
  }

  void _connectInternal() {
     if (_channel != null) {
       print("WebSocketService: Already connected or connecting.");
       return; // Avoid multiple connections
     }
     if (_currentRoomType == null || _currentRoomId == null) {
        print("WebSocketService: Cannot connect without room type/id.");
        return;
     }

    // Cancel any pending reconnection timer
    _reconnectTimer?.cancel();

    if (_messageStreamController.isClosed) {
      _messageStreamController = StreamController.broadcast();
    }

    final wsUrl = '$wsBaseUrl/ws/$_currentRoomType/$_currentRoomId${_currentToken != null ? '?token=$_currentToken' : ''}';
    print('WebSocketService: Attempting to connect: $wsUrl');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      print('WebSocketService: Connection initiated.');

      _channel!.stream.listen(
        (message) {
          print('WebSocketService Received: $message');
          try {
            final decoded = jsonDecode(message);
            if (decoded is Map<String, dynamic> && decoded.containsKey('message_id')) {
              final chatMessage = ChatMessageData.fromJson(decoded);
              if (!_messageStreamController.isClosed) {
                _messageStreamController.add(chatMessage);
              }
            } else {
              print("WebSocketService: Received non-chat message: $decoded");
              if (decoded is Map<String, dynamic> && decoded.containsKey('error')) {
                 if (!_messageStreamController.isClosed) {
                   _messageStreamController.addError("WebSocket Error: ${decoded['error']}");
                 }
              }
            }
          } catch (e) {
            print('WebSocketService: Error handling message: $e');
            if (!_messageStreamController.isClosed) {
              _messageStreamController.addError('Failed to process message: $e');
            }
          }
        },
        onDone: () {
          print('WebSocketService: Connection closed by server (onDone).');
          _handleDisconnect(attemptReconnect: true); // Attempt reconnect on server close
        },
        onError: (error) {
          print('WebSocketService: Stream error: $error');
          if (!_messageStreamController.isClosed) {
            _messageStreamController.addError('WebSocket Error: $error');
          }
           _handleDisconnect(attemptReconnect: true); // Attempt reconnect on error
        },
        // Consider setting cancelOnError to false if you want the stream to stay open
        // across certain types of errors, but usually true is safer.
        cancelOnError: true,
      );
    } catch (e) {
      print('WebSocketService: Connection failed immediately: $e');
      if (!_messageStreamController.isClosed) {
        _messageStreamController.addError('WebSocket Connection Failed: $e');
      }
       _handleDisconnect(attemptReconnect: true); // Attempt reconnect on initial failure
    }
  }


  void _handleDisconnect({bool attemptReconnect = false}) {
     // Clear channel immediately
     _channel = null;

     // Only attempt reconnect if not manually disconnected
     if (attemptReconnect && !_isManuallyDisconnected) {
        _scheduleReconnection();
     } else {
        print("WebSocketService: Disconnected. Manual disconnect: $_isManuallyDisconnected. Reconnect attempt: $attemptReconnect.");
     }
  }

  void _scheduleReconnection() {
    if (_reconnectTimer?.isActive ?? false) return; // Don't schedule if already pending
    if (_isManuallyDisconnected) return; // Don't reconnect if manually stopped

    print("WebSocketService: Scheduling reconnection in 5 seconds...");
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      print("WebSocketService: Attempting reconnection...");
      _connectInternal(); // Try connecting again with stored details
    });
  }

  void disconnect() {
    print('WebSocketService: Manual disconnection requested.');
    _isManuallyDisconnected = true; // Set flag
    _reconnectTimer?.cancel(); // Cancel any pending reconnects
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null; // Ensure channel is cleared
    } else {
       print('WebSocketService: Already disconnected.');
    }
    // Don't close stream controller here, allow potential future connects
  }

  void send(String message) {
    if (_channel != null && _channel?.closeCode == null) {
      print('WebSocketService Sending: $message');
      _channel!.sink.add(message);
    } else {
      print('WebSocketService: Not connected, cannot send message.');
      // Option 1: Throw error
      throw Exception("WebSocket not connected.");
      // Option 2: Try reconnecting? (Can lead to complex loops)
      // _connectInternal(); // Maybe try to reconnect before sending? Risky.
    }
  }

  // Call this when the service is truly no longer needed (e.g., app shutdown)
  void dispose() {
    print("WebSocketService: Disposing...");
    _isManuallyDisconnected = true; // Prevent any further reconnect attempts
    _reconnectTimer?.cancel();
    disconnect(); // Ensure channel is closed
    if (!_messageStreamController.isClosed) {
      _messageStreamController.close();
      print("WebSocketService: Message Stream Controller closed.");
    }
  }
}
