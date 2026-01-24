// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApiAppSettings {

 String get defaultQuality; int get downloadConcurrent; String? get proxyUrl; String get themeMode; String get language;
/// Create a copy of ApiAppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiAppSettingsCopyWith<ApiAppSettings> get copyWith => _$ApiAppSettingsCopyWithImpl<ApiAppSettings>(this as ApiAppSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiAppSettings&&(identical(other.defaultQuality, defaultQuality) || other.defaultQuality == defaultQuality)&&(identical(other.downloadConcurrent, downloadConcurrent) || other.downloadConcurrent == downloadConcurrent)&&(identical(other.proxyUrl, proxyUrl) || other.proxyUrl == proxyUrl)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode => Object.hash(runtimeType,defaultQuality,downloadConcurrent,proxyUrl,themeMode,language);

@override
String toString() {
  return 'ApiAppSettings(defaultQuality: $defaultQuality, downloadConcurrent: $downloadConcurrent, proxyUrl: $proxyUrl, themeMode: $themeMode, language: $language)';
}


}

/// @nodoc
abstract mixin class $ApiAppSettingsCopyWith<$Res>  {
  factory $ApiAppSettingsCopyWith(ApiAppSettings value, $Res Function(ApiAppSettings) _then) = _$ApiAppSettingsCopyWithImpl;
@useResult
$Res call({
 String defaultQuality, int downloadConcurrent, String? proxyUrl, String themeMode, String language
});




}
/// @nodoc
class _$ApiAppSettingsCopyWithImpl<$Res>
    implements $ApiAppSettingsCopyWith<$Res> {
  _$ApiAppSettingsCopyWithImpl(this._self, this._then);

  final ApiAppSettings _self;
  final $Res Function(ApiAppSettings) _then;

/// Create a copy of ApiAppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultQuality = null,Object? downloadConcurrent = null,Object? proxyUrl = freezed,Object? themeMode = null,Object? language = null,}) {
  return _then(_self.copyWith(
defaultQuality: null == defaultQuality ? _self.defaultQuality : defaultQuality // ignore: cast_nullable_to_non_nullable
as String,downloadConcurrent: null == downloadConcurrent ? _self.downloadConcurrent : downloadConcurrent // ignore: cast_nullable_to_non_nullable
as int,proxyUrl: freezed == proxyUrl ? _self.proxyUrl : proxyUrl // ignore: cast_nullable_to_non_nullable
as String?,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiAppSettings].
extension ApiAppSettingsPatterns on ApiAppSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiAppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiAppSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiAppSettings value)  $default,){
final _that = this;
switch (_that) {
case _ApiAppSettings():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiAppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ApiAppSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String defaultQuality,  int downloadConcurrent,  String? proxyUrl,  String themeMode,  String language)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiAppSettings() when $default != null:
return $default(_that.defaultQuality,_that.downloadConcurrent,_that.proxyUrl,_that.themeMode,_that.language);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String defaultQuality,  int downloadConcurrent,  String? proxyUrl,  String themeMode,  String language)  $default,) {final _that = this;
switch (_that) {
case _ApiAppSettings():
return $default(_that.defaultQuality,_that.downloadConcurrent,_that.proxyUrl,_that.themeMode,_that.language);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String defaultQuality,  int downloadConcurrent,  String? proxyUrl,  String themeMode,  String language)?  $default,) {final _that = this;
switch (_that) {
case _ApiAppSettings() when $default != null:
return $default(_that.defaultQuality,_that.downloadConcurrent,_that.proxyUrl,_that.themeMode,_that.language);case _:
  return null;

}
}

}

/// @nodoc


class _ApiAppSettings extends ApiAppSettings {
  const _ApiAppSettings({required this.defaultQuality, required this.downloadConcurrent, this.proxyUrl, required this.themeMode, required this.language}): super._();
  

@override final  String defaultQuality;
@override final  int downloadConcurrent;
@override final  String? proxyUrl;
@override final  String themeMode;
@override final  String language;

/// Create a copy of ApiAppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiAppSettingsCopyWith<_ApiAppSettings> get copyWith => __$ApiAppSettingsCopyWithImpl<_ApiAppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiAppSettings&&(identical(other.defaultQuality, defaultQuality) || other.defaultQuality == defaultQuality)&&(identical(other.downloadConcurrent, downloadConcurrent) || other.downloadConcurrent == downloadConcurrent)&&(identical(other.proxyUrl, proxyUrl) || other.proxyUrl == proxyUrl)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode => Object.hash(runtimeType,defaultQuality,downloadConcurrent,proxyUrl,themeMode,language);

@override
String toString() {
  return 'ApiAppSettings(defaultQuality: $defaultQuality, downloadConcurrent: $downloadConcurrent, proxyUrl: $proxyUrl, themeMode: $themeMode, language: $language)';
}


}

/// @nodoc
abstract mixin class _$ApiAppSettingsCopyWith<$Res> implements $ApiAppSettingsCopyWith<$Res> {
  factory _$ApiAppSettingsCopyWith(_ApiAppSettings value, $Res Function(_ApiAppSettings) _then) = __$ApiAppSettingsCopyWithImpl;
@override @useResult
$Res call({
 String defaultQuality, int downloadConcurrent, String? proxyUrl, String themeMode, String language
});




}
/// @nodoc
class __$ApiAppSettingsCopyWithImpl<$Res>
    implements _$ApiAppSettingsCopyWith<$Res> {
  __$ApiAppSettingsCopyWithImpl(this._self, this._then);

  final _ApiAppSettings _self;
  final $Res Function(_ApiAppSettings) _then;

/// Create a copy of ApiAppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultQuality = null,Object? downloadConcurrent = null,Object? proxyUrl = freezed,Object? themeMode = null,Object? language = null,}) {
  return _then(_ApiAppSettings(
defaultQuality: null == defaultQuality ? _self.defaultQuality : defaultQuality // ignore: cast_nullable_to_non_nullable
as String,downloadConcurrent: null == downloadConcurrent ? _self.downloadConcurrent : downloadConcurrent // ignore: cast_nullable_to_non_nullable
as int,proxyUrl: freezed == proxyUrl ? _self.proxyUrl : proxyUrl // ignore: cast_nullable_to_non_nullable
as String?,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ApiAuthorInfo {

 String get id; String get name; String? get avatarUrl; bool get isSubscribed;
/// Create a copy of ApiAuthorInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiAuthorInfoCopyWith<ApiAuthorInfo> get copyWith => _$ApiAuthorInfoCopyWithImpl<ApiAuthorInfo>(this as ApiAuthorInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiAuthorInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl,isSubscribed);

@override
String toString() {
  return 'ApiAuthorInfo(id: $id, name: $name, avatarUrl: $avatarUrl, isSubscribed: $isSubscribed)';
}


}

/// @nodoc
abstract mixin class $ApiAuthorInfoCopyWith<$Res>  {
  factory $ApiAuthorInfoCopyWith(ApiAuthorInfo value, $Res Function(ApiAuthorInfo) _then) = _$ApiAuthorInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? avatarUrl, bool isSubscribed
});




}
/// @nodoc
class _$ApiAuthorInfoCopyWithImpl<$Res>
    implements $ApiAuthorInfoCopyWith<$Res> {
  _$ApiAuthorInfoCopyWithImpl(this._self, this._then);

  final ApiAuthorInfo _self;
  final $Res Function(ApiAuthorInfo) _then;

/// Create a copy of ApiAuthorInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatarUrl = freezed,Object? isSubscribed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiAuthorInfo].
extension ApiAuthorInfoPatterns on ApiAuthorInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiAuthorInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiAuthorInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiAuthorInfo value)  $default,){
final _that = this;
switch (_that) {
case _ApiAuthorInfo():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiAuthorInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ApiAuthorInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? avatarUrl,  bool isSubscribed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiAuthorInfo() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.isSubscribed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? avatarUrl,  bool isSubscribed)  $default,) {final _that = this;
switch (_that) {
case _ApiAuthorInfo():
return $default(_that.id,_that.name,_that.avatarUrl,_that.isSubscribed);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? avatarUrl,  bool isSubscribed)?  $default,) {final _that = this;
switch (_that) {
case _ApiAuthorInfo() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.isSubscribed);case _:
  return null;

}
}

}

/// @nodoc


class _ApiAuthorInfo implements ApiAuthorInfo {
  const _ApiAuthorInfo({required this.id, required this.name, this.avatarUrl, required this.isSubscribed});
  

@override final  String id;
@override final  String name;
@override final  String? avatarUrl;
@override final  bool isSubscribed;

/// Create a copy of ApiAuthorInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiAuthorInfoCopyWith<_ApiAuthorInfo> get copyWith => __$ApiAuthorInfoCopyWithImpl<_ApiAuthorInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiAuthorInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl,isSubscribed);

@override
String toString() {
  return 'ApiAuthorInfo(id: $id, name: $name, avatarUrl: $avatarUrl, isSubscribed: $isSubscribed)';
}


}

/// @nodoc
abstract mixin class _$ApiAuthorInfoCopyWith<$Res> implements $ApiAuthorInfoCopyWith<$Res> {
  factory _$ApiAuthorInfoCopyWith(_ApiAuthorInfo value, $Res Function(_ApiAuthorInfo) _then) = __$ApiAuthorInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? avatarUrl, bool isSubscribed
});




}
/// @nodoc
class __$ApiAuthorInfoCopyWithImpl<$Res>
    implements _$ApiAuthorInfoCopyWith<$Res> {
  __$ApiAuthorInfoCopyWithImpl(this._self, this._then);

  final _ApiAuthorInfo _self;
  final $Res Function(_ApiAuthorInfo) _then;

/// Create a copy of ApiAuthorInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatarUrl = freezed,Object? isSubscribed = null,}) {
  return _then(_ApiAuthorInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ApiBanner {

 String get title; String? get description; String get picUrl; String? get videoCode;
/// Create a copy of ApiBanner
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiBannerCopyWith<ApiBanner> get copyWith => _$ApiBannerCopyWithImpl<ApiBanner>(this as ApiBanner, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiBanner&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.picUrl, picUrl) || other.picUrl == picUrl)&&(identical(other.videoCode, videoCode) || other.videoCode == videoCode));
}


@override
int get hashCode => Object.hash(runtimeType,title,description,picUrl,videoCode);

@override
String toString() {
  return 'ApiBanner(title: $title, description: $description, picUrl: $picUrl, videoCode: $videoCode)';
}


}

/// @nodoc
abstract mixin class $ApiBannerCopyWith<$Res>  {
  factory $ApiBannerCopyWith(ApiBanner value, $Res Function(ApiBanner) _then) = _$ApiBannerCopyWithImpl;
@useResult
$Res call({
 String title, String? description, String picUrl, String? videoCode
});




}
/// @nodoc
class _$ApiBannerCopyWithImpl<$Res>
    implements $ApiBannerCopyWith<$Res> {
  _$ApiBannerCopyWithImpl(this._self, this._then);

  final ApiBanner _self;
  final $Res Function(ApiBanner) _then;

/// Create a copy of ApiBanner
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = freezed,Object? picUrl = null,Object? videoCode = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,picUrl: null == picUrl ? _self.picUrl : picUrl // ignore: cast_nullable_to_non_nullable
as String,videoCode: freezed == videoCode ? _self.videoCode : videoCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiBanner].
extension ApiBannerPatterns on ApiBanner {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiBanner value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiBanner() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiBanner value)  $default,){
final _that = this;
switch (_that) {
case _ApiBanner():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiBanner value)?  $default,){
final _that = this;
switch (_that) {
case _ApiBanner() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? description,  String picUrl,  String? videoCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiBanner() when $default != null:
return $default(_that.title,_that.description,_that.picUrl,_that.videoCode);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? description,  String picUrl,  String? videoCode)  $default,) {final _that = this;
switch (_that) {
case _ApiBanner():
return $default(_that.title,_that.description,_that.picUrl,_that.videoCode);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? description,  String picUrl,  String? videoCode)?  $default,) {final _that = this;
switch (_that) {
case _ApiBanner() when $default != null:
return $default(_that.title,_that.description,_that.picUrl,_that.videoCode);case _:
  return null;

}
}

}

/// @nodoc


class _ApiBanner implements ApiBanner {
  const _ApiBanner({required this.title, this.description, required this.picUrl, this.videoCode});
  

@override final  String title;
@override final  String? description;
@override final  String picUrl;
@override final  String? videoCode;

/// Create a copy of ApiBanner
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiBannerCopyWith<_ApiBanner> get copyWith => __$ApiBannerCopyWithImpl<_ApiBanner>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiBanner&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.picUrl, picUrl) || other.picUrl == picUrl)&&(identical(other.videoCode, videoCode) || other.videoCode == videoCode));
}


@override
int get hashCode => Object.hash(runtimeType,title,description,picUrl,videoCode);

@override
String toString() {
  return 'ApiBanner(title: $title, description: $description, picUrl: $picUrl, videoCode: $videoCode)';
}


}

/// @nodoc
abstract mixin class _$ApiBannerCopyWith<$Res> implements $ApiBannerCopyWith<$Res> {
  factory _$ApiBannerCopyWith(_ApiBanner value, $Res Function(_ApiBanner) _then) = __$ApiBannerCopyWithImpl;
@override @useResult
$Res call({
 String title, String? description, String picUrl, String? videoCode
});




}
/// @nodoc
class __$ApiBannerCopyWithImpl<$Res>
    implements _$ApiBannerCopyWith<$Res> {
  __$ApiBannerCopyWithImpl(this._self, this._then);

  final _ApiBanner _self;
  final $Res Function(_ApiBanner) _then;

/// Create a copy of ApiBanner
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = freezed,Object? picUrl = null,Object? videoCode = freezed,}) {
  return _then(_ApiBanner(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,picUrl: null == picUrl ? _self.picUrl : picUrl // ignore: cast_nullable_to_non_nullable
as String,videoCode: freezed == videoCode ? _self.videoCode : videoCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ApiCloudflareChallenge {

 String get url; String get userAgent;
/// Create a copy of ApiCloudflareChallenge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiCloudflareChallengeCopyWith<ApiCloudflareChallenge> get copyWith => _$ApiCloudflareChallengeCopyWithImpl<ApiCloudflareChallenge>(this as ApiCloudflareChallenge, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiCloudflareChallenge&&(identical(other.url, url) || other.url == url)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent));
}


@override
int get hashCode => Object.hash(runtimeType,url,userAgent);

@override
String toString() {
  return 'ApiCloudflareChallenge(url: $url, userAgent: $userAgent)';
}


}

/// @nodoc
abstract mixin class $ApiCloudflareChallengeCopyWith<$Res>  {
  factory $ApiCloudflareChallengeCopyWith(ApiCloudflareChallenge value, $Res Function(ApiCloudflareChallenge) _then) = _$ApiCloudflareChallengeCopyWithImpl;
@useResult
$Res call({
 String url, String userAgent
});




}
/// @nodoc
class _$ApiCloudflareChallengeCopyWithImpl<$Res>
    implements $ApiCloudflareChallengeCopyWith<$Res> {
  _$ApiCloudflareChallengeCopyWithImpl(this._self, this._then);

  final ApiCloudflareChallenge _self;
  final $Res Function(ApiCloudflareChallenge) _then;

/// Create a copy of ApiCloudflareChallenge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? userAgent = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiCloudflareChallenge].
extension ApiCloudflareChallengePatterns on ApiCloudflareChallenge {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiCloudflareChallenge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiCloudflareChallenge() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiCloudflareChallenge value)  $default,){
final _that = this;
switch (_that) {
case _ApiCloudflareChallenge():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiCloudflareChallenge value)?  $default,){
final _that = this;
switch (_that) {
case _ApiCloudflareChallenge() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String userAgent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiCloudflareChallenge() when $default != null:
return $default(_that.url,_that.userAgent);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String userAgent)  $default,) {final _that = this;
switch (_that) {
case _ApiCloudflareChallenge():
return $default(_that.url,_that.userAgent);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String userAgent)?  $default,) {final _that = this;
switch (_that) {
case _ApiCloudflareChallenge() when $default != null:
return $default(_that.url,_that.userAgent);case _:
  return null;

}
}

}

/// @nodoc


class _ApiCloudflareChallenge implements ApiCloudflareChallenge {
  const _ApiCloudflareChallenge({required this.url, required this.userAgent});
  

@override final  String url;
@override final  String userAgent;

/// Create a copy of ApiCloudflareChallenge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiCloudflareChallengeCopyWith<_ApiCloudflareChallenge> get copyWith => __$ApiCloudflareChallengeCopyWithImpl<_ApiCloudflareChallenge>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiCloudflareChallenge&&(identical(other.url, url) || other.url == url)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent));
}


@override
int get hashCode => Object.hash(runtimeType,url,userAgent);

@override
String toString() {
  return 'ApiCloudflareChallenge(url: $url, userAgent: $userAgent)';
}


}

/// @nodoc
abstract mixin class _$ApiCloudflareChallengeCopyWith<$Res> implements $ApiCloudflareChallengeCopyWith<$Res> {
  factory _$ApiCloudflareChallengeCopyWith(_ApiCloudflareChallenge value, $Res Function(_ApiCloudflareChallenge) _then) = __$ApiCloudflareChallengeCopyWithImpl;
@override @useResult
$Res call({
 String url, String userAgent
});




}
/// @nodoc
class __$ApiCloudflareChallengeCopyWithImpl<$Res>
    implements _$ApiCloudflareChallengeCopyWith<$Res> {
  __$ApiCloudflareChallengeCopyWithImpl(this._self, this._then);

  final _ApiCloudflareChallenge _self;
  final $Res Function(_ApiCloudflareChallenge) _then;

/// Create a copy of ApiCloudflareChallenge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? userAgent = null,}) {
  return _then(_ApiCloudflareChallenge(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ApiComment {

 String get id; String get userName; String? get userAvatar; String get content; String get time; int get likes; int get dislikes; List<ApiComment> get replies; bool get hasMoreReplies;
/// Create a copy of ApiComment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiCommentCopyWith<ApiComment> get copyWith => _$ApiCommentCopyWithImpl<ApiComment>(this as ApiComment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiComment&&(identical(other.id, id) || other.id == id)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatar, userAvatar) || other.userAvatar == userAvatar)&&(identical(other.content, content) || other.content == content)&&(identical(other.time, time) || other.time == time)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.dislikes, dislikes) || other.dislikes == dislikes)&&const DeepCollectionEquality().equals(other.replies, replies)&&(identical(other.hasMoreReplies, hasMoreReplies) || other.hasMoreReplies == hasMoreReplies));
}


@override
int get hashCode => Object.hash(runtimeType,id,userName,userAvatar,content,time,likes,dislikes,const DeepCollectionEquality().hash(replies),hasMoreReplies);

@override
String toString() {
  return 'ApiComment(id: $id, userName: $userName, userAvatar: $userAvatar, content: $content, time: $time, likes: $likes, dislikes: $dislikes, replies: $replies, hasMoreReplies: $hasMoreReplies)';
}


}

/// @nodoc
abstract mixin class $ApiCommentCopyWith<$Res>  {
  factory $ApiCommentCopyWith(ApiComment value, $Res Function(ApiComment) _then) = _$ApiCommentCopyWithImpl;
@useResult
$Res call({
 String id, String userName, String? userAvatar, String content, String time, int likes, int dislikes, List<ApiComment> replies, bool hasMoreReplies
});




}
/// @nodoc
class _$ApiCommentCopyWithImpl<$Res>
    implements $ApiCommentCopyWith<$Res> {
  _$ApiCommentCopyWithImpl(this._self, this._then);

  final ApiComment _self;
  final $Res Function(ApiComment) _then;

/// Create a copy of ApiComment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userName = null,Object? userAvatar = freezed,Object? content = null,Object? time = null,Object? likes = null,Object? dislikes = null,Object? replies = null,Object? hasMoreReplies = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatar: freezed == userAvatar ? _self.userAvatar : userAvatar // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,dislikes: null == dislikes ? _self.dislikes : dislikes // ignore: cast_nullable_to_non_nullable
as int,replies: null == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as List<ApiComment>,hasMoreReplies: null == hasMoreReplies ? _self.hasMoreReplies : hasMoreReplies // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiComment].
extension ApiCommentPatterns on ApiComment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiComment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiComment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiComment value)  $default,){
final _that = this;
switch (_that) {
case _ApiComment():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiComment value)?  $default,){
final _that = this;
switch (_that) {
case _ApiComment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userName,  String? userAvatar,  String content,  String time,  int likes,  int dislikes,  List<ApiComment> replies,  bool hasMoreReplies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiComment() when $default != null:
return $default(_that.id,_that.userName,_that.userAvatar,_that.content,_that.time,_that.likes,_that.dislikes,_that.replies,_that.hasMoreReplies);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userName,  String? userAvatar,  String content,  String time,  int likes,  int dislikes,  List<ApiComment> replies,  bool hasMoreReplies)  $default,) {final _that = this;
switch (_that) {
case _ApiComment():
return $default(_that.id,_that.userName,_that.userAvatar,_that.content,_that.time,_that.likes,_that.dislikes,_that.replies,_that.hasMoreReplies);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userName,  String? userAvatar,  String content,  String time,  int likes,  int dislikes,  List<ApiComment> replies,  bool hasMoreReplies)?  $default,) {final _that = this;
switch (_that) {
case _ApiComment() when $default != null:
return $default(_that.id,_that.userName,_that.userAvatar,_that.content,_that.time,_that.likes,_that.dislikes,_that.replies,_that.hasMoreReplies);case _:
  return null;

}
}

}

