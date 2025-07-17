import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../services/sample_data_service.dart';

class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({Key? key}) : super(key: key);

  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  bool _isCreatingQuestionnaire = false;
  bool _isCreatingGymData = false;
  bool _questionnaireCreated = false;
  bool _gymDataCreated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Setup'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Database Setup',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Use this screen to populate your Firestore database with sample data. This should only be done once.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Questionnaire Setup
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _questionnaireCreated ? Icons.check_circle : Icons.assignment,
                          color: _questionnaireCreated ? Colors.green : AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Create Sample Questionnaires',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Creates workout and nutrition questionnaires with sample questions.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_questionnaireCreated)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Questionnaires created successfully!',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    else
                      CustomButton(
                        text: 'Create Questionnaires',
                        onPressed: _isCreatingQuestionnaire ? null : () => _createQuestionnaires(),
                        icon: _isCreatingQuestionnaire ? null : Icons.add,
                      ),
                    if (_isCreatingQuestionnaire)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Gym Traffic Setup
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _gymDataCreated ? Icons.check_circle : Icons.people,
                          color: _gymDataCreated ? Colors.green : AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Create Sample Gym Traffic Data',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Creates realistic gym traffic patterns for all days and hours.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_gymDataCreated)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Gym traffic data created successfully!',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    else
                      CustomButton(
                        text: 'Create Gym Data',
                        type: ButtonType.secondary,
                        onPressed: _isCreatingGymData ? null : () => _createGymData(),
                        icon: _isCreatingGymData ? null : Icons.add,
                      ),
                    if (_isCreatingGymData)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),

              const Spacer(),

              if (_questionnaireCreated && _gymDataCreated)
                CustomCard(
                  color: Colors.green.withOpacity(0.1),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.celebration,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Setup Complete!',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your database has been populated with sample data. You can now test the questionnaire and gym traffic features.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.green),
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

  Future<void> _createQuestionnaires() async {
    setState(() {
      _isCreatingQuestionnaire = true;
    });

    try {
      await SampleDataService.createSampleQuestionnaire();
      setState(() {
        _questionnaireCreated = true;
      });
      _showSuccessMessage('Questionnaires created successfully!');
    } catch (e) {
      _showErrorMessage('Failed to create questionnaires: $e');
    } finally {
      setState(() {
        _isCreatingQuestionnaire = false;
      });
    }
  }

  Future<void> _createGymData() async {
    setState(() {
      _isCreatingGymData = true;
    });

    try {
      await SampleDataService.createSampleGymTraffic();
      setState(() {
        _gymDataCreated = true;
      });
      _showSuccessMessage('Gym traffic data created successfully!');
    } catch (e) {
      _showErrorMessage('Failed to create gym data: $e');
    } finally {
      setState(() {
        _isCreatingGymData = false;
      });
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
