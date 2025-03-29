// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appcast _$AppcastFromJson(Map<String, dynamic> json) => Appcast(
      items: (json['items'] as List<dynamic>)
          .map((e) => AppcastItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AppcastToJson(Appcast instance) => <String, dynamic>{
      'items': instance.items,
    };

AppcastItem _$AppcastItemFromJson(Map<String, dynamic> json) => AppcastItem(
      versionString: json['versionString'] as String?,
      displayVersionString: json['displayVersionString'] as String?,
      fileURL: json['fileURL'] as String?,
      contentLength: (json['contentLength'] as num?)?.toInt(),
      infoURL: json['infoURL'] as String?,
      title: json['title'] as String?,
      dateString: json['dateString'] as String?,
      releaseNotesURL: json['releaseNotesURL'] as String?,
      itemDescription: json['itemDescription'] as String?,
      itemDescriptionFormat: json['itemDescriptionFormat'] as String?,
      fullReleaseNotesURL: json['fullReleaseNotesURL'] as String?,
      minimumSystemVersion: json['minimumSystemVersion'] as String?,
      minimumOperatingSystemVersionIsOK:
          json['minimumOperatingSystemVersionIsOK'] as bool?,
      maximumSystemVersion: json['maximumSystemVersion'] as String?,
      maximumOperatingSystemVersionIsOK:
          json['maximumOperatingSystemVersionIsOK'] as bool?,
      channel: json['channel'] as String?,
      criticalUpdate: json['criticalUpdate'] as bool?,
      os: json['os'] as String?,
    );

Map<String, dynamic> _$AppcastItemToJson(AppcastItem instance) =>
    <String, dynamic>{
      'versionString': instance.versionString,
      'displayVersionString': instance.displayVersionString,
      'fileURL': instance.fileURL,
      'contentLength': instance.contentLength,
      'infoURL': instance.infoURL,
      'title': instance.title,
      'dateString': instance.dateString,
      'releaseNotesURL': instance.releaseNotesURL,
      'itemDescription': instance.itemDescription,
      'itemDescriptionFormat': instance.itemDescriptionFormat,
      'fullReleaseNotesURL': instance.fullReleaseNotesURL,
      'minimumSystemVersion': instance.minimumSystemVersion,
      'minimumOperatingSystemVersionIsOK':
          instance.minimumOperatingSystemVersionIsOK,
      'maximumSystemVersion': instance.maximumSystemVersion,
      'maximumOperatingSystemVersionIsOK':
          instance.maximumOperatingSystemVersionIsOK,
      'channel': instance.channel,
      'criticalUpdate': instance.criticalUpdate,
      'os': instance.os,
    };
