#mapdiv(style="width:50%;height:50%")

:javascript
	var mc;
	function initialize() {
		var markers = [];

		-@strikes.each do |strike|
			
		var mapOptions = {
			center: strikeLatlng,
			zoom: 8
		};
		map = new google.maps.Map(document.getElementById("mapdiv"), mapOptions);
		mc = new MarkerClusterer(map, markers);

		

	}
	google.maps.event.addDomListener(window, 'load', initialize);