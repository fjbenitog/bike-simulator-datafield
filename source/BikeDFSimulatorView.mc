using Toybox.WatchUi;
using Toybox.Attention;

class BikeDFSimulatorView extends WatchUi.DataField {

	private var distance = 0;
	private var lastKm = 0;
	private var time = 0;
	private var lastTime = 0;
	private var alert = false;
	private var alertDuration = 2000;
	

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
    	time = info.timerTime;
    	distance = distanceInKm(info);
    }
    
    function onUpdate(dc) {
        var trackProfileScreen = View.findDrawableById("TrackProfileScreen");
        checkAlert();       
        trackProfileScreen.distance = distance;
        trackProfileScreen.alerting = alert;
        View.onUpdate(dc);
    }
    
    function onShow() {
    	var trackProfileScreen = View.findDrawableById("TrackProfileScreen");
        trackProfileScreen.changeZoom();
        View.onShow();
    }
    
    function distanceInKm(info){
    	var distance = info.elapsedDistance;
    	if(distance == null || distance<0){ 
    		distance = 0;
    	}
    	//return distance/1000;
    	return distance/50;
    } 
    
    
    function checkAlert(){
    	var currentKm = distance.toLong();
    	if(currentKm - lastKm == 1){
    		alert = true;
    		lastKm = currentKm;
    		lastTime = time;
	    	if(Attention has :playTone){
				Attention.playTone(Attention.TONE_DISTANCE_ALERT);
			}
			if (Attention has :vibrate) {
				var vibeData =
					[
						new Attention.VibeProfile(50, alertDuration)
					];
				Attention.vibrate(vibeData);
			}
    	}
    	if(alert && (time  - lastTime) > alertDuration){
        	lastTime = time;
        	alert = false;
        }
	}
    
       
    

}