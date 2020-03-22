using Toybox.WatchUi;
using Toybox.Attention;

class BikeDFSimulatorView extends WatchUi.DataField {
	 

    // Set the label of the data field here.
    function initialize() {
        DataField.initialize();
    }
    
    function onLayout(dc) {
        setLayout(Rez.Layouts.ProfileTrackView(dc));
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
    	ActivityValues.time = info.timerTime;
    	ActivityValues.distance = distanceInKm(info);
    }
    
    function onUpdate(dc) {
        var trackProfileScreen = View.findDrawableById("TrackProfileScreen");
        checkAlert();       
        View.onUpdate(dc);
    }
    
    function onShow() {
    	var trackProfileScreen = View.findDrawableById("TrackProfileScreen");
        changeZoom();
        View.onShow();
    }
    

    
    function distanceInKm(info){
    	var distance = info.elapsedDistance;
    	if(distance == null || distance<0){ 
    		distance = 0;
    	}
    	return distance/1000;
    	//return distance/50;
    } 
    
    
    function checkAlert(){
    	var currentKm = ActivityValues.distance.toLong();
    	if(currentKm - ActivityValues.lastKm == 1){
    		ActivityValues.alert = true;
    		ActivityValues.lastKm = currentKm;
    		ActivityValues.lastTime = ActivityValues.time;
	    	if(Attention has :playTone){
				Attention.playTone(Attention.TONE_DISTANCE_ALERT);
			}
			if (Attention has :vibrate) {
				var vibeData =
					[
						new Attention.VibeProfile(50, ActivityValues.alertDuration)
					];
				Attention.vibrate(vibeData);
			}
    	}
    	if(ActivityValues.alert && (ActivityValues.time  - ActivityValues.lastTime) > ActivityValues.alertDuration){
        	ActivityValues.lastTime = ActivityValues.time;
        	ActivityValues.alert = false;
        }
	}
    
       
    function changeZoom(){
		ActivityValues.zoom = !ActivityValues.zoom;
	}

}