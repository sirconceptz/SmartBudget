import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:smart_budget/utils/my_logger.dart';

class MockPackageInfo extends Mock implements PackageInfo {}

class MockPathProvider extends PathProviderPlatform {
  @override
  Future<String> getApplicationDocumentsPath() async {
    return Directory.systemTemp.path; // Używamy tymczasowego katalogu
  }
}

void main() {
  setUpAll(() {
    PathProviderPlatform.instance = MockPathProvider();
  });

  test('should write log to file', () async {
    final mockPackageInfo = MockPackageInfo();
    when(() => mockPackageInfo.version).thenReturn("1.0.0");

    PackageInfo.setMockInitialValues(
      appName: 'SmartBudget',
      packageName: 'com.roundbyte.smartbudget',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );

    await MyLogger.write("TEST_TAG", "Test message");

    final tempDir = Directory.systemTemp;
    final logFile = File('${tempDir.path}/SMART_BUDGET_LOG1.0.0.txt');

    expect(await logFile.exists(), isTrue);
    final logContent = await logFile.readAsString();
    expect(logContent.contains("TEST_TAG"), isTrue);
    expect(logContent.contains("Test message"), isTrue);
  });

  test('should return correct file path', () async {
    final logger = MyLogger();
    final filePath = await logger.getFileUri();

    expect(filePath, isNotNull);
    expect(filePath!.contains("SMART_BUDGET_LOG"), isTrue);
  });
}
