import Toybox.Lang;

class Indicator {
  var _index as Number;
  var _type as Number;
  var _position as Number;
  var _appearance as Number;
  var _color1 as Number;
  var _color2 as Number;
  var _value = false;

  public function initialize(
    index as Number,
    type as Number,
    position as Number,
    appearance as Number,
    color1 as Number,
    color2 as Number) {
    _index = index;
    _type = type;
    _position = position;
    _appearance = appearance;
    _color1 = color1;
    _color2 = color2;
  }

  public function getIndex() as Number {
    return _index;
  }

  public function getType() as Number {
    return _type;
  }

  public function getPosition() as Number {
    return _position;
  }

  public function getAppearance() as Number {
    return _appearance;
  }

  public function getColor1() as Number {
    return _color1;
  }

  public function getColor2() as Number {
    return _color2;
  }

  public function setValue(value as Boolean) {
    _value = value;
  }

  public function getValue() as Boolean {
    return _value;
  }
}