/// @nodoc


class _ApiComment implements ApiComment {
  const _ApiComment({required this.id, required this.userName, this.userAvatar, required this.content, required this.time, required this.likes, required this.dislikes, required final  List<ApiComment> replies, required this.hasMoreReplies}): _replies = replies;
  

@override final  String id;
@override final  String userName;
@override final  String? userAvatar;
@override final  String content;
@override final  String time;
@override final  int likes;
@override final  int dislikes;
 final  List<ApiComment> _replies;
@override List<ApiComment> get replies {
  if (_replies is EqualUnmodifiableListView) return _replies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_replies);
}

@override final  bool hasMoreReplies;

/// Create a copy of ApiComment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiCommentCopyWith<_ApiComment> get copyWith => __$ApiCommentCopyWithImpl<_ApiComment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiComment&&(identical(other.id, id) || other.id == id)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatar, userAvatar) || other.userAvatar == userAvatar)&&(identical(other.content, content) || other.content == content)&&(identical(other.time, time) || other.time == time)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.dislikes, dislikes) || other.dislikes == dislikes)&&const DeepCollectionEquality().equals(other._replies, _replies)&&(identical(other.hasMoreReplies, hasMoreReplies) || other.hasMoreReplies == hasMoreReplies));
}


@override
int get hashCode => Object.hash(runtimeType,id,userName,userAvatar,content,time,likes,dislikes,const DeepCollectionEquality().hash(_replies),hasMoreReplies);

@override
String toString() {
  return 'ApiComment(id: $id, userName: $userName, userAvatar: $userAvatar, content: $content, time: $time, likes: $likes, dislikes: $dislikes, replies: $replies, hasMoreReplies: $hasMoreReplies)';
}


}

/// @nodoc
abstract mixin class _$ApiCommentCopyWith<$Res> implements $ApiCommentCopyWith<$Res> {
  factory _$ApiCommentCopyWith(_ApiComment value, $Res Function(_ApiComment) _then) = __$ApiCommentCopyWithImpl;
@override @useResult
$Res call({
 String id, String userName, String? userAvatar, String content, String time, int likes, int dislikes, List<ApiComment> replies, bool hasMoreReplies
});




}
/// @nodoc
class __$ApiCommentCopyWithImpl<$Res>
    implements _$ApiCommentCopyWith<$Res> {
  __$ApiCommentCopyWithImpl(this._self, this._then);

  final _ApiComment _self;
  final $Res Function(_ApiComment) _then;

/// Create a copy of ApiComment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userName = null,Object? userAvatar = freezed,Object? content = null,Object? time = null,Object? likes = null,Object? dislikes = null,Object? replies = null,Object? hasMoreReplies = null,}) {
  return _then(_ApiComment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatar: freezed == userAvatar ? _self.userAvatar : userAvatar // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,dislikes: null == dislikes ? _self.dislikes : dislikes // ignore: cast_nullable_to_non_nullable
as int,replies: null == replies ? _self._replies : replies // ignore: cast_nullable_to_non_nullable
as List<ApiComment>,hasMoreReplies: null == hasMoreReplies ? _self.hasMoreReplies : hasMoreReplies // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ApiCommentList {

 List<ApiComment> get comments; int get total; int get page; bool get hasNext;
/// Create a copy of ApiCommentList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiCommentListCopyWith<ApiCommentList> get copyWith => _$ApiCommentListCopyWithImpl<ApiCommentList>(this as ApiCommentList, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiCommentList&&const DeepCollectionEquality().equals(other.comments, comments)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(comments),total,page,hasNext);

@override
String toString() {
  return 'ApiCommentList(comments: $comments, total: $total, page: $page, hasNext: $hasNext)';
}


}

/// @nodoc
abstract mixin class $ApiCommentListCopyWith<$Res>  {
  factory $ApiCommentListCopyWith(ApiCommentList value, $Res Function(ApiCommentList) _then) = _$ApiCommentListCopyWithImpl;
@useResult
$Res call({
 List<ApiComment> comments, int total, int page, bool hasNext
});




}
/// @nodoc
class _$ApiCommentListCopyWithImpl<$Res>
    implements $ApiCommentListCopyWith<$Res> {
  _$ApiCommentListCopyWithImpl(this._self, this._then);

  final ApiCommentList _self;
  final $Res Function(ApiCommentList) _then;

/// Create a copy of ApiCommentList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? comments = null,Object? total = null,Object? page = null,Object? hasNext = null,}) {
  return _then(_self.copyWith(
comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<ApiComment>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiCommentList].
extension ApiCommentListPatterns on ApiCommentList {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiCommentList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiCommentList() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiCommentList value)  $default,){
final _that = this;
switch (_that) {
case _ApiCommentList():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiCommentList value)?  $default,){
final _that = this;
switch (_that) {
case _ApiCommentList() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ApiComment> comments,  int total,  int page,  bool hasNext)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiCommentList() when $default != null:
return $default(_that.comments,_that.total,_that.page,_that.hasNext);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ApiComment> comments,  int total,  int page,  bool hasNext)  $default,) {final _that = this;
switch (_that) {
case _ApiCommentList():
return $default(_that.comments,_that.total,_that.page,_that.hasNext);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ApiComment> comments,  int total,  int page,  bool hasNext)?  $default,) {final _that = this;
switch (_that) {
case _ApiCommentList() when $default != null:
return $default(_that.comments,_that.total,_that.page,_that.hasNext);case _:
  return null;

}
}

}

/// @nodoc


class _ApiCommentList implements ApiCommentList {
  const _ApiCommentList({required final  List<ApiComment> comments, required this.total, required this.page, required this.hasNext}): _comments = comments;
  

 final  List<ApiComment> _comments;
@override List<ApiComment> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}

@override final  int total;
@override final  int page;
@override final  bool hasNext;

/// Create a copy of ApiCommentList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiCommentListCopyWith<_ApiCommentList> get copyWith => __$ApiCommentListCopyWithImpl<_ApiCommentList>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiCommentList&&const DeepCollectionEquality().equals(other._comments, _comments)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_comments),total,page,hasNext);

@override
String toString() {
  return 'ApiCommentList(comments: $comments, total: $total, page: $page, hasNext: $hasNext)';
}


}

