// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function log() {
	if (app && app.debug && window.console && window.console.log) {
		try {
			console.log.apply(this, arguments);
		} catch (e) {}
	}
}

var BikeSyke = Class.create({
	debug: true,
	useStreetview: false,
	config: {
		defaultCenter: new google.maps.LatLng(59.5658, 10.4523)
	},
	initialize: function() {
		
	},
	updatePositionUsingGeolocation: function() {
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
	},
	setMode: function(mode) {
		if (/BOTH|LOCKS|BIKES/.test(mode)) {
			app.mode = mode;
			app.racks.invoke("update");
		}
	},
	setCenter: function(latitude, longitude, accuracy) {
		var gLocation = (latitude && longitude) ? new google.maps.LatLng(latitude, longitude) : app.config.defaultCenter;
		app.map.setCenter(gLocation);
	}
	
});

var app = new BikeSyke();


app.init = function () {
	var myOptions = {
		center: app.config.defaultCenter,
		zoom: 13,
		scaleControl:true,
		navigationControl:true,
		mapTypeControl:false,
		mapTypeId: google.maps.MapTypeId.ROADMAP
	};
	app.map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

	app.updatePositionUsingGeolocation();
	
	var rackProvider = new RackProvider(app.map, function() {return app.mode;});
	new Ajax.Request('/application/getmany', {
		method:'get',
		onSuccess: function(transport){
			var json = transport.responseText.evalJSON();
			$A(json).each(function(rack) {
				app.racks.push(new app.rack(rack, {
					provider: rackProvider,
					useStreetview:  app.useStreetview
				}));
			});
		}
	});
};


document.observe("dom:loaded", function() {
	app.init();
});

app.mode = "BOTH"; // BIKES, LOCKS

RackProvider = Class.create({
	initialize: function(map, getMode) {
		this.map = map;
		this.mode = getMode;
	},
	getRackData: function(id, callback) {
		new Ajax.Request('/application/getjson/' + id + '.json', {
			method:'get',
			onSuccess: function(transport){
				var json = transport.responseText.evalJSON();
				callback(json);
			}
		});
	},
	getMarker: function (options) {
	/*  var iconOptions = {width:32, height:32, primaryColor:"#cccccc", cornerColor:"#FFFFFF", strokeColor:"#000000"};
		var iconOptions = {width:32, height:32, primaryColor:"#cccccc", label:"a", labelSize:0, labelColor:"#000000", shape:"circle"}; */
		var _options = Object.extend({
			map: this.map,
			position: app.config.defaultCenter,
			vsible: false
		}, options || {});
		return new google.maps.Marker(_options);
	},
	getMarkerIcon: function(providerData) {
		// http://gmaps-utility-library.googlecode.com/svn/trunk/mapiconmaker/1.1/examples/markericonoptions-wizard.html
		// https://chart.googleapis.com/chart?chst=d_map_pin_icon_withshadow&chld=bicycle|cccccc|ffffff
		// http://chart.apis.google.com/chart?cht=it&chs=32x32&chco=cccccc,000000ff,ffffff01&chl=a&chx=000000,0&chf=bg,s,00000000&ext=.png
		var icon;
		if (this.mode() === "BOTH") {
			url = "https://chart.googleapis.com/chart?chst=d_map_pin_icon&chld=bicycle|cccccc|ffffff";
		}
		else if (this.mode() === "BIKES" || this.mode() === "LOCKS") {
			url = "https://chart.googleapis.com/chart?chst=d_map_pin_letter&chld=" + providerData[this.mode() === "BIKES" ? "bikes" : "locks"] + "|666666|ffffff";
		}
		return url;
	},
	getMarkerVisibility: function(providerData) {
		return app.mode === "BOTH" || 
			(app.mode === "BIKES" && providerData.bikes > 0) ||
			(app.mode === "LOCKS" && providerData.locks > 0);
	}
	
});

app.racks = $A();

