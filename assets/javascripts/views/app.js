(function (views){

  views.App = Backbone.View.extend({

    template: Handlebars.compile($("#metric-list").html()),

    initialize: function(options) {
      _.bindAll(this, "render");
      this.collection.bind('reset', this.render);
    },
    
    render: function() {
      $(this.el).html(this.template({ metrics: this.collection.toJSON() }));
      return this;
    }
  });

})(app.views);