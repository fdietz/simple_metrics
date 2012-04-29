(function (views, collections){

  var InstrumentTable = Backbone.View.extend({
    template: Handlebars.compile($("#instrument-details-table").html()),

    events: {},

    initialize: function(options) {
      this.model.bind('reset', this.render, this);
      this.model.bind('change', this.render, this);
    },

    render: function() {
      $(this.el).html(this.template({ instrument: this.model.toJSON() }));
      return this;
    }
  });

  var InstrumentSidebar = Backbone.View.extend({
    template: Handlebars.compile($("#instrument-details-sidebar").html()),

    events: {},

    initialize: function(options) {
      this.model.bind('reset', this.render, this);
      this.model.bind('change', this.render, this);
    },

    render: function() {
      $(this.el).html(this.template({ instrument: this.model.toJSON() }));
      return this;
    }
  });

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

    renderGraph: function(graphElement) {
      var time = "hour";

      var targets = _.map(this.model.get('metrics'), function(metric) {
        return metric.name;
      });

      var hourGraphCollection = new collections.Graph({
        targets: targets,
        time: time
      });

      hourGraphCollection.fetch({ success: function(collection, resopnse) {
        console.log("raw", hourGraphCollection, hourGraphCollection.models);

        graph = new views.Graph({ series: collection.toJSON(), time: time, el: graphElement });
        graph.render();
      }});
    },

    render: function() {
      $(this.el).html(this.template({ instrument: this.model.toJSON() }));

      table = new InstrumentTable({ model: this.model });
      table.render();
      this.$("#instrument-table-container").append(table.el);

      sidebar = new InstrumentSidebar( { model: this.model });
      sidebar.render();
      this.$("#instrument-sidebar-container").append(sidebar.el);

      this.renderGraph(this.$("#instrument-graph-container"));

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
      var items = _.map(collections.metrics, function(metric) {
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
      tmp.push({ name: metricName });
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

})(app.views, app.collections);