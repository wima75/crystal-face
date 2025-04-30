using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Application as App;

import Toybox.Lang;

class Indicators extends Ui.Drawable {

  private var mSpacing;
  private var mBatteryWidth;

  // use dictionary because with array there are compiler warnings
  private var _indicators1 = {} as Dictionary<Number, Indicator>;
  private var _indicators2 = {} as Dictionary<Number, Indicator>;

  private enum IndicatorTypes {
    INDICATOR_TYPE_None = -1,
    INDICATOR_TYPE_Bluetooth = 0,
    INDICATOR_TYPE_Alarms = 1,
    INDICATOR_TYPE_Notifications = 2,
    INDICATOR_TYPE_BluetoothOrNotifications = 3,
    INDICATOR_TYPE_Battery = 4,
    INDICATOR_TYPE_DoNotDisturb = 5,
    INDICATOR_TYPE_Seconds = 6
  }

  private enum IndicatorPositions {
    //INDICATOR_POSITION_Dynamic = 0,
    INDICATOR_POSITION_Fixed = 1
  }

  private enum IndicatorAppearance {
    //INDICATOR_APPEARANCE_Normal = 0,
    INDICATOR_APPEARANCE_HideWhenFalse = 1,
    INDICATOR_APPEARANCE_Combined1Default2Light = 2
  }

  typedef IndicatorsParams as {
    :locX as Number,
    :locY as Number,
    :spacingX as Number,
    :spacingY as Number,
    :batteryWidth as Number
  };

  function initialize(params as IndicatorsParams) {
    Drawable.initialize(params);

    if (params[:spacingX] != null) {
      mSpacing = params[:spacingX];
    } else {
      mSpacing = params[:spacingY];
    }
    mBatteryWidth = params[:batteryWidth];

    onSettingsChanged();
  }

  function onSettingsChanged() {
    for (var i = 0; i < 3; i++) {
      var indicator = new Indicator(
        i,
        getPropertyValue("Indicator1" + (i + 1) + "Type"),
        getPropertyValue("Indicator1" + (i + 1) + "Position"),
        getPropertyValue("Indicator1" + (i + 1) + "Appearance")
      );
      _indicators1.put(i, indicator);
      indicator = new Indicator(
        i,
        getPropertyValue("Indicator2" + (i + 1) + "Type"),
        getPropertyValue("Indicator2" + (i + 1) + "Position"),
        getPropertyValue("Indicator2" + (i + 1) + "Appearance")
      );
      _indicators2.put(i, indicator);
    }
  }

  function draw(dc) {
    drawIndicators(dc);
  }

  (:horizontal_indicators)
  function drawIndicators(dc) {
    // eg Venu Sq 2

    var y = locY;
    var visibleIndicators = getVisibleIndicators(_indicators1);

    var size = visibleIndicators.size();
    var xPositions = new [size];
    if (size == 0) {
        // No indicators to draw
        return;
    } else if (size == 1) {
        // 1 visible indicator
        if (visibleIndicators.get(0).getPosition() == INDICATOR_POSITION_Fixed) {
          xPositions[0] = getLocX(visibleIndicators[0].getIndex());
        } else {
          xPositions[0] = locX;
        }
    } else if (size == 2) {
      var visibleIndicator0 = visibleIndicators.get(0);
      var visibleIndicator1 = visibleIndicators.get(1);
      // 2 visible indicators
      if (visibleIndicator0.getPosition() == INDICATOR_POSITION_Fixed) {
          // First fixed
          xPositions[0] = getLocX(visibleIndicator0.getIndex());
          if (visibleIndicator1.getPosition() == INDICATOR_POSITION_Fixed) {
            xPositions[1] = getLocX(visibleIndicator1.getIndex());
          } else {
            xPositions[1] = locX + (mSpacing / 2);
          }
      } else if (visibleIndicator1.getPosition() == INDICATOR_POSITION_Fixed) {
          // Second fixed: First centered left
          xPositions[1] = getLocX(visibleIndicator1.getIndex());
          xPositions[0] = locX - (mSpacing / 2);
      } else {
          // Dynamic
          xPositions[0] = locX - (mSpacing / 2);
          xPositions[1] = locX + (mSpacing / 2);
      }
    } else if (size == 3) {
      xPositions[0] = locX - mSpacing;
      xPositions[1] = locX;
      xPositions[2] = locX + mSpacing;
    }
    
    for (var i = 0; i < size; i++) {
      drawIndicator(dc, visibleIndicators.get(i).getType(), xPositions[i], y);
    }
  }

