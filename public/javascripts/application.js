// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function log() {
	if (window.app && window.app.debug && window.console && window.console.log) {
		try {
			console.log.apply(this, arguments);
		} catch (e) {}
	}
}

document.observe("dom:loaded", function() {
	window.app = new BikeSike("BOTH");
});

var BikeSike = Class.create({
	debug: true,
	config: {
		defaultZoom: 13,
		defaultCenter: new google.maps.LatLng(59.91130774, 10.75086325),
		maxDistance: 10000
	},
	initialize: function(mode) {
		this.mode = mode; // BOTH, BIKES, LOCKS
		
		this.initMap();
		
		this.rackProvider = new RackProvider(this.map, function() {
			return this.mode;
		}.bind(this));
		
		this.initRacks();
	},
	initMap: function () {
		var myOptions = {
			center: this.config.defaultCenter,
			zoom: this.config.defaultZoom,
			scaleControl: true,
			navigationControl: true,
			mapTypeControl: false,
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		this.map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

		var map = this.map;
		
		this.updatePositionUsingGeolocation();

		this.initBoundsChangedHandler();
		
		this.initZoomEvents();
		
		this.addModeControls();
		
		this.addLocationControl();
	},
	addLocationControl: function() {
		if (navigator.geolocation) {
			var locate = $("locate");
			locate.observe("click", function(event) {
				event.stop();
				this.updatePositionUsingGeolocation();
			}.bindAsEventListener(this));
			this.map.controls[google.maps.ControlPosition.RIGHT_BOTTOM].push(locate);
		}
	},
	addModeControls: function() {
		var controlDiv = $("modeControls");
		var controls = controlDiv.select(".control");
		controls.invoke("observe", "click", function(event) {
			event.stop();
			var target = $(event.target);
			if (target.hasClassName("active") || target.hasClassName("disabled")) {
				return;
			}
			var mode = target.getAttribute("data-mode");
			this.setMode(mode);
			controls.invoke("removeClassName", "active");
			target.addClassName("active");
		}.bindAsEventListener(this));
		this.map.controls[google.maps.ControlPosition.RIGHT_TOP].push(controlDiv);
	},
	initZoomEvents: function() {
		google.maps.event.addListener(this.map, 'zoom_changed', function() {
			var zoom = this.map.getZoom();
			$$(".zoomed"  ).invoke(zoom < 14 ? "addClassName" : "removeClassName", "disabled");
			$$(".unzoomed").invoke(zoom < 14 ? "removeClassName" : "addClassName", "disabled");
			if (zoom < 14) {
				this.setMode("BOTH");
			}
		}.bindAsEventListener(this));
	},
	initBoundsChangedHandler: function() {
		var mapChangedTimer;
		google.maps.event.addListener(this.map, 'bounds_changed', function(e) {
			clearTimeout(mapChangedTimer);
			mapChangedTimer = setTimeout(this.mapBoundsChanged.bind(this), 50);
		}.bindAsEventListener(this));
	},
	mapBoundsChanged: function() {
		if (this.mode !== "BOTH") {
			var bounds = this.map.getBounds(),
				ne = bounds.getNorthEast(),
				sw = bounds.getSouthWest(),
				coords = $H({"sw": sw.lat() + "," + sw.lng(), "ne": ne.lat() + "," + ne.lng()}).toQueryString();
			//log("Diagonal distance at zoom level ", this.map.getZoom(), ": ", google.maps.geometry.spherical.computeDistanceBetween(sw, ne));
			new Ajax.Request('/bysykkel/getallfromlocation?' + coords, {
				method: 'get',
				onSuccess: this.addOrUpdateRacksFromAjax.bind(this)
			});
		}
	},
	initRacks: function() {
		this.racks = $A();
		new Ajax.Request('/bysykkel/getmany', {
			method:'get',
			onSuccess: this.addOrUpdateRacksFromAjax.bind(this)
		});
	},
	addOrUpdateRacksFromAjax: function(transport) {
		var json = transport.responseText.evalJSON();
		$A(json).each(function(obj) {
			var rack = this.racks.filter(function(rack) {
				return rack.id === obj.id;
			}).first();
			if (rack) {
				rack.updateDataFromAjax(obj);
			}
			else {
				rack = new Rack(obj, {
					provider: this.rackProvider
				});
				rack.on("infoWindowOpen", this.onInfoWindowOpen.bind(this));
				this.racks.push(rack);
			}
		}.bind(this));
	},
	onInfoWindowOpen: function() {
		this.racks.invoke("closeInfoWindow");
	},
	updatePositionUsingGeolocation: function() {
		// Try W3C Geolocation (Preferred)
		if (navigator.geolocation) {
			navigator.geolocation.getCurrentPosition(function(position) {
				this.setCenter(position.coords.latitude, position.coords.longitude, position.coords.accuracy);
			}.bind(this), function() {
				this.setCenter();
			}.bind(this));
		// Browser doesn't support Geolocation
		} else {
			this.setCenter();
		}
	},	
	setMode: function(mode) {
		if (/BOTH|LOCKS|BIKES/.test(mode)) {
			this.mode = mode;
			this.racks.invoke("update");
		}
	},
	setCenter: function(latitude, longitude, accuracy) {
		var gLocation = (latitude && longitude) ? new google.maps.LatLng(latitude, longitude) : this.config.defaultCenter;
		if (google.maps.geometry.spherical.computeDistanceBetween(gLocation, this.config.defaultCenter) < this.config.maxDistance) {
			// var diff = accuracy / (2*Math.PI*6378137) * 360;
			this.map.setCenter(gLocation);
			if (accuracy) {
				var zoom = 12;
				if (accuracy < 1000) {
					zoom = 13;
				}
				if (accuracy < 500) {
					zoom = 14;
				}
				this.map.setZoom(zoom);
			}
			if (navigator.geolocation && accuracy) {
				if (this.currentLocationMarker) {
					this.currentLocationMarker.setPosition(gLocation);
				}
				else {
					this.currentLocationMarker = new google.maps.Marker({
						map: this.map,
						visible: true,
						icon: "http://chart.apis.google.com/chart?cht=it&chs=12x12&chco=0e5eff,000000ff,ffffff01&chl=&chx=000000,0&chf=bg,s,00000000&ext=.png",
						position: gLocation
					});
				}
			}
		}
	}
});

var RackProvider = Class.create({
	initialize: function(map, getMode) {
		this.map = map;
		this.mode = getMode;
	},
	getRackData: function(id, callback) {
		new Ajax.Request('/bysykkel/getjson/' + id + '.json', {
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

var Rack = Class.create({
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
	
		// events hash
		this.events = {};
		
		if (!this.initMarker()) {
			this.provider.getRackData(this.id, this.updateDataFromAjax.bindAsEventListener(this));
		}
		
		// disable street view
		this.useStreetview = false;
	},
	initMarker: function() {
		if (!this.marker && this.latitude && this.longitude) {
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
		this.trigger("infoWindowOpen");
		this.infoWindow.open(app.map, this.marker);
	},
	closeInfoWindow: function() {
		if (this.infoWindow) {
			this.infoWindow.close();
		}
	},
	infoWindowReadyHandler: function(e) {
		if (this.useStreetview) {
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
	},
	on: function(event, callback) {
		if (!this.events[event]) {
			this.events[event] = $A();
		}
		this.events[event].push(callback);
	},
	trigger: function(event) {
		if (this.events[event]) {
			this.events[event].each(function(callback) {
				callback();
			});
		}
	}
});
