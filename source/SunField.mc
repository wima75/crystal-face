/*
 Converted from the JavaScript library:

 (c) 2011-2015, Vladimir Agafonkin
 SunCalc is a JavaScript library for calculating sun/moon position and light phases.
 https://github.com/mourner/suncalc
*/

using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Lang as Lang;
using Toybox.System as Sys;
using Toybox.Application as App;

class SunField {
	private var _isMoonCalculationNeccessary = false;
	private var _timesToday;
	private var _timesTomorrow;

	var _moonIllumination;

	var PI = Math.PI;
	var rad = PI / 180d;

	public function SetIsCalculationNeccessary(forPosition) {
		_timesToday = null;
		_timesTomorrow = null;
		if (!forPosition) {
			_isMoonCalculationNeccessary = true;
		}
	}

	public function GetSunrise(date, lat, lng) {
		var moment = GetTimesToday(date, lat, lng);
		if (moment == null) {
			return {
				"value" => "gps?",
				"icon" => ">"	
			};
		}
		var sunrise = Calendar.info(moment["sunrise"], Time.FORMAT_SHORT);
		var value = formatTime(sunrise.hour, sunrise.min);
		return {
			"value" => value,
			"icon" => ">"
		};
	}

	public function GetSunset(date, lat, lng) {
		var moment = GetTimesToday(date, lat, lng);
		if (moment == null) {
			return {
				"value" => "gps?",
				"icon" => "?"	
			};
		}
		var sunset = Calendar.info(moment["sunset"], Time.FORMAT_SHORT);
		var value = formatTime(sunset.hour, sunset.min);
		return {
			"value" => value,
			"icon" => "?"
		};
	}

	public function GetSunriseSunset(now, lat, lng) {
		var nowInfo = Calendar.info(now, Time.FORMAT_SHORT);
		var today = Calendar.moment({:day => nowInfo.day, :month => nowInfo.month, :year => nowInfo.year, :hour => 0, :minute => 0, :second => 0});
		var sunTimesToday = GetTimesToday(today, lat, lng);
		if (sunTimesToday == null) {
			return {
				"value" => "gps?",
				"icon" => "?"	
			};
		}
		var sunriseToday = Calendar.info(sunTimesToday["sunrise"], Time.FORMAT_SHORT);
		var sunsetToday = Calendar.info(sunTimesToday["sunset"], Time.FORMAT_SHORT);
		var icon = "?";
		var value = "-";
		var nowValue = now.value();
		if (nowValue < sunTimesToday["sunrise"].value()) {
			icon = ">";
			value = formatTime(sunriseToday.hour, sunriseToday.min);
			_timesTomorrow = null;
		} else if (nowValue > sunTimesToday["sunset"].value()) {
			icon = ">";
			var tomorrow = today.add(new Time.Duration(Calendar.SECONDS_PER_DAY));
			var timesTomorrow = GetTimesTomorrow(tomorrow, lat, lng);
			var sunriseTomorrow = Calendar.info(timesTomorrow["sunrise"], Time.FORMAT_SHORT);
			value = formatTime(sunriseTomorrow.hour, sunriseTomorrow.min);
		} else {
			icon = "?";
			value = formatTime(sunsetToday.hour, sunsetToday.min);
			_timesTomorrow = null;
		}

		return {
			"value" => value,
			"icon" => icon
		};
	}

	private function GetTimesToday(date, lat, lng) {
		if (_timesToday == null) {
			_timesToday = GetTimes(date, lat, lng);
		}
		return _timesToday;
	}

	private function GetTimesTomorrow(date, lat, lng) {
		if (_timesTomorrow == null) {
			_timesTomorrow = GetTimes(date, lat, lng);
		}
		return _timesTomorrow;
	}

	private function GetTimes(date, lat, lng) {
		if (lat == null || lng == null) {
			return null;
		}

		var lw = rad * (-lng);
    var phi = rad * lat;

		var d = toDays(date);
		var n = julianCycle(d, lw);
		var ds = approxTransit(0, lw, n);
		var M = solarMeanAnomaly(ds);
		var L = eclipticLongitude(M);
		var dec = declination(L, 0);
		
		var Jnoon = solarTransitJ(ds, M, L);
		
		var i;
		var len;
		var time;
		var Jset;
		var Jrise;
		
		var result = { };
		
		i = 0;
		time = times[i];

		Jset = getSetJ(time[0] * rad, lw, phi, dec, n, M, L);
		Jrise = Jnoon - (Jset - Jnoon);
	
		//var solarNoon = fromJulian(Jnoon, 0);
		var sunrise = fromJulian(Jrise, 0);

		//result["solarNoon"] = solarNoon;
		result["sunrise"] = sunrise;
		result["sunset"] = fromJulian(Jset, 0);
		//var noonS = solarNoon.hour * 3600 + solarNoon.min * 60 + solarNoon.sec;
		//var riseS = sunrise.hour * 3600 + sunrise.min * 60 + sunrise.sec;

		//_isSunCalculationNeccessary = false;

		var times = { 
			"sunrise" => result["sunrise"], 
			"sunset" => result["sunset"],
			//"riseS" => riseS,
			//"solarNoonS" => noonS,
			//"riseToNoonS" => (Jnoon - Jrise) * 86400,
			//"noonToSetS" => (Jset - Jnoon) * 86400
		};
		return times;
	}

