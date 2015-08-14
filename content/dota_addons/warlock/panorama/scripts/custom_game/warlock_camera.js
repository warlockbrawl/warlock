/*

Scrolling distance camera with interpolation

*/

(function() {
	var CAMERA_DIST_MIN = 500;
	var CAMERA_DIST_MAX = 1500;
	var CAMERA_DIST_PER_SCROLL = 200;
	var CAMERA_UPDATE_INTERVAL = 1.0 / 60.0;
	var CAMERA_FILTER_ALPHA = 0.8;
	
	var cameraDistTarget = 1100;
	var cameraDist = 1100;

	GameUI.SetMouseCallback(function(eventName, arg) {
		if(eventName == "wheeled") {
			//Set camera target distance and clamp
			cameraDistTarget = Math.max(CAMERA_DIST_MIN, Math.min(CAMERA_DIST_MAX, cameraDist - arg * CAMERA_DIST_PER_SCROLL));
			return true;
		}
		
		return false;
	});
	
	function interpCamera() {
		//Interpolate between the current camera distance and the target camera distance
		cameraDist = CAMERA_FILTER_ALPHA * cameraDist + (1 - CAMERA_FILTER_ALPHA) * cameraDistTarget;
		GameUI.SetCameraDistance(cameraDist);
		$.Schedule(CAMERA_UPDATE_INTERVAL, interpCamera);
	}
	
	$.Schedule(CAMERA_UPDATE_INTERVAL, interpCamera);
})();