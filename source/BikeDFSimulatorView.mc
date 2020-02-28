using Toybox.WatchUi;

class BikeDFSimulatorView extends WatchUi.DataField {

	hidden var distance = 0;
	hidden var percentage = 0;
	

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
    	distance = distanceInKm(info);
 		percentage = distanceInKm(info);
    }
    
    function onUpdate(dc) {
        var trackProfileScreen = View.findDrawableById("TrackProfileScreen");
        trackProfileScreen.distance = distance;
        View.onUpdate(dc);
    }
    
    function onShow() {
    	var trackProfileScreen = View.findDrawableById("TrackProfileScreen");
        trackProfileScreen.changeZoom();
        View.onShow();
    }
    
    
    function meterDistance(info){
    	var distance = info.elapsedDistance;
    	if(distance == null || distance<0){ 
    		distance = 0;
    	}
    	return distance;
    }
    
    function distanceInKm(info){
//    	return meterDistance(info)/1000;
    	return meterDistance(info)/50;
    }    
    

}