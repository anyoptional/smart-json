import 'package:flutter_test/flutter_test.dart';

import 'package:smart_json/smart_json.dart';

void main() {

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

  test("loop", () {
    final map = <String, dynamic>{"1":2, "2":"two", "3": null};
    final json = JSON.from(map);
    final representation = json.toString();
    print(representation);
  });
}

//void main() {
//  test('adds one to input values', () {
//    final calculator = Calculator();
//    expect(calculator.addOne(2), 3);
//    expect(calculator.addOne(-7), -6);
//    expect(calculator.addOne(0), 1);
//    expect(() => calculator.addOne(null), throwsNoSuchMethodError);
//  });
//}