  (:vertical_indicators)
  function drawIndicators(dc) {
    var indicators = {};
    var x = locX;

    for (var j = 0; j < 2; j++) {
      if (j == 0) {
        indicators = _indicators1;
      } else {
        indicators = _indicators2;
        x = dc.getWidth() - locX;
      }

      var visibleIndicators = getVisibleIndicators(indicators);

      var size = visibleIndicators.size();
      var yPositions = new [size];
      if (size == 0) {
          // No indicators to draw
          return;
      } else if (size == 1) {
          // 1 visible indicator
          if (visibleIndicators.get(0).getPosition() == INDICATOR_POSITION_Fixed) {
            yPositions[0] = getLocY(visibleIndicators.get(0).getIndex());
          } else {
            yPositions[0] = locY;
          }
      } else if (size == 2) {
        var visibleIndicator0 = visibleIndicators.get(0);
        var visibleIndicator1 = visibleIndicators.get(1);
          // 2 visible indicators
          if (visibleIndicator0.getPosition() == INDICATOR_POSITION_Fixed) {
              // First fixed
              yPositions[0] = getLocY(visibleIndicator0.getIndex());
              if (visibleIndicator1.getPosition() == INDICATOR_POSITION_Fixed) {
                yPositions[1] = getLocY(visibleIndicator1.getIndex());
              } else {
                yPositions[1] = locY + (mSpacing / 2);
              }
          } else if (visibleIndicator1.getPosition() == INDICATOR_POSITION_Fixed) {
              // Second fixed: First centered above
              yPositions[1] = getLocY(visibleIndicator1.getIndex());
              yPositions[0] = locY - (mSpacing / 2);
          } else {
              // Dynamic
              yPositions[0] = locY - (mSpacing / 2);
              yPositions[1] = locY + (mSpacing / 2);
          }
      } else if (size == 3) {
          yPositions[0] = locY - mSpacing;
          yPositions[1] = locY;
          yPositions[2] = locY + mSpacing;
      }
      
      for (var i = 0; i < size; i++) {
        drawIndicator(dc, visibleIndicators.get(i), x, yPositions[i]);
      }
    }
  }

  private function getVisibleIndicators(indicators) as Dictionary<Number, Indicator> {
    var visibleIndicators = {} as Dictionary<Number, Indicator>;
    var index = 0;
    for (var i = 0; i < indicators.size(); i++) {
      var indicator = indicators.get(i);
      if (indicator.getType() != INDICATOR_TYPE_None) {
        var indicatorValue = getIndicatorValue(indicator.getType());
        indicator.setValue(indicatorValue);
        if (!(indicator.getAppearance() == INDICATOR_APPEARANCE_HideWhenFalse && indicatorValue == false)) {
          visibleIndicators.put(index, indicator);
          index++;
        }
      }
    }
    return visibleIndicators;
  }

  private function getLocX(index) {
    if (index == 0) {
      return locX - mSpacing;
    }
    if (index == 1) {
      return locX;
    }
    return locX + mSpacing;
  }

  private function getLocY(index) {
    if (index == 0) {
      return locY - mSpacing;
    }
    if (index == 1) {
      return locY;
    }
    return locY + mSpacing;
  }

  private function getIndicatorValue(indicatorType) as Boolean {
    if (indicatorType == -1) {
      return true;
    }

    if (indicatorType == INDICATOR_TYPE_Battery) {
      return true;
    }

    if (indicatorType == INDICATOR_TYPE_Seconds) {
      return true;
    }

    var settings = Sys.getDeviceSettings();
    
    if (indicatorType == INDICATOR_TYPE_BluetoothOrNotifications) {
      if (settings.phoneConnected && (settings.notificationCount > 0)) {
        return true;
      } else {
        return settings.phoneConnected;
      }
    }

    if (indicatorType == INDICATOR_TYPE_Bluetooth) {
      return settings.phoneConnected;
    }

    if (indicatorType == INDICATOR_TYPE_Notifications) {
      return settings.notificationCount > 0;
    }

    if (indicatorType == INDICATOR_TYPE_Alarms) {
      return settings.alarmCount > 0;
    }

    if (indicatorType == INDICATOR_TYPE_DoNotDisturb) {
      if (settings has :doNotDisturb) {
        return settings.doNotDisturb;
      }
      return false;
    }

    return false;
  }

  private function drawIndicator(dc, indicator, x, y) {
    var indicatorType = indicator.getType();
    if (indicatorType == -1) {
      return;
    }

    if (indicatorType == INDICATOR_TYPE_Battery) {
      drawBatteryMeter(dc, x, y, mBatteryWidth, mBatteryWidth / 2);
      return;
    }

    var value = indicator.getValue();

    // Show notifications icon if connected and there are notifications, bluetoothicon otherwise.
    var settings = Sys.getDeviceSettings();
    
    if (indicatorType == INDICATOR_TYPE_BluetoothOrNotifications) {
      if (settings.phoneConnected && (settings.notificationCount > 0)) {
        indicatorType = INDICATOR_TYPE_Notifications;
      } else {
        indicatorType = INDICATOR_TYPE_Bluetooth;
      }
    }

    if (indicatorType == INDICATOR_TYPE_Seconds) {
      var clockTime = Sys.getClockTime();
      var seconds = clockTime.sec.format("%02d");
      dc.setColor(gThemeColour, Graphics.COLOR_TRANSPARENT);
      dc.drawText(
        x,
        y,
        gSecondsFont,
        seconds,
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
      return;
    }

    dc.setColor(value ? gThemeColour : gMeterBackgroundColour, Graphics.COLOR_TRANSPARENT);

    var appearance = indicator.getAppearance();

    var char = "";
    if (indicatorType == INDICATOR_TYPE_Bluetooth) {
      char = "8";
    } else if (indicatorType == INDICATOR_TYPE_Alarms) {
      char = ":";
    } else if (indicatorType == INDICATOR_TYPE_Notifications) {
      if (appearance == INDICATOR_APPEARANCE_Combined1Default2Light) {
        dc.setColor(gMonoLightColour, Graphics.COLOR_TRANSPARENT);
      }
      char = "5";
    } else if (indicatorType == INDICATOR_TYPE_DoNotDisturb) {
      char = "J";
    }

    // Icon
    dc.drawText(
      x,
      y,
      gIconsFont,
      char,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }
}
