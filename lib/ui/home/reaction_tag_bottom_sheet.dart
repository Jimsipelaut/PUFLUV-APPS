import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReactionTagBottomSheet extends StatefulWidget {
  final List<String> currentTags;
  final Function(List<String>) onSave;

  const ReactionTagBottomSheet({
    super.key,
    required this.currentTags,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required List<String> currentTags,
    required Function(List<String>) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReactionTagBottomSheet(
        currentTags: currentTags,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ReactionTagBottomSheet> createState() => _ReactionTagBottomSheetState();
}

class _ReactionTagBottomSheetState extends State<ReactionTagBottomSheet> {
  late List<String> _tags;
  final TextEditingController _inputController = TextEditingController();
  String _selectedEmoji = '🫶';
  bool _isSaving = false;

  final List<String> _quickEmojis = ['🫶', '❤️', '🥰', '✨', '🥺', '☕', '🥐', '😴'];

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.currentTags);
    _inputController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addTag() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    if (_tags.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 6 tag balasan')),
      );
      return;
    }

    final newTag = '$_selectedEmoji $text'.trim();
    if (newTag.length > 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tag terlalu panjang (maksimal 16 karakter)')),
      );
      return;
    }

    setState(() {
      _tags.add(newTag);
      _inputController.clear();
    });
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
  }

  void _cycleEmoji() {
    final idx = _quickEmojis.indexOf(_selectedEmoji);
    final nextIdx = (idx + 1) % _quickEmojis.length;
    setState(() {
      _selectedEmoji = _quickEmojis[nextIdx];
    });
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSave(_tags);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan tag: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentInputText = _inputController.text.trim();
    final combinedPreview = '$_selectedEmoji $currentInputText'.trim();
    final charCount = combinedPreview.length;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: 580,
        decoration: const BoxDecoration(
          color: Color(0xFF181B22),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tag balasan',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFAF6F1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Buat sendiri. Maksimal 6 tag.',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFF9AA0AA),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1014),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_tags.length}/6',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFFE6D3C3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Form Input Tag
            Text(
              'Nama tag',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFF9AA0AA),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E1014),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _inputController,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: const Color(0xFFFAF6F1),
                      ),
                      maxLength: 14,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        hintText: 'Hati-hati',
                        hintStyle: TextStyle(color: Color(0xFF6B7380)),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: _cycleEmoji,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E1014),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _selectedEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFFE6D3C3), size: 32),
                  onPressed: _tags.length < 6 && currentInputText.isNotEmpty ? _addTag : null,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$charCount/16',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF9AA0AA),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Pratinjau
            Text(
              'Pratinjau',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFF9AA0AA),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE6D3C3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_selectedEmoji, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 8),
                    Text(
                      currentInputText.isNotEmpty ? currentInputText : 'Hati-hati',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: const Color(0xFFE6D3C3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Daftar Tag Kalian
            Text(
              'Tag kalian',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFF9AA0AA),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_tags.length, (index) {
                final tag = _tags[index];
                return Container(
                  padding: const EdgeInsets.only(left: 14, right: 6, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1014),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: const Color(0xFFFAF6F1),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _removeTag(index),
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFF9AA0AA),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const Spacer(),

            // Tombol Simpan
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE6D3C3),
                  foregroundColor: const Color(0xFF14161B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF14161B)),
                      )
                    : Text(
                        'Simpan tag',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
