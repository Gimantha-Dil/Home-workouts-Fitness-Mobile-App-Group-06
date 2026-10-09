import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class CreateGuidanceScreen extends StatefulWidget {
  const CreateGuidanceScreen({super.key});

  @override
  State<CreateGuidanceScreen> createState() => _CreateGuidanceScreenState();
}

class _CreateGuidanceScreenState extends State<CreateGuidanceScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _category = 'Warm-up';
  String _status = 'Draft';
  bool _saving = false;
  String? _uploadedImageUrl;
  String? _uploadedImageName;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickOrUploadImage() async {
    setState(() {
      _uploadedImageUrl = 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop';
      _uploadedImageName = 'guidance_banner.jpg';
    });
  }

  Future<void> _saveGuidance([String? forcedStatus]) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user?.verificationStatus != 'approved') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin approval is required before you can publish clinical guidance.')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a guidance title.')),
      );
      return;
    }

    final savingStatus = forcedStatus ?? _status;

    setState(() => _saving = true);

    try {
      final uid = user?.id ?? '';
      final authorName = user?.name ?? 'Healthcare Advisor';

      final docRef = FirebaseFirestore.instance.collection('safetyContent').doc();
      await docRef.set({
        'id': docRef.id,
        'title': title,
        'category': _category,
        'content': content,
        'imageUrl': _uploadedImageUrl ?? '',
        'status': savingStatus == 'Publish' ? 'Published' : 'Draft',
        'createdBy': uid,
        'authorName': authorName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Safety guidance saved as ${savingStatus == 'Publish' ? 'Published' : 'Draft'} successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save guidance: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isApproved = user?.verificationStatus == 'approved';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Row(
          children: [
            Text('Create Safety Guidance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(width: 6),
            _Badge(text: '• H04', color: AppColors.brandTeal),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (!isApproved)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Account Pending Admin Approval: You can view your dashboard, but publishing clinical guidance is locked until the admin verifies your credentials.',
                              style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Title *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      Text('0/80', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'e.g. Warm-up Guide'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Category *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    items: const ['Warm-up', 'Cool-down', 'Precautions', 'Warning Signs', 'Health Considerations']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Content *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      Text('Markdown supported', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Editor Toolbar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.format_bold, size: 18, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Icon(Icons.format_italic, size: 18, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Icon(Icons.format_underlined, size: 18, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Icon(Icons.format_list_bulleted, size: 18, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Icon(Icons.format_quote, size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Write safety guidance content here...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add Image (optional)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      Text('JPG, PNG up to 5MB', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Click Upload Box / Preview Box
                  _uploadedImageUrl != null
                      ? Container(
                          height: 110,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.brandTeal),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _uploadedImageUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: AppColors.textSecondary),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_uploadedImageName ?? 'guidance_image.jpg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    const Text('Ready for publication • 2.4 MB', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _uploadedImageUrl = null;
                                          _uploadedImageName = null;
                                        });
                                      },
                                      child: const Text('Remove image', style: TextStyle(fontSize: 10, color: AppColors.danger, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : InkWell(
                          onTap: _pickOrUploadImage,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCCFBF1), style: BorderStyle.solid),
                            ),
                            child: _saving
                                ? const Center(child: CircularProgressIndicator())
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(radius: 16, backgroundColor: Color(0xFFCCFBF1), child: Icon(Icons.cloud_upload_outlined, color: AppColors.brandTeal, size: 18)),
                                      SizedBox(height: 6),
                                      Text('Click to upload image to Supabase', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                      Text('or drag and drop your media file', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                    ],
                                  ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  const Text('Status', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _status = 'Draft');
                            _saveGuidance('Draft');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _status == 'Draft' ? const Color(0xFFCCFBF1) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _status == 'Draft' ? AppColors.brandTeal : const Color(0xFFE5E7EB)),
                            ),
                            child: const Text('• Draft', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _status = 'Publish');
                            _saveGuidance('Publish');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _status == 'Publish' ? const Color(0xFFCCFBF1) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _status == 'Publish' ? AppColors.brandTeal : const Color(0xFFE5E7EB)),
                            ),
                            child: const Text('• Publish', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_saving)
                    const CircularProgressIndicator()
                  else
                    PrimaryButton(
                      label: 'Save Guidance →',
                      onPressed: () => _saveGuidance(),
                    ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
