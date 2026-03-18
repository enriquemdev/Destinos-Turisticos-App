// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'destination_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Destination {

 String get xid; String get name; String? get description; String? get imageUrl; String get category; double get latitude; double get longitude; String? get address; String? get url; String? get wikipedia; String? get osm; double? get rate;
/// Create a copy of Destination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DestinationCopyWith<Destination> get copyWith => _$DestinationCopyWithImpl<Destination>(this as Destination, _$identity);

  /// Serializes this Destination to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Destination&&(identical(other.xid, xid) || other.xid == xid)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.address, address) || other.address == address)&&(identical(other.url, url) || other.url == url)&&(identical(other.wikipedia, wikipedia) || other.wikipedia == wikipedia)&&(identical(other.osm, osm) || other.osm == osm)&&(identical(other.rate, rate) || other.rate == rate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,xid,name,description,imageUrl,category,latitude,longitude,address,url,wikipedia,osm,rate);

@override
String toString() {
  return 'Destination(xid: $xid, name: $name, description: $description, imageUrl: $imageUrl, category: $category, latitude: $latitude, longitude: $longitude, address: $address, url: $url, wikipedia: $wikipedia, osm: $osm, rate: $rate)';
}


}

/// @nodoc
abstract mixin class $DestinationCopyWith<$Res>  {
  factory $DestinationCopyWith(Destination value, $Res Function(Destination) _then) = _$DestinationCopyWithImpl;
@useResult
$Res call({
 String xid, String name, String? description, String? imageUrl, String category, double latitude, double longitude, String? address, String? url, String? wikipedia, String? osm, double? rate
});




}
/// @nodoc
class _$DestinationCopyWithImpl<$Res>
    implements $DestinationCopyWith<$Res> {
  _$DestinationCopyWithImpl(this._self, this._then);

  final Destination _self;
  final $Res Function(Destination) _then;

/// Create a copy of Destination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? xid = null,Object? name = null,Object? description = freezed,Object? imageUrl = freezed,Object? category = null,Object? latitude = null,Object? longitude = null,Object? address = freezed,Object? url = freezed,Object? wikipedia = freezed,Object? osm = freezed,Object? rate = freezed,}) {
  return _then(_self.copyWith(
xid: null == xid ? _self.xid : xid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,wikipedia: freezed == wikipedia ? _self.wikipedia : wikipedia // ignore: cast_nullable_to_non_nullable
as String?,osm: freezed == osm ? _self.osm : osm // ignore: cast_nullable_to_non_nullable
as String?,rate: freezed == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [Destination].
extension DestinationPatterns on Destination {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Destination value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Destination() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Destination value)  $default,){
final _that = this;
switch (_that) {
case _Destination():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Destination value)?  $default,){
final _that = this;
switch (_that) {
case _Destination() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String xid,  String name,  String? description,  String? imageUrl,  String category,  double latitude,  double longitude,  String? address,  String? url,  String? wikipedia,  String? osm,  double? rate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Destination() when $default != null:
return $default(_that.xid,_that.name,_that.description,_that.imageUrl,_that.category,_that.latitude,_that.longitude,_that.address,_that.url,_that.wikipedia,_that.osm,_that.rate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String xid,  String name,  String? description,  String? imageUrl,  String category,  double latitude,  double longitude,  String? address,  String? url,  String? wikipedia,  String? osm,  double? rate)  $default,) {final _that = this;
switch (_that) {
case _Destination():
return $default(_that.xid,_that.name,_that.description,_that.imageUrl,_that.category,_that.latitude,_that.longitude,_that.address,_that.url,_that.wikipedia,_that.osm,_that.rate);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String xid,  String name,  String? description,  String? imageUrl,  String category,  double latitude,  double longitude,  String? address,  String? url,  String? wikipedia,  String? osm,  double? rate)?  $default,) {final _that = this;
switch (_that) {
case _Destination() when $default != null:
return $default(_that.xid,_that.name,_that.description,_that.imageUrl,_that.category,_that.latitude,_that.longitude,_that.address,_that.url,_that.wikipedia,_that.osm,_that.rate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Destination extends Destination {
  const _Destination({required this.xid, required this.name, this.description, this.imageUrl, required this.category, required this.latitude, required this.longitude, this.address, this.url, this.wikipedia, this.osm, this.rate}): super._();
  factory _Destination.fromJson(Map<String, dynamic> json) => _$DestinationFromJson(json);

@override final  String xid;
@override final  String name;
@override final  String? description;
@override final  String? imageUrl;
@override final  String category;
@override final  double latitude;
@override final  double longitude;
@override final  String? address;
@override final  String? url;
@override final  String? wikipedia;
@override final  String? osm;
@override final  double? rate;

/// Create a copy of Destination
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DestinationCopyWith<_Destination> get copyWith => __$DestinationCopyWithImpl<_Destination>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DestinationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Destination&&(identical(other.xid, xid) || other.xid == xid)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.address, address) || other.address == address)&&(identical(other.url, url) || other.url == url)&&(identical(other.wikipedia, wikipedia) || other.wikipedia == wikipedia)&&(identical(other.osm, osm) || other.osm == osm)&&(identical(other.rate, rate) || other.rate == rate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,xid,name,description,imageUrl,category,latitude,longitude,address,url,wikipedia,osm,rate);

@override
String toString() {
  return 'Destination(xid: $xid, name: $name, description: $description, imageUrl: $imageUrl, category: $category, latitude: $latitude, longitude: $longitude, address: $address, url: $url, wikipedia: $wikipedia, osm: $osm, rate: $rate)';
}


}

/// @nodoc
abstract mixin class _$DestinationCopyWith<$Res> implements $DestinationCopyWith<$Res> {
  factory _$DestinationCopyWith(_Destination value, $Res Function(_Destination) _then) = __$DestinationCopyWithImpl;
@override @useResult
$Res call({
 String xid, String name, String? description, String? imageUrl, String category, double latitude, double longitude, String? address, String? url, String? wikipedia, String? osm, double? rate
});




}
/// @nodoc
class __$DestinationCopyWithImpl<$Res>
    implements _$DestinationCopyWith<$Res> {
  __$DestinationCopyWithImpl(this._self, this._then);

  final _Destination _self;
  final $Res Function(_Destination) _then;

/// Create a copy of Destination
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? xid = null,Object? name = null,Object? description = freezed,Object? imageUrl = freezed,Object? category = null,Object? latitude = null,Object? longitude = null,Object? address = freezed,Object? url = freezed,Object? wikipedia = freezed,Object? osm = freezed,Object? rate = freezed,}) {
  return _then(_Destination(
xid: null == xid ? _self.xid : xid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,wikipedia: freezed == wikipedia ? _self.wikipedia : wikipedia // ignore: cast_nullable_to_non_nullable
as String?,osm: freezed == osm ? _self.osm : osm // ignore: cast_nullable_to_non_nullable
as String?,rate: freezed == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
