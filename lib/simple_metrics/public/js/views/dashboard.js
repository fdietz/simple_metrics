( function ( views ){

  views.Dashboard = Backbone.View.extend({
    render: function() {
      $(this.el).html("This is a dashboard view");
      return this;
    }
  });

})( app.views );