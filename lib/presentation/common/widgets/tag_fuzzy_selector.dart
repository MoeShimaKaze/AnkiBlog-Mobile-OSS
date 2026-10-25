import 'package:flutter/material.dart';

class TagFuzzySelector extends StatefulWidget {
  const TagFuzzySelector({
    super.key,
    required this.selectedTags,
    required this.suggestions,
    required this.onChanged,
    this.hintText = '输入标签，回车添加',
  });

  final List<String> selectedTags;
  final List<String> suggestions;
  final ValueChanged<List<String>> onChanged;
  final String hintText;

  @override
  State<TagFuzzySelector> createState() => _TagFuzzySelectorState();
}

class _TagFuzzySelectorState extends State<TagFuzzySelector> {
  final _controller = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty) return;
    final exists = widget.selectedTags.any(
      (item) => item.toLowerCase() == tag.toLowerCase(),
    );
    if (exists) {
      _controller.clear();
      setState(() => _keyword = '');
      return;
    }
    widget.onChanged([...widget.selectedTags, tag]);
    _controller.clear();
    setState(() => _keyword = '');
  }

  void _removeTag(String tag) {
    widget.onChanged(
      widget.selectedTags.where((item) => item != tag).toList(growable: false),
    );
  }

  List<String> get _matchedSuggestions {
    final keyword = _keyword.trim().toLowerCase();
    return widget.suggestions
        .where((tag) => tag.trim().isNotEmpty)
        .where(
          (tag) => !widget.selectedTags.any(
            (item) => item.toLowerCase() == tag.toLowerCase(),
          ),
        )
        .where((tag) => keyword.isEmpty || tag.toLowerCase().contains(keyword))
        .take(8)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final matches = _matchedSuggestions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.sell_outlined),
            suffixIcon: _keyword.trim().isNotEmpty
                ? IconButton(
                    tooltip: '添加标签',
                    icon: const Icon(Icons.add),
                    onPressed: () => _addTag(_controller.text),
                  )
                : null,
          ),
          textInputAction: TextInputAction.done,
          onChanged: (value) => setState(() => _keyword = value),
          onSubmitted: _addTag,
        ),
        if (widget.selectedTags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.selectedTags
                .map(
                  (tag) =>
                      Chip(label: Text(tag), onDeleted: () => _removeTag(tag)),
                )
                .toList(growable: false),
          ),
        ],
        if (matches.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: matches
                .map(
                  (tag) => ActionChip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    onPressed: () => _addTag(tag),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ],
    );
  }
}
