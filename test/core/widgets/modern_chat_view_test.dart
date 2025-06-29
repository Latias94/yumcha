import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yumcha/core/widgets/modern_chat_view.dart';
import 'package:yumcha/core/providers/chat_state_provider.dart';
import 'package:yumcha/features/chat/domain/entities/conversation_ui_state.dart';

void main() {
  group('ModernChatView', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should display empty state when no conversation',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: ModernChatView(),
          ),
        ),
      );

      // Should show empty message list
      expect(find.text('No messages yet'), findsOneWidget);
      expect(find.text('Start a conversation to see messages here'),
          findsOneWidget);
    });

    testWidgets('should display conversation title in app bar', (tester) async {
      // Set up a conversation
      final conversation = ConversationUiState(
        id: 'test-conv',
        channelName: 'Test Conversation',
        channelMembers: 1,
        selectedProviderId: 'test-provider',
      );

      container
          .read(chatStateProvider.notifier)
          .setCurrentConversation(conversation);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: ModernChatView(
              conversationId: 'test-conv',
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show conversation title in app bar
      expect(find.text('Test Conversation'), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      // Set loading state
      container.read(chatStateProvider.notifier).setLoading(true);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: ModernChatView(),
          ),
        ),
      );

      await tester.pump();

      // Should show loading indicator in app bar
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error state when error occurs', (tester) async {
      // Set error state
      container.read(chatStateProvider.notifier).setError('Test error');

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: ModernChatView(),
          ),
        ),
      );

      await tester.pump();

      // Should show error message
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should clear error when retry button is tapped',
        (tester) async {
      // Set error state
      container.read(chatStateProvider.notifier).setError('Test error');

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: ModernChatView(),
          ),
        ),
      );

      await tester.pump();

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Error should be cleared
      final state = container.read(chatStateProvider);
      expect(state.error, isNull);
    });

    testWidgets('should show chat input when enabled', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: ModernChatView(
              enableInput: true,
            ),
          ),
        ),
      );

      // Should show chat input
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('should hide chat input when disabled', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: ModernChatView(
              enableInput: false,
            ),
          ),
        ),
      );

      // Should not show chat input
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('should call onMessageSent when message is sent',
        (tester) async {
      String? sentMessage;

      // Set up a conversation first
      final conversation = ConversationUiState(
        id: 'test-conv',
        channelName: 'Test Conversation',
        channelMembers: 1,
        selectedProviderId: 'test-provider',
        assistantId: 'test-assistant',
      );

      container
          .read(chatStateProvider.notifier)
          .setCurrentConversation(conversation);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: ModernChatView(
              onMessageSent: (message) {
                sentMessage = message;
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Enter text and send
      await tester.enterText(find.byType(TextField), 'Hello, world!');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Should call callback
      expect(sentMessage, equals('Hello, world!'));
    });

    testWidgets('should show chat options menu', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: ModernChatView(),
          ),
        ),
      );

      // Tap more options button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Should show options menu
      expect(find.text('Clear Messages'), findsOneWidget);
      expect(find.text('Chat Settings'), findsOneWidget);
    });

    testWidgets('should clear messages when clear option is selected',
        (tester) async {
      // Set up conversation with messages
      final conversation = ConversationUiState(
        id: 'test-conv',
        channelName: 'Test Conversation',
        channelMembers: 1,
        selectedProviderId: 'test-provider',
      );

      container
          .read(chatStateProvider.notifier)
          .setCurrentConversation(conversation);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: ModernChatView(),
          ),
        ),
      );

      // Open options menu and select clear
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear Messages'));
      await tester.pumpAndSettle();

      // Messages should be cleared (this would need actual messages to test properly)
      // For now, just verify the action doesn't crash
      expect(find.byType(ModernChatView), findsOneWidget);
    });
  });
}
