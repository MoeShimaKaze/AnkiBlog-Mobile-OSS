import 'package:flutter/material.dart';

/// Two-step delete dialog.
/// 1. Calls [onSendCode] to send verification code
/// 2. Shows code input field
/// 3. Calls [onConfirm] with the entered code
///
/// Returns true if deletion was confirmed and successful.
Future<bool> showConfirmDeleteDialog(
  BuildContext context, {
  required String title,
  required String description,
  required Future<void> Function() onSendCode,
  required Future<void> Function(String verificationCode) onConfirm,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ConfirmDeleteDialogContent(
      title: title,
      description: description,
      onSendCode: onSendCode,
      onConfirm: onConfirm,
    ),
  );
  return result == true;
}

class _ConfirmDeleteDialogContent extends StatefulWidget {
  const _ConfirmDeleteDialogContent({
    required this.title,
    required this.description,
    required this.onSendCode,
    required this.onConfirm,
  });

  final String title;
  final String description;
  final Future<void> Function() onSendCode;
  final Future<void> Function(String verificationCode) onConfirm;

  @override
  State<_ConfirmDeleteDialogContent> createState() =>
      _ConfirmDeleteDialogContentState();
}

class _ConfirmDeleteDialogContentState
    extends State<_ConfirmDeleteDialogContent> {
  final _codeController = TextEditingController();
  bool _codeSent = false;
  bool _sending = false;
  bool _confirming = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.onSendCode();
      setState(() {
        _codeSent = true;
        _sending = false;
      });
    } catch (e) {
      setState(() {
        _error = '发送验证码失败: $e';
        _sending = false;
      });
    }
  }

  Future<void> _confirm() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = '请输入验证码');
      return;
    }
    setState(() {
      _confirming = true;
      _error = null;
    });
    try {
      await widget.onConfirm(code);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = '删除失败: $e';
        _confirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.description),
          const SizedBox(height: 16),
          if (!_codeSent) ...[
            const Text('将向管理员邮箱发送验证码以确认删除操作。'),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ] else ...[
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: '验证码',
                border: OutlineInputBorder(),
                hintText: '请输入邮箱收到的验证码',
              ),
              autofocus: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        if (!_codeSent)
          FilledButton(
            onPressed: _sending ? null : _sendCode,
            child: _sending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('发送验证码'),
          )
        else
          FilledButton(
            onPressed: _confirming ? null : _confirm,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: _confirming
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('确认删除'),
          ),
      ],
    );
  }
}
