(function (app) {

  app.Router = Backbone.Router.extend({
    routes: {
      "":               "home",
      "metrics":        "metrics",
      "metrics/:name":    "metric_details",
      "dashboard":      "dashboard",
      "about":          "about"
    },

    home: function() {
      console.log("ROUTER: home");
      new app.views.App({ el: "#main", collection: app.collections.metrics }).render();
    },
    metrics: function() {
      console.log("ROUTER: metrics");
      new app.views.App({ el: "#main", collection: app.collections.metrics }).render();
    },
    metric_details: function(name) {
      console.log("ROUTER: metric details:", name);

      metric = new app.models.Metric({ name: name});
      metric.fetch({
        success: function(model, resp) {
          new app.views.Metric({ el: "#main", model: model }).render();
        },
        error: function() {
          alert("Document not found:"+id);
        }
      });
    },
    dashboard: function() {
      console.log("ROUTER: dashboard");
      new app.views.Dashboard({ el: "#main" }).render();
    },
    about: function() {
      console.log("ROUTER: about");
    }
  });

})(app);