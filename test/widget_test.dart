import 'package:ankiblog_mobile/app.dart';
import 'package:ankiblog_mobile/data/models/public_content.dart';
import 'package:ankiblog_mobile/data/models/site_config.dart';
import 'package:ankiblog_mobile/presentation/providers/public_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('AnkiBlog app starts on the home shell', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          siteConfigProvider.overrideWith(
            (ref) async => const SiteConfig(
              siteName: 'AnkiBlog',
              siteTagline: '',
              siteDescription: '',
              heroTitle: 'AnkiBlog',
              heroSubtitle: '',
              logoUrl: null,
              ownerName: null,
              ownerAvatar: null,
              ownerBio: null,
            ),
          ),
          featuredArticlesProvider.overrideWith((ref) async => const []),
          featuredProductsProvider.overrideWith((ref) async => const []),
          publicTodosProvider.overrideWith((ref) async => const []),
          publicOutfitsProvider.overrideWith((ref) async => const []),
          publicMakeupsProvider.overrideWith((ref) async => const []),
          goalsSummaryProvider.overrideWith(
            (ref) async => const GoalsSummary(
              activeGoalCount: 0,
              totalCheckInDays: 0,
              maxCurrentStreak: 0,
              maxLongestStreak: 0,
              thisMonthCheckIns: 0,
              unlockedMilestoneCount: 0,
              totalMilestoneCount: 0,
            ),
          ),
        ],
        child: const AnkiBlogApp(),
      ),
    );
    await tester.pump();

    expect(find.text('首页'), findsOneWidget);
    expect(find.text('发现'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
  });
}
