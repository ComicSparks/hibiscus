// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CacheInfo {

 BigInt get coverCacheSize; BigInt get videoCacheSize; BigInt get totalSize;
/// Create a copy of CacheInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CacheInfoCopyWith<CacheInfo> get copyWith => _$CacheInfoCopyWithImpl<CacheInfo>(this as CacheInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CacheInfo&&(identical(other.coverCacheSize, coverCacheSize) || other.coverCacheSize == coverCacheSize)&&(identical(other.videoCacheSize, videoCacheSize) || other.videoCacheSize == videoCacheSize)&&(identical(other.totalSize, totalSize) || other.totalSize == totalSize));
}


@override
int get hashCode => Object.hash(runtimeType,coverCacheSize,videoCacheSize,totalSize);

@override
String toString() {
  return 'CacheInfo(coverCacheSize: $coverCacheSize, videoCacheSize: $videoCacheSize, totalSize: $totalSize)';
}


}

/// @nodoc
abstract mixin class $CacheInfoCopyWith<$Res>  {
  factory $CacheInfoCopyWith(CacheInfo value, $Res Function(CacheInfo) _then) = _$CacheInfoCopyWithImpl;
@useResult
$Res call({
 BigInt coverCacheSize, BigInt videoCacheSize, BigInt totalSize
});




}
/// @nodoc
class _$CacheInfoCopyWithImpl<$Res>
    implements $CacheInfoCopyWith<$Res> {
  _$CacheInfoCopyWithImpl(this._self, this._then);

  final CacheInfo _self;
  final $Res Function(CacheInfo) _then;

/// Create a copy of CacheInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coverCacheSize = null,Object? videoCacheSize = null,Object? totalSize = null,}) {
  return _then(_self.copyWith(
coverCacheSize: null == coverCacheSize ? _self.coverCacheSize : coverCacheSize // ignore: cast_nullable_to_non_nullable
as BigInt,videoCacheSize: null == videoCacheSize ? _self.videoCacheSize : videoCacheSize // ignore: cast_nullable_to_non_nullable
as BigInt,totalSize: null == totalSize ? _self.totalSize : totalSize // ignore: cast_nullable_to_non_nullable
as BigInt,
  ));
}

}


/// Adds pattern-matching-related methods to [CacheInfo].
extension CacheInfoPatterns on CacheInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CacheInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CacheInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CacheInfo value)  $default,){
final _that = this;
switch (_that) {
case _CacheInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CacheInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CacheInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BigInt coverCacheSize,  BigInt videoCacheSize,  BigInt totalSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CacheInfo() when $default != null:
return $default(_that.coverCacheSize,_that.videoCacheSize,_that.totalSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BigInt coverCacheSize,  BigInt videoCacheSize,  BigInt totalSize)  $default,) {final _that = this;
switch (_that) {
case _CacheInfo():
return $default(_that.coverCacheSize,_that.videoCacheSize,_that.totalSize);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BigInt coverCacheSize,  BigInt videoCacheSize,  BigInt totalSize)?  $default,) {final _that = this;
switch (_that) {
case _CacheInfo() when $default != null:
return $default(_that.coverCacheSize,_that.videoCacheSize,_that.totalSize);case _:
  return null;

}
}

}

/// @nodoc


class _CacheInfo implements CacheInfo {
  const _CacheInfo({required this.coverCacheSize, required this.videoCacheSize, required this.totalSize});
  

@override final  BigInt coverCacheSize;
@override final  BigInt videoCacheSize;
@override final  BigInt totalSize;

/// Create a copy of CacheInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CacheInfoCopyWith<_CacheInfo> get copyWith => __$CacheInfoCopyWithImpl<_CacheInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CacheInfo&&(identical(other.coverCacheSize, coverCacheSize) || other.coverCacheSize == coverCacheSize)&&(identical(other.videoCacheSize, videoCacheSize) || other.videoCacheSize == videoCacheSize)&&(identical(other.totalSize, totalSize) || other.totalSize == totalSize));
}


@override
int get hashCode => Object.hash(runtimeType,coverCacheSize,videoCacheSize,totalSize);

@override
String toString() {
  return 'CacheInfo(coverCacheSize: $coverCacheSize, videoCacheSize: $videoCacheSize, totalSize: $totalSize)';
}


}

/// @nodoc
abstract mixin class _$CacheInfoCopyWith<$Res> implements $CacheInfoCopyWith<$Res> {
  factory _$CacheInfoCopyWith(_CacheInfo value, $Res Function(_CacheInfo) _then) = __$CacheInfoCopyWithImpl;
@override @useResult
$Res call({
 BigInt coverCacheSize, BigInt videoCacheSize, BigInt totalSize
});




}
/// @nodoc
class __$CacheInfoCopyWithImpl<$Res>
    implements _$CacheInfoCopyWith<$Res> {
  __$CacheInfoCopyWithImpl(this._self, this._then);

  final _CacheInfo _self;
  final $Res Function(_CacheInfo) _then;

/// Create a copy of CacheInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coverCacheSize = null,Object? videoCacheSize = null,Object? totalSize = null,}) {
  return _then(_CacheInfo(
coverCacheSize: null == coverCacheSize ? _self.coverCacheSize : coverCacheSize // ignore: cast_nullable_to_non_nullable
as BigInt,videoCacheSize: null == videoCacheSize ? _self.videoCacheSize : videoCacheSize // ignore: cast_nullable_to_non_nullable
as BigInt,totalSize: null == totalSize ? _self.totalSize : totalSize // ignore: cast_nullable_to_non_nullable
as BigInt,
  ));
}


}

// dart format on
