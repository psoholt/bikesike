// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
/*
 * The Bysykkel javascript application
 * Displaying status of all bysykkel racks in Oslo, Norway
 *
 * @author	Anders Karlsson, andersk2@gmail.com
 */


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
		defaultZoomLevel: 13,
		autoUpdateZoomLevel: 15,
		defaultCenter: new google.maps.LatLng(59.91130774, 10.75086325),
		maxDistance: 10000,
		pinNoResourcesColor: "ece5db",
		pinBikesColor: "25359c",
		pinLocksColor: "c72222",
		pinBothColor: "cccccc"
	},
	initialize: function(mode) {
		this.mode = mode; // BOTH, BIKES, LOCKS
		
		this.initMap();
		
		this.rackProvider = new RackProvider(this.config, this.map, function() {
			return this.mode;
		}.bind(this));
		
		this.initRacks();
	},
	initMap: function () {
		var myOptions = {
			center: this.config.defaultCenter,
			zoom: this.config.defaultZoomLevel,
			scaleControl: true,
			navigationControl: true,
			mapTypeControl: false,
			streetViewControl: false,
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
			this.map.controls[google.maps.ControlPosition.LEFT_TOP].push(locate);
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
		}.bindAsEventListener(this));
		this.map.controls[google.maps.ControlPosition.RIGHT_TOP].push(controlDiv);
	},
	initZoomEvents: function() {
		
		google.maps.event.addListener(this.map, 'zoom_changed', function() {
			var zoom = this.map.getZoom();
			$$(".zoomed"  ).invoke(zoom < this.config.autoUpdateZoomLevel ? "addClassName" : "removeClassName", "disabled");
			$$(".unzoomed").invoke(zoom < this.config.autoUpdateZoomLevel ? "removeClassName" : "addClassName", "disabled");
			if (zoom < this.config.autoUpdateZoomLevel) {
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
		// only keep markers on map visible
		this.racks.invoke("update");
		
		function coordRound(number) {
			var factor = 10000; // 10 meter accuracy
			return Math.round( factor * number ) / factor;
		}
		
		// in modes when displaying numbered markers make sure to keep them updated when on map
		if (this.mode !== "BOTH") {
			var bounds = this.map.getBounds(),
				ne = bounds.getNorthEast(),
				sw = bounds.getSouthWest(),
				coords = $H({
					"swlat": coordRound(sw.lat()),
					"swlng": coordRound(sw.lng()), 
					"nelat": coordRound(ne.lat()),
					"nelng": coordRound(ne.lng())
				});
			if (this.mapBoundsRequest && 
				this.mapBoundsRequest.transport && 
				typeof this.mapBoundsRequest.transport.abort === "function") {
				this.mapBoundsRequest.transport.abort();
			}
			setTimeout(function() {
				
			this.mapBoundsRequest = new Ajax.Request('/bysykkel/allwithinarea', {
				method: 'get',
				parameters: coords,
				onSuccess: this.addOrUpdateRacksFromAjax.bind(this)
			});
			}.bind(this), 5000);
		}
	},
	initRacks: function() {
		this.racks = $A();
		new Ajax.Request('/bysykkel/all', {
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
			if (mode !== "BOTH") {
				this.mapBoundsChanged();
			}
			else {
				this.racks.invoke("update");
			}
			var controls = $$("#modeControls .control");
			controls.invoke("removeClassName", "active");
			controls.each(function(control) {
				if (control.getAttribute("data-mode") === mode) {
					control.addClassName("active");
				}
			});
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
	initialize: function(config, map, getMode) {
		this.config = config;
		this.map    = map;
		this.mode   = getMode;
		
		this.GOOGLECHARTS = 
		
		this.updateMapBounds();
		google.maps.event.addListener(this.map, 'bounds_changed', this.updateMapBounds.bind(this));
	},
	updateMapBounds: function() {
		var bounds = this.map.getBounds();
		if (bounds) {
			bounds.ne     = bounds.getNorthEast();
			bounds.sw     = bounds.getSouthWest();
			bounds.ne.lat = bounds.ne.lat();
			bounds.ne.lng = bounds.ne.lng();
			bounds.sw.lat = bounds.sw.lat();
			bounds.sw.lng = bounds.sw.lng();
		}	
		this.mapBounds = bounds;
	},
	getRackData: function(id, callback) {
		new Ajax.Request('/bysykkel/station/' + id + '.json', {
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
	getMarkerIcon: function(providerData, rack) {
		// http://gmaps-utility-library.googlecode.com/svn/trunk/mapiconmaker/1.1/examples/markericonoptions-wizard.html
		// https://chart.googleapis.com/chart?chst=d_map_pin_icon_withshadow&chld=bicycle|cccccc|ffffff
		// http://chart.apis.google.com/chart?cht=it&chs=32x32&chco=cccccc,000000ff,ffffff01&chl=a&chx=000000,0&chf=bg,s,00000000&ext=.png
		var url,
			mode = this.mode(),
			chartType = "d_map_pin_letter",
			chartLetter = "",
			chartBgColor,
			chartFgColor = "ffffff";
		
		if (mode === "BOTH") {
			chartType = "d_map_pin_icon";
			chartLetter = "bicycle";
			chartBgColor = this.config.pinBothColor;
		}
		else if (mode === "BIKES" || mode === "LOCKS") {
			var chartLetter = providerData[mode === "BIKES" ? "bikes" : "locks"];
			if (chartLetter === 0) {
				chartLetter = "x";
				chartFgColor = "000000";
				chartBgColor = this.config.pinNoResourcesColor;
			}
			else {
				chartBgColor = this.config[mode === "BIKES" ? "pinBikesColor" : "pinLocksColor"];
			}
		}
		url = "https://chart.googleapis.com/chart?chst=" + chartType + "&chld=" + chartLetter + "|" + chartBgColor + "|" + chartFgColor;
		return url;
	},
	getMarkerVisibility: function(providerData) {
		return this.isWithinMapBounds(providerData);
	},
	isWithinMapBounds: function(providerData) {
		var b  = this.mapBounds;
		if (!b) {
			return false;
		}
		var sw = b.sw,
			ne = b.ne,
			lng = providerData.longitude,
			lat = providerData.latitude;
		return b &&
			sw.lat <= lat    &&
			   lat <= ne.lat &&
			sw.lng <= lng    &&
			   lng <= ne.lng;
	},
	getMap: function() {
		return this.map;
	}
});

var Rack = Class.create({
	initialize: function(obj, options) {
		// properties
		this.id          = obj.id;
		this.latitude    = null;
		this.longitude   = null;
		this.description = null;
		this.bikes       = 0;
		this.locks       = 0;

		// map objects
		this.infoWindow = null;
		this.marker     = null;

		// resources
		this.provider = options.provider;
	
		// events hash
		this.events = {};
		
		this.updateDataFromAjax(obj);
		
		if (!this.marker) {
			this.requestData();
		}
	},
	initMarker: function() {
		if (!this.marker && this.latitude && this.longitude) {
			var markerIcon = this.provider.getMarkerIcon(this.toCommonObject());
			this.marker = this.provider.getMarker({
				position: new google.maps.LatLng(this.latitude, this.longitude),
				icon: markerIcon,
				visible: true
			});
			this.marker.visible = true;
			this.marker.icon    = markerIcon;
			
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
			var commonObject = this.toCommonObject(),
				visibility   = this.provider.getMarkerVisibility(commonObject) || !!this.infoWindowOpen,
				icon;
			if (visibility) {
				icon         = this.provider.getMarkerIcon(commonObject);
			}
			visibility === this.marker.visible       || this.marker.setVisible( this.marker.visible = visibility );
			!visibility || icon === this.marker.icon || this.marker.setIcon( this.marker.icon = icon );
		}
	},
	showLoading: function() {
		if (this.infoWindow) {
			$(this.infoWindow.getContent()).addClassName("loading");
		}
	},
	hideLoading: function() {
		if (this.infoWindow) {
			$(this.infoWindow.getContent()).removeClassName("loading");
		}
	},
	requestData: function() {
		this.provider.getRackData(this.id, this.updateDataFromAjax.bindAsEventListener(this));
		this.showLoading();
	},
	updateDataFromAjax: function(jsonData) {
		this.hideLoading();
		this.updateProperty("bikes", jsonData.ready_bikes);
		this.updateProperty("locks", jsonData.empty_locks);
		this.description || this.updateProperty("description", jsonData.description.replace(/^[\d\-]*/, ""));
		this.longitude   || this.updateProperty("longitude",   jsonData.longitude);
		this.latitude    || this.updateProperty("latitude",    jsonData.latitude);
	},
	updateProperty: function(property, value) {
		if (this[property] !== value) {
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
			this.updateMarker();
		}
	},
	markerClickHandler: function() {
		if (!this.infoWindow) {
			var element = new Element("div");
			element.insert(this.toHTML());
			this.infoWindowContent = element.firstDescendant();
			this.infoWindow = new google.maps.InfoWindow({
				content: this.infoWindowContent
			});
		}
		this.trigger("infoWindowOpen");
		this.infoWindow.open(this.provider.getMap(), this.marker);
		this.infoWindowOpen = true;
		this.requestData();
	},
	closeInfoWindow: function() {
		if (this.infoWindow) {
			this.infoWindow.close();
			this.infoWindowOpen = false;
		}
	},
	toCommonObject: function() {
		return {
			bikes:     this.bikes,
			locks:     this.locks,
			longitude: this.longitude,
			latitude:  this.latitude
		};
	},
	toString: function() {
		return "RACK id: " + this.id + ", lat: " + this.latitude + ", long: " + this.longitude;
	},
	toHTML: function() {
		var slots = (this.bikes + this.locks) / 100;
		return [
			'<div class="rack">',
				//'<h2>' + this.name + '</h2>',
				'<img src="http://cbk0.google.com/cbk?output=thumbnail&w=240&h=160&ll=' + this.latitude + ',' + this.longitude + '" />',
				this.useStreetview ? '<div class="panorama"></div>' : '',
				'<p class="title data-description">' + this.description + '</p>',
				'<ul class="res">',
					'<li>',
						'<span class="icon icon-bike">',
							'<span class="data data-bikes">' + this.bikes + '</span>',
						'</span>',
					'</li>',
					'<li>',
						'<span class="icon icon-lock">',
							'<span class="data data-locks">' + this.locks + '</span>',
						'</span>',
					'</li>',
				'</ul>',
				'<div class="load"></div>',
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
