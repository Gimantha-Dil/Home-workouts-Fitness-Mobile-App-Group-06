import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'advisor_shell.dart';

class CreateGuidanceScreen extends StatefulWidget {
  const CreateGuidanceScreen({super.key});

  @override
  State<CreateGuidanceScreen> createState() => _CreateGuidanceScreenState();
}

class _CreateGuidanceScreenState extends State<CreateGuidanceScreen> {
  final _titleController = TextEditingController();
  final _contentController = FormattedTextEditingController();
  final _categoryController = TextEditingController(text: 'Warm-up');
  final _contentFocusNode = FocusNode();
  TextSelection? _lastSelection;
  TextAlign _textAlign = TextAlign.left;
  String _status = 'Draft';
  bool _saving = false;
  String? _uploadedImageUrl;
  String? _uploadedImageName;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(() {
      if (_contentController.selection.isValid) {
        _lastSelection = _contentController.selection;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _applyFormatting(String wrapperBefore, [String? wrapperAfter]) {
    final text = _contentController.text;
    final selection = _lastSelection ?? _contentController.selection;
    final after = wrapperAfter ?? wrapperBefore;

    if (selection.isValid && !selection.isCollapsed && selection.end <= text.length) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(selection.start, selection.end, '$wrapperBefore$selectedText$after');
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + wrapperBefore.length + selectedText.length + after.length),
      );
    } else {
      final offset = selection.isValid ? selection.baseOffset : text.length;
      final insertIndex = offset >= 0 && offset <= text.length ? offset : text.length;
      final newText = text.replaceRange(insertIndex, insertIndex, '$wrapperBefore$after');
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: insertIndex + wrapperBefore.length),
      );
    }
    _contentFocusNode.requestFocus();
    setState(() {});
  }

  void _cycleAlignment() {
    setState(() {
      if (_textAlign == TextAlign.left) {
        _textAlign = TextAlign.center;
      } else if (_textAlign == TextAlign.center) {
        _textAlign = TextAlign.right;
      } else if (_textAlign == TextAlign.right) {
        _textAlign = TextAlign.justify;
      } else {
        _textAlign = TextAlign.left;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Text Alignment: ${_textAlign.name.toUpperCase()}'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final url = await SupabaseService.uploadUserPhoto(
          fileName: pickedFile.name,
          photoBytes: bytes,
        );
        setState(() {
          _uploadedImageUrl = url;
          _uploadedImageName = pickedFile.name;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickOrUploadImage() async {
    setState(() => _saving = true);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: kIsWeb);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final name = file.name;
        final List<int> bytes = List<int>.from(file.bytes ?? []);
        final url = await SupabaseService.uploadUserPhoto(fileName: name, photoBytes: bytes);
        setState(() {
          _uploadedImageUrl = url;
          _uploadedImageName = name;
        });
      } else {
        await _pickImageFromGallery();
      }
    } catch (_) {
      await _pickImageFromGallery();
    }
    setState(() => _saving = false);
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
          SnackBar(
            content: Text('Safety guidance saved as ${savingStatus == 'Publish' ? 'Published' : 'Draft'} successfully!'),
            backgroundColor: AppColors.brandTeal,
          ),
        );

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdvisorShell()),
          );
        }
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
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AdvisorShell()),
              );
            }
          },
        ),
        title: const Row(
          children: [
            Text('Create Safety Guidance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(width: 6),
            _Badge(text: '• REAL-TIME EDITOR', color: AppColors.brandTeal),
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
                      child: const Row(
                        children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Title *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      Text('${_titleController.text.length}/80', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Content *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      Text('${_contentController.text.length} chars', style: const TextStyle(fontSize: 9, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Formatting Toolbar (Bold, Italic, Underline, Align/List, Double Quotes)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.format_bold, size: 20, color: AppColors.textPrimary),
                          tooltip: 'Bold (B)',
                          onPressed: () => _applyFormatting('**'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_italic, size: 20, color: AppColors.textPrimary),
                          tooltip: 'Italic (I)',
                          onPressed: () => _applyFormatting('*'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_underlined, size: 20, color: AppColors.textPrimary),
                          tooltip: 'Underline (U)',
                          onPressed: () => _applyFormatting('<u>', '</u>'),
                        ),
                        IconButton(
                          icon: Icon(
                            _textAlign == TextAlign.center
                                ? Icons.format_align_center
                                : (_textAlign == TextAlign.right
                                ? Icons.format_align_right
                                : (_textAlign == TextAlign.justify ? Icons.format_align_justify : Icons.format_align_left)),
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                          tooltip: 'Align & List (Left, Center, Right, Justify)',
                          onPressed: _cycleAlignment,
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_quote, size: 20, color: AppColors.textPrimary),
                          tooltip: 'Double Quotes ("...")',
                          onPressed: () => _applyFormatting('“', '”'),
                        ),
                      ],
                    ),
                  ),

                  // Direct Formatted Word-Style TextField
                  TextField(
                    controller: _contentController,
                    focusNode: _contentFocusNode,
                    textAlign: _textAlign,
                    maxLines: 8,
                    style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Type safety guidance text here...',
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
                      label: _status == 'Publish' ? 'Publish Guidance →' : 'Save Guidance →',
                      onPressed: () => _saveGuidance(),
                    ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const AdvisorShell()),
                        );
                      }
                    },
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

/// Custom TextEditingController that formats text IN REAL TIME INSIDE THE TEXTFIELD
class FormattedTextEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final spans = <TextSpan>[];
    final textVal = text;

    if (textVal.isEmpty) {
      return TextSpan(style: style, children: const []);
    }

    final regExp = RegExp(r'(\*\*.*?\*\*|\*.*?\*|<u>.*?</u>|“.*?”|".*?")');
    int lastMatchEnd = 0;

    for (final match in regExp.allMatches(textVal)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: textVal.substring(lastMatchEnd, match.start),
          style: style,
        ));
      }

      final matchedText = match.group(0) ?? '';
      if (matchedText.startsWith('**') && matchedText.endsWith('**') && matchedText.length >= 4) {
        spans.add(TextSpan(
          text: matchedText.substring(2, matchedText.length - 2),
          style: (style ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.brandTealDark,
          ),
        ));
      } else if (matchedText.startsWith('*') && matchedText.endsWith('*') && matchedText.length >= 2) {
        spans.add(TextSpan(
          text: matchedText.substring(1, matchedText.length - 1),
          style: (style ?? const TextStyle()).copyWith(
            fontStyle: FontStyle.italic,
          ),
        ));
      } else if (matchedText.startsWith('<u>') && matchedText.endsWith('</u>') && matchedText.length >= 7) {
        spans.add(TextSpan(
          text: matchedText.substring(3, matchedText.length - 4),
          style: (style ?? const TextStyle()).copyWith(
            decoration: TextDecoration.underline,
          ),
        ));
      } else if ((matchedText.startsWith('“') && matchedText.endsWith('”')) || (matchedText.startsWith('"') && matchedText.endsWith('"'))) {
        spans.add(TextSpan(
          text: matchedText,
          style: (style ?? const TextStyle()).copyWith(
            color: AppColors.brandTeal,
            fontWeight: FontWeight.w600,
          ),
        ));
      } else {
        spans.add(TextSpan(text: matchedText, style: style));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < textVal.length) {
      spans.add(TextSpan(
        text: textVal.substring(lastMatchEnd),
        style: style,
      ));
    }

    return TextSpan(style: style, children: spans);
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
