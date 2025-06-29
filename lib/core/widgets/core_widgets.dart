/// Core widgets export file
///
/// Exports all core UI components for easy importing throughout the application.
/// These widgets are built using the new state management architecture.

// === Message Operation Widgets ===
export 'message_operation_widget.dart';
export 'modern_batch_operations_widget.dart';

// === Search Widgets ===
export 'search_bar_widget.dart';

// === Core UI Components ===
/// Modern message operation widget for handling message actions
/// Provides edit, delete, copy, regenerate, and other message operations
/// with progress indicators and error handling.

/// Modern batch operations widget for handling multiple message operations
/// Supports batch delete, copy, export, translate, and mark operations
/// with progress tracking and selection management.

/// Search bar widget for content search functionality
/// Provides search input, options, navigation controls, and result preview
/// with support for regex, case sensitivity, and filtering options.

/// Usage Examples:
///
/// ```dart
/// // Message operations
/// MessageOperationWidget(
///   message: message,
///   isLastMessage: true,
///   showOnHover: true,
/// )
///
/// // Batch operations
/// ModernBatchOperationsWidget(
///   messages: messages,
///   onClose: () => print('Batch mode closed'),
/// )
///
/// // Search functionality
/// SearchBarWidget(
///   onResultSelected: (result) => navigateToMessage(result.messageId),
///   onClose: () => print('Search closed'),
/// )
/// ```
///
/// All widgets are built with:
/// - Material Design 3 principles
/// - Responsive design for different screen sizes
/// - Accessibility support
/// - Animation and micro-interactions
/// - Error handling and loading states
/// - Integration with the new state management architecture