/// @nodoc
abstract mixin class _$ApiCommentListCopyWith<$Res> implements $ApiCommentListCopyWith<$Res> {
  factory _$ApiCommentListCopyWith(_ApiCommentList value, $Res Function(_ApiCommentList) _then) = __$ApiCommentListCopyWithImpl;
@override @useResult
$Res call({
 List<ApiComment> comments, int total, int page, bool hasNext
});




}
/// @nodoc
class __$ApiCommentListCopyWithImpl<$Res>
    implements _$ApiCommentListCopyWith<$Res> {
  __$ApiCommentListCopyWithImpl(this._self, this._then);

  final _ApiCommentList _self;
  final $Res Function(_ApiCommentList) _then;

/// Create a copy of ApiCommentList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? comments = null,Object? total = null,Object? page = null,Object? hasNext = null,}) {
  return _then(_ApiCommentList(
comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<ApiComment>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ApiDownloadStatus {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiDownloadStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ApiDownloadStatus()';
}


}

/// @nodoc
class $ApiDownloadStatusCopyWith<$Res>  {
$ApiDownloadStatusCopyWith(ApiDownloadStatus _, $Res Function(ApiDownloadStatus) __);
}


/// Adds pattern-matching-related methods to [ApiDownloadStatus].
extension ApiDownloadStatusPatterns on ApiDownloadStatus {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ApiDownloadStatus_Pending value)?  pending,TResult Function( ApiDownloadStatus_Downloading value)?  downloading,TResult Function( ApiDownloadStatus_Paused value)?  paused,TResult Function( ApiDownloadStatus_Completed value)?  completed,TResult Function( ApiDownloadStatus_Failed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ApiDownloadStatus_Pending() when pending != null:
return pending(_that);case ApiDownloadStatus_Downloading() when downloading != null:
return downloading(_that);case ApiDownloadStatus_Paused() when paused != null:
return paused(_that);case ApiDownloadStatus_Completed() when completed != null:
return completed(_that);case ApiDownloadStatus_Failed() when failed != null:
return failed(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ApiDownloadStatus_Pending value)  pending,required TResult Function( ApiDownloadStatus_Downloading value)  downloading,required TResult Function( ApiDownloadStatus_Paused value)  paused,required TResult Function( ApiDownloadStatus_Completed value)  completed,required TResult Function( ApiDownloadStatus_Failed value)  failed,}){
final _that = this;
switch (_that) {
case ApiDownloadStatus_Pending():
return pending(_that);case ApiDownloadStatus_Downloading():
return downloading(_that);case ApiDownloadStatus_Paused():
return paused(_that);case ApiDownloadStatus_Completed():
return completed(_that);case ApiDownloadStatus_Failed():
return failed(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ApiDownloadStatus_Pending value)?  pending,TResult? Function( ApiDownloadStatus_Downloading value)?  downloading,TResult? Function( ApiDownloadStatus_Paused value)?  paused,TResult? Function( ApiDownloadStatus_Completed value)?  completed,TResult? Function( ApiDownloadStatus_Failed value)?  failed,}){
final _that = this;
switch (_that) {
case ApiDownloadStatus_Pending() when pending != null:
return pending(_that);case ApiDownloadStatus_Downloading() when downloading != null:
return downloading(_that);case ApiDownloadStatus_Paused() when paused != null:
return paused(_that);case ApiDownloadStatus_Completed() when completed != null:
return completed(_that);case ApiDownloadStatus_Failed() when failed != null:
return failed(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  pending,TResult Function()?  downloading,TResult Function()?  paused,TResult Function()?  completed,TResult Function( String error)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ApiDownloadStatus_Pending() when pending != null:
return pending();case ApiDownloadStatus_Downloading() when downloading != null:
return downloading();case ApiDownloadStatus_Paused() when paused != null:
return paused();case ApiDownloadStatus_Completed() when completed != null:
return completed();case ApiDownloadStatus_Failed() when failed != null:
return failed(_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  pending,required TResult Function()  downloading,required TResult Function()  paused,required TResult Function()  completed,required TResult Function( String error)  failed,}) {final _that = this;
switch (_that) {
case ApiDownloadStatus_Pending():
return pending();case ApiDownloadStatus_Downloading():
return downloading();case ApiDownloadStatus_Paused():
return paused();case ApiDownloadStatus_Completed():
return completed();case ApiDownloadStatus_Failed():
return failed(_that.error);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  pending,TResult? Function()?  downloading,TResult? Function()?  paused,TResult? Function()?  completed,TResult? Function( String error)?  failed,}) {final _that = this;
switch (_that) {
case ApiDownloadStatus_Pending() when pending != null:
return pending();case ApiDownloadStatus_Downloading() when downloading != null:
return downloading();case ApiDownloadStatus_Paused() when paused != null:
return paused();case ApiDownloadStatus_Completed() when completed != null:
return completed();case ApiDownloadStatus_Failed() when failed != null:
return failed(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ApiDownloadStatus_Pending extends ApiDownloadStatus {
  const ApiDownloadStatus_Pending(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiDownloadStatus_Pending);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ApiDownloadStatus.pending()';
}


}




/// @nodoc


class ApiDownloadStatus_Downloading extends ApiDownloadStatus {
  const ApiDownloadStatus_Downloading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiDownloadStatus_Downloading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ApiDownloadStatus.downloading()';
}


}




/// @nodoc


class ApiDownloadStatus_Paused extends ApiDownloadStatus {
  const ApiDownloadStatus_Paused(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiDownloadStatus_Paused);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ApiDownloadStatus.paused()';
}


}




/// @nodoc


class ApiDownloadStatus_Completed extends ApiDownloadStatus {
  const ApiDownloadStatus_Completed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiDownloadStatus_Completed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ApiDownloadStatus.completed()';
}


}




/// @nodoc


class ApiDownloadStatus_Failed extends ApiDownloadStatus {
  const ApiDownloadStatus_Failed({required this.error}): super._();
  

 final  String error;

/// Create a copy of ApiDownloadStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiDownloadStatus_FailedCopyWith<ApiDownloadStatus_Failed> get copyWith => _$ApiDownloadStatus_FailedCopyWithImpl<ApiDownloadStatus_Failed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiDownloadStatus_Failed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ApiDownloadStatus.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $ApiDownloadStatus_FailedCopyWith<$Res> implements $ApiDownloadStatusCopyWith<$Res> {
  factory $ApiDownloadStatus_FailedCopyWith(ApiDownloadStatus_Failed value, $Res Function(ApiDownloadStatus_Failed) _then) = _$ApiDownloadStatus_FailedCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$ApiDownloadStatus_FailedCopyWithImpl<$Res>
    implements $ApiDownloadStatus_FailedCopyWith<$Res> {
  _$ApiDownloadStatus_FailedCopyWithImpl(this._self, this._then);

  final ApiDownloadStatus_Failed _self;
  final $Res Function(ApiDownloadStatus_Failed) _then;

/// Create a copy of ApiDownloadStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(ApiDownloadStatus_Failed(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ApiDownloadTask {

 String get id; String get videoId; String get title; String get coverUrl; String? get coverPath; String? get authorId; String? get authorName; String? get authorAvatarUrl; String? get authorAvatarPath; String get quality; String? get description; List<String> get tags; ApiDownloadStatus get status; double get progress; BigInt get downloadedBytes; BigInt get totalBytes; BigInt get speed; PlatformInt64 get createdAt; String? get filePath;
/// Create a copy of ApiDownloadTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiDownloadTaskCopyWith<ApiDownloadTask> get copyWith => _$ApiDownloadTaskCopyWithImpl<ApiDownloadTask>(this as ApiDownloadTask, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiDownloadTask&&(identical(other.id, id) || other.id == id)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.coverPath, coverPath) || other.coverPath == coverPath)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.authorAvatarPath, authorAvatarPath) || other.authorAvatarPath == authorAvatarPath)&&(identical(other.quality, quality) || other.quality == quality)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.downloadedBytes, downloadedBytes) || other.downloadedBytes == downloadedBytes)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.filePath, filePath) || other.filePath == filePath));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,videoId,title,coverUrl,coverPath,authorId,authorName,authorAvatarUrl,authorAvatarPath,quality,description,const DeepCollectionEquality().hash(tags),status,progress,downloadedBytes,totalBytes,speed,createdAt,filePath]);

@override
String toString() {
  return 'ApiDownloadTask(id: $id, videoId: $videoId, title: $title, coverUrl: $coverUrl, coverPath: $coverPath, authorId: $authorId, authorName: $authorName, authorAvatarUrl: $authorAvatarUrl, authorAvatarPath: $authorAvatarPath, quality: $quality, description: $description, tags: $tags, status: $status, progress: $progress, downloadedBytes: $downloadedBytes, totalBytes: $totalBytes, speed: $speed, createdAt: $createdAt, filePath: $filePath)';
}


}

/// @nodoc
abstract mixin class $ApiDownloadTaskCopyWith<$Res>  {
  factory $ApiDownloadTaskCopyWith(ApiDownloadTask value, $Res Function(ApiDownloadTask) _then) = _$ApiDownloadTaskCopyWithImpl;
@useResult
$Res call({
 String id, String videoId, String title, String coverUrl, String? coverPath, String? authorId, String? authorName, String? authorAvatarUrl, String? authorAvatarPath, String quality, String? description, List<String> tags, ApiDownloadStatus status, double progress, BigInt downloadedBytes, BigInt totalBytes, BigInt speed, PlatformInt64 createdAt, String? filePath
});


$ApiDownloadStatusCopyWith<$Res> get status;

}
/// @nodoc
class _$ApiDownloadTaskCopyWithImpl<$Res>
    implements $ApiDownloadTaskCopyWith<$Res> {
  _$ApiDownloadTaskCopyWithImpl(this._self, this._then);

  final ApiDownloadTask _self;
  final $Res Function(ApiDownloadTask) _then;

/// Create a copy of ApiDownloadTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? videoId = null,Object? title = null,Object? coverUrl = null,Object? coverPath = freezed,Object? authorId = freezed,Object? authorName = freezed,Object? authorAvatarUrl = freezed,Object? authorAvatarPath = freezed,Object? quality = null,Object? description = freezed,Object? tags = null,Object? status = null,Object? progress = null,Object? downloadedBytes = null,Object? totalBytes = null,Object? speed = null,Object? createdAt = null,Object? filePath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,coverPath: freezed == coverPath ? _self.coverPath : coverPath // ignore: cast_nullable_to_non_nullable
as String?,authorId: freezed == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String?,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,authorAvatarPath: freezed == authorAvatarPath ? _self.authorAvatarPath : authorAvatarPath // ignore: cast_nullable_to_non_nullable
as String?,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ApiDownloadStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,downloadedBytes: null == downloadedBytes ? _self.downloadedBytes : downloadedBytes // ignore: cast_nullable_to_non_nullable
as BigInt,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as BigInt,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as BigInt,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as PlatformInt64,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ApiDownloadTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiDownloadStatusCopyWith<$Res> get status {
  
  return $ApiDownloadStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// Adds pattern-matching-related methods to [ApiDownloadTask].
extension ApiDownloadTaskPatterns on ApiDownloadTask {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiDownloadTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiDownloadTask() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiDownloadTask value)  $default,){
final _that = this;
switch (_that) {
case _ApiDownloadTask():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiDownloadTask value)?  $default,){
final _that = this;
switch (_that) {
case _ApiDownloadTask() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String videoId,  String title,  String coverUrl,  String? coverPath,  String? authorId,  String? authorName,  String? authorAvatarUrl,  String? authorAvatarPath,  String quality,  String? description,  List<String> tags,  ApiDownloadStatus status,  double progress,  BigInt downloadedBytes,  BigInt totalBytes,  BigInt speed,  PlatformInt64 createdAt,  String? filePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiDownloadTask() when $default != null:
return $default(_that.id,_that.videoId,_that.title,_that.coverUrl,_that.coverPath,_that.authorId,_that.authorName,_that.authorAvatarUrl,_that.authorAvatarPath,_that.quality,_that.description,_that.tags,_that.status,_that.progress,_that.downloadedBytes,_that.totalBytes,_that.speed,_that.createdAt,_that.filePath);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String videoId,  String title,  String coverUrl,  String? coverPath,  String? authorId,  String? authorName,  String? authorAvatarUrl,  String? authorAvatarPath,  String quality,  String? description,  List<String> tags,  ApiDownloadStatus status,  double progress,  BigInt downloadedBytes,  BigInt totalBytes,  BigInt speed,  PlatformInt64 createdAt,  String? filePath)  $default,) {final _that = this;
switch (_that) {
case _ApiDownloadTask():
return $default(_that.id,_that.videoId,_that.title,_that.coverUrl,_that.coverPath,_that.authorId,_that.authorName,_that.authorAvatarUrl,_that.authorAvatarPath,_that.quality,_that.description,_that.tags,_that.status,_that.progress,_that.downloadedBytes,_that.totalBytes,_that.speed,_that.createdAt,_that.filePath);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String videoId,  String title,  String coverUrl,  String? coverPath,  String? authorId,  String? authorName,  String? authorAvatarUrl,  String? authorAvatarPath,  String quality,  String? description,  List<String> tags,  ApiDownloadStatus status,  double progress,  BigInt downloadedBytes,  BigInt totalBytes,  BigInt speed,  PlatformInt64 createdAt,  String? filePath)?  $default,) {final _that = this;
switch (_that) {
case _ApiDownloadTask() when $default != null:
return $default(_that.id,_that.videoId,_that.title,_that.coverUrl,_that.coverPath,_that.authorId,_that.authorName,_that.authorAvatarUrl,_that.authorAvatarPath,_that.quality,_that.description,_that.tags,_that.status,_that.progress,_that.downloadedBytes,_that.totalBytes,_that.speed,_that.createdAt,_that.filePath);case _:
  return null;

}
}

}

/// @nodoc


class _ApiDownloadTask implements ApiDownloadTask {
  const _ApiDownloadTask({required this.id, required this.videoId, required this.title, required this.coverUrl, this.coverPath, this.authorId, this.authorName, this.authorAvatarUrl, this.authorAvatarPath, required this.quality, this.description, required final  List<String> tags, required this.status, required this.progress, required this.downloadedBytes, required this.totalBytes, required this.speed, required this.createdAt, this.filePath}): _tags = tags;
  

@override final  String id;
@override final  String videoId;
@override final  String title;
@override final  String coverUrl;
@override final  String? coverPath;
@override final  String? authorId;
@override final  String? authorName;
@override final  String? authorAvatarUrl;
@override final  String? authorAvatarPath;
@override final  String quality;
@override final  String? description;
 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  ApiDownloadStatus status;
@override final  double progress;
@override final  BigInt downloadedBytes;
@override final  BigInt totalBytes;
@override final  BigInt speed;
@override final  PlatformInt64 createdAt;
@override final  String? filePath;

/// Create a copy of ApiDownloadTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiDownloadTaskCopyWith<_ApiDownloadTask> get copyWith => __$ApiDownloadTaskCopyWithImpl<_ApiDownloadTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiDownloadTask&&(identical(other.id, id) || other.id == id)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.coverPath, coverPath) || other.coverPath == coverPath)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.authorAvatarPath, authorAvatarPath) || other.authorAvatarPath == authorAvatarPath)&&(identical(other.quality, quality) || other.quality == quality)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.downloadedBytes, downloadedBytes) || other.downloadedBytes == downloadedBytes)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.filePath, filePath) || other.filePath == filePath));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,videoId,title,coverUrl,coverPath,authorId,authorName,authorAvatarUrl,authorAvatarPath,quality,description,const DeepCollectionEquality().hash(_tags),status,progress,downloadedBytes,totalBytes,speed,createdAt,filePath]);

@override
String toString() {
  return 'ApiDownloadTask(id: $id, videoId: $videoId, title: $title, coverUrl: $coverUrl, coverPath: $coverPath, authorId: $authorId, authorName: $authorName, authorAvatarUrl: $authorAvatarUrl, authorAvatarPath: $authorAvatarPath, quality: $quality, description: $description, tags: $tags, status: $status, progress: $progress, downloadedBytes: $downloadedBytes, totalBytes: $totalBytes, speed: $speed, createdAt: $createdAt, filePath: $filePath)';
}


}

/// @nodoc
abstract mixin class _$ApiDownloadTaskCopyWith<$Res> implements $ApiDownloadTaskCopyWith<$Res> {
  factory _$ApiDownloadTaskCopyWith(_ApiDownloadTask value, $Res Function(_ApiDownloadTask) _then) = __$ApiDownloadTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String videoId, String title, String coverUrl, String? coverPath, String? authorId, String? authorName, String? authorAvatarUrl, String? authorAvatarPath, String quality, String? description, List<String> tags, ApiDownloadStatus status, double progress, BigInt downloadedBytes, BigInt totalBytes, BigInt speed, PlatformInt64 createdAt, String? filePath
});


@override $ApiDownloadStatusCopyWith<$Res> get status;

}
/// @nodoc
class __$ApiDownloadTaskCopyWithImpl<$Res>
    implements _$ApiDownloadTaskCopyWith<$Res> {
  __$ApiDownloadTaskCopyWithImpl(this._self, this._then);

  final _ApiDownloadTask _self;
  final $Res Function(_ApiDownloadTask) _then;

/// Create a copy of ApiDownloadTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? videoId = null,Object? title = null,Object? coverUrl = null,Object? coverPath = freezed,Object? authorId = freezed,Object? authorName = freezed,Object? authorAvatarUrl = freezed,Object? authorAvatarPath = freezed,Object? quality = null,Object? description = freezed,Object? tags = null,Object? status = null,Object? progress = null,Object? downloadedBytes = null,Object? totalBytes = null,Object? speed = null,Object? createdAt = null,Object? filePath = freezed,}) {
  return _then(_ApiDownloadTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,coverPath: freezed == coverPath ? _self.coverPath : coverPath // ignore: cast_nullable_to_non_nullable
as String?,authorId: freezed == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String?,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,authorAvatarPath: freezed == authorAvatarPath ? _self.authorAvatarPath : authorAvatarPath // ignore: cast_nullable_to_non_nullable
as String?,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ApiDownloadStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,downloadedBytes: null == downloadedBytes ? _self.downloadedBytes : downloadedBytes // ignore: cast_nullable_to_non_nullable
as BigInt,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as BigInt,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as BigInt,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as PlatformInt64,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ApiDownloadTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiDownloadStatusCopyWith<$Res> get status {
  
  return $ApiDownloadStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}

/// @nodoc
mixin _$ApiExportProgress {

 int get totalFiles; int get doneFiles; String? get currentFile; BigInt get currentBytes; BigInt get currentTotalBytes; bool get done; String? get error;
/// Create a copy of ApiExportProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiExportProgressCopyWith<ApiExportProgress> get copyWith => _$ApiExportProgressCopyWithImpl<ApiExportProgress>(this as ApiExportProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiExportProgress&&(identical(other.totalFiles, totalFiles) || other.totalFiles == totalFiles)&&(identical(other.doneFiles, doneFiles) || other.doneFiles == doneFiles)&&(identical(other.currentFile, currentFile) || other.currentFile == currentFile)&&(identical(other.currentBytes, currentBytes) || other.currentBytes == currentBytes)&&(identical(other.currentTotalBytes, currentTotalBytes) || other.currentTotalBytes == currentTotalBytes)&&(identical(other.done, done) || other.done == done)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,totalFiles,doneFiles,currentFile,currentBytes,currentTotalBytes,done,error);

@override
String toString() {
  return 'ApiExportProgress(totalFiles: $totalFiles, doneFiles: $doneFiles, currentFile: $currentFile, currentBytes: $currentBytes, currentTotalBytes: $currentTotalBytes, done: $done, error: $error)';
}


}

/// @nodoc
abstract mixin class $ApiExportProgressCopyWith<$Res>  {
  factory $ApiExportProgressCopyWith(ApiExportProgress value, $Res Function(ApiExportProgress) _then) = _$ApiExportProgressCopyWithImpl;
@useResult
$Res call({
 int totalFiles, int doneFiles, String? currentFile, BigInt currentBytes, BigInt currentTotalBytes, bool done, String? error
});




}
/// @nodoc
class _$ApiExportProgressCopyWithImpl<$Res>
    implements $ApiExportProgressCopyWith<$Res> {
  _$ApiExportProgressCopyWithImpl(this._self, this._then);

  final ApiExportProgress _self;
  final $Res Function(ApiExportProgress) _then;

/// Create a copy of ApiExportProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalFiles = null,Object? doneFiles = null,Object? currentFile = freezed,Object? currentBytes = null,Object? currentTotalBytes = null,Object? done = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
totalFiles: null == totalFiles ? _self.totalFiles : totalFiles // ignore: cast_nullable_to_non_nullable
as int,doneFiles: null == doneFiles ? _self.doneFiles : doneFiles // ignore: cast_nullable_to_non_nullable
as int,currentFile: freezed == currentFile ? _self.currentFile : currentFile // ignore: cast_nullable_to_non_nullable
as String?,currentBytes: null == currentBytes ? _self.currentBytes : currentBytes // ignore: cast_nullable_to_non_nullable
as BigInt,currentTotalBytes: null == currentTotalBytes ? _self.currentTotalBytes : currentTotalBytes // ignore: cast_nullable_to_non_nullable
as BigInt,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiExportProgress].
extension ApiExportProgressPatterns on ApiExportProgress {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiExportProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiExportProgress() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiExportProgress value)  $default,){
final _that = this;
switch (_that) {
case _ApiExportProgress():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiExportProgress value)?  $default,){
final _that = this;
switch (_that) {
case _ApiExportProgress() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalFiles,  int doneFiles,  String? currentFile,  BigInt currentBytes,  BigInt currentTotalBytes,  bool done,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiExportProgress() when $default != null:
return $default(_that.totalFiles,_that.doneFiles,_that.currentFile,_that.currentBytes,_that.currentTotalBytes,_that.done,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalFiles,  int doneFiles,  String? currentFile,  BigInt currentBytes,  BigInt currentTotalBytes,  bool done,  String? error)  $default,) {final _that = this;
switch (_that) {
case _ApiExportProgress():
return $default(_that.totalFiles,_that.doneFiles,_that.currentFile,_that.currentBytes,_that.currentTotalBytes,_that.done,_that.error);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalFiles,  int doneFiles,  String? currentFile,  BigInt currentBytes,  BigInt currentTotalBytes,  bool done,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _ApiExportProgress() when $default != null:
return $default(_that.totalFiles,_that.doneFiles,_that.currentFile,_that.currentBytes,_that.currentTotalBytes,_that.done,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ApiExportProgress implements ApiExportProgress {
  const _ApiExportProgress({required this.totalFiles, required this.doneFiles, this.currentFile, required this.currentBytes, required this.currentTotalBytes, required this.done, this.error});
  

@override final  int totalFiles;
@override final  int doneFiles;
@override final  String? currentFile;
@override final  BigInt currentBytes;
@override final  BigInt currentTotalBytes;
@override final  bool done;
@override final  String? error;

/// Create a copy of ApiExportProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiExportProgressCopyWith<_ApiExportProgress> get copyWith => __$ApiExportProgressCopyWithImpl<_ApiExportProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiExportProgress&&(identical(other.totalFiles, totalFiles) || other.totalFiles == totalFiles)&&(identical(other.doneFiles, doneFiles) || other.doneFiles == doneFiles)&&(identical(other.currentFile, currentFile) || other.currentFile == currentFile)&&(identical(other.currentBytes, currentBytes) || other.currentBytes == currentBytes)&&(identical(other.currentTotalBytes, currentTotalBytes) || other.currentTotalBytes == currentTotalBytes)&&(identical(other.done, done) || other.done == done)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,totalFiles,doneFiles,currentFile,currentBytes,currentTotalBytes,done,error);

@override
String toString() {
  return 'ApiExportProgress(totalFiles: $totalFiles, doneFiles: $doneFiles, currentFile: $currentFile, currentBytes: $currentBytes, currentTotalBytes: $currentTotalBytes, done: $done, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ApiExportProgressCopyWith<$Res> implements $ApiExportProgressCopyWith<$Res> {
  factory _$ApiExportProgressCopyWith(_ApiExportProgress value, $Res Function(_ApiExportProgress) _then) = __$ApiExportProgressCopyWithImpl;
@override @useResult
$Res call({
 int totalFiles, int doneFiles, String? currentFile, BigInt currentBytes, BigInt currentTotalBytes, bool done, String? error
});




}
/// @nodoc
class __$ApiExportProgressCopyWithImpl<$Res>
    implements _$ApiExportProgressCopyWith<$Res> {
  __$ApiExportProgressCopyWithImpl(this._self, this._then);

  final _ApiExportProgress _self;
  final $Res Function(_ApiExportProgress) _then;

/// Create a copy of ApiExportProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalFiles = null,Object? doneFiles = null,Object? currentFile = freezed,Object? currentBytes = null,Object? currentTotalBytes = null,Object? done = null,Object? error = freezed,}) {
  return _then(_ApiExportProgress(
totalFiles: null == totalFiles ? _self.totalFiles : totalFiles // ignore: cast_nullable_to_non_nullable
as int,doneFiles: null == doneFiles ? _self.doneFiles : doneFiles // ignore: cast_nullable_to_non_nullable
as int,currentFile: freezed == currentFile ? _self.currentFile : currentFile // ignore: cast_nullable_to_non_nullable
as String?,currentBytes: null == currentBytes ? _self.currentBytes : currentBytes // ignore: cast_nullable_to_non_nullable
as BigInt,currentTotalBytes: null == currentTotalBytes ? _self.currentTotalBytes : currentTotalBytes // ignore: cast_nullable_to_non_nullable
as BigInt,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ApiFavoriteList {

 List<ApiVideoCard> get videos; int get total; int get page; bool get hasNext;
/// Create a copy of ApiFavoriteList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiFavoriteListCopyWith<ApiFavoriteList> get copyWith => _$ApiFavoriteListCopyWithImpl<ApiFavoriteList>(this as ApiFavoriteList, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiFavoriteList&&const DeepCollectionEquality().equals(other.videos, videos)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(videos),total,page,hasNext);

@override
String toString() {
  return 'ApiFavoriteList(videos: $videos, total: $total, page: $page, hasNext: $hasNext)';
}


}

/// @nodoc
abstract mixin class $ApiFavoriteListCopyWith<$Res>  {
  factory $ApiFavoriteListCopyWith(ApiFavoriteList value, $Res Function(ApiFavoriteList) _then) = _$ApiFavoriteListCopyWithImpl;
@useResult
$Res call({
 List<ApiVideoCard> videos, int total, int page, bool hasNext
});




}
/// @nodoc
class _$ApiFavoriteListCopyWithImpl<$Res>
    implements $ApiFavoriteListCopyWith<$Res> {
  _$ApiFavoriteListCopyWithImpl(this._self, this._then);

  final ApiFavoriteList _self;
  final $Res Function(ApiFavoriteList) _then;

/// Create a copy of ApiFavoriteList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videos = null,Object? total = null,Object? page = null,Object? hasNext = null,}) {
  return _then(_self.copyWith(
videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiFavoriteList].
extension ApiFavoriteListPatterns on ApiFavoriteList {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiFavoriteList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiFavoriteList() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiFavoriteList value)  $default,){
final _that = this;
switch (_that) {
case _ApiFavoriteList():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiFavoriteList value)?  $default,){
final _that = this;
switch (_that) {
case _ApiFavoriteList() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ApiVideoCard> videos,  int total,  int page,  bool hasNext)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiFavoriteList() when $default != null:
return $default(_that.videos,_that.total,_that.page,_that.hasNext);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ApiVideoCard> videos,  int total,  int page,  bool hasNext)  $default,) {final _that = this;
switch (_that) {
case _ApiFavoriteList():
return $default(_that.videos,_that.total,_that.page,_that.hasNext);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ApiVideoCard> videos,  int total,  int page,  bool hasNext)?  $default,) {final _that = this;
switch (_that) {
case _ApiFavoriteList() when $default != null:
return $default(_that.videos,_that.total,_that.page,_that.hasNext);case _:
  return null;

}
}

}

/// @nodoc


class _ApiFavoriteList implements ApiFavoriteList {
  const _ApiFavoriteList({required final  List<ApiVideoCard> videos, required this.total, required this.page, required this.hasNext}): _videos = videos;
  

 final  List<ApiVideoCard> _videos;
@override List<ApiVideoCard> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

@override final  int total;
@override final  int page;
@override final  bool hasNext;

/// Create a copy of ApiFavoriteList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiFavoriteListCopyWith<_ApiFavoriteList> get copyWith => __$ApiFavoriteListCopyWithImpl<_ApiFavoriteList>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiFavoriteList&&const DeepCollectionEquality().equals(other._videos, _videos)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_videos),total,page,hasNext);

@override
String toString() {
  return 'ApiFavoriteList(videos: $videos, total: $total, page: $page, hasNext: $hasNext)';
}


}

/// @nodoc
abstract mixin class _$ApiFavoriteListCopyWith<$Res> implements $ApiFavoriteListCopyWith<$Res> {
  factory _$ApiFavoriteListCopyWith(_ApiFavoriteList value, $Res Function(_ApiFavoriteList) _then) = __$ApiFavoriteListCopyWithImpl;
@override @useResult
$Res call({
 List<ApiVideoCard> videos, int total, int page, bool hasNext
});




}
/// @nodoc
class __$ApiFavoriteListCopyWithImpl<$Res>
    implements _$ApiFavoriteListCopyWith<$Res> {
  __$ApiFavoriteListCopyWithImpl(this._self, this._then);

  final _ApiFavoriteList _self;
  final $Res Function(_ApiFavoriteList) _then;

/// Create a copy of ApiFavoriteList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videos = null,Object? total = null,Object? page = null,Object? hasNext = null,}) {
  return _then(_ApiFavoriteList(
videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ApiFilterOption {

 String get value; String get label;
/// Create a copy of ApiFilterOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiFilterOptionCopyWith<ApiFilterOption> get copyWith => _$ApiFilterOptionCopyWithImpl<ApiFilterOption>(this as ApiFilterOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiFilterOption&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,value,label);

@override
String toString() {
  return 'ApiFilterOption(value: $value, label: $label)';
}


}

/// @nodoc
abstract mixin class $ApiFilterOptionCopyWith<$Res>  {
  factory $ApiFilterOptionCopyWith(ApiFilterOption value, $Res Function(ApiFilterOption) _then) = _$ApiFilterOptionCopyWithImpl;
@useResult
$Res call({
 String value, String label
});




}
/// @nodoc
class _$ApiFilterOptionCopyWithImpl<$Res>
    implements $ApiFilterOptionCopyWith<$Res> {
  _$ApiFilterOptionCopyWithImpl(this._self, this._then);

  final ApiFilterOption _self;
  final $Res Function(ApiFilterOption) _then;

/// Create a copy of ApiFilterOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? label = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiFilterOption].
extension ApiFilterOptionPatterns on ApiFilterOption {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiFilterOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiFilterOption() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiFilterOption value)  $default,){
final _that = this;
switch (_that) {
case _ApiFilterOption():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiFilterOption value)?  $default,){
final _that = this;
switch (_that) {
case _ApiFilterOption() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiFilterOption() when $default != null:
return $default(_that.value,_that.label);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String label)  $default,) {final _that = this;
switch (_that) {
case _ApiFilterOption():
return $default(_that.value,_that.label);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String label)?  $default,) {final _that = this;
switch (_that) {
case _ApiFilterOption() when $default != null:
return $default(_that.value,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _ApiFilterOption implements ApiFilterOption {
  const _ApiFilterOption({required this.value, required this.label});
  

@override final  String value;
@override final  String label;

/// Create a copy of ApiFilterOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiFilterOptionCopyWith<_ApiFilterOption> get copyWith => __$ApiFilterOptionCopyWithImpl<_ApiFilterOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiFilterOption&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,value,label);

@override
String toString() {
  return 'ApiFilterOption(value: $value, label: $label)';
}


}

/// @nodoc
abstract mixin class _$ApiFilterOptionCopyWith<$Res> implements $ApiFilterOptionCopyWith<$Res> {
  factory _$ApiFilterOptionCopyWith(_ApiFilterOption value, $Res Function(_ApiFilterOption) _then) = __$ApiFilterOptionCopyWithImpl;
@override @useResult
$Res call({
 String value, String label
});




}
/// @nodoc
class __$ApiFilterOptionCopyWithImpl<$Res>
    implements _$ApiFilterOptionCopyWith<$Res> {
  __$ApiFilterOptionCopyWithImpl(this._self, this._then);

  final _ApiFilterOption _self;
  final $Res Function(_ApiFilterOption) _then;

/// Create a copy of ApiFilterOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? label = null,}) {
  return _then(_ApiFilterOption(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ApiFilterOptions {

 List<ApiFilterOption> get genres; List<ApiTagGroup> get tags; List<ApiFilterOption> get sorts; List<ApiFilterOption> get years; List<ApiFilterOption> get durations;
/// Create a copy of ApiFilterOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiFilterOptionsCopyWith<ApiFilterOptions> get copyWith => _$ApiFilterOptionsCopyWithImpl<ApiFilterOptions>(this as ApiFilterOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiFilterOptions&&const DeepCollectionEquality().equals(other.genres, genres)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.sorts, sorts)&&const DeepCollectionEquality().equals(other.years, years)&&const DeepCollectionEquality().equals(other.durations, durations));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(genres),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(sorts),const DeepCollectionEquality().hash(years),const DeepCollectionEquality().hash(durations));

@override
String toString() {
  return 'ApiFilterOptions(genres: $genres, tags: $tags, sorts: $sorts, years: $years, durations: $durations)';
}


}

/// @nodoc
abstract mixin class $ApiFilterOptionsCopyWith<$Res>  {
  factory $ApiFilterOptionsCopyWith(ApiFilterOptions value, $Res Function(ApiFilterOptions) _then) = _$ApiFilterOptionsCopyWithImpl;
@useResult
$Res call({
 List<ApiFilterOption> genres, List<ApiTagGroup> tags, List<ApiFilterOption> sorts, List<ApiFilterOption> years, List<ApiFilterOption> durations
});




}
/// @nodoc
class _$ApiFilterOptionsCopyWithImpl<$Res>
    implements $ApiFilterOptionsCopyWith<$Res> {
  _$ApiFilterOptionsCopyWithImpl(this._self, this._then);

  final ApiFilterOptions _self;
  final $Res Function(ApiFilterOptions) _then;

/// Create a copy of ApiFilterOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? genres = null,Object? tags = null,Object? sorts = null,Object? years = null,Object? durations = null,}) {
  return _then(_self.copyWith(
genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<ApiFilterOption>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<ApiTagGroup>,sorts: null == sorts ? _self.sorts : sorts // ignore: cast_nullable_to_non_nullable
as List<ApiFilterOption>,years: null == years ? _self.years : years // ignore: cast_nullable_to_non_nullable
as List<ApiFilterOption>,durations: null == durations ? _self.durations : durations // ignore: cast_nullable_to_non_nullable
as List<ApiFilterOption>,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiFilterOptions].
extension ApiFilterOptionsPatterns on ApiFilterOptions {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiFilterOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiFilterOptions() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiFilterOptions value)  $default,){
final _that = this;
switch (_that) {
case _ApiFilterOptions():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiFilterOptions value)?  $default,){
final _that = this;
switch (_that) {
case _ApiFilterOptions() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ApiFilterOption> genres,  List<ApiTagGroup> tags,  List<ApiFilterOption> sorts,  List<ApiFilterOption> years,  List<ApiFilterOption> durations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiFilterOptions() when $default != null:
return $default(_that.genres,_that.tags,_that.sorts,_that.years,_that.durations);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ApiFilterOption> genres,  List<ApiTagGroup> tags,  List<ApiFilterOption> sorts,  List<ApiFilterOption> years,  List<ApiFilterOption> durations)  $default,) {final _that = this;
switch (_that) {
case _ApiFilterOptions():
return $default(_that.genres,_that.tags,_that.sorts,_that.years,_that.durations);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ApiFilterOption> genres,  List<ApiTagGroup> tags,  List<ApiFilterOption> sorts,  List<ApiFilterOption> years,  List<ApiFilterOption> durations)?  $default,) {final _that = this;
switch (_that) {
case _ApiFilterOptions() when $default != null:
return $default(_that.genres,_that.tags,_that.sorts,_that.years,_that.durations);case _:
  return null;

}
}

}

/// @nodoc


class _ApiFilterOptions implements ApiFilterOptions {
  const _ApiFilterOptions({required final  List<ApiFilterOption> genres, required final  List<ApiTagGroup> tags, required final  List<ApiFilterOption> sorts, required final  List<ApiFilterOption> years, required final  List<ApiFilterOption> durations}): _genres = genres,_tags = tags,_sorts = sorts,_years = years,_durations = durations;
  

 final  List<ApiFilterOption> _genres;
@override List<ApiFilterOption> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

 final  List<ApiTagGroup> _tags;
@override List<ApiTagGroup> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<ApiFilterOption> _sorts;
@override List<ApiFilterOption> get sorts {
  if (_sorts is EqualUnmodifiableListView) return _sorts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sorts);
}

 final  List<ApiFilterOption> _years;
@override List<ApiFilterOption> get years {
  if (_years is EqualUnmodifiableListView) return _years;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_years);
}

 final  List<ApiFilterOption> _durations;
@override List<ApiFilterOption> get durations {
  if (_durations is EqualUnmodifiableListView) return _durations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_durations);
}


/// Create a copy of ApiFilterOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiFilterOptionsCopyWith<_ApiFilterOptions> get copyWith => __$ApiFilterOptionsCopyWithImpl<_ApiFilterOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiFilterOptions&&const DeepCollectionEquality().equals(other._genres, _genres)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._sorts, _sorts)&&const DeepCollectionEquality().equals(other._years, _years)&&const DeepCollectionEquality().equals(other._durations, _durations));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_genres),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_sorts),const DeepCollectionEquality().hash(_years),const DeepCollectionEquality().hash(_durations));

@override
String toString() {
  return 'ApiFilterOptions(genres: $genres, tags: $tags, sorts: $sorts, years: $years, durations: $durations)';
}


}

/// @nodoc
abstract mixin class _$ApiFilterOptionsCopyWith<$Res> implements $ApiFilterOptionsCopyWith<$Res> {
  factory _$ApiFilterOptionsCopyWith(_ApiFilterOptions value, $Res Function(_ApiFilterOptions) _then) = __$ApiFilterOptionsCopyWithImpl;
@override @useResult
$Res call({
 List<ApiFilterOption> genres, List<ApiTagGroup> tags, List<ApiFilterOption> sorts, List<ApiFilterOption> years, List<ApiFilterOption> durations
});




}
/// @nodoc
class __$ApiFilterOptionsCopyWithImpl<$Res>
    implements _$ApiFilterOptionsCopyWith<$Res> {
  __$ApiFilterOptionsCopyWithImpl(this._self, this._then);

  final _ApiFilterOptions _self;
  final $Res Function(_ApiFilterOptions) _then;

/// Create a copy of ApiFilterOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? genres = null,Object? tags = null,Object? sorts = null,Object? years = null,Object? durations = null,}) {
  return _then(_ApiFilterOptions(
genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<ApiFilterOption>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<ApiTagGroup>,sorts: null == sorts ? _self._sorts : sorts // ignore: cast_nullable_to_non_nullable
as List<ApiFilterOption>,years: null == years ? _self._years : years // ignore: cast_nullable_to_non_nullable
as List<ApiFilterOption>,durations: null == durations ? _self._durations : durations // ignore: cast_nullable_to_non_nullable
as List<ApiFilterOption>,
  ));
}


}

/// @nodoc
mixin _$ApiHomePage {

 String? get formToken; String? get avatarUrl; String? get username; ApiBanner? get banner; List<ApiVideoCard> get latestRelease; List<ApiVideoCard> get latestUpload; List<ApiHomeSection> get sections;
/// Create a copy of ApiHomePage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiHomePageCopyWith<ApiHomePage> get copyWith => _$ApiHomePageCopyWithImpl<ApiHomePage>(this as ApiHomePage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiHomePage&&(identical(other.formToken, formToken) || other.formToken == formToken)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.username, username) || other.username == username)&&(identical(other.banner, banner) || other.banner == banner)&&const DeepCollectionEquality().equals(other.latestRelease, latestRelease)&&const DeepCollectionEquality().equals(other.latestUpload, latestUpload)&&const DeepCollectionEquality().equals(other.sections, sections));
}


@override
int get hashCode => Object.hash(runtimeType,formToken,avatarUrl,username,banner,const DeepCollectionEquality().hash(latestRelease),const DeepCollectionEquality().hash(latestUpload),const DeepCollectionEquality().hash(sections));

@override
String toString() {
  return 'ApiHomePage(formToken: $formToken, avatarUrl: $avatarUrl, username: $username, banner: $banner, latestRelease: $latestRelease, latestUpload: $latestUpload, sections: $sections)';
}


}

/// @nodoc
abstract mixin class $ApiHomePageCopyWith<$Res>  {
  factory $ApiHomePageCopyWith(ApiHomePage value, $Res Function(ApiHomePage) _then) = _$ApiHomePageCopyWithImpl;
@useResult
$Res call({
 String? formToken, String? avatarUrl, String? username, ApiBanner? banner, List<ApiVideoCard> latestRelease, List<ApiVideoCard> latestUpload, List<ApiHomeSection> sections
});


$ApiBannerCopyWith<$Res>? get banner;

}
/// @nodoc
class _$ApiHomePageCopyWithImpl<$Res>
    implements $ApiHomePageCopyWith<$Res> {
  _$ApiHomePageCopyWithImpl(this._self, this._then);

  final ApiHomePage _self;
  final $Res Function(ApiHomePage) _then;

/// Create a copy of ApiHomePage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? formToken = freezed,Object? avatarUrl = freezed,Object? username = freezed,Object? banner = freezed,Object? latestRelease = null,Object? latestUpload = null,Object? sections = null,}) {
  return _then(_self.copyWith(
formToken: freezed == formToken ? _self.formToken : formToken // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as ApiBanner?,latestRelease: null == latestRelease ? _self.latestRelease : latestRelease // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,latestUpload: null == latestUpload ? _self.latestUpload : latestUpload // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<ApiHomeSection>,
  ));
}
/// Create a copy of ApiHomePage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiBannerCopyWith<$Res>? get banner {
    if (_self.banner == null) {
    return null;
  }

  return $ApiBannerCopyWith<$Res>(_self.banner!, (value) {
    return _then(_self.copyWith(banner: value));
  });
}
}


/// Adds pattern-matching-related methods to [ApiHomePage].
extension ApiHomePagePatterns on ApiHomePage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiHomePage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiHomePage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiHomePage value)  $default,){
final _that = this;
switch (_that) {
case _ApiHomePage():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiHomePage value)?  $default,){
final _that = this;
switch (_that) {
case _ApiHomePage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? formToken,  String? avatarUrl,  String? username,  ApiBanner? banner,  List<ApiVideoCard> latestRelease,  List<ApiVideoCard> latestUpload,  List<ApiHomeSection> sections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiHomePage() when $default != null:
return $default(_that.formToken,_that.avatarUrl,_that.username,_that.banner,_that.latestRelease,_that.latestUpload,_that.sections);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? formToken,  String? avatarUrl,  String? username,  ApiBanner? banner,  List<ApiVideoCard> latestRelease,  List<ApiVideoCard> latestUpload,  List<ApiHomeSection> sections)  $default,) {final _that = this;
switch (_that) {
case _ApiHomePage():
return $default(_that.formToken,_that.avatarUrl,_that.username,_that.banner,_that.latestRelease,_that.latestUpload,_that.sections);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? formToken,  String? avatarUrl,  String? username,  ApiBanner? banner,  List<ApiVideoCard> latestRelease,  List<ApiVideoCard> latestUpload,  List<ApiHomeSection> sections)?  $default,) {final _that = this;
switch (_that) {
case _ApiHomePage() when $default != null:
return $default(_that.formToken,_that.avatarUrl,_that.username,_that.banner,_that.latestRelease,_that.latestUpload,_that.sections);case _:
  return null;

}
}

}

/// @nodoc


class _ApiHomePage implements ApiHomePage {
  const _ApiHomePage({this.formToken, this.avatarUrl, this.username, this.banner, required final  List<ApiVideoCard> latestRelease, required final  List<ApiVideoCard> latestUpload, required final  List<ApiHomeSection> sections}): _latestRelease = latestRelease,_latestUpload = latestUpload,_sections = sections;
  

@override final  String? formToken;
@override final  String? avatarUrl;
@override final  String? username;
@override final  ApiBanner? banner;
 final  List<ApiVideoCard> _latestRelease;
@override List<ApiVideoCard> get latestRelease {
  if (_latestRelease is EqualUnmodifiableListView) return _latestRelease;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_latestRelease);
}

 final  List<ApiVideoCard> _latestUpload;
@override List<ApiVideoCard> get latestUpload {
  if (_latestUpload is EqualUnmodifiableListView) return _latestUpload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_latestUpload);
}

 final  List<ApiHomeSection> _sections;
@override List<ApiHomeSection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}


/// Create a copy of ApiHomePage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiHomePageCopyWith<_ApiHomePage> get copyWith => __$ApiHomePageCopyWithImpl<_ApiHomePage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiHomePage&&(identical(other.formToken, formToken) || other.formToken == formToken)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.username, username) || other.username == username)&&(identical(other.banner, banner) || other.banner == banner)&&const DeepCollectionEquality().equals(other._latestRelease, _latestRelease)&&const DeepCollectionEquality().equals(other._latestUpload, _latestUpload)&&const DeepCollectionEquality().equals(other._sections, _sections));
}


@override
int get hashCode => Object.hash(runtimeType,formToken,avatarUrl,username,banner,const DeepCollectionEquality().hash(_latestRelease),const DeepCollectionEquality().hash(_latestUpload),const DeepCollectionEquality().hash(_sections));

@override
String toString() {
  return 'ApiHomePage(formToken: $formToken, avatarUrl: $avatarUrl, username: $username, banner: $banner, latestRelease: $latestRelease, latestUpload: $latestUpload, sections: $sections)';
}


}

/// @nodoc
abstract mixin class _$ApiHomePageCopyWith<$Res> implements $ApiHomePageCopyWith<$Res> {
  factory _$ApiHomePageCopyWith(_ApiHomePage value, $Res Function(_ApiHomePage) _then) = __$ApiHomePageCopyWithImpl;
@override @useResult
$Res call({
 String? formToken, String? avatarUrl, String? username, ApiBanner? banner, List<ApiVideoCard> latestRelease, List<ApiVideoCard> latestUpload, List<ApiHomeSection> sections
});


@override $ApiBannerCopyWith<$Res>? get banner;

}
/// @nodoc
class __$ApiHomePageCopyWithImpl<$Res>
    implements _$ApiHomePageCopyWith<$Res> {
  __$ApiHomePageCopyWithImpl(this._self, this._then);

  final _ApiHomePage _self;
  final $Res Function(_ApiHomePage) _then;

/// Create a copy of ApiHomePage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? formToken = freezed,Object? avatarUrl = freezed,Object? username = freezed,Object? banner = freezed,Object? latestRelease = null,Object? latestUpload = null,Object? sections = null,}) {
  return _then(_ApiHomePage(
formToken: freezed == formToken ? _self.formToken : formToken // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as ApiBanner?,latestRelease: null == latestRelease ? _self._latestRelease : latestRelease // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,latestUpload: null == latestUpload ? _self._latestUpload : latestUpload // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<ApiHomeSection>,
  ));
}

/// Create a copy of ApiHomePage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiBannerCopyWith<$Res>? get banner {
    if (_self.banner == null) {
    return null;
  }

  return $ApiBannerCopyWith<$Res>(_self.banner!, (value) {
    return _then(_self.copyWith(banner: value));
  });
}
}

/// @nodoc
mixin _$ApiHomeSection {

 String get name; List<ApiVideoCard> get videos;
/// Create a copy of ApiHomeSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiHomeSectionCopyWith<ApiHomeSection> get copyWith => _$ApiHomeSectionCopyWithImpl<ApiHomeSection>(this as ApiHomeSection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiHomeSection&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.videos, videos));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(videos));

@override
String toString() {
  return 'ApiHomeSection(name: $name, videos: $videos)';
}


}

/// @nodoc
abstract mixin class $ApiHomeSectionCopyWith<$Res>  {
  factory $ApiHomeSectionCopyWith(ApiHomeSection value, $Res Function(ApiHomeSection) _then) = _$ApiHomeSectionCopyWithImpl;
@useResult
$Res call({
 String name, List<ApiVideoCard> videos
});




}
/// @nodoc
class _$ApiHomeSectionCopyWithImpl<$Res>
    implements $ApiHomeSectionCopyWith<$Res> {
  _$ApiHomeSectionCopyWithImpl(this._self, this._then);

  final ApiHomeSection _self;
  final $Res Function(ApiHomeSection) _then;

/// Create a copy of ApiHomeSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? videos = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiHomeSection].
extension ApiHomeSectionPatterns on ApiHomeSection {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiHomeSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiHomeSection() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiHomeSection value)  $default,){
final _that = this;
switch (_that) {
case _ApiHomeSection():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiHomeSection value)?  $default,){
final _that = this;
switch (_that) {
case _ApiHomeSection() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<ApiVideoCard> videos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiHomeSection() when $default != null:
return $default(_that.name,_that.videos);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<ApiVideoCard> videos)  $default,) {final _that = this;
switch (_that) {
case _ApiHomeSection():
return $default(_that.name,_that.videos);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<ApiVideoCard> videos)?  $default,) {final _that = this;
switch (_that) {
case _ApiHomeSection() when $default != null:
return $default(_that.name,_that.videos);case _:
  return null;

}
}

}

/// @nodoc


class _ApiHomeSection implements ApiHomeSection {
  const _ApiHomeSection({required this.name, required final  List<ApiVideoCard> videos}): _videos = videos;
  

@override final  String name;
 final  List<ApiVideoCard> _videos;
@override List<ApiVideoCard> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}


/// Create a copy of ApiHomeSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiHomeSectionCopyWith<_ApiHomeSection> get copyWith => __$ApiHomeSectionCopyWithImpl<_ApiHomeSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiHomeSection&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._videos, _videos));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_videos));

@override
String toString() {
  return 'ApiHomeSection(name: $name, videos: $videos)';
}


}

