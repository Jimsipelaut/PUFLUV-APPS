import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/model/important_date_model.dart';
import '../auth/auth_provider.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal terlebih dahulu')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Tanggal diperbarui' : 'Tanggal ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal menyimpan'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DateProvider(),
      child: Consumer<DateProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_isEdit ? 'Edit Tanggal' : 'Tambah Tanggal'),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul (mis. Anniversary)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Pilih tanggal'
                            : DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Berulang setiap tahun'),
                    subtitle: const Text('Aktifkan untuk anniversary / ulang tahun'),
                    value: _recurring,
                    onChanged: (v) => setState(() => _recurring = v),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: provider.isLoading ? null : _handleSave,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: provider.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Tanggal', style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
