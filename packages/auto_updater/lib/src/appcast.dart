import 'package:json_annotation/json_annotation.dart';

part 'appcast.g.dart';

@JsonSerializable()
class Appcast {
  const Appcast({
    required this.items,
  });

  factory Appcast.fromJson(Map<String, dynamic> json) {
    json['items'] = (json['items'] as List)
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
    return _$AppcastFromJson(json);
  }

  final List<AppcastItem> items;

  Map<String, dynamic> toJson() => _$AppcastToJson(this);
}

@JsonSerializable()
class AppcastItem {
  const AppcastItem({
    this.versionString,
    this.displayVersionString,
    this.fileURL,
    this.contentLength,
    this.infoURL,
    this.title,
    this.dateString,
    this.releaseNotesURL,
    this.itemDescription,
    this.itemDescriptionFormat,
    this.fullReleaseNotesURL,
    this.minimumSystemVersion,
    this.minimumOperatingSystemVersionIsOK,
    this.maximumSystemVersion,
    this.maximumOperatingSystemVersionIsOK,
    this.channel,
    this.criticalUpdate,
    this.os,
  });

  factory AppcastItem.fromJson(Map<String, dynamic> json) =>
      _$AppcastItemFromJson(json);

  final String? versionString;
  final String? displayVersionString;
  final String? fileURL;
  final int? contentLength;
  final String? infoURL;
  final String? title;
  final String? dateString;
  final String? releaseNotesURL;
  final String? itemDescription;
  final String? itemDescriptionFormat;
  final String? fullReleaseNotesURL;
  final String? minimumSystemVersion;
  final bool? minimumOperatingSystemVersionIsOK;
  final String? maximumSystemVersion;
  final bool? maximumOperatingSystemVersionIsOK;
  final String? channel;
  final bool? criticalUpdate;
  final String? os;

  Map<String, dynamic> toJson() => _$AppcastItemToJson(this);
}
