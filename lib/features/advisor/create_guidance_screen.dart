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
  final _categoryController = TextEditingController(text: 'Warm-up');
  String _status = 'Draft';
  bool _saving = false;
  String? _uploadedImageUrl;
  String? _uploadedImageName;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _applyFormatting(String wrapperBefore, [String? wrapperAfter]) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final after = wrapperAfter ?? wrapperBefore;

    if (selection.isValid && !selection.isCollapsed) {
      final selectedText = selection.textInside(text);
      final newText = text.replaceRange(selection.start, selection.end, '$wrapperBefore$selectedText$after');
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + wrapperBefore.length + selectedText.length + after.length),
      );
    } else {
      final offset = _contentController.selection.baseOffset;
      final insertIndex = offset >= 0 ? offset : text.length;
      final newText = text.replaceRange(insertIndex, insertIndex, '$wrapperBefore$after');
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: insertIndex + wrapperBefore.length),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => _saving = true);
        final bytes = await pickedFile.readAsBytes();
        final user = context.read<AuthProvider>().currentUser;
        final uid = user?.id ?? 'advisor';
        final ext = pickedFile.name.contains('.') ? pickedFile.name.split('.').last : 'jpg';
        final path = 'guidance/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';
        final mimeType = ext == 'png' ? 'image/png' : ext == 'webp' ? 'image/webp' : 'image/jpeg';

        await Supabase.instance.client.storage.from('user-photos').uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );

        final publicUrl = Supabase.instance.client.storage.from('user-photos').getPublicUrl(path);

        setState(() {
          _uploadedImageUrl = publicUrl;
          _uploadedImageName = pickedFile.name;
          _saving = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image successfully uploaded to Supabase (user-photos bucket)!'), duration: Duration(seconds: 2)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image to Supabase: $e')),
        );
      }
    }
  }

  void _pickOrUploadImage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload Safety Guidance Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            const Text('Select an image source from your device gallery or presets.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFCCFBF1), child: Icon(Icons.photo_library_outlined, color: AppColors.brandTeal)),
              title: const Text('Upload from Device Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Browse photos & images on your device', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImageFromGallery();
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFF3F4F6), child: Icon(Icons.image_outlined, color: AppColors.brandTeal)),
              title: const Text('Choose Sample Clinical Graphic', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Sports medicine & physiotherapy banners', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _uploadedImageUrl = 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600&auto=format&fit=crop';
                  _uploadedImageName = 'clinical_warmup_banner.jpg';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sample graphic loaded successfully!'), duration: Duration(seconds: 2)),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE0F2FE), child: Icon(Icons.link, color: AppColors.info)),
              title: const Text('Enter Image URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Paste direct image link', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              onTap: () {
                Navigator.of(ctx).pop();
                _showUrlInputDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUrlInputDialog() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Image URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(hintText: 'https://example.com/image.jpg'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty) {
                Navigator.of(ctx).pop();
                setState(() {
                  _uploadedImageUrl = url;
                  _uploadedImageName = url.split('/').last;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image loaded successfully!'), duration: Duration(seconds: 2)),
                );
              }
            },
            child: const Text('Add', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveGuidance([String? forcedStatus]) async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final category = _categoryController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a guidance title.')),
      );
      return;
    }

    final savingStatus = forcedStatus ?? _status;

    setState(() => _saving = true);

    try {
      final user = context.read<AuthProvider>().currentUser;
      final uid = user?.id ?? '';
      final authorName = user?.name ?? 'Healthcare Advisor';

      final docRef = FirebaseFirestore.instance.collection('safetyContent').doc();
      await docRef.set({
        'id': docRef.id,
        'title': title,
        'category': category.isNotEmpty ? category : 'General Safety',
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
                  const Text('Category * (Select from dropdown or type custom)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: _categoryController.text),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      const options = ['Warm-up', 'Cool-down', 'Precautions', 'Warning Signs', 'Health Considerations'];
                      if (textEditingValue.text == '') {
                        return options;
                      }
                      return options.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      _categoryController.text = selection;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      // Keep text synced
                      controller.addListener(() {
                        _categoryController.text = controller.text;
                      });
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Warm-up or custom category',
                          suffixIcon: Icon(Icons.arrow_drop_down, size: 20),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      );
                    },
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
                  // Editor Toolbar with working formatting options
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.format_bold, size: 18, color: AppColors.textPrimary),
                          tooltip: 'Bold',
                          onPressed: () => _applyFormatting('**'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_italic, size: 18, color: AppColors.textPrimary),
                          tooltip: 'Italic',
                          onPressed: () => _applyFormatting('*'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_underlined, size: 18, color: AppColors.textPrimary),
                          tooltip: 'Underline',
                          onPressed: () => _applyFormatting('<u>', '</u>'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_list_bulleted, size: 18, color: AppColors.textPrimary),
                          tooltip: 'Bullet List',
                          onPressed: () => _applyFormatting('- '),
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_quote, size: 18, color: AppColors.textPrimary),
                          tooltip: 'Quote / Blockquote',
                          onPressed: () => _applyFormatting('> '),
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_align_justify, size: 18, color: AppColors.textPrimary),
                          tooltip: 'Justify Alignment',
                          onPressed: () => _applyFormatting('<div align="justify">', '</div>'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_quote_rounded, size: 18, color: AppColors.textPrimary),
                          tooltip: 'Double Quotes ("...")',
                          onPressed: () => _applyFormatting('“', '”'),
                        ),
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
