import 'package:hive/hive.dart';

part 'document.g.dart';

@HiveType(typeId: 1)
class Document {
  @HiveField(0)
  final String filePath;

  @HiveField(1)
  final String type;

  Document({
    required this.filePath,
    required this.type,
  });
}
