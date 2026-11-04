import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a selected spreadsheet file ready for parsing.
class PickedSpreadsheetFile {
  final String fileName;
  final Uint8List bytes;

  const PickedSpreadsheetFile({
    required this.fileName,
    required this.bytes,
  });
}

/// Abstract contract for picking files. Enables seamless unit and widget testing.
abstract class FilePickerService {
  Future<PickedSpreadsheetFile?> pickSpreadsheetFile();
}

/// Provider for [FilePickerService].
final filePickerServiceProvider = Provider<FilePickerService>((ref) {
  return PlatformFilePickerService();
});

/// Default cross-platform implementation using `package:file_picker`.
class PlatformFilePickerService implements FilePickerService {
  @override
  Future<PickedSpreadsheetFile?> pickSpreadsheetFile() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
    );

    if (files.isEmpty) {
      return null;
    }

    final platformFile = files.first;
    final bytes = await platformFile.readAsBytes();

    if (bytes.isEmpty) {
      return null;
    }

    return PickedSpreadsheetFile(
      fileName: platformFile.name,
      bytes: bytes,
    );
  }
}