app.rack = Class.create({
	initialize: function(obj, options) {
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
		this.infoWindow = null;
		this.marker     = null;

		// resources
		this.provider = options.provider;
		
		this.useStreetview = options.useStreetview;

		if (!this.initMarker()) {
			this.provider.getRackData(this.id, this.updateDataFromAjax.bindAsEventListener(this));
		}
	},
	initMarker: function() {
		if (!this.marker && this.latitude && this.longitude) {
			log("adding marker");
			this.marker = this.provider.getMarker({
				position: new google.maps.LatLng(this.latitude, this.longitude),
				icon: this.provider.getMarkerIcon(this.toCommonObject()),
				visible: true
			});
			// add event listeners
			google.maps.event.addListener(this.marker, 'click', this.markerClickHandler.bindAsEventListener(this));
			
			return true;
		}
		return false;
	},
	update: function() {
		this.updateMarker();
	},
	updateMarker: function() {
		if (this.marker) {
			this.marker.setIcon(this.provider.getMarkerIcon(this.toCommonObject()));
			this.marker.setVisible(this.provider.getMarkerVisibility(this.toCommonObject()));
		}
	},
	updateDataFromAjax: function(jsonData) {
		log("ajax fetched");
		this.updateProperty("bikes",       jsonData.ready_bikes);
		this.updateProperty("locks",       jsonData.empty_locks);
		this.updateProperty("description", jsonData.description);
		this.updateProperty("longitude",   jsonData.longitude);
		this.updateProperty("latitude",    jsonData.latitude);
	},
	updateProperty: function(property, value) {
		if (this[property] !== value) {
			// log("updating rack ", this.id, " with: ", property, " = ", value);
			this[property] = value;
			if (this.infoWindowContent) {
				var dataElement = this.infoWindowContent.down(".data-"+property);
				if (dataElement) {
					dataElement.innerHTML = value;
				}
			}
			if (/longitude|latitude/.test(property)) {
				this.initMarker();
			}
			if (/locks|bikes/.test(property)) {
				this.updateMarker();
			}
		}
	},
	markerClickHandler: function() {
		this.provider.getRackData(this.id, this.updateDataFromAjax.bindAsEventListener(this));
		if (!this.infoWindow) {
			console.log("new infowindow");
			var element = new Element("div");
			element.insert(this.toHTML());
			this.infoWindowContent = element.firstDescendant();
			this.infoWindow = new google.maps.InfoWindow({
				content: this.infoWindowContent
			});
			this.infoWindowReadyListener = google.maps.event.addListener(
				this.infoWindow, 
				'domready', 
				this.infoWindowReadyHandler.bindAsEventListener(this)
			);
		}
		this.infoWindow.open(app.map, this.marker);
	},
	infoWindowReadyHandler: function(e) {
		if (this.useStreetview) {
			log("new street view");
			var currentLocation = new google.maps.LatLng(this.latitude, this.longitude),
				panoramaElement = this.infoWindowContent.down(".panorama"),
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

		    this.streetView = new google.maps.StreetViewPanorama(panoramaElement, panoramaOptions);
	    	this.streetView.setVisible(true);
		}

		// remove ready listener
		google.maps.event.removeListener(this.infoWindowReadyListener);
		
	},
	toCommonObject: function() {
		return {
			bikes: this.bikes,
			locks: this.locks
		};
	},
	toString: function() {
		return "RACK id: " + this.id + ", lat: " + this.latitude + ", long: " + this.longitude;
	},
	toHTML: function() {
		return [
			'<div class="rack">',
				//'<h2>' + this.name + '</h2>',
				'<img src="http://cbk0.google.com/cbk?output=thumbnail&w=240&h=160&ll=' + this.latitude + ',' + this.longitude + '" />',
				this.useStreetview ? '<div class="panorama"></div>' : '',
				'<p class="title data-description">' + this.description + '</p>',
				'<div class="res">',
					'<strong>Attributes: </strong>',
					'<span class="icon icon-bike"><span class="data data-bikes">' + this.bikes + '</span></span>',
					'<span class="icon icon-lock"><span class="data data-locks">' + this.locks + '</span></span>',
				'</div>',
			'</div>'
		].join('');
	}
});
