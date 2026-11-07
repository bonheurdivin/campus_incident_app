import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/enums.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../services/storage_service.dart';

class ReportScreen extends StatefulWidget {
  final Incident? existing; // null = new report, otherwise edit mode
  const ReportScreen({super.key, this.existing});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  IncidentCategory _category = IncidentCategory.facilities;

  // Photo state
  XFile? _photo;
  Uint8List? _photoBytes;
  bool _uploading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _descCtrl.text = e.description;
      _locCtrl.text = e.location;
      _category = e.category;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await ImagePicker()
        .pickImage(source: source, maxWidth: 1600, imageQuality: 80);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _photo = picked;
      _photoBytes = bytes;
    });
  }

  void _choosePhotoSource() {
    // Browsers have no camera option, so go straight to the gallery.
    if (kIsWeb) {
      _pickPhoto(ImageSource.gallery);
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().appUser;
    if (user == null) return;

    final provider = context.read<IncidentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Upload the photo first (new reports only)
    String? imageUrl;
    if (_photo != null && !_isEdit) {
      setState(() => _uploading = true);
      try {
        imageUrl = await StorageService().uploadIncidentPhoto(_photo!);
      } catch (_) {
        if (mounted) setState(() => _uploading = false);
        messenger.showSnackBar(const SnackBar(
            content: Text('Photo upload failed. Check your connection.')));
        return;
      }
      if (mounted) setState(() => _uploading = false);
    }

    final ok = _isEdit
        ? await provider.edit(
            widget.existing!.id,
            title: _titleCtrl.text,
            description: _descCtrl.text,
            location: _locCtrl.text,
            category: _category,
          )
        : await provider.submit(
            user: user,
            title: _titleCtrl.text,
            description: _descCtrl.text,
            location: _locCtrl.text,
            category: _category,
            imageUrl: imageUrl,
          );

    if (ok) {
      navigator.pop();
      messenger.showSnackBar(SnackBar(
          content: Text(
              _isEdit ? 'Report updated' : 'Report submitted. Thank you!')));
    } else {
      messenger.showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Submission failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<IncidentProvider>().busy || _uploading;
    final theme = Theme.of(context);

    return Scaffold(
      appBar:
          AppBar(title: Text(_isEdit ? 'Edit Report' : 'Report an Incident')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select a category',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: IncidentCategory.values.map((c) {
                        return ChoiceChip(
                          avatar: Icon(c.icon, size: 18),
                          label: Text(c.label),
                          selected: _category == c,
                          onSelected: (_) => setState(() => _category = c),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleCtrl,
                      maxLength: 80,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Briefly describe the issue',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().length < 5)
                          ? 'Enter at least 5 characters'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'What happened and what is the impact?',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().length < 10)
                          ? 'Enter at least 10 characters'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'e.g. Block A, Room 100',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Location is required'
                          : null,
                    ),

                    // Photo section (new reports only)
                    if (!_isEdit) ...[
                      const SizedBox(height: 16),
                      Text('Add a photo (optional)',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      if (_photoBytes == null)
                        OutlinedButton.icon(
                          onPressed: busy ? null : _choosePhotoSource,
                          icon: const Icon(Icons.add_a_photo_outlined),
                          label: const Text('Tap to add a photo'),
                          style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(64)),
                        )
                      else
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                _photoBytes!,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: busy
                                      ? null
                                      : () => setState(() {
                                            _photo = null;
                                            _photoBytes = null;
                                          }),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],

                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: busy ? null : _submit,
                      style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52)),
                      child: busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isEdit ? 'Save Changes' : 'Submit Report'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
