import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/community/data/community.dart';
import 'package:farm2fork_mobile/features/community/presentation/screens/create_post_screen.dart';
import 'package:farm2fork_mobile/features/community/presentation/screens/post_detail_screen.dart';
import 'package:farm2fork_mobile/features/feed/presentation/screens/feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

class _Farmer extends AuthController {
  @override
  Future<AuthState> build() async => const AuthState(
    status: AuthStatus.authenticated,
    user: AuthUser(
      id: 'mock_farmer_001',
      email: 'farmer@example.com',
      role: AppUserRole.farmer,
      isVerified: true,
      isActive: true,
    ),
  );
}

void main() {
  testWidgets('feed shows posts with their kind, likes and comments', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const FeedScreen(),
      overrides: [
        communityRepositoryProvider.overrideWithValue(
          MockCommunityRepository(),
        ),
        authControllerProvider.overrideWith(_Farmer.new),
      ],
    );
    expect(
      find.text('Best time to sow wheat in South Punjab?'),
      findsOneWidget,
    );
    expect(find.text('Green Valley Farm'), findsOneWidget);
    expect(find.text('Question'), findsWidgets);
    expect(find.text('#wheat'), findsOneWidget);
    expect(find.text('New post'), findsOneWidget);
  });

  testWidgets('liking a post updates the count at once', (tester) async {
    final repo = MockCommunityRepository();
    await pumpScreen(
      tester,
      const FeedScreen(),
      overrides: [
        communityRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(_Farmer.new),
      ],
    );
    expect(find.text('4'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget);
    expect((await repo.post('post_1')).likedByMe, isTrue);
  });

  testWidgets('filtering by kind narrows the feed', (tester) async {
    await pumpScreen(
      tester,
      const FeedScreen(),
      overrides: [
        communityRepositoryProvider.overrideWithValue(
          MockCommunityRepository(),
        ),
        authControllerProvider.overrideWith(_Farmer.new),
      ],
    );
    const tip = ValueKey('feed-kind-tip');
    await tester.dragUntilVisible(
      find.byKey(tip),
      find.text('All'),
      const Offset(-80, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(tip));
    await tester.pumpAndSettle();
    expect(find.text('Cool mangoes in shade before packing'), findsOneWidget);
    expect(
      find.text('Best time to sow wheat in South Punjab?'),
      findsNothing,
    );
  });

  testWidgets('a member can report another member\'s comment', (tester) async {
    final repo = MockCommunityRepository();
    await pumpScreen(
      tester,
      const PostDetailScreen(postId: 'post_1'),
      overrides: [
        communityRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(_Farmer.new),
      ],
    );
    await tester.tap(find.text('Report').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spam or advertising'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send report'));
    await tester.pumpAndSettle();
    expect(repo.reported, ['comment:c1:spam']);
    expect(find.text('Thanks. The team will review it.'), findsOneWidget);
  });

  testWidgets('publishing a post opens it', (tester) async {
    final repo = MockCommunityRepository();
    final visited = await pumpScreen(
      tester,
      const CreatePostScreen(),
      overrides: [communityRepositoryProvider.overrideWithValue(repo)],
    );
    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsNWidgets(2));

    await tester.enterText(find.byType(TextFormField).at(0), 'Kinnow ready');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Harvesting this week.',
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      '#Kinnow, harvest',
    );
    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();

    final post = (await repo.feed()).first;
    expect(post.title, 'Kinnow ready');
    expect(post.tags, ['kinnow', 'harvest']);
    expect(visited.last, AppNavConfig.postRoute(post.id));
  });

  testWidgets('commenting on a post adds it to the thread', (tester) async {
    final repo = MockCommunityRepository();
    await pumpScreen(
      tester,
      const PostDetailScreen(postId: 'post_1'),
      overrides: [
        communityRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(_Farmer.new),
      ],
    );
    expect(
      find.text('Early November worked well for our suppliers.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField).last, 'Thanks, will try!');
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();

    expect(find.text('Thanks, will try!'), findsOneWidget);
    // Own comment: a remove action is offered.
    expect(find.text('Remove'), findsWidgets);
  });
}
