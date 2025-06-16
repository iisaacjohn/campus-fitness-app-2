import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/chart_placeholder.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/section_header.dart';

class GymTrafficPrediction extends StatefulWidget {
  const GymTrafficPrediction({Key? key}) : super(key: key);

  @override
  State<GymTrafficPrediction> createState() => _GymTrafficPredictionState();
}

class _GymTrafficPredictionState extends State<GymTrafficPrediction> {
  String _selectedDay = 'Monday';
  String _selectedVibe = 'Indifferent';
  
  final List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  
  final List<Map<String, dynamic>> _vibes = [
    {
      'name': 'Heavy Lifter',
      'icon': Icons.fitness_center,
      'description': 'Prefer less crowded times for serious lifting',
    },
    {
      'name': 'Social Butterfly',
      'icon': Icons.people,
      'description': 'Enjoy working out when others are around',
    },
    {
      'name': 'Indifferent',
      'icon': Icons.thumbs_up_down,
      'description': 'No preference for gym crowd levels',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Traffic Prediction'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Introduction
                CustomCard(
                  color: AppColors.lightBlue.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primaryBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Find the Perfect Time to Work Out',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Our AI-powered system predicts gym traffic based on historical data. Select your preferences below to find the best time for your workout.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Day Selection
                SectionHeader(
                  title: 'Select Day',
                  icon: Icons.calendar_today,
                ),
                
                const SizedBox(height: 8),
                
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _days.length,
                    itemBuilder: (context, index) {
                      final day = _days[index];
                      final isSelected = day == _selectedDay;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(day),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedDay = day;
                              });
                            }
                          },
                          backgroundColor: AppColors.white,
                          selectedColor: AppColors.primaryGreen,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Vibe Selection
                SectionHeader(
                  title: 'Your Vibe',
                  icon: Icons.mood,
                ),
                
                const SizedBox(height: 8),
                
                Column(
                  children: _vibes.map((vibe) {
                    final isSelected = vibe['name'] == _selectedVibe;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CustomCard(
                        onTap: () {
                          setState(() {
                            _selectedVibe = vibe['name'];
                          });
                        },
                        color: isSelected ? AppColors.lightGreen.withOpacity(0.2) : null,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryGreen : AppColors.lightGreen.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                vibe['icon'],
                                color: isSelected ? AppColors.white : AppColors.primaryGreen,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vibe['name'],
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    vibe['description'],
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryGreen,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Prediction Results
                SectionHeader(
                  title: 'Traffic Prediction',
                  icon: Icons.analytics,
                ),
                
                const SizedBox(height: 8),
                
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gym Traffic for $_selectedDay',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ChartPlaceholder(
                        title: 'Hourly Traffic',
                        type: ChartType.bar,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb,
                                  color: AppColors.primaryGreen,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Recommended Times',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '• Early Morning (6:00 AM - 8:00 AM)\n• Mid-Afternoon (2:00 PM - 4:00 PM)',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Add to Calendar',
                        icon: Icons.calendar_today,
                        type: ButtonType.outline,
                        onPressed: () {
                          // Add to calendar functionality
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Share Results',
                        icon: Icons.share,
                        onPressed: () {
                          // Share functionality
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
