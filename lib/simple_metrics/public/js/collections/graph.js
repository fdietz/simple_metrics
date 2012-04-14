(function (collections, model) {

    collections.Graph = Backbone.Collection.extend({
      model: model,

      initialize: function(options) {
        this.targets = options.targets;
        this.time = options.time;
      },

      url: function() {
        return "/api/graph?targets[]="+this.targets+"&time="+this.time;
      }
    });

})( app.collections, app.models.Graph);