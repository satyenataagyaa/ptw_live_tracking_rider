/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;

/** This is an auto generated class representing the Location type in your schema. */
class Location extends amplify_core.Model {
  static const classType = const _LocationModelType();
  final double? _latitude;
  final double? _longitude;
  final String? _tripId;

  double get latitude {
    try {
      return _latitude!;
    } catch (e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages
              .codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion: amplify_core.AmplifyExceptionMessages
              .codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString());
    }
  }

  double get longitude {
    try {
      return _longitude!;
    } catch (e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages
              .codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion: amplify_core.AmplifyExceptionMessages
              .codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString());
    }
  }

  String get tripId {
    try {
      return _tripId!;
    } catch (e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages
              .codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion: amplify_core.AmplifyExceptionMessages
              .codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString());
    }
  }

  const Location._internal(
      {required latitude, required longitude, required tripId})
      : _latitude = latitude,
        _longitude = longitude,
        _tripId = tripId;

  factory Location(
      {required double latitude,
      required double longitude,
      required String tripId}) {
    return Location._internal(
        latitude: latitude, longitude: longitude, tripId: tripId);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Location &&
        _latitude == other._latitude &&
        _longitude == other._longitude &&
        _tripId == other._tripId;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("Location {");
    buffer.write("latitude=" +
        (_latitude != null ? _latitude!.toString() : "null") +
        ", ");
    buffer.write("longitude=" +
        (_longitude != null ? _longitude!.toString() : "null") +
        ", ");
    buffer.write("tripId=" + "$_tripId");
    buffer.write("}");

    return buffer.toString();
  }

  Location copyWith({double? latitude, double? longitude, String? tripId}) {
    return Location._internal(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        tripId: tripId ?? this.tripId);
  }

  Location copyWithModelFieldValues(
      {ModelFieldValue<double>? latitude,
      ModelFieldValue<double>? longitude,
      ModelFieldValue<String>? tripId}) {
    return Location._internal(
        latitude: latitude == null ? this.latitude : latitude.value,
        longitude: longitude == null ? this.longitude : longitude.value,
        tripId: tripId == null ? this.tripId : tripId.value);
  }

  Location.fromJson(Map<String, dynamic> json)
      : _latitude = (json['latitude'] as num?)?.toDouble(),
        _longitude = (json['longitude'] as num?)?.toDouble(),
        _tripId = json['tripId'];

  Map<String, dynamic> toJson() =>
      {'latitude': _latitude, 'longitude': _longitude, 'tripId': _tripId};

  Map<String, Object?> toMap() =>
      {'latitude': _latitude, 'longitude': _longitude, 'tripId': _tripId};

  static var schema = amplify_core.Model.defineSchema(
      define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Location";
    modelSchemaDefinition.pluralName = "Locations";

    modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.customTypeField(
            fieldName: 'latitude',
            isRequired: true,
            ofType: amplify_core.ModelFieldType(
                amplify_core.ModelFieldTypeEnum.double)));

    modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.customTypeField(
            fieldName: 'longitude',
            isRequired: true,
            ofType: amplify_core.ModelFieldType(
                amplify_core.ModelFieldTypeEnum.double)));

    modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.customTypeField(
            fieldName: 'tripId',
            isRequired: true,
            ofType: amplify_core.ModelFieldType(
                amplify_core.ModelFieldTypeEnum.string)));
  });
}

class _LocationModelType extends amplify_core.ModelType<Location> {
  const _LocationModelType();

  @override
  Location fromJson(Map<String, dynamic> jsonData) {
    return Location.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'Location';
  }
}
