$(function(){

  var Metric = Backbone.Model.extend({
    urlRoot: '/api/metrics'
  });

  var MetricList = Backbone.Collection.extend({
    model: Metric,
    url: '/api/metrics'
  });

  var DashboardView = Backbone.View.extend({
    render: function() {
      $(this.el).html("This is a dashboard view");
      return this;
    }
  });

  var Graph = Backbone.Model.extend({
  });

  var GraphCollection = Backbone.Collection.extend({
    model: Graph,

    initialize: function(options) {
      this.targets = options.targets;
      this.time = options.time;
    },

    url: function() {
      return "/api/graph?targets[]="+this.targets+"&time="+this.time;
    }
  });

  var GraphView = Backbone.View.extend({
    template: Handlebars.compile($("#graph").html()),

    initialize: function(options) {
      _.bindAll(this, "render");
      this.time = this.options.time;
      this.series = this.options.series;
    },

    render: function() {
      $(this.el).html(this.template({ time: this.time }));

      var pastel = [
        '#239928',
        '#6CCC70',
        '#DEFFA1',
        '#DEFFA1',
        '#DEFFA1',
        '#362F2B',
        '#BFD657',
        '#FF6131',
        '#FFFF9D',
        '#BEEB9F',
        '#79BD8F',
        '#00A388'
      ].reverse();

      var customPalette = new Rickshaw.Color.Palette( { scheme: pastel } );
      var spectrum14Palette = new Rickshaw.Color.Palette( { scheme: "spectrum14" } );

      function addColorToSeries(data, palette) {
        var result = [];
        $.each(data, function(k, v){
          v.color = palette.color();
          result.push(v);
        });
        return result;
      }

      graph = new Rickshaw.Graph({
        element: this.$('.graph').get(0),
        renderer: 'line',
        series: addColorToSeries(this.series, spectrum14Palette)
      });

      function timeUnit(time) {
        var timeFixture = new Rickshaw.Fixtures.Time();
        var minuteCustom = {
          name: 'minute',
          seconds: 60,
          formatter: function(d) { return d.getUTCHours()+':'+d.getUTCMinutes()+'h';}
        };
        var hourCustom = {
          name: 'hour',
          seconds: 60*15,
          formatter: function(d) { return d.getUTCHours()+':'+d.getUTCMinutes()+'h';}
        };
        var dayCustom = {
          name: 'day',
          seconds: 60*60*2,
          formatter: function(d) { return d.getUTCHours()+'h';}
        };
        var weekCustom = {
          name: 'week',
          seconds: 60*60*2*7*2,
          formatter: function(d) { return d.getUTCDate()+'. '+d.getUTCMonth()+'.';}
        };

        switch(time){
          case 'minute': return minuteCustom;
          case 'hour': return hourCustom;
          case 'day': return dayCustom;
          case 'week': return weekCustom;
        }
      }

      var x_axis = new Rickshaw.Graph.Axis.Time({
        graph: graph,
        timeUnit: timeUnit(this.minute)
      });

      var y_axis = new Rickshaw.Graph.Axis.Y({
        graph: graph,
        orientation: 'left',
        tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
        element: this.$('.y-axis').get(0)
      });

      graph.render();

      var hoverDetail = new Rickshaw.Graph.HoverDetail({
        graph: graph
      });

      return this;
    }
  });

  var MetricDetailView = Backbone.View.extend({
    template: Handlebars.compile($("#metric-details").html()),

    initialize: function() {
      _.bindAll(this, "render");
    },

    render: function() {
      $(this.el).html(this.template({ metric: this.model.toJSON() }));

      // TODO: make code more DRY
      var minuteGraphCollection = new GraphCollection({
        targets: this.model.get('name'),
        time: 'minute'
      });

      minuteGraphCollection.fetch({
        success: function() {
          var minuteView = new GraphView({
            series: minuteGraphCollection.toJSON(),
            time: "minute",
            el: this.$("#graph-container-minute")
          });
          minuteView.render();
        }
      });

      var hourGraphCollection = new GraphCollection({
        targets: this.model.get('name'),
        time: 'hour'
      });

      hourGraphCollection.fetch({
        success: function() {
          var hourView = new GraphView({
            series: hourGraphCollection.toJSON(),
            time: "hour",
            el: this.$("#graph-container-hour")
          });
          hourView.render();
        }
      });

      var dayGraphCollection = new GraphCollection({
        targets: this.model.get('name'),
        time: 'day'
      });

      dayGraphCollection.fetch({
        success: function() {
          var dayView = new GraphView({
            series: dayGraphCollection.toJSON(),
            time: "day",
            el: this.$("#graph-container-day")
          });
          dayView.render();
        }
      });

      var weekGraphCollection = new GraphCollection({
        targets: this.model.get('name'),
        time: 'week'
      });

      weekGraphCollection.fetch({
        success: function() {
          var weekView = new GraphView({
            series: weekGraphCollection.toJSON(),
            time: "week",
            el: this.$("#graph-container-week")
          });
          weekView.render();
        }
      });

      return this;
    }
  });

  var MetricListView = Backbone.View.extend({
    render: function() {
      $(this.el).html("This is a metrics list view");
      return this;
    }
  });

  var AppView = Backbone.View.extend({
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

  var metricList = new MetricList();
  metricList.fetch();

  var Router = Backbone.Router.extend({
    routes: {
      "":               "home",
      "metrics":        "metrics",
      "metrics/:name":    "metric_details",
      "dashboard":      "dashboard",
      "about":          "about"
    },

    home: function() {
      console.log("ROUTER: home");
      new AppView({ el: "#main", collection: metricList }).render();
    },
    metrics: function() {
      console.log("ROUTER: metrics");
      new AppView({ el: "#main", collection: metricList }).render();
    },
    metric_details: function(name) {
      console.log("ROUTER: metric details:", name);

      metric = new Metric({ name: name});
      metric.fetch({
        success: function(model, resp) {
          new MetricDetailView({ el: "#main", model:  model}).render();
        },
        error: function() {
          alert("Document not found:"+id);
        }
      });
    },
    dashboard: function() {
      console.log("ROUTER: dashboard");
      new DashboardView({ el: "#main" }).render();
    },
    about: function() {
      console.log("ROUTER: about");
    }
  });

  var router = new Router();
  Backbone.history.start({pushState: false});

});