import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/chart_placeholder.dart';
import '../widgets/custom_card.dart';
import '../widgets/section_header.dart';

class ProgressTracker extends StatelessWidget {
  const ProgressTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Summary
                CustomCard(
                  color: AppColors.lightGreen.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: AppColors.primaryGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your Progress',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildProgressStat(
                            context,
                            '12',
                            'Workouts',
                            Icons.fitness_center,
                          ),
                          _buildProgressStat(
                            context,
                            '3',
                            'Week Streak',
                            Icons.local_fire_department,
                          ),
                          _buildProgressStat(
                            context,
                            '85%',
                            'Goal Progress',
                            Icons.emoji_events,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Workout Consistency
                SectionHeader(
                  title: 'Workout Consistency',
                  icon: Icons.calendar_today,
                ),
                
                const SizedBox(height: 8),
                
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ChartPlaceholder(
                        title: 'Weekly Workouts',
                        type: ChartType.bar,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'You\'ve completed 4 workouts this week - that\'s 1 more than last week!',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Achievements
                SectionHeader(
                  title: 'Achievements',
                  icon: Icons.emoji_events,
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildAchievementBadge(
                        context,
                        'Early Bird',
                        'Completed 5 morning workouts',
                        Icons.wb_sunny,
                        AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAchievementBadge(
                        context,
                        'Consistency',
                        'Worked out 3 weeks in a row',
                        Icons.repeat,
                        AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildAchievementBadge(
                        context,
                        'Strength',
                        'Increased weights in 3 exercises',
                        Icons.fitness_center,
                        AppColors.primaryBlue,
                        locked: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAchievementBadge(
                        context,
                        'Explorer',
                        'Tried 5 different workouts',
                        Icons.explore,
                        AppColors.primaryGreen,
                        locked: true,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Motivational Quotes
                SectionHeader(
                  title: 'Motivation',
                  icon: Icons.favorite,
                ),
                
                const SizedBox(height: 8),
                
                SizedBox(
                  height: 160,
                  child: PageView(
                    children: [
                      _buildMotivationalQuote(
                        context,
                        '"The only bad workout is the one that didn\'t happen."',
                        '- Unknown',
                        AppColors.primaryGreen,
                      ),
                      _buildMotivationalQuote(
                        context,
                        '"Your body can stand almost anything. It\'s your mind that you have to convince."',
                        '- Andrew Murphy',
                        AppColors.primaryBlue,
                      ),
                      _buildMotivationalQuote(
                        context,
                        '"The difference between try and triumph is just a little umph!"',
                        '- Marvin Phillips',
                        AppColors.darkGreen,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Next Goal
                SectionHeader(
                  title: 'Next Goal',
                  icon: Icons.flag,
                ),
                
                const SizedBox(height: 8),
                
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_run,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Complete 5 workouts this week',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Progress: 4/5 workouts',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 0.8,
                          minHeight: 10,
                          backgroundColor: AppColors.lightBlue.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildProgressStat(BuildContext context, String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColors.primaryGreen,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildAchievementBadge(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color, {
    bool locked = false,
  }) {
    return CustomCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: locked ? Colors.grey.withOpacity(0.2) : color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              locked ? Icons.lock : icon,
              color: locked ? Colors.grey : color,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: locked ? Colors.grey : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: locked ? Colors.grey : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMotivationalQuote(BuildContext context, String quote, String author, Color color) {
    return CustomCard(
      color: color.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.format_quote,
            color: AppColors.white,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            quote,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            author,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
