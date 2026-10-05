import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
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
        title: Row(
          children: const [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
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
                    child: Row(
                      children: const [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Add Image (optional)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      Text('JPG, PNG up to 5MB', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Drag & Drop Upload Box
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCCFBF1), style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircleAvatar(radius: 16, backgroundColor: Color(0xFFCCFBF1), child: Icon(Icons.cloud_upload_outlined, color: AppColors.brandTeal, size: 18)),
                        SizedBox(height: 6),
                        Text('Click to upload image', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                        Text('or drag and drop your media file', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Status', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _status = 'Draft'),
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
                          onTap: () => setState(() => _status = 'Publish'),
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
                  PrimaryButton(
                    label: 'Save Guidance →',
                    onPressed: () => Navigator.of(context).pop(),
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
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
