import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/questionnaire_model.dart';
import '../widgets/custom_button.dart';

class QuestionnaireWidget extends StatefulWidget {
  final QuestionnaireModel questionnaire;
  final Function(Map<int, dynamic>, Map<int, String>) onSubmit;
  final VoidCallback onCancel;

  const QuestionnaireWidget({
    Key? key,
    required this.questionnaire,
    required this.onSubmit,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<QuestionnaireWidget> createState() => _QuestionnaireWidgetState();
}

class _QuestionnaireWidgetState extends State<QuestionnaireWidget> {
  final Map<int, dynamic> _answers = {};
  final Map<int, String> _followUpAnswers = {};
  final Map<int, TextEditingController> _textControllers = {};
  final Map<int, TextEditingController> _followUpControllers = {};
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Initialize text controllers for open-ended questions
    for (final question in widget.questionnaire.questions) {
      if (question.type == 'open_ended') {
        _textControllers[question.id] = TextEditingController();
      }
      if (question.followUp?.type == 'open_ended') {
        _followUpControllers[question.id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _textControllers.values.forEach((controller) => controller.dispose());
    _followUpControllers.values.forEach((controller) => controller.dispose());
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment,
                  color: AppColors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.questionnaire.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.questionnaire.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.white,
                  ),
                  onPressed: widget.onCancel,
                ),
              ],
            ),
          ),

          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentPage + 1} of ${widget.questionnaire.questions.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${((_currentPage + 1) / widget.questionnaire.questions.length * 100).round()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentPage + 1) / widget.questionnaire.questions.length,
                  backgroundColor: AppColors.lightGreen.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
              ],
            ),
          ),

          // Questions
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.questionnaire.questions.length,
              itemBuilder: (context, index) {
                final question = widget.questionnaire.questions[index];
                return _buildQuestionPage(question);
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: CustomButton(
                      text: 'Previous',
                      type: ButtonType.outline,
                      onPressed: _previousQuestion,
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: _currentPage == widget.questionnaire.questions.length - 1
                        ? 'Generate Plan'
                        : 'Next',
                    onPressed: _currentPage == widget.questionnaire.questions.length - 1
                        ? _submitQuestionnaire
                        : _nextQuestion,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(QuestionModel question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(
            question.text,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (question.required)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '* Required',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Question input based on type
          _buildQuestionInput(question),

          // Follow-up question if needed
          if (_shouldShowFollowUp(question)) ...[
            const SizedBox(height: 32),
            _buildFollowUpQuestion(question),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionInput(QuestionModel question) {
    switch (question.type) {
      case 'dropdown':
        return _buildDropdownInput(question);
      case 'multiple_choice':
        return _buildMultipleChoiceInput(question);
      case 'open_ended':
        return _buildOpenEndedInput(question);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDropdownInput(QuestionModel question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGreen),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _answers[question.id] as String?,
          hint: const Text('Select an option'),
          isExpanded: true,
          items: question.options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _answers[question.id] = value;
              // Clear follow-up answer if main answer changes
              _followUpAnswers.remove(question.id);
              if (_followUpControllers[question.id] != null) {
                _followUpControllers[question.id]!.clear();
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceInput(QuestionModel question) {
    final selectedOptions = _answers[question.id] as List<String>? ?? [];

    return Column(
      children: question.options.map((option) {
        final isSelected = selectedOptions.contains(option);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                final currentList = List<String>.from(selectedOptions);
                if (isSelected) {
                  currentList.remove(option);
                } else {
                  currentList.add(option);
                }
                _answers[question.id] = currentList;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.lightGreen.withOpacity(0.2) : AppColors.white,
                border: Border.all(
                  color: isSelected ? AppColors.primaryGreen : AppColors.lightGreen,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOpenEndedInput(QuestionModel question) {
    return TextField(
      controller: _textControllers[question.id],
      decoration: InputDecoration(
        hintText: question.placeholder ?? 'Enter your answer...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
      maxLines: 3,
      onChanged: (value) {
        _answers[question.id] = value;
      },
    );
  }

  Widget _buildFollowUpQuestion(QuestionModel question) {
    if (question.followUp == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.help_outline,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Follow-up Question',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          question.followUp!.text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _followUpControllers[question.id],
          decoration: InputDecoration(
            hintText: 'Please provide details...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightBlue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
          ),
          maxLines: 3,
          onChanged: (value) {
            _followUpAnswers[question.id] = value;
          },
        ),
      ],
    );
  }

  bool _shouldShowFollowUp(QuestionModel question) {
    if (question.followUp == null) return false;
    
    final answer = _answers[question.id];
    if (answer == null) return false;

    final condition = question.followUp!.condition;
    
    // Handle different condition formats
    if (condition.startsWith('Not ')) {
      final excludedValue = condition.substring(5).replaceAll('"', '').replaceAll("'", "");
      return answer != excludedValue;
    } else {
      final requiredValue = condition.replaceAll('"', '').replaceAll("'", "");
      return answer == requiredValue;
    }
  }

  void _nextQuestion() {
    final currentQuestion = widget.questionnaire.questions[_currentPage];
    
    // Validate required questions
    if (currentQuestion.required && !_answers.containsKey(currentQuestion.id)) {
      _showValidationError('Please answer this required question.');
      return;
    }

    // Validate follow-up if shown
    if (_shouldShowFollowUp(currentQuestion) && 
        (!_followUpAnswers.containsKey(currentQuestion.id) || 
         _followUpAnswers[currentQuestion.id]!.trim().isEmpty)) {
      _showValidationError('Please answer the follow-up question.');
      return;
    }

    if (_currentPage < widget.questionnaire.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitQuestionnaire() {
    // Final validation
    for (final question in widget.questionnaire.questions) {
      if (question.required && !_answers.containsKey(question.id)) {
        _showValidationError('Please answer all required questions.');
        return;
      }
    }

    // Update text field answers
    for (final entry in _textControllers.entries) {
      if (entry.value.text.isNotEmpty) {
        _answers[entry.key] = entry.value.text;
      }
    }

    for (final entry in _followUpControllers.entries) {
      if (entry.value.text.isNotEmpty) {
        _followUpAnswers[entry.key] = entry.value.text;
      }
    }

    widget.onSubmit(_answers, _followUpAnswers);
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
