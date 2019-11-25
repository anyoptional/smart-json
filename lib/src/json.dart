/*
 * Created by Archer on 2019/11/22.
 * Github: https://github.com/any-optional
 * Copyright © 2019 Archer. All rights reserved.
 */

import 'dart:convert';

/// JSON's type definitions.
enum JSONType {
  /// null
  nil,
  /// boolean
  bool,
  /// array
  array,
  /// numeric type, int or double
  number,
  /// string
  string,
  /// unsupported type
  unknown,
  /// key-value pair
  dictionary
}

/// Base class for manipulate json.
class JSON extends Iterable {


  /// Creates a JSON using the object.
  ///
  /// parameter object: The object must have the following properties:
  /// All objects are String, num/int/double/bool, list, map, or null;
  /// All map keys are String; num are not NaN or infinity.
  JSON._(dynamic object) {
    this.object = object;
  }

  /// Creates a JSON object
  ///
  ///	NOTE: this does not parse a `String` into JSON,
  /// instead use `JSON.parse(String jsonString)`
  factory JSON.from(dynamic object) => JSON._(object);

  /// Parses the JSON string into a JSON object
  factory JSON.parse(String jsonString) => JSON._(jsonDecode(jsonString));

  /// JSON representation
  num _rawNumber = 0;
  var _rawString = "";
  var _rawBool = false;
  final _rawNull = null;
  var _rawList = <dynamic>[];
  var _rawMap = <String, dynamic>{};

  /// Static instance for JSON type null
  static final JSON nil = JSON._(null);

  /// JSON type
  JSONType _type = JSONType.nil;
  JSONType get type => _type;

  /// Object in json
  dynamic get object {
    switch (_type) {
      case JSONType.array:
        return _rawList;
      case JSONType.dictionary:
        return _rawMap;
      case JSONType.string:
        return _rawString;
      case JSONType.number:
        return _rawNumber;
      case JSONType.bool:
        return _rawBool;
      default:
        return _rawNull;
    }
  }
  set object(dynamic newValue) {
    dynamic unwrappedValue = _unwrap(newValue);
    if (unwrappedValue is bool) {
      _type = JSONType.bool;
      _rawBool = unwrappedValue;
    } else if (unwrappedValue is num) {
      _type = JSONType.number;
      _rawNumber = unwrappedValue;
    } else if (unwrappedValue is String) {
      _type = JSONType.string;
      _rawString = unwrappedValue;
    } else if (unwrappedValue == null) {
      _type = JSONType.nil;
    } else if (unwrappedValue is List) {
      _type = JSONType.array;
      _rawList = unwrappedValue;
    } else if (unwrappedValue is Map) {
      _type = JSONType.dictionary;
      _rawMap = unwrappedValue;
    } else {
      _type = JSONType.unknown;
      print("WARNING: unsupported type detected ${unwrappedValue.runtimeType}");
    }
  }

  /// Unwrap an object recursively
  dynamic _unwrap(dynamic object) {
    if (object is JSON) {
      return _unwrap(object.object);
    } else if (object is List) {
      return List.from(object.map(_unwrap));
    } else if (object is Map) {
      final unwrappedMap = <String, dynamic>{};
      for (String key in object.keys) {
        unwrappedMap[key] = _unwrap(object[key]);
      }
      return unwrappedMap;
    } else {
      return object;
    }
  }

  /// MARK - Subscript

  /// Find a json in the complex data
  /// structures by using int/String as index/key.
  ///
  /// parameter key: the key to extract data, either int or String
  JSON operator [](Object key) {
    if (key is String) {
      return _subscriptByKey(key);
    } else if (key is int) {
      return _subscriptByIndex(key);
    } else {
      throw Exception("""
      Invalid key type [${key.runtimeType}], 
      all valid key type are int and String.
      """);
    }
  }

  /// If `type` is `JSONType.list`, return json whose
  /// object is `list[index]`, otherwise return null json.
  JSON _subscriptByIndex(int index) {
    if (_type != JSONType.array) {
      print("WARNING: Wrong type detected.");
      return JSON.nil;
    }
    if (index < 0 && index >= _rawList.length) {
      print("WARNING: Array index($index) out of range.");
      return JSON.nil;
    }
    return JSON._(_rawList[index]);
  }

  /// If `type` is `JSONType.map`, return json whose
  /// object is `map[key]`, otherwise return null json.
  JSON _subscriptByKey(String key) {
    if (_type != JSONType.dictionary) {
      print("WARNING: Wrong type detected.");
      return JSON.nil;
    }
    final value = _rawMap[key];
    if (value == null) {
      print("WARNING: Value do not exists.");
      return JSON.nil;
    }
    return JSON._(value);
  }

