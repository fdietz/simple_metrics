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

  var GraphView = Backbone.View.extend({
    template: Handlebars.compile($("#graph").html()),

    initialize: function() {
      _.bindAll(this, "render");
      this.time = this.options.time;
      this.series = this.options.series;
    },

    render: function() {
      $(this.el).html(this.template({ time: this.time }));

      console.log(this.$('.graph'));
      console.log(this.series);      

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
      };

      graph = new Rickshaw.Graph( {
        element: this.$('.graph'),
        renderer: 'line',
        series: addColorToSeries(this.series, spectrum14Palette)
      } );

      // function timeUnit(time) {
      //   var timeFixture = new Rickshaw.Fixtures.Time();
      //   var minuteCustom = {
      //     name: 'minute',
      //     seconds: 60,
      //     formatter: function(d) { return d.getUTCHours()+':'+d.getUTCMinutes()+'h'}
      //   };
      //   var hourCustom = {
      //     name: 'hour',
      //     seconds: 60*15,
      //     formatter: function(d) { return d.getUTCHours()+':'+d.getUTCMinutes()+'h'}
      //   };
      //   var dayCustom = {
      //     name: 'day',
      //     seconds: 60*60*2,
      //     formatter: function(d) { return d.getUTCHours()+'h'}
      //   };
      //   var weekCustom = {
      //     name: 'week',
      //     seconds: 60*60*2*7*2,
      //     formatter: function(d) { return d.getUTCDate()+'. '+d.getUTCMonth()+'.'}
      //     };

      //   switch(time){
      //     case 'minute': return minuteCustom; break;
      //     case 'hour': return hourCustom; break;
      //     case 'day': return dayCustom; break;
      //     case 'week': return weekCustom; break;
      //   };
      // };

      // var x_axis = new Rickshaw.Graph.Axis.Time( { 
      //   graph: graph,
      //   timeUnit: timeUnit(this.minute)
      // } );

      // var y_axis = new Rickshaw.Graph.Axis.Y( {
      //   graph: graph,
      //   orientation: 'left',
      //   tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
      //   element: document.getElementById('y-axis-'+this.minute),
      // } );

      graph.render();

      // var hoverDetail = new Rickshaw.Graph.HoverDetail( {
      //   graph: graph
      // } );

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

      // TODO: refactor this
      // var minuteContainer = this.$("#graph-container-minute");
      // $.getJSON('/api/graph?targets[]='+this.model.get('name')+'&time=minute', function(series) {
      //   var minuteView = new GraphView({
      //     series: series,
      //     time: "minute"
      //   });
      //   minuteContainer.append(minuteView.render().el);
      // });

      var hourContainer = this.$("#graph-container-hour");
      $.getJSON('/api/graph?targets[]='+this.model.get('name')+'&time=hour', function(series) {
        var hourView = new GraphView({
          series: series,
          time: "hour",
          el: hourContainer
        });
        hourView.render();
        //hourContainer.html(hourView.render().el);
      });

      // var dayContainer = this.$("#graph-container-day");
      // $.getJSON('/api/graph?targets[]='+this.model.get('name')+'&time=day', function(series) {
      //   var dayView = new GraphView({
      //     series: series,
      //     time: "day"
      //   });
      //   dayContainer.append(dayView.render().el);
      // });

      // var weekContainer = this.$("#graph-container-week");
      // $.getJSON('/api/graph?targets[]='+this.model.get('name')+'&time=week', function(series) {
      //   var weekView = new GraphView({
      //     series: series,
      //     time: "week"
      //   });
      //   weekContainer.append(weekView.render().el);
      // });

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
      "metrics/:id":    "metric_details",
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
    metric_details: function(id) {
      console.log("ROUTER: metric details:", id);

      metric = new Metric({ id: id});
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