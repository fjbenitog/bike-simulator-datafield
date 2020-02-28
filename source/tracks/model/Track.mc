class Track{

	var profile;
	var drawPoints;
	var maxPoint;
	
	
	function initialize(profile_) {
        profile = profile_;
        
        drawPoints = new [profile_.size()];
        var previousPoint = 0;
        maxPoint = 0;
        for(var i = 0 ; i < drawPoints.size() ; i++){
        	previousPoint = previousPoint + profile[i];
        	drawPoints[i] = previousPoint;
        	if(maxPoint < previousPoint){
        		maxPoint = previousPoint;
        	}
        }
    }
}