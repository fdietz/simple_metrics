(function (views, metrics){

  views.Instrument = Backbone.View.extend({
    template: Handlebars.compile($("#instrument-details").html()),

    events: {
      "click .btn.add-metric"                       : "addMetricDialog",
      "click .btn.save"                             : "save",
      "submit #modal-search-form"                   : "addMetric",
      "click #instrument-details-modal .btn-primary": "addMetric"
    },

    initialize: function(options) {
      this.model.bind('reset', this.render, this);
      this.model.bind('change', this.render, this);
    },

    render: function() {
      console.log("render", this.model);

      $(this.el).html(this.template({ instrument: this.model.toJSON() }));

      /*
      var minuteGraphCollection = new collections.Graph({
        targets: this.model.get('name'),
        time: 'minute'
      });

      minuteGraphCollection.fetch({
        success: function() {
          var minuteView = new views.Graph({
            series: minuteGraphCollection.toJSON(),
            time: "minute",
            el: this.$("#graph-container-minute")
          });
          minuteView.render();
        }
      });
      */

      return this;
    },

    addMetricDialog: function() {
      console.log("addMetricDialog");

      var items = _.map(metrics, function(metric) {
        return metric.name;
      });

      var input = this.$('#instrument-details-search-target');
      input.typeahead({ source: items, items: 5 });

      var myModal = this.$('#instrument-details-modal');

      myModal.on("shown", function() {
        input.focus();
      });

      myModal.modal({
        keyboard: true
      });

    },

    addMetric: function() {
      var myModal = this.$('#instrument-details-modal');
      var input = this.$('#instrument-details-search-target');

      var metricName = input.val();
      myModal.modal("hide");
      console.log("metricName", metricName);

      var tmp = this.model.get("metrics");
      console.log(tmp);
      tmp.push({ name: metricName });
      console.log(tmp);

      this.model.set({ metrics: tmp});

      // TODO: remove explicit rendering
      this.render();

      console.log(this.model);
      return false;
    },

    save: function() {
      console.log("save");

      this.model.save();
    }

  });

})(app.views, app.collections.metrics);