/// @nodoc
abstract mixin class _$ApiHomeSectionCopyWith<$Res> implements $ApiHomeSectionCopyWith<$Res> {
  factory _$ApiHomeSectionCopyWith(_ApiHomeSection value, $Res Function(_ApiHomeSection) _then) = __$ApiHomeSectionCopyWithImpl;
@override @useResult
$Res call({
 String name, List<ApiVideoCard> videos
});




}
/// @nodoc
class __$ApiHomeSectionCopyWithImpl<$Res>
    implements _$ApiHomeSectionCopyWith<$Res> {
  __$ApiHomeSectionCopyWithImpl(this._self, this._then);

  final _ApiHomeSection _self;
  final $Res Function(_ApiHomeSection) _then;

/// Create a copy of ApiHomeSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? videos = null,}) {
  return _then(_ApiHomeSection(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,
  ));
}


}

/// @nodoc
mixin _$ApiMyListInfo {

 bool get isWatchLater; List<ApiMyListItem> get items;
/// Create a copy of ApiMyListInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiMyListInfoCopyWith<ApiMyListInfo> get copyWith => _$ApiMyListInfoCopyWithImpl<ApiMyListInfo>(this as ApiMyListInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiMyListInfo&&(identical(other.isWatchLater, isWatchLater) || other.isWatchLater == isWatchLater)&&const DeepCollectionEquality().equals(other.items, items));
}


