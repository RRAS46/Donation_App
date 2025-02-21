import 'package:donation_app_v1/const_values/title_values.dart';
import 'package:donation_app_v1/enums/drawer_enum.dart';
import 'package:donation_app_v1/models/drawer_model.dart';
import 'package:donation_app_v1/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  Future<void> _launchInAppWithBrowserOptions(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppBrowserView,
      browserConfiguration: const BrowserConfiguration(showTitle: true),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider= Provider.of<ProfileProvider>(context,listen: false);

    return Scaffold(
      drawer: DonationAppDrawer(drawerIndex: DrawerItem.about.index,),
      appBar: AppBar(
        title: Text(PageTitles.getTitle(profileProvider.profile!.settings.language, 'about_us_page_title')),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100.withOpacity(0.5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 250,
                child: Stack(
                  children: [
                    Container(
                      height: 250,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/panther_racing_team.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      height: 250,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        width: MediaQuery.of(context).size.width * .9,
                        child: const Text(
                          'Panther Racing Team AUTH',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: 'Η Αποστολή μας',
                content: 'Στο Panther Racing Team AUTH, συνδυάζουμε την ακαδημαϊκή γνώση με την πρακτική εμπειρία για να σχεδιάσουμε, να κατασκευάσουμε και να συναρμολογήσουμε μοτοσικλέτες υψηλών επιδόσεων από την αρχή.',
                icon: Icons.lightbulb_outline,
              ),
              const Divider(),
              _buildSection(
                title: 'Το Ταξίδι',
                content: 'Από την πρώτη ιδέα έως την κατασκευή κάθε εξαρτήματος, το ταξίδι μας αντικατοπτρίζει την ομαδικότητα, τη δημιουργικότητα και την επιμονή.',
                icon: Icons.emoji_events_outlined,
              ),
              const Divider(),
              _buildSection(
                title: 'Motostudent - Μια Παγκόσμια Σκηνή',
                content: 'Το Motostudent είναι ένας διεθνής διαγωνισμός που μας δίνει την ευκαιρία να δοκιμάσουμε τις μηχανικές μας δεξιότητες και την καινοτομία μας.',
                icon: Icons.flag_outlined,
              ),
              const Divider(),
              _buildSection(
                title: 'Γιατί Χρειαζόμαστε τη Στήριξή σας',
                content: 'Η υποστήριξή σας μας βοηθά να αποκτήσουμε υλικά, να βελτιώσουμε το σχέδιό μας και να καλύψουμε τα έξοδα ταξιδιού για τον διαγωνισμό.',
                icon: Icons.volunteer_activism,
              ),
              const Divider(),
              _buildSection(
                title: 'Στηρίξτε μας',
                content: 'Ακολουθήστε μας στα κοινωνικά μέσα και υποστηρίξτε την ομάδα μας με ένα απλό κλικ.',
                icon: Icons.support,
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.favorite, color: Colors.teal.shade600),
                      onPressed: () => _launchInAppWithBrowserOptions(Uri.parse('https://instagram.com/panther_racing')),
                    ),
                    IconButton(
                      icon: Icon(Icons.language, color: Colors.blue.shade600),
                      onPressed: () => _launchInAppWithBrowserOptions(Uri.parse('https://pantherauth.gr')),
                    ),
                    IconButton(
                      icon: Icon(Icons.contact_mail, color: Colors.green.shade600),
                      onPressed: () => _launchInAppWithBrowserOptions(Uri.parse('mailto:support@panther_racing.com')),
                    ),
                    IconButton(
                      icon: Icon(Icons.video_library, color: Colors.red.shade600),
                      onPressed: () => _launchInAppWithBrowserOptions(Uri.parse('https://youtube.com/panther_racing')),
                    ),
                    IconButton(
                      icon: Icon(Icons.tiktok, color: Colors.black),
                      onPressed: () => _launchInAppWithBrowserOptions(Uri.parse('https://tiktok.com/@panther_racing')),
                    ),
                    IconButton(
                      icon: Icon(Icons.link, color: Colors.blueAccent),
                      onPressed: () => _launchInAppWithBrowserOptions(Uri.parse('https://linkedin.com/company/panther_racing')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: Colors.teal),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
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
