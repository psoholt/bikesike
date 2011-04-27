// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function log() {
	if (app.debug && window.console && window.console.log) {
		try {
			console.log.apply(this, arguments);
		} catch (e) {}
	}
}

var app = {
	debug: true
};

app.config = {
	defaultCenter: new google.maps.LatLng(59.5658, 10.4523)
};

app.updatePositionUsingGeolocation = function() {
	// Try W3C Geolocation (Preferred)
	if (navigator.geolocation) {
		navigator.geolocation.getCurrentPosition(function(position) {
			app.setCenter(position.coords.latitude, position.coords.longitude, position.coords.accuracy);
		}, function() {
			app.setCenter();
		});
	// Browser doesn't support Geolocation
	} else {
		app.setCenter();
	}
};

app.init = function () {
	var myOptions = {
		center: app.config.defaultCenter,
		zoom: 6, //13,
		scaleControl:true,
		navigationControl:true,
		mapTypeControl:false,
		mapTypeId: google.maps.MapTypeId.ROADMAP
	};
	app.map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

	app.updatePositionUsingGeolocation();
	
	new Ajax.Request('/application/getmany', {
		method:'get',
		onSuccess: function(transport){
			var json = transport.responseText.evalJSON();
			$A(json).each(function(rack) {
				app.racks.push(new app.rack(rack));
			});
			// log(app.racks.join(";"));
		}
	});
};

window.onload = app.init;

app.setCenter = function(latitude, longitude, accuracy) {
	var gLocation = (latitude && longitude) ? new google.maps.LatLng(latitude, longitude) : app.config.defaultCenter;
	app.map.setCenter(gLocation);
};

app.getMarker = function (options) {
	var _options = Object.extend({
		map: app.map,
		position: app.config.defaultCenter,
		vsible: false
	}, options || {});
	log(_options);
	return new google.maps.Marker(_options);
};

app.racks = [];

app.rack = Class.create({
	initialize: function(obj) {
		// properties
		this.id          = null;
	    this.name        = null;
		this.latitude    = null;
		this.longitude   = null;
		this.description = null;
		this.bikes       = 0;
		this.locks       = 0;

		Object.extend(this, obj);

		// map objects
		this.marker = app.getMarker({
			position: new google.maps.LatLng(this.latitude, this.longitude),
			visible: true
		});
		this.infoWindow = null;
		
		// add event listeners
		google.maps.event.addListener(this.marker, 'click', this.markerClickHandler.bindAsEventListener(this));
	},
	markerClickHandler: function() {
		if (!this.infoWindow) {
			console.log("new infowindow");
			this.infoWindow = new google.maps.InfoWindow({
				content: this.toHTML()
			});
		}
		this.infoWindow.open(app.map, this.marker);
		
		return;
		
	    var bryantPark = new google.maps.LatLng(37.869260, -122.254811);
	    var panoramaOptions = {
	      position:bryantPark,
	      pov: {
	        heading: 165,
	        pitch:0,
	        zoom:1
	      }
	    };
	    var myPano = new google.maps.StreetViewPanorama(document.getElementById("pano"), panoramaOptions);
	    myPano.setVisible(true);		
	},
	toString: function() {
		return "RACK id: " + this.id + ", lat: " + this.latitude + ", long: " + this.longitude;
	},
	toHTML: function() {
		return [
			'<div class="rack" data-latitude="' + this.latitude + '" data-longitude="' + this.longitude + '">',
				//'<h2>' + this.name + '</h2>',
				//'<p>' + this.description + '</p>',
				//'<h3>Available resources</h3>',
				'<img src="http://cbk0.google.com/cbk?output=thumbnail&w=240&h=180&ll=' + this.latitude + ',' + this.longitude + '" />',
				//'<ul>',
					'<div class="res bikes">',
						'<strong>Bikes: </strong>',
						this.bikes,
					'</div>',
					'<div class="res locks">',
						'<strong>Locks: </strong>',
						this.locks,
					'</div>',
//				'</ul>',
			'</div>'
		].join('');
	}
});

document.observe("click", function(e) {
	var rack = e.findElement(".rack");
	if (rack) {
		var latitude  = rack.getAttribute("data-latitude"),
			longitude = rack.getAttribute("data-longitude");
		if (!rack.down(".panorama")) {
			rack.down("img").insert({
				'after': '<div class="panorama" />'
			});
			var currentLocation = new google.maps.LatLng(latitude, longitude),
		    	panoramaOptions = {
					position: currentLocation,
					addressControl: false,
					panControl: false,
					zoomControl: false,
					pov: {
						heading: 165,
						pitch: 0,
						zoom: 1
					}
		    	};
		    var myPano = new google.maps.StreetViewPanorama(rack.down(".panorama"), panoramaOptions);
		    myPano.setVisible(true);		
		}
	}
});