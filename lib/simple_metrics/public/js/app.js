(function(){

  window.app = {};
  app.collections = {};
  app.models = {};
  app.views = {};
  app.mixins = {};

  $(function(){
    app.collections.metrics = new app.collections.Metric();
    app.collections.metrics.fetch();

    app.views.app = new app.views.App({ collection: app.collections.metrics });
    
    app.router = new app.Router();

    Backbone.history.start({pushState: false});
  });

})();