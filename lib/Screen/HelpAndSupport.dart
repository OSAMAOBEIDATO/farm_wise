import 'package:farm_wise/Components/SnakBar.dart';
import 'package:farm_wise/Screen/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({super.key});

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Function to launch email client with better error handling
  Future<void> _launchEmail(String email, String subject) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          ),
        ),
        title: Text(
          'Help & Support',
          style: GoogleFonts.adamina(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.adamina(fontWeight: FontWeight.w600),
          onTap: (index) => setState(() => _selectedIndex = index),
          tabs: const [
            Tab(text: 'Support', icon: Icon(Icons.support_agent, size: 20)),
            Tab(text: 'FAQs', icon: Icon(Icons.help_outline, size: 20)),
            Tab(text: 'Resources', icon: Icon(Icons.library_books, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSupportTab(),
          _buildFAQsTab(),
          _buildResourcesTab(),
        ],
      ),
    );
  }

  Widget _buildSupportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Contact Us', Icons.contact_support),
          const SizedBox(height: 16),

          // Quick Support Cards
          Row(
            children: [
              Expanded(
                child: _buildQuickSupportCard(
                  'Email Support',
                  Icons.email,
                  'Get help via email',
                      () => _launchEmail('support@farmwise.com', 'Support Request'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickSupportCard(
                  'Live Chat',
                  Icons.chat,
                  'Chat with our team',
                      () => _showChatDialog(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Support Categories', Icons.category),
          const SizedBox(height: 16),

          _buildSupportCategory('Technical Issues', Icons.bug_report, [
            'App crashes or freezes',
            'Login/sync problems',
            'Feature not working',
            'Performance issues',
          ]),

          _buildSupportCategory('Account Help', Icons.account_circle, [
            'Password reset',
            'Account settings',
            'Subscription issues',
            'Data export/backup',
          ]),

          _buildSupportCategory('Feature Requests', Icons.lightbulb, [
            'New crop types',
            'Additional features',
            'Integration requests',
            'Improvement suggestions',
          ]),

          const SizedBox(height: 24),
          _buildFeedbackCard(),

          const SizedBox(height: 24),
          _buildAppInfoCard(),
        ],
      ),
    );
  }

  Widget _buildFAQsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Frequently Asked Questions', Icons.quiz),
          const SizedBox(height: 12),

          _buildFAQSection('Getting Started', [
            _buildFAQItem(
              'How do I create my first crop?',
              'Go to the "Crops" section from the main screen, tap the "+" button, and fill in the crop details such as name, planting date, variety, and care instructions. You can also add photos and set up care reminders.',
            ),
            _buildFAQItem(
              'How do I set up weather alerts?',
              'Navigate to Settings > Notifications > Weather Alerts. Enable the alerts you want to receive and set your preferred notification times.',
            ),
            _buildFAQItem(
              'Can I use the app offline?',
              'Yes! Most features work offline. Your crop data is stored locally and will sync when you\'re back online. However, weather updates and AI disease detection require an internet connection.',
            ),
            _buildFAQItem(
              'How do I set up my first farm profile?',
              'After registration, go to Settings > Farm Profile. Add your farm name, location, size, and main crop types. This helps personalize recommendations and weather data.',
            ),
            _buildFAQItem(
              'What information should I include when adding a crop?',
              'Include crop name, variety, planting date, expected harvest date, field location, soil type, and any specific notes. The more details you provide, the better our recommendations.',
            ),
          ]),

          _buildFAQSection('Crop Management', [
            _buildFAQItem(
              'How do I track crop growth stages?',
              'Each crop has predefined growth stages. Update the stage manually or use our photo-based growth tracking feature that automatically detects growth phases.',
            ),
            _buildFAQItem(
              'Can I add multiple varieties of the same crop?',
              'Absolutely! Create separate entries for different varieties. This helps track performance differences and optimize your future planting decisions.',
            ),
            _buildFAQItem(
              'How do I record harvest data?',
              'When harvest time comes, tap on your crop and select "Record Harvest". Enter yield quantity, quality notes, and any observations for future reference.',
            ),
            _buildFAQItem(
              'Can I track expenses for each crop?',
              'Yes! Use the "Expenses" section to log costs for seeds, fertilizers, pesticides, labor, and equipment. This helps calculate profitability per crop.',
            ),
            _buildFAQItem(
              'How do I set up care reminders?',
              'Go to any crop, tap "Reminders", and set alerts for watering, fertilizing, pest control, or harvesting. Choose frequency and notification preferences.',
            ),
          ]),

          _buildFAQSection('Disease & Pest Management', [
            _buildFAQItem(
              'How accurate is the disease detection feature?',
              'Our AI model has 85-90% accuracy for common crop diseases. However, always consult with agricultural experts for serious issues or treatment decisions.',
            ),
            _buildFAQItem(
              'What should I do if a disease is detected?',
              'The app provides treatment recommendations, but we suggest consulting local agricultural experts. Document the issue with photos and track treatment effectiveness.',
            ),
            _buildFAQItem(
              'Can I report new pests or diseases not in the database?',
              'Yes! Use the "Report Issue" feature to submit photos and descriptions. Our team reviews submissions to improve our detection algorithms.',
            ),
            _buildFAQItem(
              'How do I access pest control recommendations?',
              'Go to the "Pest & Disease" section for preventive measures and treatment options. Recommendations are tailored to your location and crop types.',
            ),
          ]),

          _buildFAQSection('Weather & Environmental Data', [
            _buildFAQItem(
              'How often is weather data updated?',
              'Weather data updates every 3 hours. Historical data and forecasts help you make informed decisions about irrigation, harvesting, and field activities.',
            ),
            _buildFAQItem(
              'Can I access historical weather data?',
              'Yes! View up to 2 years of historical weather data including rainfall, temperature, humidity, and growing degree days for your farm location.',
            ),
            _buildFAQItem(
              'What weather alerts are available?',
              'We provide alerts for frost warnings, heavy rain, drought conditions, extreme temperatures, and optimal spraying conditions based on wind speed.',
            ),
            _buildFAQItem(
              'How do I change my farm location for weather data?',
              'Go to Settings > Farm Profile > Location. You can set multiple locations if you have fields in different areas.',
            ),
          ]),

          _buildFAQSection('Data Management & Sync', [
            _buildFAQItem(
              'How do I backup my farm data?',
              'Enable automatic cloud backup in Settings > Data Backup. Your crop records, photos, and notes are securely stored and synced across devices.',
            ),
            _buildFAQItem(
              'Can I export my data to other applications?',
              'Yes! Export data in CSV, PDF, or Excel formats. Go to Settings > Data Export to download crop records, financial data, and reports.',
            ),
            _buildFAQItem(
              'How do I restore data on a new device?',
              'Sign in with your account credentials on the new device. If cloud backup is enabled, your data will automatically sync within a few minutes.',
            ),
            _buildFAQItem(
              'Is my farm data secure and private?',
              'Yes! All data is encrypted during transmission and storage. We never share your personal farm data with third parties without your explicit consent.',
            ),
          ]),

          _buildFAQSection('Account & Security', [
            _buildFAQItem(
              'How do I change my password?',
              'Go to Settings > Security > Change Password. Enter your current password, then your new password twice to confirm the change.',
            ),
            _buildFAQItem(
              'How do I enable two-factor authentication?',
              'In Settings > Security > Two-Factor Authentication, tap "Enable 2FA" and follow the setup instructions using your preferred authenticator app.',
            ),
            _buildFAQItem(
              'Can I delete my account?',
              'Yes, go to Settings > Account > Delete Account. Note that this action is permanent and cannot be undone. Consider exporting your data first.',
            ),
            _buildFAQItem(
              'I forgot my password. How do I reset it?',
              'On the login screen, tap "Forgot Password". Enter your email address and follow the instructions in the reset email we send you.',
            ),
            _buildFAQItem(
              'Can I change my registered email address?',
              'Yes, go to Settings > Account > Email Address. Enter your new email and verify it through the confirmation email we send.',
            ),
          ]),

          _buildFAQSection('Subscription & Premium Features', [
            _buildFAQItem(
              'What features are included in the free version?',
              'Free features include basic crop tracking, weather updates, simple reminders, and limited disease detection. Premium unlocks advanced analytics and unlimited crops.',
            ),
            _buildFAQItem(
              'What additional features do I get with Premium?',
              'Premium includes unlimited crops, advanced analytics, detailed reports, priority customer support, and access to agricultural expert consultations.',
            ),
            _buildFAQItem(
              'How do I upgrade to Premium?',
              'Tap the "Upgrade" button in Settings or when you reach free tier limits. Choose monthly or annual subscription plans through your device\'s app store.',
            ),
            _buildFAQItem(
              'Can I cancel my Premium subscription?',
              'Yes, manage your subscription through your device\'s app store settings. You\'ll retain Premium features until the current billing period ends.',
            ),
          ]),

          _buildFAQSection('Technical Support & Troubleshooting', [
            _buildFAQItem(
              'The app is running slowly or crashing',
              'Try these steps:\n1. Close and restart the app\n2. Check for app updates\n3. Restart your device\n4. Clear the app cache\n5. Ensure sufficient storage space\n6. Contact support if issues persist.',
            ),
            _buildFAQItem(
              'Photos are not uploading or saving',
              'Check your internet connection and ensure the app has camera and storage permissions. Try taking a new photo or restart the app if issues continue.',
            ),
            _buildFAQItem(
              'Weather data is not updating',
              'Weather updates require location permission and internet access. Check both settings and try manually refreshing the weather section.',
            ),
            _buildFAQItem(
              'I can\'t sync data between my devices',
              'Ensure you\'re signed in with the same account on all devices and have internet connectivity. Check Settings > Account > Sync Status for details.',
            ),
            _buildFAQItem(
              'The app won\'t accept my location',
              'Enable location services for FarmWise in your device settings. If GPS is weak, try moving to an open area or manually enter your farm coordinates.',
            ),
          ]),

          _buildFAQSection('General Questions', [
            _buildFAQItem(
              'What crops does FarmWise support?',
              'We support over 150+ common crops including vegetables, fruits, grains, and herbs. If your crop isn\'t listed, you can add it as a custom crop type.',
            ),
            _buildFAQItem(
              'Is FarmWise suitable for small hobby farms?',
              'Absolutely! FarmWise is designed for farms of all sizes, from small backyard gardens to large commercial operations. Scale features to match your needs.',
            ),
            _buildFAQItem(
              'Can I use FarmWise for organic farming?',
              'Yes! We provide organic-specific recommendations, pest control methods, and certification tracking features to support organic farming practices.',
            ),
            _buildFAQItem(
              'How do I contact customer support?',
              'Reach us through:\n• In-app support chat\n• Email: support@farmwise.com\n• Help center: help.farmwise.com\n• Premium users get priority support within 24 hours.',
            ),
            _buildFAQItem(
              'Does FarmWise work in my country?',
              'FarmWise is available in 50+ countries with localized weather data and region-specific crop recommendations. Check our website for your country\'s availability.',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildResourcesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Learning Resources', Icons.school),
          const SizedBox(height: 16),

          _buildResourceCard(
            'Quick Start Guide',
            'Get started with FarmWise in 5 minutes',
            Icons.play_circle_fill,
            Colors.blue,
                () => _showResourceDialog('Quick Start Guide'),
          ),

          _buildResourceCard(
            'Video Tutorials',
            'Watch step-by-step video guides',
            Icons.video_library,
            Colors.red,
                () => _showResourceDialog('Video Tutorials'),
          ),

          _buildResourceCard(
            'Best Practices',
            'Learn farming best practices and tips',
            Icons.tips_and_updates,
            Colors.orange,
                () => _showResourceDialog('Best Practices'),
          ),

          _buildResourceCard(
            'Community Forum',
            'Connect with other farmers and experts',
            Icons.forum,
            Colors.purple,
                () => _showResourceDialog('Community Forum'),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Documentation', Icons.description),
          const SizedBox(height: 16),

          _buildDocumentationItem('User Manual', 'Complete app documentation'),
          _buildDocumentationItem('API Documentation', 'For developers and integrations'),
          _buildDocumentationItem('Privacy Policy', 'How we protect your data'),
          _buildDocumentationItem('Terms of Service', 'App usage terms and conditions'),

          const SizedBox(height: 24),
          _buildSectionHeader('Contact Information', Icons.contact_phone),
          const SizedBox(height: 16),

          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildQuickSupportCard(String title, IconData icon, String subtitle, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: Colors.green[700], size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.adamina(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCategory(String title, IconData icon, List<String> items) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.green[700]),
        title: Text(
          title,
          style: GoogleFonts.adamina(fontWeight: FontWeight.w600),
        ),
        children: items.map((item) => ListTile(
          dense: true,
          leading: Icon(Icons.circle, size: 8, color: Colors.grey[600]),
          title: Text(item),
          onTap: () => _launchEmail('support@farmwise.com', '$title: $item'),
        )).toList(),
      ),
    );
  }

  Widget _buildResourceCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.adamina(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDocumentationItem(String title, String subtitle) {
    return ListTile(
      leading: Icon(Icons.description, color: Colors.green[700]),
      title: Text(
        title,
        style: GoogleFonts.adamina(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: () => _showResourceDialog(title),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildContactRow(Icons.email, 'Email', 'support@farmwise.com'),
            const Divider(),
            _buildContactRow(Icons.phone, 'Phone', '+1 (555) 123-4567'),
            const Divider(),
            _buildContactRow(Icons.web, 'Website', 'www.farmwise.com'),
            const Divider(),
            _buildContactRow(Icons.schedule, 'Support Hours', 'Mon-Fri 9AM-6PM EST'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[700], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[700], size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.adamina(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildFAQSection(String title, List<Widget> items) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: GoogleFonts.adamina(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                fontSize: 16,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      leading: Icon(Icons.help_outline, color: Colors.green[600], size: 20),
      title: Text(
        question,
        style: GoogleFonts.adamina(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'App Information',
                  style: GoogleFonts.adamina(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Version', '2.1.0'),
            _buildInfoRow('Platform', 'Android & iOS'),
            _buildInfoRow('Support Email', 'support@farmwise.com'),
            _buildInfoRow('Website', 'www.farmwise.com'),
            _buildInfoRow('Last Updated', 'December 2024'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green[600]!, Colors.green[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.favorite, color: Colors.white, size: 32),
              const SizedBox(height: 12),
              Text(
                'Love FarmWise?',
                style: GoogleFonts.adamina(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rate us on the app store or share your feedback to help us improve!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showRatingDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Rate App'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _launchEmail('feedback@farmwise.com', 'App Feedback'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send Feedback'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Live Chat',
          style: GoogleFonts.adamina(fontWeight: FontWeight.bold),
        ),
        content: const Text('Live chat will be available in the next app update. For now, please use email support or check our FAQs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchEmail('support@farmwise.com', 'Support Request');
            },
            child: const Text('Email Support'),
          ),
        ],
      ),
    );
  }

  void _showResourceDialog(String resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          resource,
          style: GoogleFonts.adamina(fontWeight: FontWeight.bold),
        ),
        content: Text('$resource will open in your default browser or app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              CustomSnackBar().ShowSnackBar(context: context, text: 'Opening $resource');
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rate FarmWise',
          style: GoogleFonts.adamina(fontWeight: FontWeight.bold),
        ),
        content: const Text('Thank you for using FarmWise! Your rating helps us improve the app for all farmers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              CustomSnackBar().ShowSnackBar(context: context, text:  'Thank you for your feedback!');
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }
}