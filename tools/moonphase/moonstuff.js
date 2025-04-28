var prev;
var next;
var prevJd;
var nextJd;

function calcNewMoonPhase(cur) {
  var k, t, e;
  var m, md, om, f;
  var JDE, appJDE;
  var cal;

  if (cur.dd <= 6)
    k = Math.floor((cur.yy + ((cur.mm - 1) / 12) - 2000) * 12.3685);
  else
    k = Math.floor((cur.yy + ((cur.mm) / 12) - 2000) * 12.3685);

  for (var i = 0; i < 2; i++) {
    t = k / 1236.85;
    e = 1 - (0.002516 * t) - (0.0000074 * Math.pow(t, 2));
    JDE = 2451550.09765 + (29.530588853 * k) + (0.0001337 * Math.pow(t, 2)) - (0.000000150 * Math.pow(t, 3)) + (0.00000000073 * Math.pow(t, 4));
    m = 2.5534 + (29.10535669 * k) - (0.0000218 * Math.pow(t, 2)) - (0.00000011 * Math.pow(t, 3));
    m = m % 360;
    if (m < 0)
      m += 360;
    else
      m -= 360;

    md = 201.5643 + (385.81693528 * k) + (0.0107438 * Math.pow(t, 2)) + (0.00001239 * Math.pow(t, 3)) - (0.000000058 * Math.pow(t, 4));
    md = md % 360;
    if (md < 0)
      md += 360;
    else
      md -= 360;

    f = 160.7108 + (390.67050274 * k) - (0.0016341 * Math.pow(t, 2)) - (0.00000227 * Math.pow(t, 3)) + (0.000000011 * Math.pow(t, 4));
    f = f % 360;
    if (f < 0)
      f += 360;
    else
      f -= 360;

    om = 124.7746 - (1.56375580 * k) + (0.0020691 * Math.pow(t, 2)) + (0.00000215 * Math.pow(t, 3));
    om = om % 360;
    if (om < 0)
      om += 360;
    else if (om > 360)
      om -= 360;

    m = m * (3.14159 / 180);
    md = md * (3.14159 / 180);
    om = om * (3.14159 / 180);
    f = f * (3.14159 / 180);

    appJDE = JDE - (0.40720 * Math.sin(md)) + (.17241 * e * Math.sin(m)) + (.01608 * Math.sin(2 * md)) + (.01039 * Math.sin(2 * f)) + (.00739 * e * Math.sin(md - m))
      - (.00514 * e * Math.sin(md + m)) + (.00208 * Math.pow(e, 2) * Math.sin(2 * m)) - (.00111 * Math.sin(md - 2 * f)) - (.00057 * Math.sin(md + 2 * f))
      + (.00056 * e * Math.sin(2 * md + m)) - (.00042 * Math.sin(3 * m)) + (.00042 * e * Math.sin(m + 2 * f)) + (.00038 * e * Math.sin(m - 2 * f))
      - (.00024 * e * Math.sin(2 * md - m)) - (.00017 * om) - (.00007 * Math.sin(md + 2 * m)) + (.00004 * Math.sin(2 * md - 2 * f)) + (.00004 * Math.sin(3 * m))
      + (.00003 * Math.sin(md + m - 2 * f)) + (.00003 * Math.sin(2 * md + 2 * f)) - (.00003 * Math.sin(md + m + 2 * f)) + (.00003 * Math.sin(md - m + 2 * f))
      - (.00002 * Math.sin(md - m - 2 * f)) - (.00002 * Math.sin(3 * md + m)) + (.00002 * Math.sin(4 * md));


    cal = JDtoCalendar(appJDE);



    if (calendarToJD(cur) - calendarToJD(cal) > 0) {
      prev = cal;
      prevJd = appJDE;
      k++;
    }
    else {
      next = cal;
      nextJd = appJDE;
      k--;
    }


  }
}