@override
int get hashCode => Object.hash(runtimeType,isWatchLater,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ApiMyListInfo(isWatchLater: $isWatchLater, items: $items)';
}


}

/// @nodoc
abstract mixin class $ApiMyListInfoCopyWith<$Res>  {
  factory $ApiMyListInfoCopyWith(ApiMyListInfo value, $Res Function(ApiMyListInfo) _then) = _$ApiMyListInfoCopyWithImpl;
@useResult
$Res call({
 bool isWatchLater, List<ApiMyListItem> items
});




}
/// @nodoc
class _$ApiMyListInfoCopyWithImpl<$Res>
    implements $ApiMyListInfoCopyWith<$Res> {
  _$ApiMyListInfoCopyWithImpl(this._self, this._then);

  final ApiMyListInfo _self;
  final $Res Function(ApiMyListInfo) _then;

/// Create a copy of ApiMyListInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isWatchLater = null,Object? items = null,}) {
  return _then(_self.copyWith(
isWatchLater: null == isWatchLater ? _self.isWatchLater : isWatchLater // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ApiMyListItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiMyListInfo].
extension ApiMyListInfoPatterns on ApiMyListInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiMyListInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiMyListInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiMyListInfo value)  $default,){
final _that = this;
switch (_that) {
case _ApiMyListInfo():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiMyListInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ApiMyListInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isWatchLater,  List<ApiMyListItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiMyListInfo() when $default != null:
return $default(_that.isWatchLater,_that.items);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isWatchLater,  List<ApiMyListItem> items)  $default,) {final _that = this;
switch (_that) {
case _ApiMyListInfo():
return $default(_that.isWatchLater,_that.items);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isWatchLater,  List<ApiMyListItem> items)?  $default,) {final _that = this;
switch (_that) {
case _ApiMyListInfo() when $default != null:
return $default(_that.isWatchLater,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _ApiMyListInfo implements ApiMyListInfo {
  const _ApiMyListInfo({required this.isWatchLater, required final  List<ApiMyListItem> items}): _items = items;
  

@override final  bool isWatchLater;
 final  List<ApiMyListItem> _items;
@override List<ApiMyListItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ApiMyListInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiMyListInfoCopyWith<_ApiMyListInfo> get copyWith => __$ApiMyListInfoCopyWithImpl<_ApiMyListInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiMyListInfo&&(identical(other.isWatchLater, isWatchLater) || other.isWatchLater == isWatchLater)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,isWatchLater,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ApiMyListInfo(isWatchLater: $isWatchLater, items: $items)';
}


}

/// @nodoc
abstract mixin class _$ApiMyListInfoCopyWith<$Res> implements $ApiMyListInfoCopyWith<$Res> {
  factory _$ApiMyListInfoCopyWith(_ApiMyListInfo value, $Res Function(_ApiMyListInfo) _then) = __$ApiMyListInfoCopyWithImpl;
@override @useResult
$Res call({
 bool isWatchLater, List<ApiMyListItem> items
});




}
/// @nodoc
class __$ApiMyListInfoCopyWithImpl<$Res>
    implements _$ApiMyListInfoCopyWith<$Res> {
  __$ApiMyListInfoCopyWithImpl(this._self, this._then);

  final _ApiMyListInfo _self;
  final $Res Function(_ApiMyListInfo) _then;

/// Create a copy of ApiMyListInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isWatchLater = null,Object? items = null,}) {
  return _then(_ApiMyListInfo(
isWatchLater: null == isWatchLater ? _self.isWatchLater : isWatchLater // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ApiMyListItem>,
  ));
}


}

/// @nodoc
mixin _$ApiMyListItem {

 String get code; String get title; bool get isSelected;
/// Create a copy of ApiMyListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiMyListItemCopyWith<ApiMyListItem> get copyWith => _$ApiMyListItemCopyWithImpl<ApiMyListItem>(this as ApiMyListItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiMyListItem&&(identical(other.code, code) || other.code == code)&&(identical(other.title, title) || other.title == title)&&(identical(other.isSelected, isSelected) || other.isSelected == isSelected));
}


@override
int get hashCode => Object.hash(runtimeType,code,title,isSelected);

@override
String toString() {
  return 'ApiMyListItem(code: $code, title: $title, isSelected: $isSelected)';
}


}

/// @nodoc
abstract mixin class $ApiMyListItemCopyWith<$Res>  {
  factory $ApiMyListItemCopyWith(ApiMyListItem value, $Res Function(ApiMyListItem) _then) = _$ApiMyListItemCopyWithImpl;
@useResult
$Res call({
 String code, String title, bool isSelected
});




}
/// @nodoc
class _$ApiMyListItemCopyWithImpl<$Res>
    implements $ApiMyListItemCopyWith<$Res> {
  _$ApiMyListItemCopyWithImpl(this._self, this._then);

  final ApiMyListItem _self;
  final $Res Function(ApiMyListItem) _then;

/// Create a copy of ApiMyListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? title = null,Object? isSelected = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isSelected: null == isSelected ? _self.isSelected : isSelected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiMyListItem].
extension ApiMyListItemPatterns on ApiMyListItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiMyListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiMyListItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiMyListItem value)  $default,){
final _that = this;
switch (_that) {
case _ApiMyListItem():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiMyListItem value)?  $default,){
final _that = this;
switch (_that) {
case _ApiMyListItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String title,  bool isSelected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiMyListItem() when $default != null:
return $default(_that.code,_that.title,_that.isSelected);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String title,  bool isSelected)  $default,) {final _that = this;
switch (_that) {
case _ApiMyListItem():
return $default(_that.code,_that.title,_that.isSelected);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String title,  bool isSelected)?  $default,) {final _that = this;
switch (_that) {
case _ApiMyListItem() when $default != null:
return $default(_that.code,_that.title,_that.isSelected);case _:
  return null;

}
}

}

/// @nodoc


class _ApiMyListItem implements ApiMyListItem {
  const _ApiMyListItem({required this.code, required this.title, required this.isSelected});
  

@override final  String code;
@override final  String title;
@override final  bool isSelected;

/// Create a copy of ApiMyListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiMyListItemCopyWith<_ApiMyListItem> get copyWith => __$ApiMyListItemCopyWithImpl<_ApiMyListItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiMyListItem&&(identical(other.code, code) || other.code == code)&&(identical(other.title, title) || other.title == title)&&(identical(other.isSelected, isSelected) || other.isSelected == isSelected));
}


@override
int get hashCode => Object.hash(runtimeType,code,title,isSelected);

@override
String toString() {
  return 'ApiMyListItem(code: $code, title: $title, isSelected: $isSelected)';
}


}

/// @nodoc
abstract mixin class _$ApiMyListItemCopyWith<$Res> implements $ApiMyListItemCopyWith<$Res> {
  factory _$ApiMyListItemCopyWith(_ApiMyListItem value, $Res Function(_ApiMyListItem) _then) = __$ApiMyListItemCopyWithImpl;
@override @useResult
$Res call({
 String code, String title, bool isSelected
});




}
/// @nodoc
class __$ApiMyListItemCopyWithImpl<$Res>
    implements _$ApiMyListItemCopyWith<$Res> {
  __$ApiMyListItemCopyWithImpl(this._self, this._then);

  final _ApiMyListItem _self;
  final $Res Function(_ApiMyListItem) _then;

/// Create a copy of ApiMyListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? title = null,Object? isSelected = null,}) {
  return _then(_ApiMyListItem(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isSelected: null == isSelected ? _self.isSelected : isSelected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ApiPlayHistory {

 String get videoId; String get title; String get coverUrl; double get progress; int get duration; PlatformInt64 get lastPlayedAt;
/// Create a copy of ApiPlayHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiPlayHistoryCopyWith<ApiPlayHistory> get copyWith => _$ApiPlayHistoryCopyWithImpl<ApiPlayHistory>(this as ApiPlayHistory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiPlayHistory&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.lastPlayedAt, lastPlayedAt) || other.lastPlayedAt == lastPlayedAt));
}


@override
int get hashCode => Object.hash(runtimeType,videoId,title,coverUrl,progress,duration,lastPlayedAt);

@override
String toString() {
  return 'ApiPlayHistory(videoId: $videoId, title: $title, coverUrl: $coverUrl, progress: $progress, duration: $duration, lastPlayedAt: $lastPlayedAt)';
}


}

/// @nodoc
abstract mixin class $ApiPlayHistoryCopyWith<$Res>  {
  factory $ApiPlayHistoryCopyWith(ApiPlayHistory value, $Res Function(ApiPlayHistory) _then) = _$ApiPlayHistoryCopyWithImpl;
@useResult
$Res call({
 String videoId, String title, String coverUrl, double progress, int duration, PlatformInt64 lastPlayedAt
});




}
/// @nodoc
class _$ApiPlayHistoryCopyWithImpl<$Res>
    implements $ApiPlayHistoryCopyWith<$Res> {
  _$ApiPlayHistoryCopyWithImpl(this._self, this._then);

  final ApiPlayHistory _self;
  final $Res Function(ApiPlayHistory) _then;

/// Create a copy of ApiPlayHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videoId = null,Object? title = null,Object? coverUrl = null,Object? progress = null,Object? duration = null,Object? lastPlayedAt = null,}) {
  return _then(_self.copyWith(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,lastPlayedAt: null == lastPlayedAt ? _self.lastPlayedAt : lastPlayedAt // ignore: cast_nullable_to_non_nullable
as PlatformInt64,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiPlayHistory].
extension ApiPlayHistoryPatterns on ApiPlayHistory {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiPlayHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiPlayHistory() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiPlayHistory value)  $default,){
final _that = this;
switch (_that) {
case _ApiPlayHistory():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiPlayHistory value)?  $default,){
final _that = this;
switch (_that) {
case _ApiPlayHistory() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String videoId,  String title,  String coverUrl,  double progress,  int duration,  PlatformInt64 lastPlayedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiPlayHistory() when $default != null:
return $default(_that.videoId,_that.title,_that.coverUrl,_that.progress,_that.duration,_that.lastPlayedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String videoId,  String title,  String coverUrl,  double progress,  int duration,  PlatformInt64 lastPlayedAt)  $default,) {final _that = this;
switch (_that) {
case _ApiPlayHistory():
return $default(_that.videoId,_that.title,_that.coverUrl,_that.progress,_that.duration,_that.lastPlayedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String videoId,  String title,  String coverUrl,  double progress,  int duration,  PlatformInt64 lastPlayedAt)?  $default,) {final _that = this;
switch (_that) {
case _ApiPlayHistory() when $default != null:
return $default(_that.videoId,_that.title,_that.coverUrl,_that.progress,_that.duration,_that.lastPlayedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ApiPlayHistory implements ApiPlayHistory {
  const _ApiPlayHistory({required this.videoId, required this.title, required this.coverUrl, required this.progress, required this.duration, required this.lastPlayedAt});
  

@override final  String videoId;
@override final  String title;
@override final  String coverUrl;
@override final  double progress;
@override final  int duration;
@override final  PlatformInt64 lastPlayedAt;

/// Create a copy of ApiPlayHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiPlayHistoryCopyWith<_ApiPlayHistory> get copyWith => __$ApiPlayHistoryCopyWithImpl<_ApiPlayHistory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiPlayHistory&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.lastPlayedAt, lastPlayedAt) || other.lastPlayedAt == lastPlayedAt));
}


@override
int get hashCode => Object.hash(runtimeType,videoId,title,coverUrl,progress,duration,lastPlayedAt);

@override
String toString() {
  return 'ApiPlayHistory(videoId: $videoId, title: $title, coverUrl: $coverUrl, progress: $progress, duration: $duration, lastPlayedAt: $lastPlayedAt)';
}


}

/// @nodoc
abstract mixin class _$ApiPlayHistoryCopyWith<$Res> implements $ApiPlayHistoryCopyWith<$Res> {
  factory _$ApiPlayHistoryCopyWith(_ApiPlayHistory value, $Res Function(_ApiPlayHistory) _then) = __$ApiPlayHistoryCopyWithImpl;
@override @useResult
$Res call({
 String videoId, String title, String coverUrl, double progress, int duration, PlatformInt64 lastPlayedAt
});




}
/// @nodoc
class __$ApiPlayHistoryCopyWithImpl<$Res>
    implements _$ApiPlayHistoryCopyWith<$Res> {
  __$ApiPlayHistoryCopyWithImpl(this._self, this._then);

  final _ApiPlayHistory _self;
  final $Res Function(_ApiPlayHistory) _then;

/// Create a copy of ApiPlayHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videoId = null,Object? title = null,Object? coverUrl = null,Object? progress = null,Object? duration = null,Object? lastPlayedAt = null,}) {
  return _then(_ApiPlayHistory(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,lastPlayedAt: null == lastPlayedAt ? _self.lastPlayedAt : lastPlayedAt // ignore: cast_nullable_to_non_nullable
as PlatformInt64,
  ));
}


}

/// @nodoc
mixin _$ApiPlayHistoryList {

 List<ApiPlayHistory> get items; int get total; int get page; bool get hasNext;
/// Create a copy of ApiPlayHistoryList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiPlayHistoryListCopyWith<ApiPlayHistoryList> get copyWith => _$ApiPlayHistoryListCopyWithImpl<ApiPlayHistoryList>(this as ApiPlayHistoryList, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiPlayHistoryList&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,page,hasNext);

@override
String toString() {
  return 'ApiPlayHistoryList(items: $items, total: $total, page: $page, hasNext: $hasNext)';
}


}

/// @nodoc
abstract mixin class $ApiPlayHistoryListCopyWith<$Res>  {
  factory $ApiPlayHistoryListCopyWith(ApiPlayHistoryList value, $Res Function(ApiPlayHistoryList) _then) = _$ApiPlayHistoryListCopyWithImpl;
@useResult
$Res call({
 List<ApiPlayHistory> items, int total, int page, bool hasNext
});




}
/// @nodoc
class _$ApiPlayHistoryListCopyWithImpl<$Res>
    implements $ApiPlayHistoryListCopyWith<$Res> {
  _$ApiPlayHistoryListCopyWithImpl(this._self, this._then);

  final ApiPlayHistoryList _self;
  final $Res Function(ApiPlayHistoryList) _then;

/// Create a copy of ApiPlayHistoryList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,Object? hasNext = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ApiPlayHistory>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiPlayHistoryList].
extension ApiPlayHistoryListPatterns on ApiPlayHistoryList {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiPlayHistoryList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiPlayHistoryList() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiPlayHistoryList value)  $default,){
final _that = this;
switch (_that) {
case _ApiPlayHistoryList():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiPlayHistoryList value)?  $default,){
final _that = this;
switch (_that) {
case _ApiPlayHistoryList() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ApiPlayHistory> items,  int total,  int page,  bool hasNext)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiPlayHistoryList() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.hasNext);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ApiPlayHistory> items,  int total,  int page,  bool hasNext)  $default,) {final _that = this;
switch (_that) {
case _ApiPlayHistoryList():
return $default(_that.items,_that.total,_that.page,_that.hasNext);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ApiPlayHistory> items,  int total,  int page,  bool hasNext)?  $default,) {final _that = this;
switch (_that) {
case _ApiPlayHistoryList() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.hasNext);case _:
  return null;

}
}

}

/// @nodoc


class _ApiPlayHistoryList implements ApiPlayHistoryList {
  const _ApiPlayHistoryList({required final  List<ApiPlayHistory> items, required this.total, required this.page, required this.hasNext}): _items = items;
  

 final  List<ApiPlayHistory> _items;
@override List<ApiPlayHistory> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;
@override final  int page;
@override final  bool hasNext;

/// Create a copy of ApiPlayHistoryList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiPlayHistoryListCopyWith<_ApiPlayHistoryList> get copyWith => __$ApiPlayHistoryListCopyWithImpl<_ApiPlayHistoryList>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiPlayHistoryList&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,page,hasNext);

@override
String toString() {
  return 'ApiPlayHistoryList(items: $items, total: $total, page: $page, hasNext: $hasNext)';
}


}

/// @nodoc
abstract mixin class _$ApiPlayHistoryListCopyWith<$Res> implements $ApiPlayHistoryListCopyWith<$Res> {
  factory _$ApiPlayHistoryListCopyWith(_ApiPlayHistoryList value, $Res Function(_ApiPlayHistoryList) _then) = __$ApiPlayHistoryListCopyWithImpl;
@override @useResult
$Res call({
 List<ApiPlayHistory> items, int total, int page, bool hasNext
});




}
/// @nodoc
class __$ApiPlayHistoryListCopyWithImpl<$Res>
    implements _$ApiPlayHistoryListCopyWith<$Res> {
  __$ApiPlayHistoryListCopyWithImpl(this._self, this._then);

  final _ApiPlayHistoryList _self;
  final $Res Function(_ApiPlayHistoryList) _then;

/// Create a copy of ApiPlayHistoryList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,Object? hasNext = null,}) {
  return _then(_ApiPlayHistoryList(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ApiPlayHistory>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ApiPlaylistInfo {

 String? get name; List<ApiVideoCard> get videos;
/// Create a copy of ApiPlaylistInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiPlaylistInfoCopyWith<ApiPlaylistInfo> get copyWith => _$ApiPlaylistInfoCopyWithImpl<ApiPlaylistInfo>(this as ApiPlaylistInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiPlaylistInfo&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.videos, videos));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(videos));

@override
String toString() {
  return 'ApiPlaylistInfo(name: $name, videos: $videos)';
}


}

/// @nodoc
abstract mixin class $ApiPlaylistInfoCopyWith<$Res>  {
  factory $ApiPlaylistInfoCopyWith(ApiPlaylistInfo value, $Res Function(ApiPlaylistInfo) _then) = _$ApiPlaylistInfoCopyWithImpl;
@useResult
$Res call({
 String? name, List<ApiVideoCard> videos
});




}
/// @nodoc
class _$ApiPlaylistInfoCopyWithImpl<$Res>
    implements $ApiPlaylistInfoCopyWith<$Res> {
  _$ApiPlaylistInfoCopyWithImpl(this._self, this._then);

  final ApiPlaylistInfo _self;
  final $Res Function(ApiPlaylistInfo) _then;

/// Create a copy of ApiPlaylistInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? videos = null,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiPlaylistInfo].
extension ApiPlaylistInfoPatterns on ApiPlaylistInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiPlaylistInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiPlaylistInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiPlaylistInfo value)  $default,){
final _that = this;
switch (_that) {
case _ApiPlaylistInfo():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiPlaylistInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ApiPlaylistInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  List<ApiVideoCard> videos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiPlaylistInfo() when $default != null:
return $default(_that.name,_that.videos);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  List<ApiVideoCard> videos)  $default,) {final _that = this;
switch (_that) {
case _ApiPlaylistInfo():
return $default(_that.name,_that.videos);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  List<ApiVideoCard> videos)?  $default,) {final _that = this;
switch (_that) {
case _ApiPlaylistInfo() when $default != null:
return $default(_that.name,_that.videos);case _:
  return null;

}
}

}

/// @nodoc


class _ApiPlaylistInfo implements ApiPlaylistInfo {
  const _ApiPlaylistInfo({this.name, required final  List<ApiVideoCard> videos}): _videos = videos;
  

@override final  String? name;
 final  List<ApiVideoCard> _videos;
@override List<ApiVideoCard> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}


/// Create a copy of ApiPlaylistInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiPlaylistInfoCopyWith<_ApiPlaylistInfo> get copyWith => __$ApiPlaylistInfoCopyWithImpl<_ApiPlaylistInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiPlaylistInfo&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._videos, _videos));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_videos));

@override
String toString() {
  return 'ApiPlaylistInfo(name: $name, videos: $videos)';
}


}

/// @nodoc
abstract mixin class _$ApiPlaylistInfoCopyWith<$Res> implements $ApiPlaylistInfoCopyWith<$Res> {
  factory _$ApiPlaylistInfoCopyWith(_ApiPlaylistInfo value, $Res Function(_ApiPlaylistInfo) _then) = __$ApiPlaylistInfoCopyWithImpl;
@override @useResult
$Res call({
 String? name, List<ApiVideoCard> videos
});




}
/// @nodoc
class __$ApiPlaylistInfoCopyWithImpl<$Res>
    implements _$ApiPlaylistInfoCopyWith<$Res> {
  __$ApiPlaylistInfoCopyWithImpl(this._self, this._then);

  final _ApiPlaylistInfo _self;
  final $Res Function(_ApiPlaylistInfo) _then;

/// Create a copy of ApiPlaylistInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? videos = null,}) {
  return _then(_ApiPlaylistInfo(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,
  ));
}


}

/// @nodoc
mixin _$ApiSearchFilters {

 String? get query; String? get genre; List<String> get tags; bool get broadMatch; String? get sort; String? get year; String? get month; String? get date; String? get duration; int get page;
/// Create a copy of ApiSearchFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiSearchFiltersCopyWith<ApiSearchFilters> get copyWith => _$ApiSearchFiltersCopyWithImpl<ApiSearchFilters>(this as ApiSearchFilters, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiSearchFilters&&(identical(other.query, query) || other.query == query)&&(identical(other.genre, genre) || other.genre == genre)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.broadMatch, broadMatch) || other.broadMatch == broadMatch)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.date, date) || other.date == date)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.page, page) || other.page == page));
}


@override
int get hashCode => Object.hash(runtimeType,query,genre,const DeepCollectionEquality().hash(tags),broadMatch,sort,year,month,date,duration,page);

@override
String toString() {
  return 'ApiSearchFilters(query: $query, genre: $genre, tags: $tags, broadMatch: $broadMatch, sort: $sort, year: $year, month: $month, date: $date, duration: $duration, page: $page)';
}


}

