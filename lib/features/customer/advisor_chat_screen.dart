import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';

class AdvisorChatScreen extends StatefulWidget {
  final String advisorId;
  final String advisorName;
  final String advisorSpecialty;
  final String? advisorPhotoUrl;
  final String? customerUid;
  final String? customerName;

  const AdvisorChatScreen({
    super.key,
    required this.advisorId,
    required this.advisorName,
    required this.advisorSpecialty,
    this.advisorPhotoUrl,
    this.customerUid,
    this.customerName,
  });

  @override
  State<AdvisorChatScreen> createState() => _AdvisorChatScreenState();
}

class _AdvisorChatScreenState extends State<AdvisorChatScreen> {
  final _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String get _chatId {
    final user = fb.FirebaseAuth.instance.currentUser;
    final myUid = user?.uid ?? 'guest';
    final otherUid = (myUid == widget.advisorId && widget.customerUid != null && widget.customerUid!.isNotEmpty)
        ? widget.customerUid!
        : widget.advisorId;

    final uids = [myUid, otherUid]..sort();
    return '${uids[0]}_${uids[1]}';
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? quickText]) async {
    final text = quickText ?? _msgController.text.trim();
    if (text.isEmpty) return;

    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _msgController.clear();
    final senderName = user.displayName ?? 'FitPulse User';
    final chatId = _chatId;

    try {
      final chatDocRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

      // 1. Explicitly create Parent Chat document in Firestore
      await chatDocRef.set({
        'id': chatId,
        'customerUid': (user.uid == widget.advisorId && widget.customerUid != null)
            ? widget.customerUid!
            : user.uid,
        'customerName': (user.uid == widget.advisorId && widget.customerName != null)
            ? widget.customerName!
            : senderName,
        'advisorUid': widget.advisorId,
        'advisorName': widget.advisorName,
        'lastMessage': text,
        'lastSenderId': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Add Message to subcollection
      await chatDocRef.collection('messages').add({
        'senderId': user.uid,
        'senderName': senderName,
        'receiverId': user.uid == widget.advisorId ? (widget.customerUid ?? '') : widget.advisorId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = fb.FirebaseAuth.instance.currentUser;

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
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFCCFBF1),
              child: ClipOval(
                child: AppNetworkImage(
                  url: widget.advisorPhotoUrl,
                  width: 36,
                  height: 36,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.advisorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(widget.advisorSpecialty, style: const TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
            child: const Row(
              children: [
                CircleAvatar(radius: 3, backgroundColor: AppColors.success),
                SizedBox(width: 4),
                Text('CLINICAL LINE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Clinical Supervision Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFE0F2FE),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Direct medical chat with ${widget.advisorName}. Ask questions about workout exertion or health concerns.',
                      style: const TextStyle(fontSize: 10, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            // Messages List Stream
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(_chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.brandTeal));
                  }

                  final docs = snap.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xFFCCFBF1),
                            child: Icon(Icons.chat_bubble_outline, color: AppColors.brandTeal, size: 28),
                          ),
                          const SizedBox(height: 12),
                          Text('Start Consultation with ${widget.advisorName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text('Send a message or pick a quick topic below:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (ctx, i) {
                      final data = docs[i].data();
                      final isMe = data['senderId'] == user?.uid;
                      final text = data['text'] ?? '';
                      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                      final timeStr = timestamp != null
                          ? '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}'
                          : 'Just now';

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isMe ? AppColors.brandTeal : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(14),
                              topRight: const Radius.circular(14),
                              bottomLeft: isMe ? const Radius.circular(14) : const Radius.circular(2),
                              bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(14),
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                text,
                                style: TextStyle(fontSize: 12, color: isMe ? Colors.white : AppColors.textPrimary, height: 1.3),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  timeStr,
                                  style: TextStyle(fontSize: 8, color: isMe ? Colors.white70 : AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Quick Clinical Question Chips
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _quickChip('Is my heart rate 145 BPM normal?'),
                  _quickChip('Experiencing knee joint stiffness'),
                  _quickChip('Need advice on warm-up routine'),
                  _quickChip('Can I train 4 days in a row?'),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Message Input Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'Message ${widget.advisorName}...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.brandTeal,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip(String label) {
    return GestureDetector(
      onTap: () => _sendMessage(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCCFBF1)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
      ),
    );
  }
}