function calcFullMoonPhase(cur) {
  var k, t, e;
  var m, md, om, f;
  var JDE, appJDE;
  var cal;
  if (cur.dd <= 21)
    k = Math.floor((cur.yy + ((cur.mm - 1) / 12) - 2000) * 12.3685) + 0.5;
  else
    k = Math.floor((cur.yy + ((cur.mm) / 12) - 2000) * 12.3685) + 0.5;

  for (var i = 0; i < 2; i++) {
    t = k / 1236.85;
    e = 1 - (0.002516 * t) - (0.0000074 * Math.pow(t, 2));
    JDE = 2451550.09765 + (29.530588853 * k) + (0.0001337 * Math.pow(t, 2)) - (0.000000150 * Math.pow(t, 3)) + (0.00000000073 * Math.pow(t, 4));
    m = 2.5534 + (29.10535669 * k) - (0.0000218 * Math.pow(t, 2)) - (0.00000011 * Math.pow(t, 3));
    m = m % 360;
    if (m < 0)
      m += 360;
    else
      m -= 360;


    md = 201.5643 + (385.81693528 * k) + (0.0107438 * Math.pow(t, 2)) + (0.00001239 * Math.pow(t, 3)) - (0.000000058 * Math.pow(t, 4));
    md = md % 360;
    if (md < 0)
      md += 360;
    else
      md -= 360;

    f = 160.7108 + (390.67050274 * k) - (0.0016341 * Math.pow(t, 2)) - (0.00000227 * Math.pow(t, 3)) + (0.000000011 * Math.pow(t, 4));
    f = f % 360;
    if (f < 0)
      f += 360;
    else
      f -= 360;

    om = 124.7746 - (1.56375580 * k) + (0.0020691 * Math.pow(t, 2)) + (0.00000215 * Math.pow(t, 3));
    om = om % 360;
    if (om < 0)
      om += 360;
    else if (om > 360)
      om -= 360;

    m = m * (3.14159 / 180);
    md = md * (3.14159 / 180);
    om = om * (3.14159 / 180);
    f = f * (3.14159 / 180);

    appJDE = JDE - 0.40614 * Math.sin(md) +
      0.17302 * e * Math.sin(m) +
      0.01614 * Math.sin(2 * md) +
      0.01043 * Math.sin(2 * f) +
      0.00734 * e * Math.sin(md - m) +
      -0.00514 * e * Math.sin(md + m) +
      0.00209 * Math.pow(e, 2) * Math.sin(2 * m) +
      -0.00111 * Math.sin(md - 2 * f) +
      -0.00057 * Math.sin(md + 2 * f) +
      0.00056 * e * Math.sin(2 * md + m) +
      -0.00042 * Math.sin(3 * md) +
      0.00042 * e * Math.sin(m + 2 * f) +
      0.00038 * e * Math.sin(m - 2 * f) +
      -0.00024 * e * Math.sin(2 * md - m) +
      -0.00017 * Math.sin(om) +
      -0.00007 * Math.sin(md + 2 * m) +
      0.00004 * Math.sin(2 * md - 2 * f) +
      0.00004 * Math.sin(3 * m) +
      0.00003 * Math.sin(md + m - 2 * f) +
      0.00003 * Math.sin(2 * md + 2 * f) +
      -0.00003 * Math.sin(md + m + 2 * f) +
      0.00003 * Math.sin(md - m + 2 * f) +
      -0.00002 * Math.sin(md - m - 2 * f) +
      -0.00002 * Math.sin(3 * md + m) +
      0.00002 * Math.sin(4 * md);

    cal = JDtoCalendar(appJDE);

    if (calendarToJD(cur) - calendarToJD(cal) > 0) {
      prev = cal;
      k++;
    }
    else {
      next = cal;
      k--;
    }
  }
}

function JDtoCalendar(jd) {
  var z;
  var f;
  var alp, a, b, c, d, e;
  var dd;
  var mm, yy;
  var tmpH, tmpM, tmpS;


  z = Math.floor(jd + 0.5);
  f = (jd + 0.5) - z;
  if (z < 2299161) {
    a = z;
  }
  else {
    alp = Math.floor((z - 1867216.25) / 36524.25);
    a = z + 1 + alp - Math.floor(alp / 4);
  }
  b = a + 1524;
  c = Math.floor((b - 122.1) / 365.25);
  d = Math.floor(c * 365.25);
  e = Math.floor((b - d) / 30.6001);

  if (e < 14)
    mm = e - 1;
  else
    mm = e - 13;

  if (mm > 2)
    yy = c - 4716;
  else
    yy = c - 4715;

  dd = b - d - Math.floor(30.6001 * e) + f;

  var cal = {
    yy: yy,
    mm: mm,
    dd: Math.floor(dd),
    hr: 0,
    min: 0,
    sec: 0
  };
  tmpH = (dd - cal.dd) * 24;
  cal.hr = Math.floor(tmpH);
  tmpM = (tmpH - cal.hr) * 60;
  cal.min = Math.floor(tmpM);
  tmpS = (tmpM - cal.min) * 60;
  cal.sec = Math.floor(tmpS);

  return cal;
}

function calendarToJD(cal) {
  var calCopy = {
    yy: cal.yy,
    mm: cal.mm,
    dd: cal.dd,
    hr: cal.hr,
    min: cal.min,
    sec: cal.sec
  }
  var JDE;
  var a, b;
  var d = (calCopy.dd + calCopy.hr / 24);

  if (calCopy.mm <= 2) {
    calCopy.yy--;
    calCopy.mm += 12;
  }
  a = calCopy.yy / 10;
  b = 2 - a + (a / 4);

  JDE = (365.25 * (calCopy.yy + 4716)) + (30.6001 * (calCopy.mm + 1)) + d + b - 1524.5;
  return JDE;
}