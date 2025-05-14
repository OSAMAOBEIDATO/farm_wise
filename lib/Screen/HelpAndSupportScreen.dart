import 'package:flutter/material.dart';
import 'package:farm_wise/Common/Constant.dart';
import 'package:farm_wise/Components/SnakBar.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Please enter your feedback or question',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSubmitting = false;
      _feedbackController.clear();
    });

    CustomSnackBar().ShowSnackBar(
      context: context,
      text: 'Thank you for your feedback!',
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'obeidatosama38@gmail.com',
      query: 'subject=Support Request&body=Please describe your issue:',
    );

    // In a real app, use url_launcher package properly
    // This is just for demonstration
    print("Would launch email with URI: $emailUri");

    // Example using url_launcher:
    // if (await canLaunchUrl(emailUri)) {
    //   await launchUrl(emailUri);
    // } else {
    //   CustomSnackBar().ShowSnackBar(
    //     context: context,
    //     text: 'Could not launch email client',
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Frequently Asked Questions'),
            _buildFaqSection(),

            const SizedBox(height: 24),
            _buildSectionTitle('Contact Support'),
            _buildContactSupport(),

            const SizedBox(height: 24),
            _buildSectionTitle('Knowledge Base'),
            _buildKnowledgeBase(),

            const SizedBox(height: 24),
            _buildSectionTitle('App Information'),
            _buildAppInfo(),

            const SizedBox(height: 24),
            _buildSectionTitle('Send Feedback'),
            _buildFeedbackForm(),

            const SizedBox(height: 24),
            _buildSectionTitle('Community Resources'),
            _buildCommunityResources(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _faqItems[index].isExpanded = !isExpanded;
          });
        },
        children: _faqItems.map<ExpansionPanel>((FaqItem item) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(
                  item.question,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              );
            },
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Text(item.answer),
            ),
            isExpanded: item.isExpanded,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactSupport() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactItem(
              Icons.email_outlined,
              'Email Support',
              'obeidatosama38@gmail.com',
              _launchEmail,
            ),
            Divider(),
            _buildContactItem(
              Icons.phone_outlined,
              'Phone Support',
              '+1 (555) 123-4567',
                  () {},
            ),
            Divider(),
            const Text(
              'Support Hours: Monday to Friday, 9:00 AM - 5:00 PM',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Expected Response Time: Within 24 hours',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.green[700]),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeBase() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildKnowledgeItem(
            'Seasonal Planting Guide',
            'Learn the best times to plant your crops',
            Icons.calendar_today,
          ),
          Divider(height: 1),
          _buildKnowledgeItem(
            'Common Crop Diseases',
            'Identify and treat common agricultural issues',
            Icons.healing,
          ),
          Divider(height: 1),
          _buildKnowledgeItem(
            'Soil Management Tips',
            'Maintain healthy soil for better crop yields',
            Icons.landscape,
          ),
          Divider(height: 1),
          _buildKnowledgeItem(
            'Water Conservation',
            'Efficient irrigation practices for your farm',
            Icons.water_drop,
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeItem(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green[100],
        child: Icon(icon, color: Colors.green[700], size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Navigate to article detail
      },
    );
  }

  Widget _buildAppInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('App Version', '1.0.3'),
            const SizedBox(height: 12),
            _buildInfoRow('Last Updated', 'May 10, 2025'),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                // Navigate to privacy policy
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Privacy Policy'),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // Navigate to terms of service
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Terms of Service'),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFeedbackForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(
                hintText: 'Share your thoughts or report an issue...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityResources() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildCommunityItem(
            'Local Farmer Network',
            'Connect with farmers in your area',
            Icons.people,
          ),
          Divider(height: 1),
          _buildCommunityItem(
            'Agricultural Events',
            'Find farming workshops and markets nearby',
            Icons.event,
          ),
          Divider(height: 1),
          _buildCommunityItem(
            'Forum Discussions',
            'Join conversations about farming topics',
            Icons.forum,
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityItem(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green[100],
        child: Icon(icon, color: Colors.green[700], size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        setState(() {

        });
      },
    );
  }
}

// Model class for FAQ items
class FaqItem {
  final String question;
  final String answer;
  bool isExpanded;

  FaqItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

// Sample FAQ data
final List<FaqItem> _faqItems = [
  FaqItem(
    question: 'How do I add a new crop to my calendar?',
    answer: 'To add a new crop, go to the Calendar tab and tap the "+" button in the bottom right corner. Fill in the crop details including name, type, and planting date. The app will automatically calculate the expected harvest date based on the crop type.',
  ),
  FaqItem(
    question: 'How can I identify a plant disease?',
    answer: 'Navigate to the Disease tab and tap the camera icon. Take a clear photo of the affected plant part. Our AI system will analyze the image and provide possible disease identifications along with recommended treatments.',
  ),
  FaqItem(
    question: 'How do I set up notifications for my crops?',
    answer: 'Go to Account Settings > Notifications. Here you can customize which notifications you want to receive and how far in advance you want to be notified about planting and harvesting dates.',
  ),
  FaqItem(
    question: 'Can I use FarmWise offline?',
    answer: 'Yes, most features of FarmWise work offline. Your crop calendar and previously saved information will be accessible without an internet connection. However, features like disease identification and syncing data across devices require connectivity.',
  ),
  FaqItem(
    question: 'How do I reset my password?',
    answer: 'On the login screen, tap "Forgot Password". Enter your email address and follow the instructions sent to your inbox to create a new password.',
  ),
];