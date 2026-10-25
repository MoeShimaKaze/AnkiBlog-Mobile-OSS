import 'package:ankiblog_mobile/presentation/pages/admin/outfit/outfit_list_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/outfit/outfit_detail_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/outfit/outfit_form_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/outfit/daily_outfit_manage_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/makeup/makeup_list_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/makeup/makeup_detail_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/makeup/makeup_form_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/todo/todo_lists_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/todo/todo_list_detail_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/todo/todo_item_form_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/todo/todo_smart_list_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/goal/goals_list_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/goal/goal_detail_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/goal/goal_form_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/wardrobe/wardrobe_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/cosmetics/cosmetics_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/purchase/purchase_list_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/accounting/accounting_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/dashboard/dashboard_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/article/article_list_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/article/article_edit_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/product/product_manage_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/product/product_edit_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/product/product_category_manage_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/comment/comment_manage_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/user/user_manage_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/site/site_config_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/site/background_manage_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/site/friend_link_manage_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/site/social_link_manage_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/page/page_type_manage_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/page/custom_page_manage_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/page/custom_page_edit_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/notification/notification_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/subscription/subscription_manage_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/system/cache_manage_page.dart';
import 'package:ankiblog_mobile/presentation/pages/admin/system/file_manage_page.dart';
import 'package:ankiblog_mobile/presentation/pages/discover/discover_page.dart';
import 'package:ankiblog_mobile/presentation/pages/home/home_page.dart';
import 'package:ankiblog_mobile/presentation/pages/main_shell.dart';
import 'package:ankiblog_mobile/presentation/pages/message/message_page.dart';
import 'package:ankiblog_mobile/presentation/pages/placeholders/create_page.dart';
import 'package:ankiblog_mobile/presentation/pages/profile/login_page.dart';
import 'package:ankiblog_mobile/presentation/pages/profile/profile_page.dart';
import 'package:ankiblog_mobile/presentation/pages/profile/register_page.dart';
import 'package:ankiblog_mobile/presentation/pages/profile/settings_page.dart';
import 'package:ankiblog_mobile/presentation/pages/profile/user_info_page.dart';
import 'package:ankiblog_mobile/presentation/pages/profile/my_comments_page.dart';
import 'package:ankiblog_mobile/presentation/pages/profile/my_likes_page.dart';
import 'package:ankiblog_mobile/presentation/pages/profile/my_favorites_page.dart';
import 'package:ankiblog_mobile/presentation/pages/public/article_detail_page.dart';
import 'package:ankiblog_mobile/presentation/pages/public/custom_pages_page.dart';
import 'package:ankiblog_mobile/presentation/pages/public/custom_page_detail_page.dart';
import 'package:ankiblog_mobile/presentation/pages/public/daily_outfit_page.dart';
import 'package:ankiblog_mobile/presentation/pages/public/makeups_page.dart';
import 'package:ankiblog_mobile/presentation/pages/public/outfit_detail_page.dart';
import 'package:ankiblog_mobile/presentation/pages/public/outfits_page.dart';
import 'package:ankiblog_mobile/presentation/pages/public/product_detail_page.dart';
import 'package:ankiblog_mobile/presentation/pages/public/search_page.dart';
import 'package:ankiblog_mobile/presentation/pages/public/todos_page.dart';
import 'package:ankiblog_mobile/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthRoute = path == '/login' || path == '/register';
      final requiresAuth =
          path.startsWith('/user/') ||
          path == '/settings' ||
          path.startsWith('/admin/');

      if (authState.isLoading) return null;
      if (!authState.isAuthenticated && requiresAuth) {
        return '/login';
      }
      if (authState.isAuthenticated && isAuthRoute) {
        return '/profile';
      }
      if (path.startsWith('/admin/') && !authState.isAdmin) {
        return '/profile';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/discover',
            builder: (context, state) => const DiscoverPage(),
          ),
          GoRoute(
            path: '/articles',
            builder: (context, state) => const DiscoverPage(initialIndex: 0),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const DiscoverPage(initialIndex: 1),
          ),
          GoRoute(
            path: '/friends',
            builder: (context, state) => const DiscoverPage(initialIndex: 3),
          ),
          GoRoute(
            path: '/social-links',
            builder: (context, state) => const DiscoverPage(initialIndex: 3),
          ),
          GoRoute(
            path: '/create',
            builder: (context, state) => const CreatePage(),
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const MessagePage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/articles/:slug',
        builder: (context, state) =>
            ArticleDetailPage(slug: state.pathParameters['slug'] ?? ''),
      ),
      GoRoute(
        path: '/products/:slug',
        builder: (context, state) =>
            ProductDetailPage(slug: state.pathParameters['slug'] ?? ''),
      ),
      GoRoute(
        path: '/pages',
        builder: (context, state) => const CustomPagesPage(),
      ),
      GoRoute(
        path: '/pages/:slug',
        builder: (context, state) =>
            CustomPageDetailPage(slug: state.pathParameters['slug'] ?? ''),
      ),
      GoRoute(
        path: '/daily-outfit',
        builder: (context, state) => const DailyOutfitPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/user/info',
        builder: (context, state) => const UserInfoPage(),
      ),
      GoRoute(
        path: '/user/comments',
        builder: (context, state) => const MyCommentsPage(),
      ),
      GoRoute(
        path: '/user/likes',
        builder: (context, state) => const MyLikesPage(),
      ),
      GoRoute(
        path: '/user/favorites',
        builder: (context, state) => const MyFavoritesPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(path: '/todos', builder: (context, state) => const TodosPage()),
      GoRoute(
        path: '/outfits',
        builder: (context, state) => const OutfitsPage(),
      ),
      GoRoute(
        path: '/outfits/:id',
        builder: (context, state) =>
            OutfitDetailPage(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/makeups',
        builder: (context, state) => const MakeupsPage(),
      ),
      GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
      // Admin routes
      GoRoute(
        path: '/admin/outfits',
        builder: (context, state) => const AdminOutfitListPage(),
      ),
      GoRoute(
        path: '/admin/outfits/create',
        builder: (context, state) => const AdminOutfitFormPage(),
      ),
      GoRoute(
        path: '/admin/daily-outfit',
        builder: (context, state) => const DailyOutfitManagePage(),
      ),
      GoRoute(
        path: '/admin/outfits/:id',
        builder: (context, state) =>
            AdminOutfitDetailPage(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/admin/makeups',
        builder: (context, state) => const AdminMakeupListPage(),
      ),
      GoRoute(
        path: '/admin/makeups/create',
        builder: (context, state) => const AdminMakeupFormPage(),
      ),
      GoRoute(
        path: '/admin/makeups/:id',
        builder: (context, state) =>
            AdminMakeupDetailPage(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/admin/todos',
        builder: (context, state) => const AdminTodoListsPage(),
      ),
      GoRoute(
        path: '/admin/todos/create',
        builder: (context, state) => const AdminTodoItemFormPage(),
      ),
      GoRoute(
        path: '/admin/todos/lists/:id',
        builder: (context, state) =>
            AdminTodoListDetailPage(listId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/admin/todos/smart/my-day',
        builder: (context, state) =>
            const AdminTodoSmartListPage(type: SmartListType.myDay),
      ),
      GoRoute(
        path: '/admin/todos/smart/important',
        builder: (context, state) =>
            const AdminTodoSmartListPage(type: SmartListType.important),
      ),
      GoRoute(
        path: '/admin/todos/smart/planned',
        builder: (context, state) =>
            const AdminTodoSmartListPage(type: SmartListType.planned),
      ),
      GoRoute(
        path: '/admin/goals',
        builder: (context, state) => const AdminGoalsListPage(),
      ),
      GoRoute(
        path: '/admin/goals/create',
        builder: (context, state) => const AdminGoalFormPage(),
      ),
      GoRoute(
        path: '/admin/goals/:id',
        builder: (context, state) =>
            AdminGoalDetailPage(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/admin/wardrobe',
        builder: (context, state) => const AdminWardrobePage(),
      ),
      GoRoute(
        path: '/admin/cosmetics',
        builder: (context, state) => const AdminCosmeticsPage(),
      ),
      GoRoute(
        path: '/admin/purchases',
        builder: (context, state) => const AdminPurchaseListPage(),
      ),
      GoRoute(
        path: '/admin/accounting',
        builder: (context, state) => const AdminAccountingPage(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/admin/articles',
        builder: (context, state) => const ArticleListPage(),
      ),
      GoRoute(
        path: '/admin/articles/create',
        builder: (context, state) => const ArticleEditPage(),
      ),
      GoRoute(
        path: '/admin/articles/edit/:id',
        builder: (context, state) =>
            ArticleEditPage(articleId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/admin/products',
        builder: (context, state) => const ProductManagePage(),
      ),
      GoRoute(
        path: '/admin/products/create',
        builder: (context, state) => const ProductEditPage(),
      ),
      GoRoute(
        path: '/admin/products/edit/:id',
        builder: (context, state) =>
            ProductEditPage(productId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/admin/product-categories',
        builder: (context, state) => const ProductCategoryManagePage(),
      ),
      GoRoute(
        path: '/admin/comments',
        builder: (context, state) => const CommentManagePage(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserManagePage(),
      ),
      GoRoute(
        path: '/admin/site',
        builder: (context, state) => const SiteConfigPage(),
      ),
      GoRoute(
        path: '/admin/backgrounds',
        builder: (context, state) => const BackgroundManagePage(),
      ),
      GoRoute(
        path: '/admin/friend-links',
        builder: (context, state) => const FriendLinkManagePage(),
      ),
      GoRoute(
        path: '/admin/social-links',
        builder: (context, state) => const SocialLinkManagePage(),
      ),
      GoRoute(
        path: '/admin/pages',
        builder: (context, state) => const PageTypeManagePage(),
      ),
      GoRoute(
        path: '/admin/custom-pages',
        builder: (context, state) => const CustomPageManagePage(),
      ),
      GoRoute(
        path: '/admin/custom-pages/create',
        builder: (context, state) => const CustomPageEditPage(),
      ),
      GoRoute(
        path: '/admin/custom-pages/edit/:id',
        builder: (context, state) =>
            CustomPageEditPage(pageId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/admin/notifications',
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: '/admin/subscriptions',
        builder: (context, state) => const SubscriptionManagePage(),
      ),
      GoRoute(
        path: '/admin/cache',
        builder: (context, state) => const CacheManagePage(),
      ),
      GoRoute(
        path: '/admin/files',
        builder: (context, state) => const FileManagePage(),
      ),
    ],
  );
});
