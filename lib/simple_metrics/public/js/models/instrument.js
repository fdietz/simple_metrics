(function (models) {

  models.Instrument = Backbone.Model.extend({
    urlRoot: '/api/instruments'
  });

})(app.models);