	private function formatTime(hour, min) {
		return App.getApp().formatTime(hour, min);
	}
	
	function toJulian(date) { return date.value().toDouble() * 1000d / 86400000d - 0.5d + 2440588d; }
	function fromJulian(j, offset)  { 
		var moment = new Time.Moment((j + 0.5d - 2440588d) * 86400000d / 1000d + offset);
		return moment;
	}
	function toDays(date)   { return toJulian(date) - 2451545d; }
	
	// general calculations for position
	var e = rad * 23.4397d; // obliquity of the Earth

	function rightAscension(l, b) { return MathFunctions.Atan2(Math.sin(l) * Math.cos(e) - Math.tan(b) * Math.sin(e), Math.cos(l)); }
	function declination(l, b)    { return Math.asin(Math.sin(b) * Math.cos(e) + Math.cos(b) * Math.sin(e) * Math.sin(l)); }
	
	// general sun calculations

	function solarMeanAnomaly(d) { return rad * (357.5291d + 0.98560028d * d); }
	
	function eclipticLongitude(M) {
    	var C = rad * (1.9148d * Math.sin(M) + 0.02d * Math.sin(2 * M) + 0.0003d * Math.sin(3d * M)), P = rad * 102.9372d;

    	return M + C + P + PI;
	}
	
	function sunCoords(d) {
	    var M = solarMeanAnomaly(d);
	    var L = eclipticLongitude(M);
	
	    return {
	        "dec" => declination(L, 0),
	        "ra" => rightAscension(L, 0)
	    };
	}
	
	// sun times configuration (angle, morning name, evening name)

	var times = [
	    [-0.833d, "sunrise",       "sunset"      ]
	];
	
	
	// calculations for sun times

	var J0 = 0.0009d;
	
	function julianCycle(d, lw) { return MathFunctions.Round(d - J0 - lw / (2d * PI)); }
	
	function approxTransit(Ht, lw, n) { return J0 + (Ht + lw) / (2d * PI) + n; }
	function solarTransitJ(ds, M, L)  { return 2451545d + ds + 0.0053d * Math.sin(M) - 0.0069d * Math.sin(2d * L); }
	
	function hourAngle(h, phi, d) { return Math.acos((Math.sin(h) - Math.sin(phi) * Math.sin(d)) / (Math.cos(phi) * Math.cos(d))); }
	
	// returns set time for the given sun altitude
	function getSetJ(h, lw, phi, dec, n, M, L) {
	
	    var w = hourAngle(h, phi, dec);
	    var a = approxTransit(w, lw, n);
	    return solarTransitJ(a, M, L);
	}

	// moon calculations, based on http://aa.quae.nl/en/reken/hemelpositie.html formulas

	function moonCoords(d) { 
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

	public function GetMoonIllumination(date) {

		if (!_isMoonCalculationNeccessary) {
			return _moonIllumination;
		}
		//Sys.println("Calc Moon");
		var d = toDays(date);
		var s = sunCoords(d);
		var m = moonCoords(d);
		var sdist = 149598000d; // distance from Earth to Sun in km

		var phi = Math.acos(Math.sin(s["dec"]) * Math.sin(m["dec"]) + Math.cos(s["dec"]) * Math.cos(m["dec"]) * Math.cos(s["ra"] - m["ra"]));
		var inc = MathFunctions.Atan2(sdist * Math.sin(phi), m["dist"] - sdist * Math.cos(phi));
		var angle = MathFunctions.Atan2(Math.cos(s["dec"]) * Math.sin(s["ra"] - m["ra"]), Math.sin(s["dec"]) * Math.cos(m["dec"]) -
						Math.cos(s["dec"]) * Math.sin(m["dec"]) * Math.cos(s["ra"] - m["ra"]));

		_moonIllumination = 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / PI;

		_isMoonCalculationNeccessary = false;

		return _moonIllumination;
	}
}
	