function is_blank(obj)
{
  return obj == null || obj == '';

}

function Strike(attributes)
{
  attributes = attributes ? attributes : {};
  this.attributes = attributes;
  this.visible = true;
}

Strike.prototype = {
  get: function(key)
  {
    return this.attributes[key];
  },

  set: function(key, value)
  {
    this.attributes[key] = value;
  },

  visibleOnMap: function()
  {
    return true;
  },

  marker: function()
  {
    if (!this._marker)
    {
      this._marker = new google.maps.Marker({'position': new google.maps.LatLng(this.get('lat'), this.get('lon'))});
    }
    return this._marker;
  },

  show: function()
  {
    $(this.divID()).show();
    this.visible = true;
  },

  hide: function()
  {
    $(this.divID()).hide();
    this.visible = false;
  },

  divID: function()
  {
    return "#strike-" + this.get('n');
  },

  filter: function(options)
  {
    options = options || null;
    var matched = false;
    if (options == null)
    {
      matched = true;
    }
    else
    {
      for (var p in options)
      {
        matched = this.get(p) == options[p];
        if (!matched)
          break;
      }
    }

    if (matched)
    {
      this.show();
    }
    else
    {
      this.hide();
    }
    return matched;
  }
};

function StrikeCollection(options)
{
  options = options ? options : {};
  this.mapDiv = options.mapDiv ? options.mapDiv : 'mapdiv';
  this.strikesURL = options.strikesURL ? options.strikesURL : '/strikes.json';
  this.strikes = null;
  this._filter = null;

  if (this.mapDiv)
  {

    var elem = document.getElementById(this.mapDiv);
    if (elem)
    {
      this.map = new google.maps.Map(elem, {
        zoomControlOptions: {position: google.maps.ControlPosition.TOP_RIGHT, style: google.maps.ZoomControlStyle.SMALL},
        panControl: false,
        streetViewControl: false
      });
    }
  }
  var foo = this;

  $(document).bind('sushiDronesFiltered', function(e) {foo.setHeading(e);});

  // google.maps.event.addListener(this.map, 'dragend', function() { foo.onMove(); });
  // google.maps.event.addListener(this.map, 'zoom_changed', function() { foo.onMove(); });

  this.fetch();
};


StrikeCollection.prototype = {
  fetch: function()
  {
    var foo = this;
    $.getJSON(this.strikesURL, function(data){foo._load(data)});
  },

  _load: function(data)
  {
    var foo = this;
    this.strikes = [];
    this.markers = [];

    this.template('strike');

    if (!this.strikeView)
    {
      this.strikeView = $('#strikes > .scrolling');
    }
    this.strikeView.html('');

    $(data).each(function(i,s){ foo._eachStrike(i,s); });

    if (this.map)
    {
      this.markerCluster = new MarkerClusterer(this.map, this.markers);
      this.zoomAll();
    }

    $('a.filter').click(function(e){ foo.filterClick(e); return false; });

    this.raiseRendered();
  },

  _eachStrike: function(i,s)
  {
    var strike = new Strike(s)
    this.strikes.push(strike);

    if (this.map != undefined && this.map != null)
    {
      this.markers.push(strike.marker());
    }
    var t = this.template('strike');
    this.strikeView.append(t(s));

  },

  template: function(name)
  {
    if (!this._templates)
    {
      this._templates = {};
    }

    if (!this._templates[name])
    {
      this._templates[name] = _.template($('#' + name + '-template').html().trim());
    }
    return this._templates[name];
  },

  filter: function()
  {
    var foo = this;

    this.markerCluster.clearMarkers();
    $(this.strikes).each(
      function(i,x)
      {
        x.filter(foo._filter);
      }
    );
    this.markerCluster.addMarkers(this.getVisibleMarkers());

    this.raiseRendered(this._filter);
  },

  filterClick: function(e)
  {
    e.preventDefault();
    this._filter = {};

    var l = $(e.currentTarget);
    loc = l.data('location');
    if (loc)
    {
      var tmp = loc.split(',');
      if (tmp[0])
      {
        this._filter.c = tmp[0];
      }
      if (tmp[1])
      {
        this._filter.l = tmp[1];
      }
      if (tmp[2])
      {
        this._filter.t = tmp[2];
      }
    }
    this.filter();
    this.onMove();
  },

  getVisibleMarkers: function()
  {
    var v = this.strikes.filter(function(s){return s.visible});
    var all = [];
    $(v).each(function(i,x){ all.push(x.marker());})
    return all;
  },

  getMarkerCount: function()
  {
    return this.markerCluster.getTotalMarkers();
  },

  zoomAll: function()
  {
    if (this.strikes.length == 1)
    {
      this.map.setCenter(this.markers[0].getPosition());
      this.map.setZoom(8);
    }
    else
    {
      this.markerCluster.fitMapToMarkers();
    }

    this.buildUrl(true);
  },

  showAll: function()
  {
    this._filter = null;
    this.filter();
    this.buildUrl();
  },

  setHeading: function(e)
  {
    var elem = $('#strikes > h1');

    if (e.options)
    {
      elem.html('Filtered ');
    }
    else
    {
      elem.html('Strikes: ');
    }
    elem.append(this.getMarkerCount() + " of " + this.strikes.length);
  },

  raiseRendered: function(options)
  {
    $.event.trigger('sushiDronesFiltered', {options: options});
  },

  getState: function()
  {
    return {lat: this.map.getCenter().lat(), lng: this.map.getCenter().lng(), zoom: this.map.getZoom(), filter: this._filter};
  },

  setState: function(data)
  {
    if (data != null)
    {
      this.map.setCenter(new google.maps.LatLng(data.lat, data.lng));
      this.map.setZoom(data.zoom);
      if (this._filter != data.filter)
      {
        this._filter = data.filter;
        this.filter();
      }
    }
    else
    {
      this.showAll();
      this.zoomAll();
    }

  },

  buildUrl: function(skipCoords)
  {
    var url = '/';

    if (this._filter != null && !is_blank(this._filter.c))
    {
      url = url + this._filter.c;

      if (!is_blank(this._filter.l))
      {
        url = url + "/" + this._filter.l;

        if (!is_blank(this._filter.t))
        {
          url = url + "/" + this._filter.t;
        }
      }
    }

    if (!skipCoords)
    {
      url = url + "?c=" + this.map.getCenter().lat() + "," + this.map.getCenter().lng() +
        "&z=" + this.map.getZoom();
    }

    return url.toLowerCase().split(' ').join('+');
  },

  onMove: function()
  {
    window.history.pushState(this.getState(), "", this.buildUrl());
  },

  onpopstate: function(event)
  {
    this.setState(event.state);
  }
};

var SC;

$(function(){
  SC = new StrikeCollection();
  $('a.zoomAll').click(function(e){e.preventDefault(); SC.zoomAll()});
  $('a.showAll').click(function(e){e.preventDefault(); SC.showAll()});
  $('a.collapse').click(function(e){e.preventDefault(); $('#strikes').addClass('collapsed')});
  $('a.expand').click(function(e){e.preventDefault(); $('#strikes').removeClass('collapsed')});

  $(window).bind('popstate',  
    function(event) {
        SC.onpopstate(event.originalEvent);
    });
});
