import 'package:ankiblog_mobile/presentation/common/utils/image_picker_helper.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/markdown_viewer.dart';
import 'package:flutter/material.dart';

class MarkdownEditor extends StatefulWidget {
  const MarkdownEditor({
    super.key,
    this.initialContent,
    required this.onChanged,
    this.hintText = '输入 Markdown 内容...',
    this.minLines = 10,
    this.onImageUpload,
  });

  final String? initialContent;
  final ValueChanged<String> onChanged;
  final String hintText;
  final int minLines;

  /// Callback to upload an image and return its URL.
  /// When null, the image button inserts a placeholder.
  final Future<String?> Function(String filePath)? onImageUpload;

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late final TextEditingController _controller;
  bool _isPreview = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insert(String prefix, [String suffix = '']) {
    final sel = _controller.selection;
    final text = _controller.text;
    final start = sel.start >= 0 ? sel.start : text.length;
    final end = sel.end >= 0 ? sel.end : text.length;
    final selected = text.substring(start, end);
    final replacement = '$prefix$selected$suffix';
    _controller.text =
        text.substring(0, start) + replacement + text.substring(end);
    _controller.selection = TextSelection.collapsed(
      offset: start + prefix.length + selected.length + suffix.length,
    );
    widget.onChanged(_controller.text);
  }

  Future<void> _pickAndUploadImage() async {
    if (widget.onImageUpload == null) {
      _insert('![alt](', ')');
      return;
    }

    final source = await showImageSourceSheet(context);
    if (source == null || !mounted) return;

    final picked = await pickImageWithConfirmation(
      context,
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final url = await widget.onImageUpload!(picked.path);
      if (url != null && url.isNotEmpty) {
        _insert('![', ']($url)');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('图片上传失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(context),
        const Divider(height: 1),
        if (_isPreview)
          Container(
            constraints: BoxConstraints(minHeight: widget.minLines * 24.0),
            padding: const EdgeInsets.all(12),
            child: MarkdownViewer(data: _controller.text),
          )
        else
          TextField(
            controller: _controller,
            maxLines: null,
            minLines: widget.minLines,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
            onChanged: widget.onChanged,
          ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          _ToolBtn(
            icon: Icons.title,
            tooltip: '标题',
            onTap: () => _insert('## '),
          ),
          _ToolBtn(
            icon: Icons.format_bold,
            tooltip: '粗体',
            onTap: () => _insert('**', '**'),
          ),
          _ToolBtn(
            icon: Icons.format_italic,
            tooltip: '斜体',
            onTap: () => _insert('*', '*'),
          ),
          _ToolBtn(
            icon: Icons.code,
            tooltip: '代码',
            onTap: () => _insert('`', '`'),
          ),
          _ToolBtn(
            icon: Icons.link,
            tooltip: '链接',
            onTap: () => _insert('[', '](url)'),
          ),
          _uploading
              ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _ToolBtn(
                  icon: Icons.image,
                  tooltip: '图片',
                  onTap: _pickAndUploadImage,
                ),
          _ToolBtn(
            icon: Icons.format_list_bulleted,
            tooltip: '列表',
            onTap: () => _insert('- '),
          ),
          _ToolBtn(
            icon: Icons.format_quote,
            tooltip: '引用',
            onTap: () => _insert('> '),
          ),
          _ToolBtn(
            icon: Icons.code_outlined,
            tooltip: '代码块',
            onTap: () => _insert('```\n', '\n```'),
          ),
          const VerticalDivider(width: 16),
          _ToolBtn(
            icon: _isPreview ? Icons.edit : Icons.preview,
            tooltip: _isPreview ? '编辑' : '预览',
            onTap: () => setState(() => _isPreview = !_isPreview),
            color: _isPreview ? Theme.of(context).colorScheme.primary : null,
          ),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  const _ToolBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