/// @nodoc
abstract mixin class $ApiSearchFiltersCopyWith<$Res>  {
  factory $ApiSearchFiltersCopyWith(ApiSearchFilters value, $Res Function(ApiSearchFilters) _then) = _$ApiSearchFiltersCopyWithImpl;
@useResult
$Res call({
 String? query, String? genre, List<String> tags, bool broadMatch, String? sort, String? year, String? month, String? date, String? duration, int page
});




}
/// @nodoc
class _$ApiSearchFiltersCopyWithImpl<$Res>
    implements $ApiSearchFiltersCopyWith<$Res> {
  _$ApiSearchFiltersCopyWithImpl(this._self, this._then);

  final ApiSearchFilters _self;
  final $Res Function(ApiSearchFilters) _then;

/// Create a copy of ApiSearchFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = freezed,Object? genre = freezed,Object? tags = null,Object? broadMatch = null,Object? sort = freezed,Object? year = freezed,Object? month = freezed,Object? date = freezed,Object? duration = freezed,Object? page = null,}) {
  return _then(_self.copyWith(
query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,broadMatch: null == broadMatch ? _self.broadMatch : broadMatch // ignore: cast_nullable_to_non_nullable
as bool,sort: freezed == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String?,month: freezed == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiSearchFilters].
extension ApiSearchFiltersPatterns on ApiSearchFilters {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiSearchFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiSearchFilters() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiSearchFilters value)  $default,){
final _that = this;
switch (_that) {
case _ApiSearchFilters():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiSearchFilters value)?  $default,){
final _that = this;
switch (_that) {
case _ApiSearchFilters() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? query,  String? genre,  List<String> tags,  bool broadMatch,  String? sort,  String? year,  String? month,  String? date,  String? duration,  int page)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiSearchFilters() when $default != null:
return $default(_that.query,_that.genre,_that.tags,_that.broadMatch,_that.sort,_that.year,_that.month,_that.date,_that.duration,_that.page);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? query,  String? genre,  List<String> tags,  bool broadMatch,  String? sort,  String? year,  String? month,  String? date,  String? duration,  int page)  $default,) {final _that = this;
switch (_that) {
case _ApiSearchFilters():
return $default(_that.query,_that.genre,_that.tags,_that.broadMatch,_that.sort,_that.year,_that.month,_that.date,_that.duration,_that.page);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? query,  String? genre,  List<String> tags,  bool broadMatch,  String? sort,  String? year,  String? month,  String? date,  String? duration,  int page)?  $default,) {final _that = this;
switch (_that) {
case _ApiSearchFilters() when $default != null:
return $default(_that.query,_that.genre,_that.tags,_that.broadMatch,_that.sort,_that.year,_that.month,_that.date,_that.duration,_that.page);case _:
  return null;

}
}

}

/// @nodoc


class _ApiSearchFilters extends ApiSearchFilters {
  const _ApiSearchFilters({this.query, this.genre, required final  List<String> tags, required this.broadMatch, this.sort, this.year, this.month, this.date, this.duration, required this.page}): _tags = tags,super._();
  

@override final  String? query;
@override final  String? genre;
 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  bool broadMatch;
@override final  String? sort;
@override final  String? year;
@override final  String? month;
@override final  String? date;
@override final  String? duration;
@override final  int page;

/// Create a copy of ApiSearchFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiSearchFiltersCopyWith<_ApiSearchFilters> get copyWith => __$ApiSearchFiltersCopyWithImpl<_ApiSearchFilters>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiSearchFilters&&(identical(other.query, query) || other.query == query)&&(identical(other.genre, genre) || other.genre == genre)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.broadMatch, broadMatch) || other.broadMatch == broadMatch)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.date, date) || other.date == date)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.page, page) || other.page == page));
}


@override
int get hashCode => Object.hash(runtimeType,query,genre,const DeepCollectionEquality().hash(_tags),broadMatch,sort,year,month,date,duration,page);

@override
String toString() {
  return 'ApiSearchFilters(query: $query, genre: $genre, tags: $tags, broadMatch: $broadMatch, sort: $sort, year: $year, month: $month, date: $date, duration: $duration, page: $page)';
}


}

/// @nodoc
abstract mixin class _$ApiSearchFiltersCopyWith<$Res> implements $ApiSearchFiltersCopyWith<$Res> {
  factory _$ApiSearchFiltersCopyWith(_ApiSearchFilters value, $Res Function(_ApiSearchFilters) _then) = __$ApiSearchFiltersCopyWithImpl;
@override @useResult
$Res call({
 String? query, String? genre, List<String> tags, bool broadMatch, String? sort, String? year, String? month, String? date, String? duration, int page
});




}
/// @nodoc
class __$ApiSearchFiltersCopyWithImpl<$Res>
    implements _$ApiSearchFiltersCopyWith<$Res> {
  __$ApiSearchFiltersCopyWithImpl(this._self, this._then);

  final _ApiSearchFilters _self;
  final $Res Function(_ApiSearchFilters) _then;

/// Create a copy of ApiSearchFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = freezed,Object? genre = freezed,Object? tags = null,Object? broadMatch = null,Object? sort = freezed,Object? year = freezed,Object? month = freezed,Object? date = freezed,Object? duration = freezed,Object? page = null,}) {
  return _then(_ApiSearchFilters(
query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,broadMatch: null == broadMatch ? _self.broadMatch : broadMatch // ignore: cast_nullable_to_non_nullable
as bool,sort: freezed == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String?,month: freezed == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ApiSearchResult {

 List<ApiVideoCard> get videos; int get total; int get page; bool get hasNext;
/// Create a copy of ApiSearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiSearchResultCopyWith<ApiSearchResult> get copyWith => _$ApiSearchResultCopyWithImpl<ApiSearchResult>(this as ApiSearchResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiSearchResult&&const DeepCollectionEquality().equals(other.videos, videos)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(videos),total,page,hasNext);

@override
String toString() {
  return 'ApiSearchResult(videos: $videos, total: $total, page: $page, hasNext: $hasNext)';
}


}

/// @nodoc
abstract mixin class $ApiSearchResultCopyWith<$Res>  {
  factory $ApiSearchResultCopyWith(ApiSearchResult value, $Res Function(ApiSearchResult) _then) = _$ApiSearchResultCopyWithImpl;
@useResult
$Res call({
 List<ApiVideoCard> videos, int total, int page, bool hasNext
});




}
/// @nodoc
class _$ApiSearchResultCopyWithImpl<$Res>
    implements $ApiSearchResultCopyWith<$Res> {
  _$ApiSearchResultCopyWithImpl(this._self, this._then);

  final ApiSearchResult _self;
  final $Res Function(ApiSearchResult) _then;

/// Create a copy of ApiSearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videos = null,Object? total = null,Object? page = null,Object? hasNext = null,}) {
  return _then(_self.copyWith(
videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiSearchResult].
extension ApiSearchResultPatterns on ApiSearchResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiSearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiSearchResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiSearchResult value)  $default,){
final _that = this;
switch (_that) {
case _ApiSearchResult():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiSearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _ApiSearchResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ApiVideoCard> videos,  int total,  int page,  bool hasNext)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiSearchResult() when $default != null:
return $default(_that.videos,_that.total,_that.page,_that.hasNext);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ApiVideoCard> videos,  int total,  int page,  bool hasNext)  $default,) {final _that = this;
switch (_that) {
case _ApiSearchResult():
return $default(_that.videos,_that.total,_that.page,_that.hasNext);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ApiVideoCard> videos,  int total,  int page,  bool hasNext)?  $default,) {final _that = this;
switch (_that) {
case _ApiSearchResult() when $default != null:
return $default(_that.videos,_that.total,_that.page,_that.hasNext);case _:
  return null;

}
}

}

/// @nodoc


class _ApiSearchResult implements ApiSearchResult {
  const _ApiSearchResult({required final  List<ApiVideoCard> videos, required this.total, required this.page, required this.hasNext}): _videos = videos;
  

 final  List<ApiVideoCard> _videos;
@override List<ApiVideoCard> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

@override final  int total;
@override final  int page;
@override final  bool hasNext;

/// Create a copy of ApiSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiSearchResultCopyWith<_ApiSearchResult> get copyWith => __$ApiSearchResultCopyWithImpl<_ApiSearchResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiSearchResult&&const DeepCollectionEquality().equals(other._videos, _videos)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_videos),total,page,hasNext);

@override
String toString() {
  return 'ApiSearchResult(videos: $videos, total: $total, page: $page, hasNext: $hasNext)';
}


}

/// @nodoc
abstract mixin class _$ApiSearchResultCopyWith<$Res> implements $ApiSearchResultCopyWith<$Res> {
  factory _$ApiSearchResultCopyWith(_ApiSearchResult value, $Res Function(_ApiSearchResult) _then) = __$ApiSearchResultCopyWithImpl;
@override @useResult
$Res call({
 List<ApiVideoCard> videos, int total, int page, bool hasNext
});




}
/// @nodoc
class __$ApiSearchResultCopyWithImpl<$Res>
    implements _$ApiSearchResultCopyWith<$Res> {
  __$ApiSearchResultCopyWithImpl(this._self, this._then);

  final _ApiSearchResult _self;
  final $Res Function(_ApiSearchResult) _then;

/// Create a copy of ApiSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videos = null,Object? total = null,Object? page = null,Object? hasNext = null,}) {
  return _then(_ApiSearchResult(
videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ApiSeriesInfo {

 String get id; String get title; List<ApiSeriesVideo> get videos; int get currentIndex;
/// Create a copy of ApiSeriesInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiSeriesInfoCopyWith<ApiSeriesInfo> get copyWith => _$ApiSeriesInfoCopyWithImpl<ApiSeriesInfo>(this as ApiSeriesInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiSeriesInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.videos, videos)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(videos),currentIndex);

@override
String toString() {
  return 'ApiSeriesInfo(id: $id, title: $title, videos: $videos, currentIndex: $currentIndex)';
}


}

/// @nodoc
abstract mixin class $ApiSeriesInfoCopyWith<$Res>  {
  factory $ApiSeriesInfoCopyWith(ApiSeriesInfo value, $Res Function(ApiSeriesInfo) _then) = _$ApiSeriesInfoCopyWithImpl;
@useResult
$Res call({
 String id, String title, List<ApiSeriesVideo> videos, int currentIndex
});




}
/// @nodoc
class _$ApiSeriesInfoCopyWithImpl<$Res>
    implements $ApiSeriesInfoCopyWith<$Res> {
  _$ApiSeriesInfoCopyWithImpl(this._self, this._then);

  final ApiSeriesInfo _self;
  final $Res Function(ApiSeriesInfo) _then;

/// Create a copy of ApiSeriesInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? videos = null,Object? currentIndex = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<ApiSeriesVideo>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiSeriesInfo].
extension ApiSeriesInfoPatterns on ApiSeriesInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiSeriesInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiSeriesInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiSeriesInfo value)  $default,){
final _that = this;
switch (_that) {
case _ApiSeriesInfo():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiSeriesInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ApiSeriesInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  List<ApiSeriesVideo> videos,  int currentIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiSeriesInfo() when $default != null:
return $default(_that.id,_that.title,_that.videos,_that.currentIndex);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  List<ApiSeriesVideo> videos,  int currentIndex)  $default,) {final _that = this;
switch (_that) {
case _ApiSeriesInfo():
return $default(_that.id,_that.title,_that.videos,_that.currentIndex);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  List<ApiSeriesVideo> videos,  int currentIndex)?  $default,) {final _that = this;
switch (_that) {
case _ApiSeriesInfo() when $default != null:
return $default(_that.id,_that.title,_that.videos,_that.currentIndex);case _:
  return null;

}
}

}

/// @nodoc


class _ApiSeriesInfo implements ApiSeriesInfo {
  const _ApiSeriesInfo({required this.id, required this.title, required final  List<ApiSeriesVideo> videos, required this.currentIndex}): _videos = videos;
  

@override final  String id;
@override final  String title;
 final  List<ApiSeriesVideo> _videos;
@override List<ApiSeriesVideo> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

@override final  int currentIndex;

/// Create a copy of ApiSeriesInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiSeriesInfoCopyWith<_ApiSeriesInfo> get copyWith => __$ApiSeriesInfoCopyWithImpl<_ApiSeriesInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiSeriesInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._videos, _videos)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(_videos),currentIndex);

@override
String toString() {
  return 'ApiSeriesInfo(id: $id, title: $title, videos: $videos, currentIndex: $currentIndex)';
}


}

/// @nodoc
abstract mixin class _$ApiSeriesInfoCopyWith<$Res> implements $ApiSeriesInfoCopyWith<$Res> {
  factory _$ApiSeriesInfoCopyWith(_ApiSeriesInfo value, $Res Function(_ApiSeriesInfo) _then) = __$ApiSeriesInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, List<ApiSeriesVideo> videos, int currentIndex
});




}
/// @nodoc
class __$ApiSeriesInfoCopyWithImpl<$Res>
    implements _$ApiSeriesInfoCopyWith<$Res> {
  __$ApiSeriesInfoCopyWithImpl(this._self, this._then);

  final _ApiSeriesInfo _self;
  final $Res Function(_ApiSeriesInfo) _then;

/// Create a copy of ApiSeriesInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? videos = null,Object? currentIndex = null,}) {
  return _then(_ApiSeriesInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<ApiSeriesVideo>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ApiSeriesVideo {

 String get id; String get title; String get coverUrl; String get episode;
/// Create a copy of ApiSeriesVideo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiSeriesVideoCopyWith<ApiSeriesVideo> get copyWith => _$ApiSeriesVideoCopyWithImpl<ApiSeriesVideo>(this as ApiSeriesVideo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiSeriesVideo&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.episode, episode) || other.episode == episode));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,coverUrl,episode);

@override
String toString() {
  return 'ApiSeriesVideo(id: $id, title: $title, coverUrl: $coverUrl, episode: $episode)';
}


}

/// @nodoc
abstract mixin class $ApiSeriesVideoCopyWith<$Res>  {
  factory $ApiSeriesVideoCopyWith(ApiSeriesVideo value, $Res Function(ApiSeriesVideo) _then) = _$ApiSeriesVideoCopyWithImpl;
@useResult
$Res call({
 String id, String title, String coverUrl, String episode
});




}
/// @nodoc
class _$ApiSeriesVideoCopyWithImpl<$Res>
    implements $ApiSeriesVideoCopyWith<$Res> {
  _$ApiSeriesVideoCopyWithImpl(this._self, this._then);

  final ApiSeriesVideo _self;
  final $Res Function(ApiSeriesVideo) _then;

/// Create a copy of ApiSeriesVideo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? coverUrl = null,Object? episode = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,episode: null == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiSeriesVideo].
extension ApiSeriesVideoPatterns on ApiSeriesVideo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiSeriesVideo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiSeriesVideo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiSeriesVideo value)  $default,){
final _that = this;
switch (_that) {
case _ApiSeriesVideo():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiSeriesVideo value)?  $default,){
final _that = this;
switch (_that) {
case _ApiSeriesVideo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String coverUrl,  String episode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiSeriesVideo() when $default != null:
return $default(_that.id,_that.title,_that.coverUrl,_that.episode);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String coverUrl,  String episode)  $default,) {final _that = this;
switch (_that) {
case _ApiSeriesVideo():
return $default(_that.id,_that.title,_that.coverUrl,_that.episode);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String coverUrl,  String episode)?  $default,) {final _that = this;
switch (_that) {
case _ApiSeriesVideo() when $default != null:
return $default(_that.id,_that.title,_that.coverUrl,_that.episode);case _:
  return null;

}
}

}

/// @nodoc


class _ApiSeriesVideo implements ApiSeriesVideo {
  const _ApiSeriesVideo({required this.id, required this.title, required this.coverUrl, required this.episode});
  

@override final  String id;
@override final  String title;
@override final  String coverUrl;
@override final  String episode;

/// Create a copy of ApiSeriesVideo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiSeriesVideoCopyWith<_ApiSeriesVideo> get copyWith => __$ApiSeriesVideoCopyWithImpl<_ApiSeriesVideo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiSeriesVideo&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.episode, episode) || other.episode == episode));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,coverUrl,episode);

@override
String toString() {
  return 'ApiSeriesVideo(id: $id, title: $title, coverUrl: $coverUrl, episode: $episode)';
}


}

