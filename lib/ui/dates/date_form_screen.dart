import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/model/important_date_model.dart';
import '../auth/auth_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';
import 'date_provider.dart';

class DateFormScreen extends StatefulWidget {
  final ImportantDateModel? existing;
  const DateFormScreen({super.key, this.existing});

  @override
  State<DateFormScreen> createState() => _DateFormScreenState();
}

class _DateFormScreenState extends State<DateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  bool _recurring = true;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _titleController.text = widget.existing!.title;
      _recurring = widget.existing!.recurring;
      try {
        _selectedDate = DateFormat('yyyy-MM-dd').parseStrict(widget.existing!.date);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      AppSnack.show(context, 'Pilih tanggal terlebih dahulu', type: AppSnackType.error);
      return;
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null || user.coupleId == null) return;

    final provider = Provider.of<DateProvider>(context, listen: false);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    bool success;
    if (_isEdit) {
      success = await provider.updateDate(
        coupleId: user.coupleId!,
        dateId: widget.existing!.dateId,
        title: _titleController.text,
        date: dateStr,
        recurring: _recurring,
      );
    } else {
      success = await provider.addDate(
        coupleId: user.coupleId!,
        title: _titleController.text,
        date: dateStr,
        recurring: _recurring,
      );
    }

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      AppSnack.show(
        context,
        _isEdit ? 'Tanggal diperbarui' : 'Tanggal ditambahkan',
        type: AppSnackType.success,
      );
    } else {
      AppSnack.show(
        context,
        provider.errorMessage ?? 'Gagal menyimpan',
        type: AppSnackType.error,
      );
    }
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return DateFormat('dd MMMM yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DateProvider(),
      child: Consumer<DateProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.bg,
            appBar: AppBar(
              title: Text(_isEdit ? 'Edit tanggal' : 'Tambah tanggal'),
            ),
            body: SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        children: [
                          AppTextField(
                            controller: _titleController,
                            label: 'Judul',
                            hint: 'mis. Anniversary',
                            textCapitalization: TextCapitalization.sentences,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          AppFieldShell(
                            label: 'Tanggal',
                            child: InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 52),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.outline),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedDate == null
                                            ? 'Pilih tanggal'
                                            : _formatDate(_selectedDate!),
                                        style: AppText.body(
                                          15,
                                          color: _selectedDate == null
                                              ? AppColors.hint
                                              : AppColors.text,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.muted,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          AppCard(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _recurring = !_recurring),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Berulang setiap tahun',
                                          style: AppText.body(14, weight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Aktifkan untuk anniversary / ulang tahun',
                                          style: AppText.body(12, color: AppColors.muted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _CustomSwitch(
                                    value: _recurring,
                                    onChanged: (v) => setState(() => _recurring = v),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: AppPrimaryButton(
                        label: _isEdit ? 'Simpan perubahan' : 'Tambah tanggal',
                        loading: provider.isLoading,
                        onPressed: _handleSave,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 52,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? AppColors.accent : AppColors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value ? AppColors.accent : AppColors.outline,
            width: 1.2,
          ),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: value ? AppColors.onAccent : AppColors.muted,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
