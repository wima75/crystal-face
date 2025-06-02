/*
Idea and implementation by Marco Wittwer
This class is for calculating if a date is full moon or new moon.
On the garmin watch face, there are two problems: time and memory.
The calculations for updating the view cannot be more than about one second.
And the memory size is limited.

My solution was to precalculate the full moon and new moon dates and save
them in a compressed string. This needs less memory than an array of dates.
For precalculate and compress see tools/moonphase/moonsCompressed.html
*/

import Toybox.Lang;
using Toybox.Time.Gregorian;
using Toybox.Math as Math;
using Toybox.System as Sys;

class MoonField {
  var _moonPhase;
  var _appearance = 0;

  private enum Appearance {
    //MoonPhaseAppearanceDefaultThemeColor = 0,
    MoonPhaseAppearanceLightColor = 1,
    MoonPhaseAppearanceMidtoneColor = 2,
    MoonPhaseAppearanceMidtoneColorFullMoonLight = 3
  }

  public function SetAppearance(appearance as Number) {
    _appearance = appearance;
  }

  public function getIcon(moonPhase, moonChar as Char) as Dictionary {
    var color = gThemeColour;
    if (_appearance == MoonPhaseAppearanceLightColor) {
      color = gMonoLightColour;
    } else if (_appearance == MoonPhaseAppearanceMidtoneColor) {
      color = gMeterBackgroundColour;
    } else if (_appearance == MoonPhaseAppearanceMidtoneColorFullMoonLight) {
      color = gMeterBackgroundColour;
    }

    var moonCharNumber = moonChar.toNumber();

    if (moonPhase == 0) {
      return {
        "char" => moonCharNumber.toChar().toString(),
        "color" => color
      };
    }

    if (moonPhase == 0.5) {
      if (_appearance == MoonPhaseAppearanceMidtoneColorFullMoonLight) {
        color = gMonoLightColour;
      }
      return {
        "char" => (moonCharNumber + 4).toChar().toString(),
        "color" => color
      };
    }

    if (moonPhase < 0.5) {
      moonCharNumber += MathFunctions.Floor(moonPhase / (0.5 / 3.0)).toNumber() + 1;
      return {
        "char" => moonCharNumber.toChar().toString(),
        "color" => color
      };
    }

    moonCharNumber += (MathFunctions.Floor((moonPhase-0.5) / (0.5 / 3.0))).toNumber() + 5;
    return {
      "char" => moonCharNumber.toChar().toString(),
      "color" => color
    };
  }

  public function isFullMoon(d,m,y) {
		var x = encodeDate(d,m,y);
		var f = "c5Kb6Ka7K98K79K7wK5xK4yK31L12L33L24L15Lv5Lt6Lt7Ls8Lq9LqwLoxLoyLm1Mk2Mm3Mk4Mk5Mj6Mi7Mh8Mf9MfwMexMdyMc1Na2Nb3N94N85N76N67N58N39N3wN2xN2yNvyNu1Os2Ou3Os4Or5Oq6Op7Oo8Om9OmwOlxOkyOj1Pi2Pj3Pi4Ph5Pf6Pf7Pd8Pb9PbwPaxP9yP81Q72Q93Q74Q75Q56Q47Q38Q19Qu9QuwQsxQsyQr1Rq2Rr3Rp4Rp5Rn6Rm7Rl8Rj9RiwRhxRgyRf1Se2Sg3Se4Se5Sc6Sc7Sa8S99S8wS6xS6yS41T32T53T34T35T26T17Tv7Tt8Ts9TrwTpxTpyTn1Um2Un3Um4Um5Uk6Uk7Uj8Uh9UhwUfxUfyUd1Vb2Vc3Va4Va5V86V87V78V59V5wV4xV3yV21Wv1W23Wv3Wt4Wt5Wr6Wr7Wp8Wo9WowWmxWmyWl1Xj2Xl3Xj4Xi5Xh6Xg7Xe8Xd9XdwXbxXbyXa1Y92Ya3Y94Y85Y66Y67Y48Y29Y2wYvwYuxYuyYt1Zs2Zs3Zr4Zq5Zo6Zo7Zm8Zk9ZkwZixZiyZh1".find(x);
		if(f == null) {
			return false;
		}
		return true;
	}
	
	public function isNewMoon(d,m,y) {
		var x = encodeDate(d,m,y);
		var f = "r5Kp6Ko7Kn8Kl9KlwKkxKkyKi1Lh2Lj3Lh4Lg5Lf6Le7Lc8Lb9LawL9xL9yL71M62M83M64M65M46M47M28Mv8Mu9MtwMsxMryMq1Np2Nq3No4No5Nm6Nm7Nk8Ni9NiwNgxNgyNe1Od2Of3Od4Od5Oc6Ob7Oa8O89O7wO6xO5yO41P22P43P24P25P16Pu6Pu7Ps8Pr9PqwPpxPoyPn1Ql2Qn3Ql4Ql5Qj6Qj7Qi8Qg9QgwQexQeyQc1Rb2Rb3Ra4R95R86R77R68R49R4wR3xR2yR11Su1S13Su3St4Ss5Sq6Sq7So8Sn9SnwSmxSlySk1Ti2Tk3Ti4Ti5Tg6Tf7Te8Tc9TcwTbxTayT91U82U93U84U75U66U57U38U29U1wUvwUtxUtyUs1Vr2Vr3Vq4Vp5Vo6Vn7Vl8Vk9VjwVixVhyVg1Wf2Wg3Wf4Wf5Wd6Wd7Wb8W99W9wW7xW6yW51X42X53X44X45X36X27X18Xu8Xs9XswXqxXqyXo1Yn2Yo3Yn4Yn5Yl6Yl7Yj8Yi9YhwYgxYfyYe1Zc2Zd3Zb4Zb5Z96Z97Z88Z69Z6wZ4xZ4yZ21".find(x);
		if(f == null) {
			return false;
		}
		return true;
	}

	private function encodeDate(d,m,y) {
		return encodeDay(d) + encodeMonth(m) + encodeYear(y);
	}
	
	private function encodeDay(d) {
		if(d>=10) {
			var chars = "abcdefghijklmnopqrstuv";
			var index = d - 10;
			return chars.substring(index, index + 1);
		} else {
			return d.toString();
		}
	}
	
	private function encodeMonth(m) {
		if(m>=10) {
			var chars = "wxy";
			var index = m - 10;
			return chars.substring(index, index + 1);
		} else {
			return m.toString();
		}
	}
	
	private function encodeYear(y) {
		var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		var index = y - 2015;
		return chars.substring(index, index + 1);
	}
}