/// @nodoc
abstract mixin class _$ApiSeriesVideoCopyWith<$Res> implements $ApiSeriesVideoCopyWith<$Res> {
  factory _$ApiSeriesVideoCopyWith(_ApiSeriesVideo value, $Res Function(_ApiSeriesVideo) _then) = __$ApiSeriesVideoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String coverUrl, String episode
});




}
/// @nodoc
class __$ApiSeriesVideoCopyWithImpl<$Res>
    implements _$ApiSeriesVideoCopyWith<$Res> {
  __$ApiSeriesVideoCopyWithImpl(this._self, this._then);

  final _ApiSeriesVideo _self;
  final $Res Function(_ApiSeriesVideo) _then;

/// Create a copy of ApiSeriesVideo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? coverUrl = null,Object? episode = null,}) {
  return _then(_ApiSeriesVideo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,episode: null == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ApiSubscriptionsPage {

 List<ApiAuthorInfo> get authors; List<ApiVideoCard> get videos; int get page; bool get hasNext;
/// Create a copy of ApiSubscriptionsPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiSubscriptionsPageCopyWith<ApiSubscriptionsPage> get copyWith => _$ApiSubscriptionsPageCopyWithImpl<ApiSubscriptionsPage>(this as ApiSubscriptionsPage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiSubscriptionsPage&&const DeepCollectionEquality().equals(other.authors, authors)&&const DeepCollectionEquality().equals(other.videos, videos)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(authors),const DeepCollectionEquality().hash(videos),page,hasNext);

@override
String toString() {
  return 'ApiSubscriptionsPage(authors: $authors, videos: $videos, page: $page, hasNext: $hasNext)';
}


}

/// @nodoc
abstract mixin class $ApiSubscriptionsPageCopyWith<$Res>  {
  factory $ApiSubscriptionsPageCopyWith(ApiSubscriptionsPage value, $Res Function(ApiSubscriptionsPage) _then) = _$ApiSubscriptionsPageCopyWithImpl;
@useResult
$Res call({
 List<ApiAuthorInfo> authors, List<ApiVideoCard> videos, int page, bool hasNext
});




}
/// @nodoc
class _$ApiSubscriptionsPageCopyWithImpl<$Res>
    implements $ApiSubscriptionsPageCopyWith<$Res> {
  _$ApiSubscriptionsPageCopyWithImpl(this._self, this._then);

  final ApiSubscriptionsPage _self;
  final $Res Function(ApiSubscriptionsPage) _then;

/// Create a copy of ApiSubscriptionsPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? authors = null,Object? videos = null,Object? page = null,Object? hasNext = null,}) {
  return _then(_self.copyWith(
authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<ApiAuthorInfo>,videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiSubscriptionsPage].
extension ApiSubscriptionsPagePatterns on ApiSubscriptionsPage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiSubscriptionsPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiSubscriptionsPage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiSubscriptionsPage value)  $default,){
final _that = this;
switch (_that) {
case _ApiSubscriptionsPage():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiSubscriptionsPage value)?  $default,){
final _that = this;
switch (_that) {
case _ApiSubscriptionsPage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ApiAuthorInfo> authors,  List<ApiVideoCard> videos,  int page,  bool hasNext)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiSubscriptionsPage() when $default != null:
return $default(_that.authors,_that.videos,_that.page,_that.hasNext);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ApiAuthorInfo> authors,  List<ApiVideoCard> videos,  int page,  bool hasNext)  $default,) {final _that = this;
switch (_that) {
case _ApiSubscriptionsPage():
return $default(_that.authors,_that.videos,_that.page,_that.hasNext);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ApiAuthorInfo> authors,  List<ApiVideoCard> videos,  int page,  bool hasNext)?  $default,) {final _that = this;
switch (_that) {
case _ApiSubscriptionsPage() when $default != null:
return $default(_that.authors,_that.videos,_that.page,_that.hasNext);case _:
  return null;

}
}

}

/// @nodoc


class _ApiSubscriptionsPage implements ApiSubscriptionsPage {
  const _ApiSubscriptionsPage({required final  List<ApiAuthorInfo> authors, required final  List<ApiVideoCard> videos, required this.page, required this.hasNext}): _authors = authors,_videos = videos;
  

 final  List<ApiAuthorInfo> _authors;
@override List<ApiAuthorInfo> get authors {
  if (_authors is EqualUnmodifiableListView) return _authors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authors);
}

 final  List<ApiVideoCard> _videos;
@override List<ApiVideoCard> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

@override final  int page;
@override final  bool hasNext;

/// Create a copy of ApiSubscriptionsPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiSubscriptionsPageCopyWith<_ApiSubscriptionsPage> get copyWith => __$ApiSubscriptionsPageCopyWithImpl<_ApiSubscriptionsPage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiSubscriptionsPage&&const DeepCollectionEquality().equals(other._authors, _authors)&&const DeepCollectionEquality().equals(other._videos, _videos)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_authors),const DeepCollectionEquality().hash(_videos),page,hasNext);

@override
String toString() {
  return 'ApiSubscriptionsPage(authors: $authors, videos: $videos, page: $page, hasNext: $hasNext)';
}


}

/// @nodoc
abstract mixin class _$ApiSubscriptionsPageCopyWith<$Res> implements $ApiSubscriptionsPageCopyWith<$Res> {
  factory _$ApiSubscriptionsPageCopyWith(_ApiSubscriptionsPage value, $Res Function(_ApiSubscriptionsPage) _then) = __$ApiSubscriptionsPageCopyWithImpl;
@override @useResult
$Res call({
 List<ApiAuthorInfo> authors, List<ApiVideoCard> videos, int page, bool hasNext
});




}
/// @nodoc
class __$ApiSubscriptionsPageCopyWithImpl<$Res>
    implements _$ApiSubscriptionsPageCopyWith<$Res> {
  __$ApiSubscriptionsPageCopyWithImpl(this._self, this._then);

  final _ApiSubscriptionsPage _self;
  final $Res Function(_ApiSubscriptionsPage) _then;

/// Create a copy of ApiSubscriptionsPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? authors = null,Object? videos = null,Object? page = null,Object? hasNext = null,}) {
  return _then(_ApiSubscriptionsPage(
authors: null == authors ? _self._authors : authors // ignore: cast_nullable_to_non_nullable
as List<ApiAuthorInfo>,videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ApiTagGroup {

 String get name; List<ApiFilterOption> get tags;
/// Create a copy of ApiTagGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiTagGroupCopyWith<ApiTagGroup> get copyWith => _$ApiTagGroupCopyWithImpl<ApiTagGroup>(this as ApiTagGroup, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiTagGroup&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.tags, tags));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'ApiTagGroup(name: $name, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $ApiTagGroupCopyWith<$Res>  {
  factory $ApiTagGroupCopyWith(ApiTagGroup value, $Res Function(ApiTagGroup) _then) = _$ApiTagGroupCopyWithImpl;
@useResult
$Res call({
 String name, List<ApiFilterOption> tags
});




}
/// @nodoc
class _$ApiTagGroupCopyWithImpl<$Res>
    implements $ApiTagGroupCopyWith<$Res> {
  _$ApiTagGroupCopyWithImpl(this._self, this._then);

  final ApiTagGroup _self;
  final $Res Function(ApiTagGroup) _then;

/// Create a copy of ApiTagGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? tags = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<ApiFilterOption>,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiTagGroup].
extension ApiTagGroupPatterns on ApiTagGroup {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiTagGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiTagGroup() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiTagGroup value)  $default,){
final _that = this;
switch (_that) {
case _ApiTagGroup():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiTagGroup value)?  $default,){
final _that = this;
switch (_that) {
case _ApiTagGroup() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<ApiFilterOption> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiTagGroup() when $default != null:
return $default(_that.name,_that.tags);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<ApiFilterOption> tags)  $default,) {final _that = this;
switch (_that) {
case _ApiTagGroup():
return $default(_that.name,_that.tags);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<ApiFilterOption> tags)?  $default,) {final _that = this;
switch (_that) {
case _ApiTagGroup() when $default != null:
return $default(_that.name,_that.tags);case _:
  return null;

}
}

}

/// @nodoc


class _ApiTagGroup implements ApiTagGroup {
  const _ApiTagGroup({required this.name, required final  List<ApiFilterOption> tags}): _tags = tags;
  

@override final  String name;
 final  List<ApiFilterOption> _tags;
@override List<ApiFilterOption> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of ApiTagGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiTagGroupCopyWith<_ApiTagGroup> get copyWith => __$ApiTagGroupCopyWithImpl<_ApiTagGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiTagGroup&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._tags, _tags));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'ApiTagGroup(name: $name, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$ApiTagGroupCopyWith<$Res> implements $ApiTagGroupCopyWith<$Res> {
  factory _$ApiTagGroupCopyWith(_ApiTagGroup value, $Res Function(_ApiTagGroup) _then) = __$ApiTagGroupCopyWithImpl;
@override @useResult
$Res call({
 String name, List<ApiFilterOption> tags
});




}
/// @nodoc
class __$ApiTagGroupCopyWithImpl<$Res>
    implements _$ApiTagGroupCopyWith<$Res> {
  __$ApiTagGroupCopyWithImpl(this._self, this._then);

  final _ApiTagGroup _self;
  final $Res Function(_ApiTagGroup) _then;

/// Create a copy of ApiTagGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? tags = null,}) {
  return _then(_ApiTagGroup(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<ApiFilterOption>,
  ));
}


}

/// @nodoc
mixin _$ApiUserInfo {

 String get id; String get name; String? get avatarUrl; bool get isLoggedIn;
/// Create a copy of ApiUserInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiUserInfoCopyWith<ApiUserInfo> get copyWith => _$ApiUserInfoCopyWithImpl<ApiUserInfo>(this as ApiUserInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiUserInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isLoggedIn, isLoggedIn) || other.isLoggedIn == isLoggedIn));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl,isLoggedIn);

@override
String toString() {
  return 'ApiUserInfo(id: $id, name: $name, avatarUrl: $avatarUrl, isLoggedIn: $isLoggedIn)';
}


}

/// @nodoc
abstract mixin class $ApiUserInfoCopyWith<$Res>  {
  factory $ApiUserInfoCopyWith(ApiUserInfo value, $Res Function(ApiUserInfo) _then) = _$ApiUserInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? avatarUrl, bool isLoggedIn
});




}
/// @nodoc
class _$ApiUserInfoCopyWithImpl<$Res>
    implements $ApiUserInfoCopyWith<$Res> {
  _$ApiUserInfoCopyWithImpl(this._self, this._then);

  final ApiUserInfo _self;
  final $Res Function(ApiUserInfo) _then;

/// Create a copy of ApiUserInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatarUrl = freezed,Object? isLoggedIn = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isLoggedIn: null == isLoggedIn ? _self.isLoggedIn : isLoggedIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiUserInfo].
extension ApiUserInfoPatterns on ApiUserInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiUserInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiUserInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiUserInfo value)  $default,){
final _that = this;
switch (_that) {
case _ApiUserInfo():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiUserInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ApiUserInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? avatarUrl,  bool isLoggedIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiUserInfo() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.isLoggedIn);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? avatarUrl,  bool isLoggedIn)  $default,) {final _that = this;
switch (_that) {
case _ApiUserInfo():
return $default(_that.id,_that.name,_that.avatarUrl,_that.isLoggedIn);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? avatarUrl,  bool isLoggedIn)?  $default,) {final _that = this;
switch (_that) {
case _ApiUserInfo() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.isLoggedIn);case _:
  return null;

}
}

}

/// @nodoc


class _ApiUserInfo implements ApiUserInfo {
  const _ApiUserInfo({required this.id, required this.name, this.avatarUrl, required this.isLoggedIn});
  

@override final  String id;
@override final  String name;
@override final  String? avatarUrl;
@override final  bool isLoggedIn;

/// Create a copy of ApiUserInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiUserInfoCopyWith<_ApiUserInfo> get copyWith => __$ApiUserInfoCopyWithImpl<_ApiUserInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiUserInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isLoggedIn, isLoggedIn) || other.isLoggedIn == isLoggedIn));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl,isLoggedIn);

@override
String toString() {
  return 'ApiUserInfo(id: $id, name: $name, avatarUrl: $avatarUrl, isLoggedIn: $isLoggedIn)';
}


}

/// @nodoc
abstract mixin class _$ApiUserInfoCopyWith<$Res> implements $ApiUserInfoCopyWith<$Res> {
  factory _$ApiUserInfoCopyWith(_ApiUserInfo value, $Res Function(_ApiUserInfo) _then) = __$ApiUserInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? avatarUrl, bool isLoggedIn
});




}
/// @nodoc
class __$ApiUserInfoCopyWithImpl<$Res>
    implements _$ApiUserInfoCopyWith<$Res> {
  __$ApiUserInfoCopyWithImpl(this._self, this._then);

  final _ApiUserInfo _self;
  final $Res Function(_ApiUserInfo) _then;

/// Create a copy of ApiUserInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatarUrl = freezed,Object? isLoggedIn = null,}) {
  return _then(_ApiUserInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isLoggedIn: null == isLoggedIn ? _self.isLoggedIn : isLoggedIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ApiVideoCard {

 String get id; String get title; String get coverUrl; String? get duration; String? get views; String? get uploadDate; String? get authorName; List<String> get tags;
/// Create a copy of ApiVideoCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiVideoCardCopyWith<ApiVideoCard> get copyWith => _$ApiVideoCardCopyWithImpl<ApiVideoCard>(this as ApiVideoCard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiVideoCard&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.views, views) || other.views == views)&&(identical(other.uploadDate, uploadDate) || other.uploadDate == uploadDate)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&const DeepCollectionEquality().equals(other.tags, tags));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,coverUrl,duration,views,uploadDate,authorName,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'ApiVideoCard(id: $id, title: $title, coverUrl: $coverUrl, duration: $duration, views: $views, uploadDate: $uploadDate, authorName: $authorName, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $ApiVideoCardCopyWith<$Res>  {
  factory $ApiVideoCardCopyWith(ApiVideoCard value, $Res Function(ApiVideoCard) _then) = _$ApiVideoCardCopyWithImpl;
@useResult
$Res call({
 String id, String title, String coverUrl, String? duration, String? views, String? uploadDate, String? authorName, List<String> tags
});




}
/// @nodoc
class _$ApiVideoCardCopyWithImpl<$Res>
    implements $ApiVideoCardCopyWith<$Res> {
  _$ApiVideoCardCopyWithImpl(this._self, this._then);

  final ApiVideoCard _self;
  final $Res Function(ApiVideoCard) _then;

/// Create a copy of ApiVideoCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? coverUrl = null,Object? duration = freezed,Object? views = freezed,Object? uploadDate = freezed,Object? authorName = freezed,Object? tags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,views: freezed == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as String?,uploadDate: freezed == uploadDate ? _self.uploadDate : uploadDate // ignore: cast_nullable_to_non_nullable
as String?,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiVideoCard].
extension ApiVideoCardPatterns on ApiVideoCard {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiVideoCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiVideoCard() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiVideoCard value)  $default,){
final _that = this;
switch (_that) {
case _ApiVideoCard():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiVideoCard value)?  $default,){
final _that = this;
switch (_that) {
case _ApiVideoCard() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String coverUrl,  String? duration,  String? views,  String? uploadDate,  String? authorName,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiVideoCard() when $default != null:
return $default(_that.id,_that.title,_that.coverUrl,_that.duration,_that.views,_that.uploadDate,_that.authorName,_that.tags);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String coverUrl,  String? duration,  String? views,  String? uploadDate,  String? authorName,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _ApiVideoCard():
return $default(_that.id,_that.title,_that.coverUrl,_that.duration,_that.views,_that.uploadDate,_that.authorName,_that.tags);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String coverUrl,  String? duration,  String? views,  String? uploadDate,  String? authorName,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _ApiVideoCard() when $default != null:
return $default(_that.id,_that.title,_that.coverUrl,_that.duration,_that.views,_that.uploadDate,_that.authorName,_that.tags);case _:
  return null;

}
}

}

/// @nodoc


class _ApiVideoCard implements ApiVideoCard {
  const _ApiVideoCard({required this.id, required this.title, required this.coverUrl, this.duration, this.views, this.uploadDate, this.authorName, required final  List<String> tags}): _tags = tags;
  

@override final  String id;
@override final  String title;
@override final  String coverUrl;
@override final  String? duration;
@override final  String? views;
@override final  String? uploadDate;
@override final  String? authorName;
 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of ApiVideoCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiVideoCardCopyWith<_ApiVideoCard> get copyWith => __$ApiVideoCardCopyWithImpl<_ApiVideoCard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiVideoCard&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.views, views) || other.views == views)&&(identical(other.uploadDate, uploadDate) || other.uploadDate == uploadDate)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&const DeepCollectionEquality().equals(other._tags, _tags));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,coverUrl,duration,views,uploadDate,authorName,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'ApiVideoCard(id: $id, title: $title, coverUrl: $coverUrl, duration: $duration, views: $views, uploadDate: $uploadDate, authorName: $authorName, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$ApiVideoCardCopyWith<$Res> implements $ApiVideoCardCopyWith<$Res> {
  factory _$ApiVideoCardCopyWith(_ApiVideoCard value, $Res Function(_ApiVideoCard) _then) = __$ApiVideoCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String coverUrl, String? duration, String? views, String? uploadDate, String? authorName, List<String> tags
});




}
/// @nodoc
class __$ApiVideoCardCopyWithImpl<$Res>
    implements _$ApiVideoCardCopyWith<$Res> {
  __$ApiVideoCardCopyWithImpl(this._self, this._then);

  final _ApiVideoCard _self;
  final $Res Function(_ApiVideoCard) _then;

/// Create a copy of ApiVideoCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? coverUrl = null,Object? duration = freezed,Object? views = freezed,Object? uploadDate = freezed,Object? authorName = freezed,Object? tags = null,}) {
  return _then(_ApiVideoCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,views: freezed == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as String?,uploadDate: freezed == uploadDate ? _self.uploadDate : uploadDate // ignore: cast_nullable_to_non_nullable
as String?,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$ApiVideoDetail {

 String get id; String get title; String? get chineseTitle; String get coverUrl; String? get description; String? get duration; String? get views; int? get likePercent; int? get dislikePercent; int? get likesCount; int? get dislikesCount; String? get uploadDate; ApiAuthorInfo? get author; List<String> get tags; List<ApiVideoQuality> get qualities; ApiSeriesInfo? get series; List<ApiVideoCard> get relatedVideos; String? get formToken; String? get currentUserId; bool get isFav; int? get favTimes; ApiPlaylistInfo? get playlist; ApiMyListInfo? get myList;
/// Create a copy of ApiVideoDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiVideoDetailCopyWith<ApiVideoDetail> get copyWith => _$ApiVideoDetailCopyWithImpl<ApiVideoDetail>(this as ApiVideoDetail, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiVideoDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.chineseTitle, chineseTitle) || other.chineseTitle == chineseTitle)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.views, views) || other.views == views)&&(identical(other.likePercent, likePercent) || other.likePercent == likePercent)&&(identical(other.dislikePercent, dislikePercent) || other.dislikePercent == dislikePercent)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.dislikesCount, dislikesCount) || other.dislikesCount == dislikesCount)&&(identical(other.uploadDate, uploadDate) || other.uploadDate == uploadDate)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.qualities, qualities)&&(identical(other.series, series) || other.series == series)&&const DeepCollectionEquality().equals(other.relatedVideos, relatedVideos)&&(identical(other.formToken, formToken) || other.formToken == formToken)&&(identical(other.currentUserId, currentUserId) || other.currentUserId == currentUserId)&&(identical(other.isFav, isFav) || other.isFav == isFav)&&(identical(other.favTimes, favTimes) || other.favTimes == favTimes)&&(identical(other.playlist, playlist) || other.playlist == playlist)&&(identical(other.myList, myList) || other.myList == myList));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,title,chineseTitle,coverUrl,description,duration,views,likePercent,dislikePercent,likesCount,dislikesCount,uploadDate,author,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(qualities),series,const DeepCollectionEquality().hash(relatedVideos),formToken,currentUserId,isFav,favTimes,playlist,myList]);

@override
String toString() {
  return 'ApiVideoDetail(id: $id, title: $title, chineseTitle: $chineseTitle, coverUrl: $coverUrl, description: $description, duration: $duration, views: $views, likePercent: $likePercent, dislikePercent: $dislikePercent, likesCount: $likesCount, dislikesCount: $dislikesCount, uploadDate: $uploadDate, author: $author, tags: $tags, qualities: $qualities, series: $series, relatedVideos: $relatedVideos, formToken: $formToken, currentUserId: $currentUserId, isFav: $isFav, favTimes: $favTimes, playlist: $playlist, myList: $myList)';
}


}

/// @nodoc
abstract mixin class $ApiVideoDetailCopyWith<$Res>  {
  factory $ApiVideoDetailCopyWith(ApiVideoDetail value, $Res Function(ApiVideoDetail) _then) = _$ApiVideoDetailCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? chineseTitle, String coverUrl, String? description, String? duration, String? views, int? likePercent, int? dislikePercent, int? likesCount, int? dislikesCount, String? uploadDate, ApiAuthorInfo? author, List<String> tags, List<ApiVideoQuality> qualities, ApiSeriesInfo? series, List<ApiVideoCard> relatedVideos, String? formToken, String? currentUserId, bool isFav, int? favTimes, ApiPlaylistInfo? playlist, ApiMyListInfo? myList
});


$ApiAuthorInfoCopyWith<$Res>? get author;$ApiSeriesInfoCopyWith<$Res>? get series;$ApiPlaylistInfoCopyWith<$Res>? get playlist;$ApiMyListInfoCopyWith<$Res>? get myList;

}
/// @nodoc
class _$ApiVideoDetailCopyWithImpl<$Res>
    implements $ApiVideoDetailCopyWith<$Res> {
  _$ApiVideoDetailCopyWithImpl(this._self, this._then);

  final ApiVideoDetail _self;
  final $Res Function(ApiVideoDetail) _then;

/// Create a copy of ApiVideoDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? chineseTitle = freezed,Object? coverUrl = null,Object? description = freezed,Object? duration = freezed,Object? views = freezed,Object? likePercent = freezed,Object? dislikePercent = freezed,Object? likesCount = freezed,Object? dislikesCount = freezed,Object? uploadDate = freezed,Object? author = freezed,Object? tags = null,Object? qualities = null,Object? series = freezed,Object? relatedVideos = null,Object? formToken = freezed,Object? currentUserId = freezed,Object? isFav = null,Object? favTimes = freezed,Object? playlist = freezed,Object? myList = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,chineseTitle: freezed == chineseTitle ? _self.chineseTitle : chineseTitle // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,views: freezed == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as String?,likePercent: freezed == likePercent ? _self.likePercent : likePercent // ignore: cast_nullable_to_non_nullable
as int?,dislikePercent: freezed == dislikePercent ? _self.dislikePercent : dislikePercent // ignore: cast_nullable_to_non_nullable
as int?,likesCount: freezed == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int?,dislikesCount: freezed == dislikesCount ? _self.dislikesCount : dislikesCount // ignore: cast_nullable_to_non_nullable
as int?,uploadDate: freezed == uploadDate ? _self.uploadDate : uploadDate // ignore: cast_nullable_to_non_nullable
as String?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as ApiAuthorInfo?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,qualities: null == qualities ? _self.qualities : qualities // ignore: cast_nullable_to_non_nullable
as List<ApiVideoQuality>,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as ApiSeriesInfo?,relatedVideos: null == relatedVideos ? _self.relatedVideos : relatedVideos // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,formToken: freezed == formToken ? _self.formToken : formToken // ignore: cast_nullable_to_non_nullable
as String?,currentUserId: freezed == currentUserId ? _self.currentUserId : currentUserId // ignore: cast_nullable_to_non_nullable
as String?,isFav: null == isFav ? _self.isFav : isFav // ignore: cast_nullable_to_non_nullable
as bool,favTimes: freezed == favTimes ? _self.favTimes : favTimes // ignore: cast_nullable_to_non_nullable
as int?,playlist: freezed == playlist ? _self.playlist : playlist // ignore: cast_nullable_to_non_nullable
as ApiPlaylistInfo?,myList: freezed == myList ? _self.myList : myList // ignore: cast_nullable_to_non_nullable
as ApiMyListInfo?,
  ));
}
/// Create a copy of ApiVideoDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiAuthorInfoCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $ApiAuthorInfoCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of ApiVideoDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiSeriesInfoCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $ApiSeriesInfoCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}/// Create a copy of ApiVideoDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiPlaylistInfoCopyWith<$Res>? get playlist {
    if (_self.playlist == null) {
    return null;
  }

  return $ApiPlaylistInfoCopyWith<$Res>(_self.playlist!, (value) {
    return _then(_self.copyWith(playlist: value));
  });
}/// Create a copy of ApiVideoDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiMyListInfoCopyWith<$Res>? get myList {
    if (_self.myList == null) {
    return null;
  }

  return $ApiMyListInfoCopyWith<$Res>(_self.myList!, (value) {
    return _then(_self.copyWith(myList: value));
  });
}
}


