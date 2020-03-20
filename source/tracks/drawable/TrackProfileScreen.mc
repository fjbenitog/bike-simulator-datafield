using Toybox.Graphics;
using Toybox.Math;
using Toybox.WatchUi;
using Toybox.System;

class TrackProfileScreen extends WatchUi.Drawable {

	var fontNumber = Graphics.FONT_NUMBER_MILD;
	var fontField = Graphics.FONT_SYSTEM_XTINY;
	var marginField = 0;
	var margingBottom = 0;
	
	var distance = 0;
	var percentage = 0;
	
	
	var power = 0;
	var gear = 0;
	
	var zoom = true;
	var alerting = false;
	
	var drawableTrackProfile;
	
	//Configuration
	var gears = Application.getApp().getProperty("gears");
	var powerSixe = Application.getApp().getProperty("power");
	var level = Application.getApp().getProperty("level");


	function initialize(options) {
		Drawable.initialize(options);
		var fontNumber_ = options.get(:fontNumber);
        if(fontNumber_ != null) {
            fontNumber = fontNumber_;
        }
        var fontField_ = options.get(:fontField);
        if(fontField_ != null) {
            fontField = fontField_;
        }
        var marginField_ = options.get(:marginField);
        if(marginField_ != null) {
            marginField = marginField_;
        }
        var margingBottom_ = options.get(:margingBottom);
        if(margingBottom_ != null) {
            margingBottom = margingBottom_;
        }
        drawableTrackProfile  = new DrawableTrackProfile({
        	:width 		=> System.getDeviceSettings().screenWidth - 38, 
        	:height 	=> System.getDeviceSettings().screenHeight/2 - 10 - marginField - margingBottom,
        	:y 			=> 3 * System.getDeviceSettings().screenHeight/4 - margingBottom ,
        	:x 			=> 22,
        	:padding	=> 10,
        	:font		=> Graphics.FONT_SYSTEM_TINY
        	}); 
	}
	 
	function draw(dc) {
		if(alerting){
	    	drawAlerting(dc);
		}else{
			drawableTrackProfile.distance = distance;
			drawableTrackProfile.zoom = zoom;
		    calculatePercentage();
		    calculateEmulation(gears,powerSixe,level);
		    drawFields(dc);
		    drawableTrackProfile.draw(dc);
	    }
	}
	
	private function drawAlerting(dc){
		var heightFont = Graphics.getFontHeight(Graphics.FONT_SYSTEM_MEDIUM);
		var heightNumberFont = Graphics.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);
    	dc.setColor(Graphics.COLOR_WHITE, Graphics.Graphics.COLOR_TRANSPARENT);
    	dc.drawText(dc.getWidth()/2, dc.getHeight()/8, Graphics.FONT_SYSTEM_MEDIUM,
    		 WatchUi.loadResource(Rez.Strings.powerLabel).toUpper() + ":", Graphics.TEXT_JUSTIFY_CENTER);
    	dc.drawText(dc.getWidth()/2, dc.getHeight()/8 + heightFont,
    		 Graphics.FONT_NUMBER_MEDIUM, power, Graphics.TEXT_JUSTIFY_CENTER);
    		 
    	dc.drawText(dc.getWidth()/2, dc.getHeight()/8 + heightFont + heightNumberFont, Graphics.FONT_SYSTEM_MEDIUM, 
    		WatchUi.loadResource(Rez.Strings.maxGear).toUpper() + ":", Graphics.TEXT_JUSTIFY_CENTER);
    	dc.drawText(dc.getWidth()/2, dc.getHeight()/8 + heightNumberFont + 2 * heightFont,
    		 Graphics.FONT_NUMBER_MEDIUM, gear, Graphics.TEXT_JUSTIFY_CENTER);
	}
	
	private function drawFields(dc){
		var base = dc.getHeight()/4 + marginField;
    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    	dc.setPenWidth(2);
    	dc.drawLine(0, base, dc.getWidth(), base);
    	dc.drawLine(dc.getWidth()/2, 0, dc.getWidth()/2, base);
		dc.setPenWidth(1);
		dc.drawText(dc.getWidth()/2 - 10, base - Graphics.getFontHeight(fontField), 
			fontField, WatchUi.loadResource(Rez.Strings.powerLabel).toUpper(), Graphics.TEXT_JUSTIFY_RIGHT);
		dc.drawText(dc.getWidth()/2 + 10, base - Graphics.getFontHeight(fontField), 
			fontField, WatchUi.loadResource(Rez.Strings.maxGear).toUpper(), Graphics.TEXT_JUSTIFY_LEFT);
		if(distance>0){
		    
		    dc.drawText(dc.getWidth()/2 - 10, base - Graphics.getFontHeight(fontField)  - Graphics.getFontHeight(fontNumber) - marginField/2, 
				fontNumber, power, Graphics.TEXT_JUSTIFY_RIGHT);
			dc.drawText(dc.getWidth()/2 + 10, base - Graphics.getFontHeight(fontField)  - Graphics.getFontHeight(fontNumber) - marginField/2, 
				fontNumber, gear, Graphics.TEXT_JUSTIFY_LEFT );
			
			dc.setColor(Graphics.COLOR_WHITE, Graphics.Graphics.COLOR_TRANSPARENT);
			dc.drawText(dc.getWidth()/2, dc.getHeight() - 15 , Graphics.FONT_TINY, percentage + "%", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	
		}
    }
    
    private function calculatePercentage(){
    	var profile = drawableTrackProfile.track.profile;
    	if(distance <=0 || distance>=profile.size()){
    		percentage = 0;
    	}else{
    		percentage= profile[distance.toNumber()];
		}
    }
    
	function calculateEmulation(gears, powerSize, level){
		var calculatePower = percentage + level;
		if(calculatePower > powerSize){
			power = powerSize;
			gear = gears - (calculatePower - powerSize);
		}else if(calculatePower<1){
			power = 1;
			gear = gears;
		}else{
			power = calculatePower;
			gear = gears;
		}
	}
	
	function changeZoom(){
		zoom = !zoom;
		return zoom;
	}
    


}