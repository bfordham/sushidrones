var SushiDrones = {
  Models: {},
  Collections: {},
  Views: {},
  Templates:{},
};

$(function(){

    SushiDrones.Models.Strike = Backbone.Model.extend({
      idAttribute: '_id',

      headline: function() {
        return this.get('d') + " people killed in " + this.get('t');
      },

      marker: function()
      {
        if (!this._marker)
        {
            this._marker = new google.maps.Marker({'position': new google.maps.LatLng(this.get('lat'), this.get('lon'))});
        }
        return this._marker;

      },

      isActive: function()
      {
        return this._active;
      }
    });

    SushiDrones.Collections.Strikes = Backbone.Collection.extend({
        model: SushiDrones.Models.Strike,
        url: "/strikes.json",
        initialize: function(){
            console.log("Strikes initialize")
        }
    });

    //SushiDrones.Templates.strikes = _.template("<div id=\"strikes\"></div>");
    console.log('before');
    SushiDrones.Templates.strikes = _.template($('#strikes-template').html());
    console.log('after');

    SushiDrones.Views.Strikes = Backbone.View.extend({
        el: $("#content"),
        template: SushiDrones.Templates.strikes,
      
        initialize: function () {
            _.bindAll(this, "render", "addOne", "addAll");
            this.collection.bind("sync", this.render);
            this.collection.bind("add", this.addOne);
        },
      
        render: function () {
            console.log("render")
            console.log(this.collection.length);
            $(this.el).html(this.template());
            this.addAll();
        },
      
        addAll: function () {
            console.log("addAll")
            this.collection.each(this.addOne);
        },
      
        addOne: function (model) {
            console.log("addOne")
            view = new SushiDrones.Views.Strike({ model: model });
            $(this.el).append(view.render());
        }
      
    })

    SushiDrones.Templates.strike = _.template($('#strike-template').html());

    SushiDrones.Views.Strike = Backbone.View.extend({
        tagName: "li",
        template: SushiDrones.Templates.strike,
      
        initialize: function () {
            _.bindAll(this, 'render');
        },
      
        render: function () {
            //return this.template(this.model.toJSON());
             
            //Correction
            return $(this.el).append(this.template(this.model.toJSON())) ;
        }
    })

    SushiDrones.Router = Backbone.Router.extend({
        routes: {
            "": "defaultRoute"
        },
      
        defaultRoute: function () {
            console.log("defaultRoute");
            SushiDrones.strikes = new SushiDrones.Collections.Strikes();
            SushiDrones.view = new SushiDrones.Views.Strikes({ collection: SushiDrones.strikes });
            SushiDrones.strikes.fetch();
            console.log(SushiDrones.strikes.length)
        }
    })
     
    var appRouter = new SushiDrones.Router();
    Backbone.history.start();
});