/// Adds pattern-matching-related methods to [ApiVideoDetail].
extension ApiVideoDetailPatterns on ApiVideoDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiVideoDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiVideoDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiVideoDetail value)  $default,){
final _that = this;
switch (_that) {
case _ApiVideoDetail():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiVideoDetail value)?  $default,){
final _that = this;
switch (_that) {
case _ApiVideoDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? chineseTitle,  String coverUrl,  String? description,  String? duration,  String? views,  int? likePercent,  int? dislikePercent,  int? likesCount,  int? dislikesCount,  String? uploadDate,  ApiAuthorInfo? author,  List<String> tags,  List<ApiVideoQuality> qualities,  ApiSeriesInfo? series,  List<ApiVideoCard> relatedVideos,  String? formToken,  String? currentUserId,  bool isFav,  int? favTimes,  ApiPlaylistInfo? playlist,  ApiMyListInfo? myList)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiVideoDetail() when $default != null:
return $default(_that.id,_that.title,_that.chineseTitle,_that.coverUrl,_that.description,_that.duration,_that.views,_that.likePercent,_that.dislikePercent,_that.likesCount,_that.dislikesCount,_that.uploadDate,_that.author,_that.tags,_that.qualities,_that.series,_that.relatedVideos,_that.formToken,_that.currentUserId,_that.isFav,_that.favTimes,_that.playlist,_that.myList);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? chineseTitle,  String coverUrl,  String? description,  String? duration,  String? views,  int? likePercent,  int? dislikePercent,  int? likesCount,  int? dislikesCount,  String? uploadDate,  ApiAuthorInfo? author,  List<String> tags,  List<ApiVideoQuality> qualities,  ApiSeriesInfo? series,  List<ApiVideoCard> relatedVideos,  String? formToken,  String? currentUserId,  bool isFav,  int? favTimes,  ApiPlaylistInfo? playlist,  ApiMyListInfo? myList)  $default,) {final _that = this;
switch (_that) {
case _ApiVideoDetail():
return $default(_that.id,_that.title,_that.chineseTitle,_that.coverUrl,_that.description,_that.duration,_that.views,_that.likePercent,_that.dislikePercent,_that.likesCount,_that.dislikesCount,_that.uploadDate,_that.author,_that.tags,_that.qualities,_that.series,_that.relatedVideos,_that.formToken,_that.currentUserId,_that.isFav,_that.favTimes,_that.playlist,_that.myList);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? chineseTitle,  String coverUrl,  String? description,  String? duration,  String? views,  int? likePercent,  int? dislikePercent,  int? likesCount,  int? dislikesCount,  String? uploadDate,  ApiAuthorInfo? author,  List<String> tags,  List<ApiVideoQuality> qualities,  ApiSeriesInfo? series,  List<ApiVideoCard> relatedVideos,  String? formToken,  String? currentUserId,  bool isFav,  int? favTimes,  ApiPlaylistInfo? playlist,  ApiMyListInfo? myList)?  $default,) {final _that = this;
switch (_that) {
case _ApiVideoDetail() when $default != null:
return $default(_that.id,_that.title,_that.chineseTitle,_that.coverUrl,_that.description,_that.duration,_that.views,_that.likePercent,_that.dislikePercent,_that.likesCount,_that.dislikesCount,_that.uploadDate,_that.author,_that.tags,_that.qualities,_that.series,_that.relatedVideos,_that.formToken,_that.currentUserId,_that.isFav,_that.favTimes,_that.playlist,_that.myList);case _:
  return null;

}
}

}

/// @nodoc


class _ApiVideoDetail implements ApiVideoDetail {
  const _ApiVideoDetail({required this.id, required this.title, this.chineseTitle, required this.coverUrl, this.description, this.duration, this.views, this.likePercent, this.dislikePercent, this.likesCount, this.dislikesCount, this.uploadDate, this.author, required final  List<String> tags, required final  List<ApiVideoQuality> qualities, this.series, required final  List<ApiVideoCard> relatedVideos, this.formToken, this.currentUserId, required this.isFav, this.favTimes, this.playlist, this.myList}): _tags = tags,_qualities = qualities,_relatedVideos = relatedVideos;
  

@override final  String id;
@override final  String title;
@override final  String? chineseTitle;
@override final  String coverUrl;
@override final  String? description;
@override final  String? duration;
@override final  String? views;
@override final  int? likePercent;
@override final  int? dislikePercent;
@override final  int? likesCount;
@override final  int? dislikesCount;
@override final  String? uploadDate;
@override final  ApiAuthorInfo? author;
 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<ApiVideoQuality> _qualities;
@override List<ApiVideoQuality> get qualities {
  if (_qualities is EqualUnmodifiableListView) return _qualities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_qualities);
}

@override final  ApiSeriesInfo? series;
 final  List<ApiVideoCard> _relatedVideos;
@override List<ApiVideoCard> get relatedVideos {
  if (_relatedVideos is EqualUnmodifiableListView) return _relatedVideos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_relatedVideos);
}

@override final  String? formToken;
@override final  String? currentUserId;
@override final  bool isFav;
@override final  int? favTimes;
@override final  ApiPlaylistInfo? playlist;
@override final  ApiMyListInfo? myList;

/// Create a copy of ApiVideoDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiVideoDetailCopyWith<_ApiVideoDetail> get copyWith => __$ApiVideoDetailCopyWithImpl<_ApiVideoDetail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiVideoDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.chineseTitle, chineseTitle) || other.chineseTitle == chineseTitle)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.views, views) || other.views == views)&&(identical(other.likePercent, likePercent) || other.likePercent == likePercent)&&(identical(other.dislikePercent, dislikePercent) || other.dislikePercent == dislikePercent)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.dislikesCount, dislikesCount) || other.dislikesCount == dislikesCount)&&(identical(other.uploadDate, uploadDate) || other.uploadDate == uploadDate)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._qualities, _qualities)&&(identical(other.series, series) || other.series == series)&&const DeepCollectionEquality().equals(other._relatedVideos, _relatedVideos)&&(identical(other.formToken, formToken) || other.formToken == formToken)&&(identical(other.currentUserId, currentUserId) || other.currentUserId == currentUserId)&&(identical(other.isFav, isFav) || other.isFav == isFav)&&(identical(other.favTimes, favTimes) || other.favTimes == favTimes)&&(identical(other.playlist, playlist) || other.playlist == playlist)&&(identical(other.myList, myList) || other.myList == myList));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,title,chineseTitle,coverUrl,description,duration,views,likePercent,dislikePercent,likesCount,dislikesCount,uploadDate,author,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_qualities),series,const DeepCollectionEquality().hash(_relatedVideos),formToken,currentUserId,isFav,favTimes,playlist,myList]);

@override
String toString() {
  return 'ApiVideoDetail(id: $id, title: $title, chineseTitle: $chineseTitle, coverUrl: $coverUrl, description: $description, duration: $duration, views: $views, likePercent: $likePercent, dislikePercent: $dislikePercent, likesCount: $likesCount, dislikesCount: $dislikesCount, uploadDate: $uploadDate, author: $author, tags: $tags, qualities: $qualities, series: $series, relatedVideos: $relatedVideos, formToken: $formToken, currentUserId: $currentUserId, isFav: $isFav, favTimes: $favTimes, playlist: $playlist, myList: $myList)';
}


}

/// @nodoc
abstract mixin class _$ApiVideoDetailCopyWith<$Res> implements $ApiVideoDetailCopyWith<$Res> {
  factory _$ApiVideoDetailCopyWith(_ApiVideoDetail value, $Res Function(_ApiVideoDetail) _then) = __$ApiVideoDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? chineseTitle, String coverUrl, String? description, String? duration, String? views, int? likePercent, int? dislikePercent, int? likesCount, int? dislikesCount, String? uploadDate, ApiAuthorInfo? author, List<String> tags, List<ApiVideoQuality> qualities, ApiSeriesInfo? series, List<ApiVideoCard> relatedVideos, String? formToken, String? currentUserId, bool isFav, int? favTimes, ApiPlaylistInfo? playlist, ApiMyListInfo? myList
});


@override $ApiAuthorInfoCopyWith<$Res>? get author;@override $ApiSeriesInfoCopyWith<$Res>? get series;@override $ApiPlaylistInfoCopyWith<$Res>? get playlist;@override $ApiMyListInfoCopyWith<$Res>? get myList;

}
/// @nodoc
class __$ApiVideoDetailCopyWithImpl<$Res>
    implements _$ApiVideoDetailCopyWith<$Res> {
  __$ApiVideoDetailCopyWithImpl(this._self, this._then);

  final _ApiVideoDetail _self;
  final $Res Function(_ApiVideoDetail) _then;

/// Create a copy of ApiVideoDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? chineseTitle = freezed,Object? coverUrl = null,Object? description = freezed,Object? duration = freezed,Object? views = freezed,Object? likePercent = freezed,Object? dislikePercent = freezed,Object? likesCount = freezed,Object? dislikesCount = freezed,Object? uploadDate = freezed,Object? author = freezed,Object? tags = null,Object? qualities = null,Object? series = freezed,Object? relatedVideos = null,Object? formToken = freezed,Object? currentUserId = freezed,Object? isFav = null,Object? favTimes = freezed,Object? playlist = freezed,Object? myList = freezed,}) {
  return _then(_ApiVideoDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,chineseTitle: freezed == chineseTitle ? _self.chineseTitle : chineseTitle // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,views: freezed == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as String?,likePercent: freezed == likePercent ? _self.likePercent : likePercent // ignore: cast_nullable_to_non_nullable
as int?,dislikePercent: freezed == dislikePercent ? _self.dislikePercent : dislikePercent // ignore: cast_nullable_to_non_nullable
as int?,likesCount: freezed == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int?,dislikesCount: freezed == dislikesCount ? _self.dislikesCount : dislikesCount // ignore: cast_nullable_to_non_nullable
as int?,uploadDate: freezed == uploadDate ? _self.uploadDate : uploadDate // ignore: cast_nullable_to_non_nullable
as String?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as ApiAuthorInfo?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,qualities: null == qualities ? _self._qualities : qualities // ignore: cast_nullable_to_non_nullable
as List<ApiVideoQuality>,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as ApiSeriesInfo?,relatedVideos: null == relatedVideos ? _self._relatedVideos : relatedVideos // ignore: cast_nullable_to_non_nullable
as List<ApiVideoCard>,formToken: freezed == formToken ? _self.formToken : formToken // ignore: cast_nullable_to_non_nullable
as String?,currentUserId: freezed == currentUserId ? _self.currentUserId : currentUserId // ignore: cast_nullable_to_non_nullable
as String?,isFav: null == isFav ? _self.isFav : isFav // ignore: cast_nullable_to_non_nullable
as bool,favTimes: freezed == favTimes ? _self.favTimes : favTimes // ignore: cast_nullable_to_non_nullable
as int?,playlist: freezed == playlist ? _self.playlist : playlist // ignore: cast_nullable_to_non_nullable
as ApiPlaylistInfo?,myList: freezed == myList ? _self.myList : myList // ignore: cast_nullable_to_non_nullable
as ApiMyListInfo?,
  ));
}

/// Create a copy of ApiVideoDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiAuthorInfoCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $ApiAuthorInfoCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of ApiVideoDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiSeriesInfoCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $ApiSeriesInfoCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}/// Create a copy of ApiVideoDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiPlaylistInfoCopyWith<$Res>? get playlist {
    if (_self.playlist == null) {
    return null;
  }

  return $ApiPlaylistInfoCopyWith<$Res>(_self.playlist!, (value) {
    return _then(_self.copyWith(playlist: value));
  });
}/// Create a copy of ApiVideoDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiMyListInfoCopyWith<$Res>? get myList {
    if (_self.myList == null) {
    return null;
  }

  return $ApiMyListInfoCopyWith<$Res>(_self.myList!, (value) {
    return _then(_self.copyWith(myList: value));
  });
}
}

/// @nodoc
mixin _$ApiVideoQuality {

 String get quality; String get url;
/// Create a copy of ApiVideoQuality
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiVideoQualityCopyWith<ApiVideoQuality> get copyWith => _$ApiVideoQualityCopyWithImpl<ApiVideoQuality>(this as ApiVideoQuality, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiVideoQuality&&(identical(other.quality, quality) || other.quality == quality)&&(identical(other.url, url) || other.url == url));
}


@override
int get hashCode => Object.hash(runtimeType,quality,url);

@override
String toString() {
  return 'ApiVideoQuality(quality: $quality, url: $url)';
}


}

/// @nodoc
abstract mixin class $ApiVideoQualityCopyWith<$Res>  {
  factory $ApiVideoQualityCopyWith(ApiVideoQuality value, $Res Function(ApiVideoQuality) _then) = _$ApiVideoQualityCopyWithImpl;
@useResult
$Res call({
 String quality, String url
});




}
/// @nodoc
class _$ApiVideoQualityCopyWithImpl<$Res>
    implements $ApiVideoQualityCopyWith<$Res> {
  _$ApiVideoQualityCopyWithImpl(this._self, this._then);

  final ApiVideoQuality _self;
  final $Res Function(ApiVideoQuality) _then;

/// Create a copy of ApiVideoQuality
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quality = null,Object? url = null,}) {
  return _then(_self.copyWith(
quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiVideoQuality].
extension ApiVideoQualityPatterns on ApiVideoQuality {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiVideoQuality value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiVideoQuality() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiVideoQuality value)  $default,){
final _that = this;
switch (_that) {
case _ApiVideoQuality():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiVideoQuality value)?  $default,){
final _that = this;
switch (_that) {
case _ApiVideoQuality() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String quality,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiVideoQuality() when $default != null:
return $default(_that.quality,_that.url);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String quality,  String url)  $default,) {final _that = this;
switch (_that) {
case _ApiVideoQuality():
return $default(_that.quality,_that.url);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String quality,  String url)?  $default,) {final _that = this;
switch (_that) {
case _ApiVideoQuality() when $default != null:
return $default(_that.quality,_that.url);case _:
  return null;

}
}

}

/// @nodoc


class _ApiVideoQuality implements ApiVideoQuality {
  const _ApiVideoQuality({required this.quality, required this.url});
  

@override final  String quality;
@override final  String url;

/// Create a copy of ApiVideoQuality
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiVideoQualityCopyWith<_ApiVideoQuality> get copyWith => __$ApiVideoQualityCopyWithImpl<_ApiVideoQuality>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiVideoQuality&&(identical(other.quality, quality) || other.quality == quality)&&(identical(other.url, url) || other.url == url));
}


@override
int get hashCode => Object.hash(runtimeType,quality,url);

@override
String toString() {
  return 'ApiVideoQuality(quality: $quality, url: $url)';
}


}

/// @nodoc
abstract mixin class _$ApiVideoQualityCopyWith<$Res> implements $ApiVideoQualityCopyWith<$Res> {
  factory _$ApiVideoQualityCopyWith(_ApiVideoQuality value, $Res Function(_ApiVideoQuality) _then) = __$ApiVideoQualityCopyWithImpl;
@override @useResult
$Res call({
 String quality, String url
});




}
/// @nodoc
class __$ApiVideoQualityCopyWithImpl<$Res>
    implements _$ApiVideoQualityCopyWith<$Res> {
  __$ApiVideoQualityCopyWithImpl(this._self, this._then);

  final _ApiVideoQuality _self;
  final $Res Function(_ApiVideoQuality) _then;

/// Create a copy of ApiVideoQuality
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quality = null,Object? url = null,}) {
  return _then(_ApiVideoQuality(
quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
