/*
idea and implementation by Marco Wittwer
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

class MoonPhase {
  var _moonPhase;
  var _lastSunMoonCalc = 20000101;
  
	var PI = Math.PI;
	var rad = PI / 180d;
  var e = rad * 23.4397d; // obliquity of the Earth

  function getIcon(now as Gregorian.Info, moonChar as Char) as String {
    var today = Gregorian.moment({:day => now.day, :month => now.month, :year => now.year, :hour => 0, :minute => 0, :second => 0});
    var thisCalc = now.year * 10000 + now.month * 100 + now.day;

    if (thisCalc > _lastSunMoonCalc) {
      _moonPhase = getMoonIllumination(today);
      if (isNewMoon(now.day, now.month, now.year)) {
				_moonPhase = 0;
			} else if (isFullMoon(now.day, now.month, now.year)) {
				_moonPhase = 0.5;
			}

      _lastSunMoonCalc = thisCalc;
    }

    var moonCharNumber = moonChar.toNumber();

    if (_moonPhase == 0) {
      return moonCharNumber.toChar().toString();
    }

    if (_moonPhase == 0.5) {
      return (moonCharNumber + 4).toChar().toString();
    }

    if (_moonPhase < 0.5) {
      moonCharNumber += MathFunctions.Floor(_moonPhase / (0.5 / 3.0)).toNumber() + 1;
      return moonCharNumber.toChar().toString();
    }

    moonCharNumber += (MathFunctions.Floor((_moonPhase-0.5) / (0.5 / 3.0))).toNumber() + 5;
    return moonCharNumber.toChar().toString();
  }

  private function isFullMoon(d,m,y) {
		var x = encodeDate(d,m,y);
		var f = "c5Kb6Ka7K98K79K7wK5xK4yK31L12L33L24L15Lv5Lt6Lt7Ls8Lq9LqwLoxLoyLm1Mk2Mm3Mk4Mk5Mj6Mi7Mh8Mf9MfwMexMdyMc1Na2Nb3N94N85N76N67N58N39N3wN2xN2yNvyNu1Os2Ou3Os4Or5Oq6Op7Oo8Om9OmwOlxOkyOj1Pi2Pj3Pi4Ph5Pf6Pf7Pd8Pb9PbwPaxP9yP81Q72Q93Q74Q75Q56Q47Q38Q19Qu9QuwQsxQsyQr1Rq2Rr3Rp4Rp5Rn6Rm7Rl8Rj9RiwRhxRgyRf1Se2Sg3Se4Se5Sc6Sc7Sa8S99S8wS6xS6yS41T32T53T34T35T26T17Tv7Tt8Ts9TrwTpxTpyTn1Um2Un3Um4Um5Uk6Uk7Uj8Uh9UhwUfxUfyUd1Vb2Vc3Va4Va5V86V87V78V59V5wV4xV3yV21Wv1W23Wv3Wt4Wt5Wr6Wr7Wp8Wo9WowWmxWmyWl1Xj2Xl3Xj4Xi5Xh6Xg7Xe8Xd9XdwXbxXbyXa1Y92Ya3Y94Y85Y66Y67Y48Y29Y2wYvwYuxYuyYt1Zs2Zs3Zr4Zq5Zo6Zo7Zm8Zk9ZkwZixZiyZh1".find(x);
		if(f == null) {
			return false;
		}
		return true;
	}
	
	private function isNewMoon(d,m,y) {
		var x = encodeDate(d,m,y);
		var f = "r5Kp6Ko7Kn8Kl9KlwKkxKkyKi1Lh2Lj3Lh4Lg5Lf6Le7Lc8Lb9LawL9xL9yL71M62M83M64M65M46M47M28Mv8Mu9MtwMsxMryMq1Np2Nq3No4No5Nm6Nm7Nk8Ni9NiwNgxNgyNe1Od2Of3Od4Od5Oc6Ob7Oa8O89O7wO6xO5yO41P22P43P24P25P16Pu6Pu7Ps8Pr9PqwPpxPoyPn1Ql2Qn3Ql4Ql5Qj6Qj7Qi8Qg9QgwQexQeyQc1Rb2Rb3Ra4R95R86R77R68R49R4wR3xR2yR11Su1S13Su3St4Ss5Sq6Sq7So8Sn9SnwSmxSlySk1Ti2Tk3Ti4Ti5Tg6Tf7Te8Tc9TcwTbxTayT91U82U93U84U75U66U57U38U29U1wUvwUtxUtyUs1Vr2Vr3Vq4Vp5Vo6Vn7Vl8Vk9VjwVixVhyVg1Wf2Wg3Wf4Wf5Wd6Wd7Wb8W99W9wW7xW6yW51X42X53X44X45X36X27X18Xu8Xs9XswXqxXqyXo1Yn2Yo3Yn4Yn5Yl6Yl7Yj8Yi9YhwYgxYfyYe1Zc2Zd3Zb4Zb5Z96Z97Z88Z69Z6wZ4xZ4yZ21".find(x);
		if(f == null) {
			return false;
		}
		return true;
	}

  private function toJulian(date) {
    return date.value().toDouble() * 1000d / 86400000d - 0.5d + 2440588d;
  }

  private function toDays(date) {
    return toJulian(date) - 2451545d;
  }

  private function rightAscension(l, b) {
    return MathFunctions.Atan2(Math.sin(l) * Math.cos(e) - Math.tan(b) * Math.sin(e), Math.cos(l));
  }
	
  private function declination(l, b) {
    return Math.asin(Math.sin(b) * Math.cos(e) + Math.cos(b) * Math.sin(e) * Math.sin(l));
  }

  private function solarMeanAnomaly(d) {
    return rad * (357.5291d + 0.98560028d * d);
  }
    
  private function eclipticLongitude(M) {
    var C = rad * (1.9148d * Math.sin(M) + 0.02d * Math.sin(2 * M) + 0.0003d * Math.sin(3d * M)), P = rad * 102.9372d;

    return M + C + P + PI;
  }
    
  private function sunCoords(d) as Dictionary {
    var M = solarMeanAnomaly(d);
    var L = eclipticLongitude(M);

    return {
        "dec" => declination(L, 0),
        "ra" => rightAscension(L, 0)
    };
  }

  // moon calculations, based on http://aa.quae.nl/en/reken/hemelpositie.html formulas
	private function moonCoords(d) as Dictionary { 
		// geocentric ecliptic coordinates of the moon

    	var L = rad * (218.316d + 13.176396d * d); // ecliptic longitude
      var M = rad * (134.963d + 13.064993d * d); // mean anomaly
      var F = rad * (93.272d + 13.229350d * d);  // mean distance

      var l  = L + rad * 6.289d * Math.sin(M); // longitude
      var b  = (rad * 5.128d * Math.sin(F));     // latitude
      var dt = 385001d - 20905d * Math.cos(M);  // distance to the moon in km

    return {
        "ra" => rightAscension(l, b),
        "dec" => declination(l, b),
        "dist" => dt
    };
	}

  // calculations for illumination parameters of the moon,
	// based on http://idlastro.gsfc.nasa.gov/ftp/pro/astro/mphase.pro formulas and
	// Chapter 48 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
  private function getMoonIllumination(date) {
		var d = toDays(date);
    var s = sunCoords(d);
    var m = moonCoords(d);
    var sdist = 149598000d; // distance from Earth to Sun in km

    var phi = Math.acos(Math.sin(s["dec"]) * Math.sin(m["dec"]) + Math.cos(s["dec"]) * Math.cos(m["dec"]) * Math.cos(s["ra"] - m["ra"]));
    var inc = MathFunctions.Atan2(sdist * Math.sin(phi), m["dist"] - sdist * Math.cos(phi));
    var angle = MathFunctions.Atan2(Math.cos(s["dec"]) * Math.sin(s["ra"] - m["ra"]), Math.sin(s["dec"]) * Math.cos(m["dec"]) -
            Math.cos(s["dec"]) * Math.sin(m["dec"]) * Math.cos(s["ra"] - m["ra"]));

		return 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / PI;
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
