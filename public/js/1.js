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

    show: function(markerCollection)
    {
        // check if div exists
        //make sure div is showing
        // check that marker exists in map
        // show marker
    },

    hide: function(markerCollection)
    {
        //if div exists, hide it

        // if marker exists, hide it
    }
};

$(function(){

});