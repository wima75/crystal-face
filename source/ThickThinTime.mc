using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application as App;

import Toybox.Lang;

class ThickThinTime extends Ui.Drawable {

	private var mBoldFont, mLightFont/*, mSecondsFont*/;

	// "y" parameter passed to drawText(), read from layout.xml.
	private var mSecondsY;

	// Wide rectangle: time should be moved up slightly to centre within available space.
	private var mAdjustY = 0;

	// Tight clipping rectangle for drawing seconds during partial update.
	// "y" corresponds to top of glyph, which will be lower than "y" parameter of drawText().
	// drawText() starts from the top of the font ascent, which is above the top of most glyphs.
	private var mSecondsClipRectX;
	private var mSecondsClipRectY;
	private var mSecondsClipRectWidth;
	private var mSecondsClipRectHeight;

	private var mHideSeconds = false;
	private var AM_PM_X_OFFSET = 2;

	// #10 Adjust position of seconds to compensate for hidden hours leading zero.
	private var mSecondsClipXAdjust = 0;

	typedef ThickThinTimeParams as {
		:secondsX as Number,
		:secondsY as Number,
		:secondsClipY as Number,
		:secondsClipWidth as Number,
		:secondsClipheight as Number,
		:adjustY as Number?,
		:amPmOffset as Number?
	};

	function initialize(params as ThickThinTimeParams) {
		Drawable.initialize(params);

		if (params[:adjustY] != null) {
			mAdjustY = params[:adjustY];
		}

		if (params[:amPmOffset] != null) {
			AM_PM_X_OFFSET = params[:amPmOffset];
		}

		mSecondsY = params[:secondsY];

		mSecondsClipRectX = params[:secondsX];
		mSecondsClipRectY = params[:secondsClipY];
		mSecondsClipRectWidth = params[:secondsClipWidth];
		mSecondsClipRectHeight = params[:secondsClipHeight];

		mBoldFont = Ui.loadResource(Rez.Fonts.BoldFont);
		mLightFont = Ui.loadResource(Rez.Fonts.LightFont);
		//mSecondsFont = Ui.loadResource(Rez.Fonts.SecondsFont);
	}

	function setHideSeconds(hideSeconds) {
		mHideSeconds = hideSeconds;
	}
	
	function draw(dc) {
		drawHoursMinutes(dc);
		drawSeconds(dc, /* isPartialUpdate */ false);
	}

	function drawHoursMinutes(dc) {
		var clockTime = Sys.getClockTime();
		var formattedTime = App.getApp().getFormattedTime(clockTime.hour, clockTime.min);
		formattedTime[:amPm] = formattedTime[:amPm].toUpper();

		var hours = formattedTime[:hour];
		var minutes = formattedTime[:min];
		var amPmText = formattedTime[:amPm];

		var halfDCWidth = dc.getWidth() / 2;
		var halfDCHeight = (dc.getHeight() / 2) + mAdjustY;

		// Centre combined hours and minutes text (not the same as right-aligning hours and left-aligning minutes).
		// Font has tabular figures (monospaced numbers) even across different weights, so does not matter which of hours or
		// minutes font is used to calculate total width.
		var hoursFont = mBoldFont;
		var totalWidth = dc.getTextWidthInPixels(hours + minutes, hoursFont);
		var x = halfDCWidth - (totalWidth / 2);

		// Draw hours.
		dc.setColor(gHoursColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText(
			x,
			halfDCHeight,
			hoursFont,
			hours,
			Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
		);
		x += dc.getTextWidthInPixels(hours, hoursFont);

		// Draw minutes.
		var minutesFont = gIsMinutesBold ? mBoldFont : mLightFont;
		dc.setColor(gMinutesColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText(
			x,
			halfDCHeight,
			minutesFont,
			minutes,
			Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
		);

		// If required, draw AM/PM after minutes, vertically centred.
		if (amPmText.length() > 0 && !gHideAmPm) {
			dc.setColor(gThemeColour, Graphics.COLOR_TRANSPARENT);
			x += dc.getTextWidthInPixels(minutes, minutesFont);
			dc.drawText(
				x + AM_PM_X_OFFSET, // Breathing space between minutes and AM/PM.
				halfDCHeight,
				gSecondsFont,
				amPmText,
				Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
			);
		}
	}

	// Called to draw seconds both as part of full draw(), but also onPartialUpdate() of watch face in low power mode.
	// If isPartialUpdate flag is set to true, strictly limit the updated screen area: set clip rectangle before clearing old text
	// and drawing new. Clipping rectangle should not change between seconds.
	function drawSeconds(dc, isPartialUpdate) {
		if (mHideSeconds) {
			return;
		}
		
		var clockTime = Sys.getClockTime();
		var seconds = clockTime.sec.format("%02d");

		if (isPartialUpdate) {

			dc.setClip(
				mSecondsClipRectX + mSecondsClipXAdjust,
				mSecondsClipRectY,
				mSecondsClipRectWidth,
				mSecondsClipRectHeight
			);

			// Can't optimise setting colour once, at start of low power mode, at this goes wrong on real hardware: alternates
			// every second with inverse (e.g. blue text on black, then black text on blue).
			dc.setColor(gThemeColour, /* Graphics.COLOR_RED */ gBackgroundColour);	

			// Clear old rect (assume nothing overlaps seconds text).
			dc.clear();

		} else {

			// Drawing will not be clipped, so ensure background is transparent in case font height overlaps with another
			// drawable.
			dc.setColor(gThemeColour, Graphics.COLOR_TRANSPARENT);
		}

		dc.drawText(
			mSecondsClipRectX + mSecondsClipXAdjust,
			mSecondsY,
			gSecondsFont,
			seconds,
			Graphics.TEXT_JUSTIFY_LEFT
		);
	}
}