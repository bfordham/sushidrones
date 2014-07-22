var map;
var mc;

function strikeToMarker(strike)
{
	return new google.maps.Marker({'position': new google.maps.LatLng(strike.lat, strike.lon)});
}

function initialize()
{
	if (strikes && strikes.length > 0)
	{
		var markers = [];
		for (var i =0; i < strikes.length; i++)
		{
			markers.push(strikeToMarker(strikes[i]));
		}

		map = new google.maps.Map(document.getElementById("mapdiv"));
		mc = new MarkerClusterer(map, markers);

		if (strikes.length == 1)
		{
			map.setCenter(markers[0].getPosition());
			map.setZoom(8);
		}
		else
		{
			mc.fitMapToMarkers();
		}
	}
}
google.maps.event.addDomListener(window, 'load', initialize);