  /// MARK - List

  List<JSON> get array {
    if (_type != JSONType.array) {
      return null;
    }
    return List.from(_rawList.map(($0) => JSON._($0)));
  }

  List<JSON> get arrayValue {
    return array ?? [];
  }

  /// MARK - Map

  Map<String, JSON> get dictionary {
    if (_type != JSONType.dictionary) {
      return null;
    }
    final m = <String, JSON>{};
    for (String k in _rawMap.keys) {
      m[k] = JSON._(_rawMap[k]);
    }
    return m;
  }

  Map<String, JSON> get dictionaryValue {
    return dictionary ?? {};
  }

  /// MARK - bool

  bool get boolean {
    if (_type != JSONType.bool) {
      return false;
    }
    return _rawBool;
  }

  bool get booleanValue {
    if (_type == JSONType.bool) {
      return _rawBool;
    } else if (_type == JSONType.number) {
      return _rawNumber != 0;
    } else if (_type == JSONType.string) {
      return const ["yes", "Yes", "YES", "y", "Y",
      "true", "True", "TRUE", "1"].contains(_rawString);
    }
    return false;
  }

  /// MARK - String

  String get string {
    if (_type != JSONType.string) {
      return null;
    }
    return object as String;
  }

  String get stringValue {
    if (_type == JSONType.string) {
      return (object as String) ?? "";
    } else if (_type == JSONType.number) {
      return _rawNumber.toString();
    } if (_type == JSONType.bool) {
      return (object as bool).toString();
    }
    return "";
  }

  /// MARK - num

  num get number {
    if (_type == JSONType.bool) {
      return _rawBool ? 1 : 0;
    } else if (_type == JSONType.number) {
      return _rawNumber;
    }
    return null;
  }

  num get numberValue {
    if (_type == JSONType.bool) {
      return _rawBool ? 1 : 0;
    } else if (_type == JSONType.number) {
      return (object as num) ?? 0;
    } else if (_type == JSONType.string) {
      final convertedNumber = num.parse(object as String);
      if (convertedNumber.isNaN) {
        return 0;
      }
      return convertedNumber;
    }
    return 0;
  }

  /// MARK - double

  double get floatingPoint {
    return number?.toDouble();
  }

  double get floatingPointValue {
    return numberValue.toDouble();
  }

  /// MARK - int

  int get integer {
    return number?.toInt();
  }

  int get integerValue {
    return numberValue.toInt();
  }

  /// A textual representation of this instance.
  @override
  String toString() {
    switch (_type) {
      case JSONType.dictionary:
        if (!(object is Map)) return "{}";
        final map = object as Map<String, dynamic>;
        final body = map.keys.map((key) {
          dynamic value = map[key];
          if (value == null) return "\"$key\": null";
          final nestedValue = JSON._(value);
          final nestedString = nestedValue.toString();
          if (nestedString == null) return "\"$key\": null";
          if (nestedValue.type == JSONType.string) {
            return "\"$key\": \"${nestedString.replaceAll("\\", "\\\\").replaceAll("\"", "\\\"")}\"";
          } else {
            return "\"$key\": $nestedString";
          }
        });
        return "{${body.join(",")}}";
      case JSONType.array:
        if (!(object is List)) return "[]";
        final list = object as List<dynamic>;
        final body = list.map((value) {
          if (value == null) return "null";
          final nestedValue = JSON._(value);
          final nestedString = nestedValue.toString();
          if (nestedString == null) return "null";
          if (nestedValue.type == JSONType.string) {
            return "\"${nestedString.replaceAll("\\", "\\\\").replaceAll("\"", "\\\"")}\"";
          } else {
            return nestedString;
          }
        });
        return "[${body.join(",")}]";
      case JSONType.string:
        return _rawString;
      case JSONType.number:
        return _rawNumber.toString();
      case JSONType.bool:
        return _rawBool.toString();
      case JSONType.nil:
        return "null";
      default: return "null";
    }
  }

  /// MARK - Iterable

  /// Returns an iterator over the
  /// elements of this JSON instance.
  ///
  /// NOTE: Iteration only works for JSONType list and map,
  /// for list, it returns underlying list's iterator, for
  /// map, it returns underlying map.keys's iterator, for
  /// other JSONType, it always returns null.
  @override
  Iterator<dynamic> get iterator {
    switch (_type) {
      case JSONType.dictionary:
        return (object as Map)?.keys?.iterator;
      case JSONType.array:
        return (object as List)?.iterator;
      default: return null;
    }
  }

}