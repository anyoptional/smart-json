# Smart JSON

`smart_json` makes it easy to deal with JSON data in dart.

1. [How to Use](#How-to-Use)
2. [Usage](#usage)
   - [Initialization](#initialization)
   - [Subscript](#subscript)
   - [Loop](#loop)
   - [Nullable getter](#Nullable-getter)
   - [Nonnull getter](#Nonnull-getter)
3. [String representation](#String-representation)
4. [Work with dio](#Work-with-dio)
5. [Thanks](#Thanks)

## How to Use

You can install `smart_json` by adding it to your `pubspec.yaml`:

```yaml
dependencies:
    smart_json: ^0.0.9
```

## Usage

#### Initialization

```dart
final jsonString = """
{
    "name": "in the garden of sinners",
    "url": "http://www.aniplex.com",
    "page": 88,
    "isNonProfit": true,
    "address": {
        "street": "留仙大道",
        "city": "安徽安庆",
        "country": "中国"
    },
    "links": [
        {
            "name": "Google",
            "url": "http://www.google.com"
        },
        {
            "name": "Baidu",
            "url": "http://www.baidu.com"
        },
        {
            "name": "SoSo",
            "url": "http://www.SoSo.com"
        }
    ]
}
""";
```

```dart
final json = JSON.parse(jsonString);
```

Or

```dart
import 'dart:convert';

final jsonObject = jsonDecode(jsonString);
final json = JSON.from(jsonObject);
```

#### Subscript

```dart
// Getting a int from a JSON Dictionary
final page = json["page"].int; // may be null
```

```dart
// Getting a string from a JSON Dictionary
final name = json["name"].stringValue; // never null
```

```dart
// Getting an array of string from a JSON Array
final arrayNames =  List.from(json["links"].arrayValue.map(($0) => $0["name"].stringValue));
```

```dart
// Getting a string using a path to the element
final linkName = json["links"][0]["name"];
```

#### Loop

```dart
// If json is Map
for (String key in json) {
  JSON value = json[key];
  // Do something you want
}
```

```dart
// If json is List
for (final value in json) {
  // Do something you want
}
```

#### Nullable getter

```dart
// string
final city = json["address"]["city"].string;
if (city != null) {
   // Do something you want
} else {
   // fallback
}
```

```dart
// bool
final isNonProfit = json["isNonProfit"].boolean;
if (isNonProfit != null) {
   // Do something you want
} else {
   // fallback
}
```

#### Nonnull getter

Non-optional getter is named `xxxValue`

```dart
// string
final city = json["address"]["city"].stringValue;
```

```dart
// bool
final isNonProfit = json["isNonProfit"].booleanValue;
```

## String representation
String representation will represent `null` as `"null"`:
```dart
final map = <String, dynamic>{"1":2, "2":"two", "3": null};
final json = JSON.from(map);
final representation = json.toString();
// representation is "{\"1\":2,\"2\":\"two\",\"3\":null}", which represents {"1":2,"2":"two","3":null}
```

## Work with dio

`smart_json` nicely wraps the result of the [dio](https://github.com/flutterchina/dio) response handler:

```dart
// if RequestOption.contentType is application/json
dio.get(url).then((response) {
  if (response.data != null) {
    final json = JSON.from(response.data);
    print(json);
  } else {
    // error
  }
});
```

## Thanks
`smart_json` is full inspired by [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSO), thanks to that great project.