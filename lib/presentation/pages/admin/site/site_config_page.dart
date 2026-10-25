import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/image_upload_field.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SiteConfigPage extends ConsumerStatefulWidget {
  const SiteConfigPage({super.key});

  @override
  ConsumerState<SiteConfigPage> createState() => _SiteConfigPageState();
}

class _SiteConfigPageState extends ConsumerState<SiteConfigPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = false;
  bool _initialLoading = true;
  String? _error;

  // 基础信息
  final _siteNameCtrl = TextEditingController();
  final _siteTaglineCtrl = TextEditingController();
  final _siteDescCtrl = TextEditingController();
  final _siteUrlCtrl = TextEditingController();
  final _domainCtrl = TextEditingController();
  final _siteKeywordsCtrl = TextEditingController();
  final _siteLanguageCtrl = TextEditingController();
  final _timezoneCtrl = TextEditingController();

  // 站长信息
  final _ownerNameCtrl = TextEditingController();
  final _ownerBioCtrl = TextEditingController();
  final _ownerProfessionCtrl = TextEditingController();
  final _ownerCompanyCtrl = TextEditingController();
  final _ownerLocationCtrl = TextEditingController();
  final _contactEmailCtrl = TextEditingController();
  String? _ownerAvatar;

  // 显示设置
  String? _logoUrl;
  String? _faviconUrl;
  String? _defaultShareImage;
  String _themeColor = '#000000';
  final _heroTitleCtrl = TextEditingController();
  final _heroSubtitleCtrl = TextEditingController();
  final _excerptLengthCtrl = TextEditingController();
  final _homepagePostCountCtrl = TextEditingController();

  // 功能设置
  bool _commentsEnabled = true;
  bool _commentModeration = false;
  bool _allowGuestComments = false;
  bool _enableSubscriptionService = false;
  bool _enableUserSubscriptions = false;
  bool _enableGuestSubscriptions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _siteNameCtrl.dispose();
    _siteTaglineCtrl.dispose();
    _siteDescCtrl.dispose();
    _siteUrlCtrl.dispose();
    _domainCtrl.dispose();
    _siteKeywordsCtrl.dispose();
    _siteLanguageCtrl.dispose();
    _timezoneCtrl.dispose();
    _ownerNameCtrl.dispose();
    _ownerBioCtrl.dispose();
    _ownerProfessionCtrl.dispose();
    _ownerCompanyCtrl.dispose();
    _ownerLocationCtrl.dispose();
    _contactEmailCtrl.dispose();
    _heroTitleCtrl.dispose();
    _heroSubtitleCtrl.dispose();
    _excerptLengthCtrl.dispose();
    _homepagePostCountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(adminRepositoryProvider).getSiteProfile();
      setState(() {
        _siteNameCtrl.text = profile.siteName ?? '';
        _siteTaglineCtrl.text = profile.siteTagline ?? '';
        _siteDescCtrl.text = profile.siteDescription ?? '';
        _siteUrlCtrl.text = profile.siteUrl ?? '';
        _domainCtrl.text = profile.domain ?? '';
        _siteKeywordsCtrl.text = profile.siteKeywords ?? '';
        _siteLanguageCtrl.text = profile.siteLanguage ?? '';
        _timezoneCtrl.text = profile.timezone ?? '';
        _ownerNameCtrl.text = profile.ownerName ?? '';
        _ownerBioCtrl.text = profile.ownerBio ?? '';
        _ownerProfessionCtrl.text = profile.ownerProfession ?? '';
        _ownerCompanyCtrl.text = profile.ownerCompany ?? '';
        _ownerLocationCtrl.text = profile.ownerLocation ?? '';
        _contactEmailCtrl.text = profile.contactEmail ?? '';
        _ownerAvatar = profile.ownerAvatar;
        _logoUrl = profile.logoUrl;
        _faviconUrl = profile.faviconUrl;
        _defaultShareImage = profile.defaultShareImage;
        _themeColor = profile.themeColor ?? '#000000';
        _heroTitleCtrl.text = profile.heroTitle ?? '';
        _heroSubtitleCtrl.text = profile.heroSubtitle ?? '';
        _excerptLengthCtrl.text = profile.excerptLength != null
            ? '${profile.excerptLength}'
            : '';
        _homepagePostCountCtrl.text = profile.homepagePostCount != null
            ? '${profile.homepagePostCount}'
            : '';
        _commentsEnabled = profile.commentsEnabled;
        _commentModeration = profile.commentModeration;
        _allowGuestComments = profile.allowGuestComments;
        _enableSubscriptionService = profile.enableSubscriptionService;
        _enableUserSubscriptions = profile.enableUserSubscriptions;
        _enableGuestSubscriptions = profile.enableGuestSubscriptions;
        _initialLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _initialLoading = false;
      });
    }
  }

  Map<String, dynamic> _buildBody() {
    final body = <String, dynamic>{
      'siteName': _siteNameCtrl.text.trim(),
      'siteTagline': _siteTaglineCtrl.text.trim(),
      'siteDescription': _siteDescCtrl.text.trim(),
      'siteUrl': _siteUrlCtrl.text.trim(),
      'domain': _domainCtrl.text.trim(),
      'siteKeywords': _siteKeywordsCtrl.text.trim(),
      'siteLanguage': _siteLanguageCtrl.text.trim(),
      'timezone': _timezoneCtrl.text.trim(),
      'ownerName': _ownerNameCtrl.text.trim(),
      'ownerBio': _ownerBioCtrl.text.trim(),
      'ownerProfession': _ownerProfessionCtrl.text.trim(),
      'ownerCompany': _ownerCompanyCtrl.text.trim(),
      'ownerLocation': _ownerLocationCtrl.text.trim(),
      'contactEmail': _contactEmailCtrl.text.trim(),
      'themeColor': _themeColor,
      'heroTitle': _heroTitleCtrl.text.trim(),
      'heroSubtitle': _heroSubtitleCtrl.text.trim(),
      'commentsEnabled': _commentsEnabled,
      'commentModeration': _commentModeration,
      'allowGuestComments': _allowGuestComments,
      'enableSubscriptionService': _enableSubscriptionService,
      'enableUserSubscriptions': _enableUserSubscriptions,
      'enableGuestSubscriptions': _enableGuestSubscriptions,
    };
    if (_ownerAvatar != null && _ownerAvatar!.isNotEmpty) {
      body['ownerAvatar'] = _ownerAvatar;
    }
    if (_logoUrl != null && _logoUrl!.isNotEmpty) body['logoUrl'] = _logoUrl;
    if (_faviconUrl != null && _faviconUrl!.isNotEmpty) {
      body['faviconUrl'] = _faviconUrl;
    }
    if (_defaultShareImage != null && _defaultShareImage!.isNotEmpty) {
      body['defaultShareImage'] = _defaultShareImage;
    }
    final excerptLen = int.tryParse(_excerptLengthCtrl.text.trim());
    if (excerptLen != null) body['excerptLength'] = excerptLen;
    final postCount = int.tryParse(_homepagePostCountCtrl.text.trim());
    if (postCount != null) body['homepagePostCount'] = postCount;
    return body;
  }

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Send verification code first
      await ref.read(adminRepositoryProvider).sendSiteUpdateCode();

      if (!mounted) return;

      // Show verification code dialog
      final codeCtrl = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('验证操作'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('验证码已发送到管理员邮箱，请输入验证码以保存配置。'),
              const SizedBox(height: 16),
              TextField(
                controller: codeCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '验证码',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确认保存'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        setState(() => _loading = false);
        return;
      }

      final body = _buildBody();
      final code = codeCtrl.text.trim();
      if (code.isNotEmpty) {
        body['verificationCode'] = code;
      }

      await ref.read(adminRepositoryProvider).updateSiteProfile(body);

      if (mounted) {
        ref.invalidate(siteProfileProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('站点配置已保存')));
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('站点配置'),
        actions: [
          if (!_initialLoading)
            TextButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '基础信息'),
            Tab(text: '站长信息'),
            Tab(text: '显示设置'),
            Tab(text: '功能设置'),
          ],
        ),
      ),
      body: _buildBody2(),
    );
  }

  Widget _buildBody2() {
    if (_initialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _siteNameCtrl.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadProfile, child: const Text('重试')),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildBasicInfoTab(),
        _buildOwnerInfoTab(),
        _buildDisplayTab(),
        _buildFeatureTab(),
      ],
    );
  }

  Widget _buildBasicInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _field(_siteNameCtrl, '站点名称', required: true),
        _field(_siteTaglineCtrl, '站点标语'),
        _field(_siteDescCtrl, '站点描述', maxLines: 3),
        _field(_siteUrlCtrl, '站点 URL', hint: 'https://example.com'),
        _field(_domainCtrl, '域名', hint: 'example.com'),
        _field(_siteKeywordsCtrl, '关键词', hint: '用逗号分隔'),
        _field(_siteLanguageCtrl, '语言', hint: 'zh-CN'),
        _field(_timezoneCtrl, '时区', hint: 'Asia/Shanghai'),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildOwnerInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _field(_ownerNameCtrl, '站长名称'),
        const SizedBox(height: 16),
        Text('站长头像', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        SingleImageUploadField(
          initialUrl: _ownerAvatar,
          height: 120,
          label: '上传头像',
          onChanged: (url) => setState(() => _ownerAvatar = url),
        ),
        const SizedBox(height: 16),
        _field(_ownerBioCtrl, '个人简介', maxLines: 3),
        _field(_ownerProfessionCtrl, '职业'),
        _field(_ownerCompanyCtrl, '公司/组织'),
        _field(_ownerLocationCtrl, '所在地'),
        _field(
          _contactEmailCtrl,
          '联系邮箱',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildDisplayTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Logo', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        SingleImageUploadField(
          initialUrl: _logoUrl,
          height: 120,
          label: '上传 Logo',
          onChanged: (url) => setState(() => _logoUrl = url),
        ),
        const SizedBox(height: 16),
        Text('Favicon', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        SingleImageUploadField(
          initialUrl: _faviconUrl,
          height: 80,
          label: '上传 Favicon',
          onChanged: (url) => setState(() => _faviconUrl = url),
        ),
        const SizedBox(height: 16),
        Text('默认分享图', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        SingleImageUploadField(
          initialUrl: _defaultShareImage,
          height: 120,
          label: '上传分享图',
          onChanged: (url) => setState(() => _defaultShareImage = url),
        ),
        const SizedBox(height: 16),
        Text('主题色', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        _buildColorPicker(),
        const SizedBox(height: 16),
        _field(_heroTitleCtrl, '首页标题'),
        _field(_heroSubtitleCtrl, '首页副标题'),
        _field(
          _excerptLengthCtrl,
          '摘要长度',
          hint: '150',
          keyboardType: TextInputType.number,
        ),
        _field(
          _homepagePostCountCtrl,
          '首页文章数',
          hint: '10',
          keyboardType: TextInputType.number,
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildFeatureTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('评论设置', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('启用评论'),
          value: _commentsEnabled,
          onChanged: (v) => setState(() => _commentsEnabled = v),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('评论审核'),
          subtitle: const Text('新评论需要管理员审核后才显示'),
          value: _commentModeration,
          onChanged: (v) => setState(() => _commentModeration = v),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('允许游客评论'),
          value: _allowGuestComments,
          onChanged: (v) => setState(() => _allowGuestComments = v),
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(height: 32),
        Text('订阅设置', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('启用订阅服务'),
          value: _enableSubscriptionService,
          onChanged: (v) => setState(() => _enableSubscriptionService = v),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('用户订阅'),
          value: _enableUserSubscriptions,
          onChanged: (v) => setState(() => _enableUserSubscriptions = v),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('游客订阅'),
          value: _enableGuestSubscriptions,
          onChanged: (v) => setState(() => _enableGuestSubscriptions = v),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    int maxLines = 1,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: required
            ? (v) => v == null || v.trim().isEmpty ? '请输入$label' : null
            : null,
      ),
    );
  }

  Widget _buildColorPicker() {
    const colors = [
      '#000000',
      '#1a1a2e',
      '#16213e',
      '#0f3460',
      '#533483',
      '#e94560',
      '#ff6b6b',
      '#ffa502',
      '#2ed573',
      '#1e90ff',
      '#3742fa',
      '#70a1ff',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((c) {
        final selected = _themeColor == c;
        final color = Color(int.parse(c.replaceFirst('#', '0xff')));
        return GestureDetector(
          onTap: () => setState(() => _themeColor = c),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    )
                  : null,
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
