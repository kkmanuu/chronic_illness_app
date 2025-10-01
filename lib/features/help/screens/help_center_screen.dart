import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatefulWidget {
  static const routeName = '/help-center';

  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<HelpCategory> _categories = [
    HelpCategory(
      title: 'Getting Started',
      icon: Icons.play_circle_outline,
      color: const Color(0xFF4CAF50),
      faqs: [
        FAQ(
          question: 'How do I create an account?',
          answer: 'To create an account, tap the "Sign Up" button on the login screen, enter your email, username, and password, then verify your email address.',
        ),
        FAQ(
          question: 'How do I log in?',
          answer: 'Enter your email/username and password on the login screen, then tap "Sign In". Make sure your account is verified.',
        ),
        FAQ(
          question: 'What is chronic illness tracking?',
          answer: 'Our app helps you monitor symptoms, medications, appointments, and overall health patterns to better manage your chronic condition.',
        ),
      ],
    ),
    HelpCategory(
      title: 'Account & Profile',
      icon: Icons.person_outline,
      color: const Color(0xFF2196F3),
      faqs: [
        FAQ(
          question: 'How do I update my profile?',
          answer: 'Go to your Profile screen, tap the edit icon, make your changes, and save. You can update your username, profile picture, and notification settings.',
        ),
        FAQ(
          question: 'How do I change my password?',
          answer: 'In your Profile screen, tap "Change Password" under Account Settings, enter your current password and new password.',
        ),
        FAQ(
          question: 'Can I delete my account?',
          answer: 'Currently, account deletion must be requested through our support team. Contact us at support@chronicillnessapp.com for assistance.',
        ),
      ],
    ),
    HelpCategory(
      title: 'Premium Features',
      icon: Icons.star_outline,
      color: const Color(0xFFFF9800),
      faqs: [
        FAQ(
          question: 'What are Premium features?',
          answer: 'Premium membership includes unlimited health readings, detailed reports, advanced analytics, priority support, and ad-free experience.',
        ),
        FAQ(
          question: 'How do I upgrade to Premium?',
          answer: 'Go to your Profile screen, tap "Upgrade to Premium" under Membership, and complete the payment process via M-Pesa.',
        ),
        FAQ(
          question: 'How much does Premium cost?',
          answer: 'Premium membership costs KSH 500 for 30 days of unlimited access to all premium features.',
        ),
        FAQ(
          question: 'Can I cancel my Premium subscription?',
          answer: 'Premium is a one-time 30-day purchase, not a subscription. It will automatically expire after 30 days unless renewed.',
        ),
      ],
    ),
    HelpCategory(
      title: 'Payments & Billing',
      icon: Icons.payment_outlined,
      color: const Color(0xFF9C27B0),
      faqs: [
        FAQ(
          question: 'What payment methods do you accept?',
          answer: 'We currently accept M-Pesa payments. More payment options will be added soon.',
        ),
        FAQ(
          question: 'How do I pay with M-Pesa?',
          answer: 'Select M-Pesa as payment method, enter your phone number, and follow the prompts on your phone to complete the payment.',
        ),
        FAQ(
          question: 'I made a payment but didn\'t get Premium access',
          answer: 'Payments can take a few minutes to process. If you still don\'t have access after 10 minutes, contact our support team.',
        ),
        FAQ(
          question: 'Can I get a refund?',
          answer: 'Refunds are handled on a case-by-case basis. Please contact our support team with your transaction details.',
        ),
      ],
    ),
    HelpCategory(
      title: 'Technical Issues',
      icon: Icons.bug_report_outlined,
      color: const Color(0xFFF44336),
      faqs: [
        FAQ(
          question: 'The app is crashing or freezing',
          answer: 'Try restarting the app. If the issue persists, restart your device and ensure you have the latest app version.',
        ),
        FAQ(
          question: 'I\'m not receiving notifications',
          answer: 'Check that notifications are enabled in your Profile settings and in your device\'s app settings.',
        ),
        FAQ(
          question: 'The app is running slowly',
          answer: 'Close other apps, restart the app, or restart your device. Ensure you have adequate storage space.',
        ),
        FAQ(
          question: 'I forgot my password',
          answer: 'Use the "Forgot Password" link on the login screen to reset your password via email.',
        ),
      ],
    ),
  ];

  List<FAQ> get _filteredFAQs {
    if (_searchQuery.isEmpty) return [];
    
    List<FAQ> results = [];
    for (var category in _categories) {
      for (var faq in category.faqs) {
        if (faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            faq.answer.toLowerCase().contains(_searchQuery.toLowerCase())) {
          results.add(faq);
        }
      }
    }
    return results;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.contact_support_outlined),
            onPressed: () => _showContactSupport(context),
            tooltip: 'Contact Support',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search help articles...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _searchController.clear();
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildCategories(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _filteredFAQs;
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or browse categories',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final faq = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              faq.question,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  faq.answer,
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategories() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showCategoryFAQs(context, category),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${category.faqs.length} articles',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCategoryFAQs(BuildContext context, HelpCategory category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: category.faqs.length,
                  itemBuilder: (context, index) {
                    final faq = category.faqs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          faq.question,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(
                              faq.answer,
                              style: TextStyle(
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Contact Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Need more help? Get in touch with our support team:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildContactOption(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@chronicillnessapp.com',
              onTap: () => _launchEmail(),
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              icon: Icons.phone_outlined,
              title: 'Phone Support',
              subtitle: '+254 700 000 000',
              onTap: () => _launchPhone(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.launch,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@chronicillnessapp.com',
      query: 'subject=Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+254700000000');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}

class HelpCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<FAQ> faqs;

  HelpCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.faqs,
  });
}

class FAQ {
  final String question;
  final String answer;

  FAQ({
    required this.question,
    required this.answer,
  });
}
