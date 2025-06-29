#!/usr/bin/env dart

/// Test runner for YumCha core state management
///
/// This script runs all tests for the new core state management architecture
/// and provides detailed reporting on test results and coverage.

import 'dart:io';

void main(List<String> args) async {
  print('🚀 Running YumCha Core State Management Tests');
  print('=' * 50);

  final testSuites = [
    TestSuite(
      name: 'Chat State Provider Tests',
      path: 'test/core/providers/chat_state_provider_test.dart',
      description:
          'Tests for chat state management including conversations, messages, and status',
    ),
    TestSuite(
      name: 'Streaming State Provider Tests',
      path: 'test/core/providers/streaming_state_provider_test.dart',
      description: 'Tests for streaming message management and lifecycle',
    ),
    TestSuite(
      name: 'Deduplication Manager Tests',
      path: 'test/core/services/deduplication_manager_test.dart',
      description: 'Tests for request and event deduplication functionality',
    ),
  ];

  var totalTests = 0;
  var passedTests = 0;
  var failedTests = 0;
  final failedSuites = <String>[];

  for (final suite in testSuites) {
    print('\n📋 Running: ${suite.name}');
    print('   ${suite.description}');
    print('   Path: ${suite.path}');

    try {
      final result = await Process.run(
        'flutter',
        ['test', suite.path, '--reporter=expanded'],
        workingDirectory: Directory.current.path,
      );

      if (result.exitCode == 0) {
        print('   ✅ PASSED');

        // Parse test count from output
        final output = result.stdout.toString();
        final testCount = _parseTestCount(output);
        totalTests += testCount;
        passedTests += testCount;

        print('   📊 Tests: $testCount passed');
      } else {
        print('   ❌ FAILED');
        failedSuites.add(suite.name);

        // Parse test results from output
        final output = result.stdout.toString();
        final results = _parseTestResults(output);
        totalTests += results['total'] ?? 0;
        passedTests += results['passed'] ?? 0;
        failedTests += results['failed'] ?? 0;

        print(
            '   📊 Tests: ${results['passed']} passed, ${results['failed']} failed');
        print('   🔍 Error output:');
        print('   ${result.stderr.toString().replaceAll('\n', '\n   ')}');
      }
    } catch (e) {
      print('   💥 ERROR: Failed to run test suite');
      print('   $e');
      failedSuites.add(suite.name);
    }
  }

  // Summary
  print('\n' + '=' * 50);
  print('📊 TEST SUMMARY');
  print('=' * 50);
  print('Total Tests: $totalTests');
  print('Passed: $passedTests');
  print('Failed: $failedTests');
  print(
      'Success Rate: ${totalTests > 0 ? (passedTests / totalTests * 100).toStringAsFixed(1) : 0}%');

  if (failedSuites.isNotEmpty) {
    print('\n❌ Failed Test Suites:');
    for (final suite in failedSuites) {
      print('   • $suite');
    }
  }

  if (failedTests == 0) {
    print(
        '\n🎉 All tests passed! The new state management architecture is working correctly.');
    print('\n✅ Ready for migration:');
    print('   • Chat state management is stable');
    print('   • Streaming functionality is working');
    print('   • Deduplication is preventing duplicate operations');
    print('   • All core providers are functioning correctly');
  } else {
    print(
        '\n⚠️  Some tests failed. Please review and fix issues before proceeding with migration.');
  }

  // Coverage information
  print('\n📈 To run tests with coverage:');
  print('   flutter test --coverage');
  print('   genhtml coverage/lcov.info -o coverage/html');
  print('   open coverage/html/index.html');

  // Exit with appropriate code
  exit(failedTests > 0 ? 1 : 0);
}

class TestSuite {
  final String name;
  final String path;
  final String description;

  const TestSuite({
    required this.name,
    required this.path,
    required this.description,
  });
}

int _parseTestCount(String output) {
  // Simple parsing - look for "All tests passed!" or similar patterns
  final lines = output.split('\n');
  for (final line in lines) {
    if (line.contains('All tests passed!')) {
      // Try to extract number from previous lines
      final match = RegExp(r'(\d+) tests? passed').firstMatch(output);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    }
  }

  // Fallback: count test descriptions
  final testMatches = RegExp(r'✓ ').allMatches(output);
  return testMatches.length;
}

Map<String, int> _parseTestResults(String output) {
  var passed = 0;
  var failed = 0;

  // Count passed tests (✓)
  final passedMatches = RegExp(r'✓ ').allMatches(output);
  passed = passedMatches.length;

  // Count failed tests (✗)
  final failedMatches = RegExp(r'✗ ').allMatches(output);
  failed = failedMatches.length;

  return {
    'total': passed + failed,
    'passed': passed,
    'failed': failed,
  };
}
