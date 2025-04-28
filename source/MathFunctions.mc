using Toybox.Math as Math;

module MathFunctions {
	function Atan2(y, x) {
		if(x < 0 && y == 0) {
			return Math.PI;
		}
		
		return 2 * Math.atan(y / (Math.sqrt(x*x+y*y) + x));
	}
	
	function Round(v) {
		return (v + 0.5).toLong();
	}
	
	function Floor(v) {
		return v.toLong();
	}
}
