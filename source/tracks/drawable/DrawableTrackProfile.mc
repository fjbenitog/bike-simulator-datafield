using Toybox.Graphics;
using Toybox.Math;
using Toybox.WatchUi;
using Toybox.System;

class DrawableTrackProfile extends WatchUi.Drawable {

	private var drawPoints;
	private var maxPoint;
	private const base = 20;
	var x = 0;
	var y = 0;
	var width =  System.getDeviceSettings().screenWidth - 1;
	var height;
	var padding = 0;
	var font = Graphics.FONT_XTINY;
	var initialPercentage = 0;
	
	
	private function getTracks() {
		var selectedTrack = Application.getApp().getProperty("track");
		if(selectedTrack==0){
			return randomTrack();
		}else{
			return generate("profile"+selectedTrack);
		}

	}	
	
	private function generate(profile) {
		var total = Application.getApp().getProperty(profile);
		var initial = parser(total);
		var accu = [initial[1]];
		var left = initial[0];
		while(left.length()>0){
			var result = parser(left);
			accu.add(result[1]);
			left =result[0];
		}
		return accu;
	}
	
	private function parser(value) {
		var position = value.find(",");
		if(position == null){ 
			return ["",value.toNumber()];
		}else{
			var percentage = value.substring(0, position);
			var left = value.substring(position+1, value.length());
			return [left,percentage.toNumber()];
		}
	}
					
	 
	var track = new Track(getTracks()); 

	function initialize(options) {
	    Drawable.initialize(options);

        drawPoints = track.drawPoints;
        maxPoint = track.maxPoint;
        initialPercentage = track.profile[0];
        var x_ = options.get(:x);
        if(x_ != null) {
            x = x_;
        }
        var y_ = options.get(:y);
        if(y_ != null) {
            y = y_;
        }
        var width_ = options.get(:width);
        if(width_ != null) {
            width = width_;
        }
        var height_ = options.get(:height);
        if(height_ != null) {
            height = height_;
        }
       	if(height == 0){
			height = y;
		}
        var padding_ = options.get(:padding);
        if(padding_ != null) {
            padding = padding_;
        }
        var font_ = options.get(:font);
        if(font_ != null) {
            font = font_;
        }
	}
	
	function setY(y_){
		y = y_;
	}
	
	function draw(dc) {
		
		var totalDistance =  drawPoints.size();
		var calculatedPointsAndDistance = selectPoints(ActivityValues.distance);
		var virtualdrawPoints = calculatedPointsAndDistance[0];
		var currentDistance = calculatedPointsAndDistance[1];
		var startKm = calculatedPointsAndDistance[2];
		var initPoint = calculatedPointsAndDistance[3];
	

		//Calculate scales to redimension Profile
		var screenDistance = virtualdrawPoints.size();
		var rate = width.toDouble() / (screenDistance+1);
		var scale = height.toDouble() / (maxPoint +base);
		

		//Draw border and populate polygon for profile
		var cursor = calculateCursorAndDrawProfile(rate,scale,virtualdrawPoints,currentDistance,startKm,initPoint,dc);
    	
    	drawCursor(cursor,dc);
    	
		if(ActivityValues.zoom){
	    	dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
			dc.drawText(x + width/2, y + padding/2, font, "Z:[ " + printDistance(ActivityValues.distance) + "/" +totalDistance + " Kms ]", Graphics.TEXT_JUSTIFY_CENTER);
			
    	}else{
    		dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
			dc.drawText(x + width/2, y + padding, font, printDistance(ActivityValues.distance) + "/" + screenDistance + " Kms", Graphics.TEXT_JUSTIFY_CENTER);
    	}    	
    	
	}
	
