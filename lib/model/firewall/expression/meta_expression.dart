import 'package:flutter/material.dart';
import 'package:jos_ui/model/firewall/rule.dart';
import 'package:jos_ui/widget/key_value.dart';

enum Field {
  iifgroup('iifgroup'),
  iifname('iifname'),
  iiftype('iiftype'),
  l4proto('l4proto'),
  length('length'),
  mark('mark'),
  nfproto('nfproto'),
  oif('oif'),
  oifgroup('oifgroup'),
  oifname('oifname'),
  oiftype('oiftype'),
  pkttype('pkttype'),
  priority('priority'),
  protocol('protocol'),
  rtclassid('rtclassid'),
  skgid('skgid'),
  skuid('skuid');

  final String value;

  const Field(this.value);

  factory Field.fromValue(String value) {
    return Field.values.firstWhere((item) => item.value == value);
  }
}

class MetaExpression implements Expression {
  final Field field;
  final Operation operation;
  final dynamic value;

  MetaExpression(this.field, this.operation, this.value);

  factory MetaExpression.fromMap(Map<String, dynamic> map) {
    var operation = Operation.fromValue(map['match']['op']);
    var field = Field.fromValue(map['match']['left']['meta']['key']);
    var value = map['match']['right'];

    return MetaExpression(field, operation, value);
  }

  Map<String, dynamic> toMap() {
    return {
      'match': {
        'op': operation.value,
        'left': {
          'meta': {
            'key': field.value
          },
        },
        'right': value,
      },
    };
  }

  @override
  Widget display() {
    return KeyValue(k: field.value, v: value);
  }
}
