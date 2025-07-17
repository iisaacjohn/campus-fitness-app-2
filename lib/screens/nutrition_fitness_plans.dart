import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/section_header.dart';
import '../widgets/questionnaire_widget.dart';
import '../widgets/loading_animation.dart';
import '../models/questionnaire_model.dart';
import '../services/hybrid_questionnaire_service.dart';
import '../providers/app_provider.dart';

class NutritionFitnessPlans extends StatefulWidget {
  const NutritionFitnessPlans({Key? key}) : super(key: key);

  @override
  State<NutritionFitnessPlans> createState() => _NutritionFitnessPlansState();
}

class _NutritionFitnessPlansState extends State<NutritionFitnessPlans> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showQuestionnaire = false;
  QuestionnaireModel? _questionnaire;
  bool _isLoadingQuestionnaire = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestionnaire() async {
    setState(() {
      _isLoadingQuestionnaire = true;
    });

    try {
      final questionnaire = await HybridQuestionnaireService.getWorkoutQuestionnaire();
      if (questionnaire != null) {
        setState(() {
          _questionnaire = questionnaire;
          _showQuestionnaire = true;
        });
      } else {
        _showError('Questionnaire not found.');
      }
    } catch (e) {
      _showError('Failed to load questionnaire: $e');
    } finally {
      setState(() {
        _isLoadingQuestionnaire = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _onQuestionnaireSubmit(Map<int, dynamic> answers, Map<int, String> followUpAnswers) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentUser = appProvider.currentUser;

    if (currentUser == null) {
      _showError('Please log in to save your responses.');
      return;
    }

    try {
      print('Submitting questionnaire with answers: $answers');
      print('Follow-up answers: $followUpAnswers');

      // Use the new method that handles int to string conversion
      final responseId = await HybridQuestionnaireService.saveQuestionnaireResponseFromIntKeys(
        currentUser.id,
        'workout',
        answers,
        followUpAnswers,
      );
      
      if (responseId != null) {
        setState(() {
          _showQuestionnaire = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your personalized workout plan is being generated!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );

        // Generate workout plan based on responses
        _generateWorkoutPlan(responseId, answers, followUpAnswers);
      }
    } catch (e) {
      _showError('Failed to save your responses: $e');
    }
  }

  void _generateWorkoutPlan(String responseId, Map<int, dynamic> answers, Map<int, String> followUpAnswers) {
    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plan Generated!'),
        content: const Text('Your personalized workout plan has been created based on your preferences. Check your workout plans section to view it.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition & Fitness Plans'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.fitness_center),
              text: 'Workouts',
            ),
            Tab(
              icon: Icon(Icons.restaurant_menu),
              text: 'Nutrition',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                // Workouts Tab
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Introduction
                        CustomCard(
                          color: AppColors.lightGreen.withOpacity(0.1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.fitness_center,
                                    color: AppColors.primaryGreen,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Personalized Workout Plans',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Get AI-generated workout plans tailored to your fitness level, goals, and available equipment.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              if (_isLoadingQuestionnaire)
                                const Center(child: LoadingAnimation(size: 50))
                              else
                                CustomButton(
                                  text: 'Generate Workout Plan',
                                  icon: Icons.smart_toy,
                                  onPressed: _loadQuestionnaire,
                                ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        const SizedBox(height: 24),
                        
                        // Sample Workout Plans
                        SectionHeader(
                          title: 'Sample Workout Plans',
                          icon: Icons.fitness_center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Beginner Plan
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Beginner Full Body Workout',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildWorkoutExercise(
                                'Bodyweight Squats',
                                '3 sets x 12 reps',
                                Icons.accessibility_new,
                              ),
                              _buildWorkoutExercise(
                                'Push-ups (Modified if needed)',
                                '3 sets x 8 reps',
                                Icons.accessibility_new,
                              ),
                              _buildWorkoutExercise(
                                'Dumbbell Rows',
                                '3 sets x 10 reps each side',
                                Icons.fitness_center,
                              ),
                              _buildWorkoutExercise(
                                'Plank',
                                '3 sets x 30 seconds',
                                Icons.accessibility_new,
                              ),
                              _buildWorkoutExercise(
                                'Walking Lunges',
                                '2 sets x 10 steps each leg',
                                Icons.directions_walk,
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: 'View Full Plan',
                                type: ButtonType.outline,
                                onPressed: () {
                                  // View full plan functionality
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Intermediate Plan
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Intermediate Upper/Lower Split',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Upper Body Day:',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildWorkoutExercise(
                                'Bench Press',
                                '4 sets x 8-10 reps',
                                Icons.fitness_center,
                              ),
                              _buildWorkoutExercise(
                                'Bent Over Rows',
                                '4 sets x 10 reps',
                                Icons.fitness_center,
                              ),
                              _buildWorkoutExercise(
                                'Overhead Press',
                                '3 sets x 10 reps',
                                Icons.fitness_center,
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: 'View Full Plan',
                                type: ButtonType.outline,
                                onPressed: () {
                                  // View full plan functionality
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Nutrition Tab (keeping the same content)
                SingleChildScrollView(
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
                                    Icons.restaurant_menu,
                                    color: AppColors.primaryBlue,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Personalized Nutrition Plans',
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
                                'Get AI-generated meal plans tailored to your dietary preferences, fitness goals, and campus dining options.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: 'Generate Meal Plan',
                                icon: Icons.smart_toy,
                                type: ButtonType.secondary,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Nutrition questionnaire coming soon!'),
                                      backgroundColor: AppColors.primaryBlue,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Sample Meal Plans
                        SectionHeader(
                          title: 'Sample Meal Plans',
                          icon: Icons.restaurant_menu,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Balanced Meal Plan
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Balanced Meal Plan',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildMealItem(
                                'Breakfast',
                                'Greek yogurt with berries and granola',
                                Icons.breakfast_dining,
                              ),
                              _buildMealItem(
                                'Lunch',
                                'Grilled chicken salad with mixed vegetables',
                                Icons.lunch_dining,
                              ),
                              _buildMealItem(
                                'Dinner',
                                'Baked salmon with quinoa and steamed broccoli',
                                Icons.dinner_dining,
                              ),
                              _buildMealItem(
                                'Snack',
                                'Apple with almond butter',
                                Icons.apple,
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: 'View Full Plan',
                                type: ButtonType.outline,
                                onPressed: () {
                                  // View full plan functionality
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // High Protein Plan
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'High Protein Meal Plan',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildMealItem(
                                'Breakfast',
                                'Protein smoothie with banana, protein powder, and almond milk',
                                Icons.breakfast_dining,
                              ),
                              _buildMealItem(
                                'Lunch',
                                'Turkey and avocado wrap with side salad',
                                Icons.lunch_dining,
                              ),
                              _buildMealItem(
                                'Dinner',
                                'Lean beef stir fry with brown rice and vegetables',
                                Icons.dinner_dining,
                              ),
                              _buildMealItem(
                                'Snack',
                                'Protein bar and a handful of nuts',
                                Icons.food_bank,
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: 'View Full Plan',
                                type: ButtonType.outline,
                                onPressed: () {
                                  // View full plan functionality
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Nutrition Tips
                        SectionHeader(
                          title: 'Nutrition Tips',
                          icon: Icons.lightbulb_outline,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        CustomCard(
                          color: AppColors.lightGreen.withOpacity(0.1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Campus Dining Hacks',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '• Look for the "healthy choice" options in dining halls\n'
                                '• Ask for grilled instead of fried proteins\n'
                                '• Load up on vegetables at the salad bar\n'
                                '• Choose water or unsweetened beverages\n'
                                '• Bring healthy snacks to keep in your dorm',
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
                ),
              ],
            ),
            
            // Questionnaire Overlay
            if (_showQuestionnaire && _questionnaire != null)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: QuestionnaireWidget(
                    questionnaire: _questionnaire!,
                    onSubmit: _onQuestionnaireSubmit,
                    onCancel: () {
                      setState(() {
                        _showQuestionnaire = false;
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWorkoutExercise(String name, String sets, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sets,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMealItem(String mealType, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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