	private function calculateCursorAndDrawProfile(rate,scale,virtualdrawPoints,currentDistance,startKm,initPoint,dc){
		var cursor = null;
		var prevXPoint = null;
		var prevYPoint = null; 
		var firstXPoint = null;
		var firstYPoint = null; 
		var kmMark = calculateKmMark(virtualdrawPoints.size()+1) ;
		var lineWidth = 2;
		for(var i = 0; i <= virtualdrawPoints.size(); ++i) {
			var xPoint = x + (i * rate).toNumber() + lineWidth;
			var yPoint = calculateY(i,virtualdrawPoints,scale,initPoint);
			if(i < currentDistance){ 
				cursor = [xPoint, yPoint];
			}
			if(i==0){
				firstXPoint = xPoint;
				firstYPoint = yPoint;
			}
			if(i>0){
				dc.setPenWidth(1);
				if(i > currentDistance){ 
					dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
				}else{
					dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
				}
				dc.fillPolygon([
									[prevXPoint	, prevYPoint-1],
									[xPoint		, yPoint-1	],
									[xPoint		, y			],
									[prevXPoint	, y			]
								]);
				dc.setPenWidth(2);
				dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
				dc.drawLine(prevXPoint, prevYPoint, xPoint, yPoint);
			}
			prevXPoint = xPoint;
			prevYPoint = yPoint;
			
			if(((startKm + i)%kmMark).toLong() == 0){
				dc.setPenWidth(2);
				dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		    	dc.drawLine(xPoint,y+1,xPoint,y+4);
			}

    	}
    	dc.setPenWidth(lineWidth);
    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawLine(prevXPoint, prevYPoint, prevXPoint, y);
		dc.drawLine(prevXPoint, y, firstXPoint, y);
		dc.drawLine(firstXPoint, y, firstXPoint, firstYPoint);
		dc.setPenWidth(1);
    	return cursor;
	}
	
	
	private function calculateY(i,virtualdrawPoints,scale,initPoint){
		if(i==0 && initPoint == null){
			return y - ((virtualdrawPoints[0] + base - initialPercentage) * scale).toNumber();
		}else if(i==0 && initPoint != null){
			return y - ((initPoint + base) * scale).toNumber();
		}
		else{
			return y - ((virtualdrawPoints[i-1] + base) * scale).toNumber();
		}
	
	}
	
	private function calculateKmMark(size){
		if(ActivityValues.zoom){
			return 2;
		}else{
			return (size/4);
		}
	}
	
	private function drawCursor(cursor,dc){
    	if(cursor!=null){
	    	dc.setColor(Graphics.COLOR_BLUE, Graphics.Graphics.COLOR_TRANSPARENT);
	    	dc.fillCircle(cursor[0], cursor[1], 3);
	    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
	    	dc.fillCircle(cursor[0], cursor[1], 2);
	    }
	}
	
	private function selectPoints(currentDistance){
		var virtualDistance = currentDistance;
		if(ActivityValues.zoom){
			var zoomDistance = 5;
			var startPoint = currentDistance.toLong() - zoomDistance;
			var endPoint = currentDistance.toLong() + zoomDistance;
			var initPoint = null;
			if(startPoint<0){
				startPoint = 0;
				endPoint = 2 * zoomDistance;
			}else{
				virtualDistance = zoomDistance+0.1;
				
			}
			if(endPoint > drawPoints.size()){
				virtualDistance = zoomDistance+0.1 + (endPoint - drawPoints.size());
				endPoint = drawPoints.size();
				startPoint = drawPoints.size() - 2*zoomDistance;
				
			}
			if((startPoint-1)>0){
				initPoint = drawPoints[(startPoint-1).toNumber()];
			}
			return [drawPoints.slice(startPoint, endPoint),virtualDistance,startPoint.toLong(),initPoint];
		}else{
			return [drawPoints,virtualDistance,0,null];
		}
	}
	

	private function printDistance(distance){
    	return  Lang.format( "$1$",
    		[
        		distance.format("%02.2f")
    		]
		);
    }
    
    private function randomTrack(){
		var kms = randomNumber(20,100);
		var profile = new [kms];
		var acc = 0;
		for(var i = 0; i< profile.size(); i++){
			var gradient = randomNumber(-8,8);
			if((acc + gradient)< 0){
				gradient = 0;
			}
			acc = acc + gradient;
			profile[i] = gradient;
		}
		return profile;
	}
	
	private function randomNumber(min,max){
		var maxInt = 2147483647;
		return (((Math.rand().toFloat()/maxInt)*(max-min)) + min).toNumber();
	}

	
}
