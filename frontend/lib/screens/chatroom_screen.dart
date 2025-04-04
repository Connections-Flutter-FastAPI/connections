// frontend/lib/screens/chatroom_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../theme/theme_constants.dart';
// Removed unused MessageModel import
// import '../models/message_model.dart';
import '../models/event_model.dart';
import '../models/chat_message_data.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_event_card.dart';
import '../widgets/create_event_dialog.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:convert'; // For jsonEncode in sendMessage
import '../models/message_model.dart'; // <--- ADD THIS IMPORT

// Define placeholder outside the State class
class _EventModelPlaceholder extends EventModel {
  _EventModelPlaceholder() : super(
    id: '0', title: 'Event not found', description: '', location: '',
    dateTime: DateTime.now(), maxParticipants: 0, participants: [],
    creatorId: '', communityId: '',
  );
}


class ChatroomScreen extends StatefulWidget {
  const ChatroomScreen({Key? key}) : super(key: key);

  @override
  _ChatroomScreenState createState() => _ChatroomScreenState();
}

class _ChatroomScreenState extends State<ChatroomScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // --- State Variables ---
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isDrawerOpen = false;
  late AnimationController _fabAnimationController;

  int? _currentCommunityId; // Start with null, set after fetching
  int? _selectedEventId; // Can be null if viewing community chat

  List<ChatMessageData> _messages = [];
  List<EventModel> _events = [];
  List<Map<String, dynamic>> _userCommunities = []; // Stores fetched community data {id, name, ...}

  bool _isLoadingMessages = false; // Separate loading for messages
  bool _isLoadingEvents = false;   // Separate loading for events
  bool _isLoadingCommunities = true; // Initial loading state for communities
  bool _isSendingMessage = false; // State for message sending progress

  StreamSubscription? _messageSubscription;
  Timer? _reconnectTimer; // Timer for WebSocket reconnection attempts

  // --- Lifecycle Methods ---
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: ThemeConstants.shortAnimation,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUserCommunities(); // Load communities first
      }
    });

    _tabController.addListener(_handleTabChange);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _messageController.dispose();
    _fabAnimationController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _messageSubscription?.cancel();
    _reconnectTimer?.cancel(); // Cancel any pending reconnection timer
    // Access ApiService safely before calling disconnect
    try {
      Provider.of<ApiService>(context, listen: false).disconnectWebSocket();
    } catch (e) {
      print("Error accessing ApiService during dispose: $e");
    }
    super.dispose();
  }

  // --- Scroll Listener for potential pagination ---
  void _scrollListener() {
    // Example: Load older messages when reaching the top
    if (_scrollController.position.pixels == _scrollController.position.minScrollExtent && !_isLoadingMessages) {
      print("Reached top, potentially load older messages");
      // _loadOlderMessages(); // Implement this method if pagination is needed
    }
  }

  void _handleTabChange() {
    if (mounted) {
      // Reset selected event when switching tabs
      if (_tabController.index == 0 && _selectedEventId != null) {
        _switchEvent(null); // Switch back to community chat
      }
      // Re-evaluate WebSocket connection if needed (e.g., switching from Events tab back to Chat tab)
      if (_tabController.index == 0) {
        _setupWebSocket();
      } else {
        // When switching to Events tab, disconnect WS unless an event is selected
        if (_selectedEventId == null) {
          Provider.of<ApiService>(context, listen: false).disconnectWebSocket();
        }
      }
      setState(() {}); // Update UI based on tab index
    }
  }

  // --- Data Loading ---
  Future<void> _loadUserCommunities() async {
    if (!mounted) return;
    setState(() => _isLoadingCommunities = true);
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      setState(() { _isLoadingCommunities = false; _userCommunities = []; _currentCommunityId = null; });
      return;
    }

    try {
      final communitiesData = await apiService.fetchCommunities(authProvider.token);
      if (!mounted) return;

      _userCommunities = (communitiesData as List).map((c) => Map<String, dynamic>.from(c)).toList();
      int? initialCommunityId = _currentCommunityId;

      if (_userCommunities.isNotEmpty && (initialCommunityId == null || !_userCommunities.any((c) => c['id'] == initialCommunityId))) {
        initialCommunityId = _userCommunities.first['id'] as int?;
      } else if (_userCommunities.isEmpty) {
        initialCommunityId = null;
      }

      setState(() {
        _currentCommunityId = initialCommunityId;
        _isLoadingCommunities = false;
      });

      // Load messages/events for the determined community (if any)
      if (_currentCommunityId != null) {
        _loadMessagesAndEvents();
      } else {
        // No communities, clear messages/events and ensure WS is disconnected
        setState(() { _messages = []; _events = []; _isLoadingMessages = false; _isLoadingEvents = false; });
        apiService.disconnectWebSocket();
      }

    } catch (e) {
      if (!mounted) return;
      print('Error loading communities: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading communities: $e')));
      setState(() => _isLoadingCommunities = false);
    }
  }

  Future<void> _loadMessagesAndEvents() async {
    if (!mounted || _currentCommunityId == null) return;
    setState(() { _isLoadingMessages = true; _isLoadingEvents = true; });
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      setState(() { _isLoadingMessages = false; _isLoadingEvents = false; _messages = []; _events = []; });
      return;
    }

    try {
      // Fetch messages based on whether an event is selected or not
      final messagesData = await apiService.fetchChatMessages(
        communityId: _selectedEventId == null ? _currentCommunityId : null,
        eventId: _selectedEventId,
        token: authProvider.token!,
        limit: 50, // Or more if needed
      );

      // Fetch events only if we are loading data for a community (not just an event)
      List<EventModel> fetchedEvents = _events; // Keep existing events if loading for selected event
      if (_selectedEventId == null) {
        fetchedEvents = await apiService.fetchCommunityEvents(_currentCommunityId!, authProvider.token!);
      }

      if (!mounted) return;

      // Sort messages by timestamp ascending (API returns newest first)
      final sortedMessages = (messagesData as List)
          .map((m) => ChatMessageData.fromJson(m as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Sort oldest first

      setState(() {
        _messages = sortedMessages;
        _events = fetchedEvents; // Update events list
        _isLoadingMessages = false;
        _isLoadingEvents = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(true)); // Jump to bottom on load
      _setupWebSocket(); // Setup WebSocket connection for the current context

    } catch (e) {
      if (!mounted) return;
      print('Error loading messages/events: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      setState(() { _isLoadingMessages = false; _isLoadingEvents = false; });
    }
  }


  // --- WebSocket Management ---
  void _setupWebSocket() {
    if (!mounted) return;

    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    _messageSubscription?.cancel(); // Cancel previous subscription
    _reconnectTimer?.cancel(); // Cancel any pending reconnect timer

    // Determine the correct room to connect to
    String? roomType;
    int? roomId;

    if (_selectedEventId != null) {
      roomType = "event";
      roomId = _selectedEventId;
    } else if (_currentCommunityId != null && _tabController.index == 0) { // Only connect to community room if on Chat tab
      roomType = "community";
      roomId = _currentCommunityId;
    }

    // Proceed only if authenticated and a valid room is determined
    if (authProvider.isAuthenticated && roomType != null && roomId != null) {
      print("Setting up WebSocket for $roomType $roomId");
      apiService.connectWebSocket(roomType, roomId, authProvider.token);

      _messageSubscription = apiService.messages.listen(
              (chatMessage) {
            if (!mounted) return;
            setState(() {
              // Check if message already exists (by ID) to avoid duplicates
              if (!_messages.any((m) => m.message_id == chatMessage.message_id)) {
                _messages.add(chatMessage);
                // Only scroll if near the bottom
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
              }
            });
          },
          onError: (error) {
            if (!mounted) return;
            print("Error on WebSocket message stream: $error");
            // Optionally show error to user
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chat connection error: $error'), backgroundColor: Colors.red));
            // Implement reconnection logic
            _scheduleReconnection();
          },
          onDone: () {
            if (!mounted) return;
            print("WebSocket stream closed by server.");
            // Implement reconnection logic if closure was unexpected
            _scheduleReconnection();
          }
      );
    } else {
      print("WebSocket setup skipped: Conditions not met (Auth: ${authProvider.isAuthenticated}, Room: $roomType/$roomId, Tab: ${_tabController.index})");
      apiService.disconnectWebSocket(); // Ensure WS is disconnected if conditions aren't met
    }
  }

  void _scheduleReconnection() {
    if (!mounted || (_reconnectTimer?.isActive ?? false)) return; // Don't schedule if already scheduled or unmounted
    print("Scheduling WebSocket reconnection in 5 seconds...");
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        print("Attempting WebSocket reconnection...");
        _setupWebSocket(); // Try to reconnect
      }
    });
  }

  // --- UI Actions ---
  void _toggleDrawer() {
    if (mounted) setState(() => _isDrawerOpen = !_isDrawerOpen);
  }

  void _switchCommunity(int id) {
    if (_currentCommunityId == id || !mounted) {
      if (mounted) setState(() => _isDrawerOpen = false); // Close drawer even if same community tapped
      return;
    }
    setState(() {
      _currentCommunityId = id;
      _selectedEventId = null; // Reset event selection when community changes
      _isDrawerOpen = false;
      _messages = []; // Clear messages immediately
      _events = [];   // Clear events immediately
      _isLoadingMessages = true; // Show loading indicators
      _isLoadingEvents = true;
      // Ensure correct tab is selected if needed (e.g., switch to Chat tab)
      if (_tabController.index != 0) {
        _tabController.animateTo(0);
      }
    });
    _loadMessagesAndEvents(); // Load data for the new community
  }

  // Switch between viewing community chat and a specific event chat
  void _switchEvent(int? eventId) {
    if (_selectedEventId == eventId || !mounted) return;
    setState(() {
      _selectedEventId = eventId;
      _messages = []; // Clear messages when switching event/community view
      _isLoadingMessages = true;
    });
    _loadMessagesAndEvents(); // Reload messages for the new context (event or community)
    // WebSocket connection is handled by _loadMessagesAndEvents -> _setupWebSocket
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || !mounted || _isSendingMessage) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to send messages')));
      return;
    }

    final apiService = Provider.of<ApiService>(context, listen: false);
    final int currentUserId = int.parse(authProvider.userId!); // Assume userId is parsable int

    // Optimistic UI update (optional but recommended for responsiveness)
    /* // Temporarily disable optimistic update via WebSocket only for now
    final tempId = -(DateTime.now().millisecondsSinceEpoch); // Negative ID for temp messages
    final optimisticMessage = ChatMessageData(
      message_id: tempId,
      community_id: _selectedEventId == null ? _currentCommunityId : null,
      event_id: _selectedEventId,
      user_id: currentUserId,
      username: "Me", // Placeholder username
      content: messageText,
      timestamp: DateTime.now().toLocal(), // Use local time for display
    );

    if (mounted) {
      setState(() {
        _messages.add(optimisticMessage);
        _messageController.clear();
        _isSendingMessage = true; // Indicate sending
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    */
    // Clear input and set loading immediately
    if (mounted) {
      setState(() {
        _messageController.clear();
        _isSendingMessage = true;
      });
    }

    // Send via WebSocket if connected, otherwise fallback to HTTP POST
    try {
      // ---- REMOVE THIS BLOCK ----
      // Option 1: Send via WebSocket
      // Original: if (apiService._channel != null && apiService._channel?.closeCode == null) {
      //    final messagePayload = jsonEncode({"content": messageText}); // Backend expects JSON
      //    apiService.sendWebSocketMessage(messagePayload);
      //    print("Message sent via WebSocket.");
      // }
      // ---- END REMOVAL ----
      // Directly try sending - the method handles the check
      final messagePayload = jsonEncode({"content": messageText}); // Backend expects JSON
      apiService.sendWebSocketMessage(messagePayload);
      print("Attempted to send message via WebSocket.");
      // The fallback to HTTP might need rethinking - usually you want WS *or* HTTP, not fallback.
      // If you *do* want fallback, check the WS status differently or let sendWebSocketMessage throw.

      // Example: Assuming sendWebSocketMessage throws if not connected
      // try {
      //   apiService.sendWebSocketMessage(messagePayload);
      //   print("Message sent via WebSocket.");
      // } catch (wsError) {
      //   print("WebSocket send failed ($wsError). Sending message via HTTP POST...");
      //   await apiService.sendChatMessageHttp( /* ... */ );
      //   print("Message sent via HTTP POST.");
      // }


      if (mounted) setState(() => _isSendingMessage = false);

    } catch (e) {
      if (mounted) {
        print("Error sending message: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e'), backgroundColor: Colors.red));
        setState(() => _isSendingMessage = false); // Reset sending state on error
      }
    }
  }

  void _showFabMenu() {
    if (!mounted) return;
    if (_fabAnimationController.status == AnimationStatus.completed) {
      _fabAnimationController.reverse();
    } else {
      _fabAnimationController.forward();
    }
  }

  void _showCreateEventDialog() {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to create events')));
      return;
    }
    if (_currentCommunityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a community first')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => CreateEventDialog(
        // Pass community ID as String or Int based on dialog expectation
        communityId: _currentCommunityId!.toString(),
        onSubmit: _createEvent,
      ),
    );
    _fabAnimationController.reverse(); // Close FAB menu
  }

  Future<void> _createEvent(String title, String description, String location, DateTime dateTime, int maxParticipants) async {
    if (!mounted || _currentCommunityId == null) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    setState(() => _isLoadingEvents = true); // Indicate loading

    try {
      final newEvent = await apiService.createEvent(
        _currentCommunityId!, title, description, location, dateTime, maxParticipants, authProvider.token!,
      );

      if (!mounted) return;

      setState(() {
        _events.add(newEvent); // Add to local list
        _isLoadingEvents = false;
        _tabController.animateTo(1); // Switch to Events tab
        // Optionally select the newly created event
        // _switchEvent(int.tryParse(newEvent.id));
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event "${newEvent.title}" created successfully')));

    } catch (e) {
      if (!mounted) return;
      print('Error creating event: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create event: ${e.toString()}')));
      setState(() => _isLoadingEvents = false);
    }
  }

  Future<void> _joinOrLeaveEvent(EventModel event) async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.userId == null) return;
    final apiService = Provider.of<ApiService>(context, listen: false);

    final String currentUserId = authProvider.userId!;
    final bool currentlyJoined = event.participants.contains(currentUserId);

    // Optimistic UI update
    setState(() {
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        final updatedParticipants = currentlyJoined
            ? event.participants.where((id) => id != currentUserId).toList()
            : [...event.participants, currentUserId]; // Add current user ID
        _events[index] = EventModel(
          id: event.id, title: event.title, description: event.description, location: event.location,
          dateTime: event.dateTime, maxParticipants: event.maxParticipants, creatorId: event.creatorId,
          communityId: event.communityId, imageUrl: event.imageUrl,
          participants: updatedParticipants, // Update participants list
        );
      }
    });

    try {
      if (currentlyJoined) {
        await apiService.leaveEvent(event.id, authProvider.token!);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You left "${event.title}"')));
      } else {
        // Check if event is full before attempting to join
        if (event.isFull) {
          throw Exception("Event is full");
        }
        await apiService.joinEvent(event.id, authProvider.token!);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You joined "${event.title}"')));
      }
    } catch (e) {
      if (!mounted) return;
      print('Error joining/leaving event: $e');
      // Revert optimistic update
      setState(() {
        final index = _events.indexWhere((e) => e.id == event.id);
        if (index != -1) {
          _events[index] = event; // Put original event back
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to ${currentlyJoined ? 'leave' : 'join'} event: ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  // --- Helper Getters ---
  String _getCurrentCommunityName() {
    if (_currentCommunityId == null) return "Chat";
    final community = _userCommunities.firstWhere(
          (c) => c['id'] == _currentCommunityId,
      orElse: () => {'name': 'Community'}, // Default if not found (shouldn't happen ideally)
    );
    return community['name'] as String? ?? 'Community';
  }

  String? _getCurrentEventTitle() {
    if (_selectedEventId == null) return null;
    try {
      // Find event by ID (assuming event.id is String, selectedEventId is int)
      final event = _events.firstWhere((e) => int.tryParse(e.id) == _selectedEventId);
      return event.title;
    } catch (e) {
      return "Event"; // Fallback title
    }
  }

  // --- UI Build Methods ---

  // Scroll to bottom helper
  void _scrollToBottom([bool jump = false]) {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;
        // Only auto-scroll if user is already near the bottom
        if (jump || maxScroll - currentScroll < 150) {
          _scrollController.animateTo(
            maxScroll,
            duration: jump ? Duration.zero : const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Keep state

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context); // Listen for auth changes

    final String currentTitle = _selectedEventId != null
        ? (_getCurrentEventTitle() ?? "Event Chat") // Use event title if selected
        : _getCurrentCommunityName(); // Otherwise use community name

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
            icon: Icon(_isDrawerOpen ? Icons.close : Icons.menu),
            tooltip: _isDrawerOpen ? "Close Communities" : "Open Communities",
            onPressed: _toggleDrawer
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Chat'), Tab(text: 'Events')],
          indicatorColor: ThemeConstants.highlightColor,
          labelColor: Colors.white, // Keep labels white
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // TODO: Add relevant actions, e.g., view event details if an event is selected
          if (_selectedEventId != null)
            IconButton(icon: const Icon(Icons.info_outline), tooltip: "Event Details", onPressed: () {
              // Navigate to event detail screen or show modal
            }),
        ],
      ),
      body: !authProvider.isAuthenticated
          ? _buildNotLoggedInView(isDark)
          : Stack(
        children: [
          // Main Content Area
          Column(
            children: [
              // Event Chips Row (Only visible on Events tab if events exist)
              if (_tabController.index == 1 && _events.isNotEmpty && !_isLoadingEvents)
                _buildEventChips(isDark),

              // Selected Event Card (Only visible if an event is selected)
              // We show this card regardless of the tab to provide context for the chat
              if (_selectedEventId != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildSelectedEventCard(isDark, authProvider.userId),
                ),

              // Chat Messages or Events List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Chat Tab View
                    _buildMessagesList(isDark, authProvider.userId ?? ''),
                    // Events Tab View
                    _buildEventsList(isDark, authProvider.userId),
                  ],
                ),
              ),

              // Message Input Area (Show if on Chat tab OR if an Event is selected)
              if (_tabController.index == 0 || _selectedEventId != null)
                _buildMessageInput(isDark),
            ],
          ),
          // Drawer (Always present but positioned off-screen)
          _buildDrawer(isDark, size),
        ],
      ),
      floatingActionButton: _tabController.index == 1 // Show FAB only on Events tab
          ? _buildFloatingActionButton()
          : null,
    );
  }

  // --- Helper Build Methods ---

  Widget _buildEventChips(bool isDark) {
    // Added loading indicator within the chips row container
    if (_isLoadingEvents) {
      return Container(
          height: 60,
          alignment: Alignment.center,
          color: isDark ? ThemeConstants.backgroundDarker : Colors.grey.shade100,
          child: const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
      );
    }
    if (_events.isEmpty) {
      return const SizedBox(height: 60); // Keep space if no events, prevents layout jump
    }
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: isDark ? ThemeConstants.backgroundDarker : Colors.grey.shade100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.mediumPadding),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final eventIdInt = int.tryParse(event.id);
          final isSelected = _selectedEventId == eventIdInt;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              avatar: Icon(Icons.event, size: 16, color: isSelected ? ThemeConstants.primaryColor : (isDark ? Colors.white70 : Colors.black54)),
              selected: isSelected,
              onSelected: (selected) => _switchEvent(selected ? eventIdInt : null),
              backgroundColor: isDark ? ThemeConstants.backgroundDark : Colors.white,
              selectedColor: ThemeConstants.accentColor,
              labelStyle: TextStyle(
                color: isSelected ? ThemeConstants.primaryColor : (isDark ? Colors.white : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              visualDensity: VisualDensity.compact, // Make chips a bit smaller
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(bool isDark, Size size) {
    return Stack( // Use Stack for overlay + drawer
        children: [
          // Semi-transparent overlay when drawer is open
          if (_isDrawerOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleDrawer,
                child: Container(color: Colors.black.withOpacity(0.5)), // Darker overlay
              ),
            ),
          // Animated Drawer Content
          AnimatedPositioned(
            duration: ThemeConstants.mediumAnimation,
            curve: Curves.easeInOutCubic, // Smoother curve
            left: _isDrawerOpen ? 0 : -size.width * 0.8, // Adjust width
            top: 0, bottom: 0, width: size.width * 0.8,
            child: Material(
              elevation: 16.0,
              child: Container(
                color: isDark ? ThemeConstants.backgroundDark : Colors.white,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drawer Header
                      Padding(
                        padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                        child: Text('My Communities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: isDark ? Colors.white : Colors.black87)),
                      ),
                      const Divider(height: 1),
                      // Communities List
                      Expanded(
                        child: _isLoadingCommunities
                            ? const Center(child: CircularProgressIndicator())
                            : _userCommunities.isEmpty
                            ? Center(child: Text('No communities joined yet.', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)))
                            : ListView.builder(
                          itemCount: _userCommunities.length,
                          itemBuilder: (context, index) {
                            final community = _userCommunities[index];
                            final communityIdInt = community['id'] as int;
                            final isSelected = _currentCommunityId == communityIdInt;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSelected ? ThemeConstants.accentColor : (isDark ? ThemeConstants.backgroundDarker : Colors.grey.shade200),
                                child: Text((community['name'] as String)[0].toUpperCase(), style: TextStyle(color: isSelected ? ThemeConstants.primaryColor : (isDark ? Colors.white : Colors.black87), fontWeight: FontWeight.bold)),
                              ),
                              title: Text(community['name'] as String, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isDark ? Colors.white : Colors.black87)),
                              // TODO: Add unread message count if available from API
                              // trailing: (community['unread'] as int? ?? 0) > 0 ? ... : null,
                              selected: isSelected,
                              selectedTileColor: isDark ? ThemeConstants.backgroundDarker.withOpacity(0.5) : Colors.grey.shade100,
                              onTap: () => _switchCommunity(communityIdInt),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      // Add Community Button
                      ListTile(
                        leading: const Icon(Icons.add_circle_outline, color: ThemeConstants.accentColor),
                        title: const Text('Create/Find Communities', style: TextStyle(color: ThemeConstants.accentColor)),
                        onTap: () {
                          // TODO: Navigate to Communities Screen or Create Community Screen
                          _toggleDrawer(); // Close drawer first
                          // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => CommunitiesScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end, // Align items to the right
      children: [
        // Create Event FAB (only shows when menu is open)
        ScaleTransition(
          scale: CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOutBack), // Bouncy effect
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: FloatingActionButton.small(
              heroTag: 'event_fab', // Unique heroTag
              onPressed: _showCreateEventDialog,
              backgroundColor: ThemeConstants.accentColor,
              tooltip: 'Create Event',
              child: const Icon(Icons.event, color: ThemeConstants.primaryColor),
            ),
          ),
        ),
        // Main Add/Toggle FAB
        FloatingActionButton(
          heroTag: 'main_fab', // Unique heroTag
          onPressed: _showFabMenu,
          backgroundColor: ThemeConstants.highlightColor, // Use highlight color for main FAB
          tooltip: _fabAnimationController.isCompleted ? 'Close Menu' : 'Create Event',
          child: AnimatedRotation(
            turns: _fabAnimationController.value * 0.125, // Rotate 45 degrees
            duration: ThemeConstants.shortAnimation,
            child: Icon(
                _fabAnimationController.isCompleted ? Icons.close : Icons.add, // Change icon based on state
                color: ThemeConstants.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Adjusted padding
      decoration: BoxDecoration(
          color: isDark ? ThemeConstants.backgroundDarker : Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, -2))]
      ),
      child: SafeArea( // Ensure input is above system intrusions
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end, // Align items to bottom for multi-line text field
          children: [
            // Optional: Add Attach/Emoji buttons
            // IconButton(icon: Icon(Icons.add_photo_alternate_outlined), color: ThemeConstants.accentColor, onPressed: () {}),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: isDark ? ThemeConstants.backgroundDark : Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjusted content padding
                  isDense: true, // Reduces intrinsic height
                ),
                minLines: 1,
                maxLines: 5, // Allow multi-line input
                textCapitalization: TextCapitalization.sentences,
                // Send on keyboard action or button press
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                enabled: !_isSendingMessage, // Disable while sending
              ),
            ),
            const SizedBox(width: 8),
            // Send Button with Loading Indicator
            CircleAvatar(
              radius: 22,
              backgroundColor: ThemeConstants.accentColor,
              child: _isSendingMessage
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: ThemeConstants.primaryColor))
                  : IconButton(
                icon: const Icon(Icons.send),
                color: ThemeConstants.primaryColor,
                tooltip: "Send Message",
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedInView(bool isDark) {
    // Identical to the one in me_screen.dart - Consider extracting to a common widget
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
          const SizedBox(height: 20),
          Text('Please log in to access chat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade500 : Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text('Connect with communities and events', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade600 : Colors.grey.shade600)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'), // Navigate to root (Login)
            style: ElevatedButton.styleFrom(backgroundColor: ThemeConstants.accentColor, foregroundColor: ThemeConstants.primaryColor, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            child: const Text('Log In'),
          ),
        ],
      ),
    );
  }

  // Builds the list of messages for the Chat tab
  Widget _buildMessagesList(bool isDark, String currentUserId) {
    if (_isLoadingMessages && _messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_isLoadingMessages && _messages.isEmpty) {
      return Center(child: Text('No messages yet. Start the conversation!', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(ThemeConstants.smallPadding), // Reduced padding
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final messageData = _messages[index];
        final bool isCurrentUserMessage = messageData.user_id.toString() == currentUserId;

        // Adapt ChatMessageData to MessageModel for the bubble widget
        // In a real app, you might pass ChatMessageData directly or have a unified model
        final displayMessage = MessageModel(
          id: messageData.message_id.toString(),
          userId: messageData.user_id.toString(),
          username: isCurrentUserMessage ? "Me" : messageData.username, // Use fetched username
          content: messageData.content,
          timestamp: messageData.timestamp,
          isCurrentUser: isCurrentUserMessage,
          // reactions: null, // Add reactions if fetched/supported
          // imageUrl: null, // Add image URL if fetched/supported
        );
        return ChatMessageBubble(message: displayMessage);
      },
    );
  }

  // Builds the list of events for the Events tab
  Widget _buildEventsList(bool isDark, String? currentUserId) {
    if (_isLoadingEvents && _events.isEmpty) { // Check loading state for events
      return const Center(child: CircularProgressIndicator());
    }
    if (!_isLoadingEvents && _events.isEmpty) {
      return Center(child: Text('No events scheduled for this community.', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80), // Add padding for FAB
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        // Check if the current user has joined this event
        final bool isJoined = currentUserId != null && event.participants.contains(currentUserId);

        return ChatEventCard(
          event: event,
          isJoined: isJoined,
          onTap: () => _switchEvent(int.tryParse(event.id)), // Tap to view event chat
          onJoin: () => _joinOrLeaveEvent(event),
          showJoinButton: true,
        );
      },
    );
  }

  // Builds the card displayed when a specific event chat is selected
  Widget _buildSelectedEventCard(bool isDark, String? currentUserId) {
    if (_selectedEventId == null) return const SizedBox.shrink(); // Hide if no event selected

    EventModel? event;
    try {
      event = _events.firstWhere((e) => int.tryParse(e.id) == _selectedEventId);
    } catch (e) {
      event = null; // Event not found in the current list
      print("Selected event ID $_selectedEventId not found in local list.");
    }

    if (event == null) {
      // Optionally show a placeholder or loading state if event details are being fetched separately
      print("Selected event card not built because event data is null.");
      return const SizedBox.shrink();
    }

    // Now we know 'event' is not null
    final bool isJoined = currentUserId != null && event.participants.contains(currentUserId);

    // Use ChatEventCard to display details consistently
    return ChatEventCard(
      event: event, // OK here, event is non-null
      isJoined: isJoined,
      onTap: () { /* Maybe show full event details */ },
      // ---- FIX IS HERE ----
      onJoin: () => _joinOrLeaveEvent(event!), // Assert non-null when passing to the callback
      // ---- END FIX ----
      showJoinButton: true, // Show join/leave button on the card
    );
  }
}