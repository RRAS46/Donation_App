import 'package:dio/dio.dart';
import 'package:donation_app_v1/const_values/title_values.dart';
import 'package:donation_app_v1/enums/drawer_enum.dart';
import 'package:donation_app_v1/models/drawer_model.dart';
import 'package:donation_app_v1/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

class PrivacySecurityPage extends StatefulWidget {
  @override
  _PrivacySecurityPageState createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  String? pdfPath;

  @override
  void initState() {
    super.initState();
    _preparePDF();
  }

  // Function to request permissions
  Future<bool> _requestPermission(List<Permission> permissions) async {
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    return statuses.values.every((status) => status.isGranted);
  }

  // Function to copy the PDF file from assets to a temporary location
  Future<void> _preparePDF() async {
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/privacy_policy.pdf");

    if (!await file.exists()) {
      final data = await rootBundle.load("assets/Privacy_and_Security_Policy.pdf");
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }

    setState(() {
      pdfPath = file.path;
    });
  }
  Future<String?> downloadPDF(String url, String fileName) async {
    try {
      // Request Storage Permission
      if (await Permission.storage.request().isDenied) {
        return "Permission Denied";
      }

      // Get the Downloads Directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download'); // Android Download Folder
      } else {
        directory = await getApplicationDocumentsDirectory(); // iOS Documents Folder
      }

      String filePath = '${directory.path}/$fileName';

      // Download the File
      Dio dio = Dio();
      await dio.download(url, filePath);

      return filePath; // Return the saved file path
    } catch (e) {
      return "Error: $e";
    }
  }

  // Function to open PDF viewer
  void _openPDFViewer() {
    if (pdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF not available, please try again."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(pdfPath: pdfPath!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider= Provider.of<ProfileProvider>(context,listen: false);

    return Scaffold(
      drawer: DonationAppDrawer(drawerIndex: DrawerItem.privacy.index,),
      appBar: AppBar(
        title: Text(PageTitles.getTitle(profileProvider.profile!.settings.language, 'privacy_security_page_title')),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildPrivacySections(),
            SizedBox(height: 20),
            _buildPDFSection(),
          ],
        ),
      ),
    );
  }

  // Header Section
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.green.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Privacy & Security", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 5),
          Text("We value your privacy and work hard to keep your information secure.", style: TextStyle(fontSize: 16, color: Colors.white70)),
        ],
      ),
    );
  }

  // Privacy Sections
  Widget _buildPrivacySections() {
    List<Map<String, String>> privacyItems = [
      {"title": "Data Collection", "content": "We collect minimal data necessary for app functionality, such as your email, profile information, and donation history."},
      {"title": "How We Use Your Data", "content": "Your data is used to enhance your experience, provide customer support, and ensure smooth transactions. We do not sell your data."},
      {"title": "Third-Party Services", "content": "We may share necessary data with trusted partners for payment processing and analytics, but only as required for app functionality."},
      {"title": "Security Measures", "content": "We use industry-standard encryption and security protocols to protect your information from unauthorized access."},
      {"title": "Managing Your Data", "content": "You can update or delete your account information by visiting the settings section or contacting support."},
      {"title": "Permissions & Access", "content": "We may request access to your camera, storage, and location for specific features. You can manage these permissions in your device settings."},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: privacyItems.map((item) => _buildExpandableItem(item["title"]!, item["content"]!)).toList(),
    );
  }

  Widget _buildExpandableItem(String title, String content) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ExpansionTile(
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal.shade700)),
        children: [Padding(padding: EdgeInsets.all(16), child: Text(content, style: TextStyle(fontSize: 14, color: Colors.black87)))],
      ),
    );
  }

  // PDF Viewer Section
  Widget _buildPDFSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: Icon(Icons.picture_as_pdf, color: Colors.redAccent),
        title: Text("View Full Privacy Policy"),
        subtitle: Text("Tap to open the detailed privacy document."),
        onTap: _openPDFViewer,
      ),
    );
  }
}

// PDF Viewer Screen
class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;

  PDFViewerScreen({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Privacy Policy")),
      body: PDFView(filePath: pdfPath),
    );
  }
}
