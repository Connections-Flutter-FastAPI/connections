import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../theme/theme_constants.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import 'dart:math' as math;

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  // Selected time filter
  String _selectedTimeFilter = 'Today';
  
  // Time filter options
  final List<String> _timeFilters = [
    'Today',
    'Tomorrow',
    'This Weekend',
    'Upcoming',
    'Custom Date',
  ];

  // Selected interest category
  String? _selectedInterest;

  // Interest categories with icons
  final List<Map<String, dynamic>> _interests = [
    {"name": "Sports", "icon": Icons.sports_soccer},
    {"name": "Video Games", "icon": Icons.videogame_asset},
    {"name": "Gymming", "icon": Icons.fitness_center},
    {"name": "Movies", "icon": Icons.movie},
    {"name": "Music", "icon": Icons.music_note},
    {"name": "Photography", "icon": Icons.camera_alt},
    {"name": "Travel", "icon": Icons.flight},
    {"name": "Cooking", "icon": Icons.restaurant},
  ];

  // Mock events data (would come from API in real app)
  final List<Map<String, dynamic>> _mockEvents = [
    {
      'title': 'Football Meetup',
      'community': 'Sports Enthusiasts',
      'date': 'Today, 6:00 PM',
      'participants': 18,
      'imageUrl': 'https://images.unsplash.com/photo-1575361204480-aadea25e6e68',
    },
    {
      'title': 'Gaming Tournament',
      'community': 'Gamers Club',
      'date': 'Tomorrow, 3:00 PM',
      'participants': 32,
      'imageUrl': 'https://images.unsplash.com/photo-1511882150382-421056c89033',
    },
    {
      'title': 'Design Workshop',
      'community': 'UI/UX Designers',
      'date': 'This Weekend',
      'participants': 24,
      'imageUrl': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71',
    },
    {
      'title': 'Coding Bootcamp',
      'community': 'Tech Geeks',
      'date': 'Next Monday, 10:00 AM',
      'participants': 15,
      'imageUrl': 'https://images.unsplash.com/photo-1581472723648-909f4851d4ae',
    },
  ];

  // Mock popular communities data
  final List<Map<String, dynamic>> _mockCommunities = [
    {
      'name': 'Tech Enthusiasts',
      'members': 1253,
      'image': 'https://images.unsplash.com/photo-1518770660439-4636190af475',
    },
    {
      'name': 'Fitness Freaks',
      'members': 987,
      'image': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd',
    },
    {
      'name': 'Music Lovers',
      'members': 2345,
      'image': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4',
    },
    {
      'name': 'Book Club',
      'members': 834,
      'image': 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d',
    },
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: ThemeConstants.accentColor,
              onPrimary: ThemeConstants.primaryColor,
              surface: ThemeConstants.backgroundDark,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: ThemeConstants.backgroundDarker,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        // Format date as "MMM dd, yyyy"
        final day = picked.day.toString();
        final month = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ][picked.month - 1];
        _selectedTimeFilter = '$month $day';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ThemeConstants.headingText,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            onPressed: () {
              // Show search
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, size: 28),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: ThemeConstants.errorColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: const Text(
                      '5',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
            onPressed: () {
              // Show notifications
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh data
          await Future.delayed(const Duration(milliseconds: 800));
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Filter Section
              Padding(
                padding: const EdgeInsets.only(
                  top: ThemeConstants.mediumPadding,
                  bottom: ThemeConstants.smallPadding,
                  left: ThemeConstants.mediumPadding,
                ),
                child: Text(
                  'When are you free?',
                  style: TextStyle(
                    fontSize: ThemeConstants.subtitleText,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              
              // Horizontal scrollable time filters
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.mediumPadding),
                  itemCount: _timeFilters.length,
                  itemBuilder: (context, index) {
                    final filter = _timeFilters[index];
                    final isSelected = _selectedTimeFilter == filter;
                    
                    return GestureDetector(
                      onTap: () {
                        if (filter == 'Custom Date') {
                          _selectDate(context);
                        } else {
                          setState(() {
                            _selectedTimeFilter = filter;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: ThemeConstants.smallPadding),
                        padding: const EdgeInsets.symmetric(
                          horizontal: ThemeConstants.mediumPadding,
                          vertical: ThemeConstants.smallPadding,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ThemeConstants.accentColor
                              : (isDark ? ThemeConstants.backgroundDarker : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isSelected
                              ? ThemeConstants.glowEffect(ThemeConstants.accentColor, radius: 8)
                              : null,
                        ),
                        child: Row(
                          children: [
                            if (filter == 'Custom Date')
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: isSelected
                                    ? ThemeConstants.primaryColor
                                    : (isDark ? Colors.white70 : Colors.grey.shade700),
                              ),
                            if (filter == 'Custom Date')
                              const SizedBox(width: 4),
                            Text(
                              filter,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? ThemeConstants.primaryColor
                                    : (isDark ? Colors.white70 : Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Upcoming Events Section
              Padding(
                padding: const EdgeInsets.only(
                  top: ThemeConstants.largePadding,
                  bottom: ThemeConstants.smallPadding,
                  left: ThemeConstants.mediumPadding,
                  right: ThemeConstants.mediumPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: ThemeConstants.subtitleText,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // View all events
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              
              // Events Carousel
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.mediumPadding),
                  itemCount: _mockEvents.length,
                  itemBuilder: (context, index) {
                    final event = _mockEvents[index];
                    return _buildEventCard(event, isDark);
                  },
                ),
              ),
              
              // Popular Communities Section
              Padding(
                padding: const EdgeInsets.only(
                  top: ThemeConstants.largePadding,
                  bottom: ThemeConstants.smallPadding,
                  left: ThemeConstants.mediumPadding,
                  right: ThemeConstants.mediumPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Communities',
                      style: TextStyle(
                        fontSize: ThemeConstants.subtitleText,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // View all communities
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              
              // Communities Horizontal Scroll
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.mediumPadding),
                  itemCount: _mockCommunities.length,
                  itemBuilder: (context, index) {
                    final community = _mockCommunities[index];
                    return _buildCommunityCard(community, isDark);
                  },
                ),
              ),
              
              // Interest-Based Community Selection
              Padding(
                padding: const EdgeInsets.only(
                  top: ThemeConstants.largePadding,
                  bottom: ThemeConstants.smallPadding,
                  left: ThemeConstants.mediumPadding,
                  right: ThemeConstants.mediumPadding,
                ),
                child: Text(
                  'Discover by Interest',
                  style: TextStyle(
                    fontSize: ThemeConstants.subtitleText,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              
              // Interest Grid
              Padding(
                padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    crossAxisSpacing: ThemeConstants.smallPadding,
                    mainAxisSpacing: ThemeConstants.smallPadding,
                  ),
                  itemCount: _interests.length,
                  itemBuilder: (context, index) {
                    final interest = _interests[index];
                    final isSelected = _selectedInterest == interest['name'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedInterest = isSelected ? null : interest['name'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: ThemeConstants.shortAnimation,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ThemeConstants.accentColor
                              : (isDark ? ThemeConstants.backgroundDarker : Colors.white),
                          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
                          boxShadow: isSelected
                              ? ThemeConstants.glowEffect(ThemeConstants.accentColor)
                              : ThemeConstants.softShadow(),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              interest['icon'],
                              color: isSelected
                                  ? ThemeConstants.primaryColor
                                  : (isDark ? ThemeConstants.accentColor : ThemeConstants.primaryColor),
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              interest['name'],
                              style: TextStyle(
                                fontSize: ThemeConstants.microText,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? ThemeConstants.primaryColor
                                    : (isDark ? Colors.white70 : Colors.grey.shade800),
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: ThemeConstants.largePadding),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Create event
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
        backgroundColor: ThemeConstants.accentColor,
        foregroundColor: ThemeConstants.primaryColor,
      ),
    );
  }
  
  Widget _buildEventCard(Map<String, dynamic> event, bool isDark) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: ThemeConstants.mediumPadding),
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
        ),
        child: Stack(
          children: [
            // Background Image with Gradient Overlay
            Positioned.fill(
              child: Image.network(
                '${event['imageUrl']}?w=500&auto=format&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: ThemeConstants.primaryColor,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white54, size: 40),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Community name with highlight color
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeConstants.highlightColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event['community'],
                      style: TextStyle(
                        color: ThemeConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: ThemeConstants.microText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Event Title
                  Text(
                    event['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: ThemeConstants.subtitleText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Date & Time
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: ThemeConstants.accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event['date'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Participants
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        color: ThemeConstants.accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event['participants']} participants',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Join Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Join event
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConstants.accentColor,
                        foregroundColor: ThemeConstants.primaryColor,
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Join Event'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCommunityCard(Map<String, dynamic> community, bool isDark) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: ThemeConstants.mediumPadding),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.smallPadding),
          child: Row(
            children: [
              // Community Image/Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
                  color: isDark ? ThemeConstants.backgroundDarker : Colors.grey.shade200,
                  image: DecorationImage(
                    image: NetworkImage('${community['image']}?w=200&auto=format&fit=crop'),
                    fit: BoxFit.cover,
                    onError: (_, __) => const SizedBox(),
                  ),
                ),
              ),
              const SizedBox(width: ThemeConstants.smallPadding),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      community['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${community['members']} members',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 26,
                      child: OutlinedButton(
                        onPressed: () {
                          // Join community
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: ThemeConstants.accentColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Join',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}