import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';

class TokenImportDialog extends StatefulWidget {
  const TokenImportDialog({super.key, required this.controller});

  final CredentialController controller;

  @override
  State<TokenImportDialog> createState() => _TokenImportDialogState();
}

class _TokenImportDialogState extends State<TokenImportDialog> {
  late final TextEditingController _tokenController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorText = null;
    });
    try {
      await widget.controller.importToken(_tokenController.text);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() {
        _errorText = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AlertDialog(
        title: const Text('粘贴 Token'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const Key('import-token-input'),
                controller: _tokenController,
                maxLines: 6,
                minLines: 4,
                decoration: const InputDecoration(labelText: 'Token'),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: widget.controller.isImporting.value
                ? null
                : () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('submit-import-token'),
            onPressed: widget.controller.isImporting.value ? null : _submit,
            child: Text(widget.controller.isImporting.value ? '导入中' : '导入'),
          ),
        ],
      ),
    );
  }
}
