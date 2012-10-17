(function() {
  var BaseRenderer, CurrencyRenderer, WeatherRenderer,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  BaseRenderer = (function() {

    function BaseRenderer() {}

    BaseRenderer.prototype.initDatesAndChart = function() {
      this.chart = this.container.children('.js-chart');
      this.from = this.getDate(this.container, 'from');
      return this.to = this.getDate(this.container, 'to');
    };

    BaseRenderer.prototype.getDate = function(container, dateType) {
      return container.children('input[name=' + dateType + ']').datepicker('getDate');
    };

    BaseRenderer.prototype.nextDate = function(date) {
      return new Date(date.getTime() + 24 * 60 * 60 * 1000);
    };

    BaseRenderer.prototype.render = function() {
      var rangeData;
      this.showSpinner();
      rangeData = this.withPrediction(this.getDateRangeData());
      if (rangeData.error) {
        this.showError(rangeData.message);
      } else {
        this.chart.empty();
        this.showHighChart(rangeData);
      }
      return this.hideSpinner();
    };

    BaseRenderer.prototype.showHighChart = function(rangeData) {
      var data;
      return new Highcharts.Chart({
        chart: {
          type: 'spline',
          renderTo: this.chart[0],
          marginBottom: 40,
          marginTop: 70,
          marginRight: 30,
          marginLeft: 90
        },
        title: {
          text: this.chartTitle(),
          y: 30
        },
        xAxis: {
          categories: (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = rangeData.length; _i < _len; _i++) {
              data = rangeData[_i];
              _results.push(data.date);
            }
            return _results;
          })()
        },
        yAxis: {
          title: {
            text: this.chartSeriesName()
          }
        },
        series: [
          {
            name: this.chartSeriesName(),
            data: (function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = rangeData.length; _i < _len; _i++) {
                data = rangeData[_i];
                _results.push(data.value);
              }
              return _results;
            })()
          }
        ],
        legend: {
          enabled: false
        },
        plotOptions: {
          series: {
            color: 'yellow'
          }
        },
        tooltip: {
          backgroundColor: '#BDBDBD'
        }
      });
    };

    BaseRenderer.prototype.getDateRangeData = function() {
      var date, dayData, rangeData;
      rangeData = [];
      date = this.from;
      while (date <= this.to) {
        dayData = this.getDayData(date);
        if (dayData.error) {
          return dayData;
        } else {
          rangeData.push(dayData);
          date = this.nextDate(date);
        }
      }
      return rangeData;
    };

    BaseRenderer.prototype.getDayData = function(date) {
      var result,
        _this = this;
      result = null;
      $.ajax({
        url: this.apiUrl(date),
        async: false,
        dataType: 'json',
        success: function(response) {
          return result = _this.parseResponse(response);
        },
        error: function() {
          return result = {
            error: true,
            message: 'Failed to fetch data for ' + $.datepicker.formatDate('dd/mm/yy', date) + '.'
          };
        }
      });
      return $.extend(result, {
        date: $.datepicker.formatDate('dd/mm/yy', date)
      });
    };

    BaseRenderer.prototype.showError = function(error) {
      return this.chart.empty().append($('<div>', {
        "class": 'error',
        text: error
      }));
    };

    BaseRenderer.prototype.showSpinner = function() {
      this.spinner = new Spinner().spin(this.container[0]);
      return this.container.append($('<div>', {
        "class": 'overlay'
      }));
    };

    BaseRenderer.prototype.hideSpinner = function() {
      if (this.spinner) {
        this.spinner.stop();
        this.spinner = null;
      }
      return this.container.children('.overlay').remove();
    };

    BaseRenderer.prototype.withPrediction = function(rangeData) {
      return rangeData;
    };

    BaseRenderer.prototype.chartTitle = function() {
      throw 'not implemented';
    };

    BaseRenderer.prototype.chartYAxisTitle = function() {
      throw 'not implemented';
    };

    BaseRenderer.prototype.chartSeriesName = function() {
      throw 'not implemented';
    };

    BaseRenderer.prototype.parseResponse = function(response) {
      throw 'not implemented';
    };

    BaseRenderer.prototype.apiUrl = function(date) {
      throw 'not implemented';
    };

    return BaseRenderer;

  })();

  CurrencyRenderer = (function(_super) {

    __extends(CurrencyRenderer, _super);

    CurrencyRenderer.API_KEY = '902f65f28d5f4348a6974942a4775eb8';

    CurrencyRenderer.API_URL = 'http://openexchangerates.org/api/';

    function CurrencyRenderer(container, currency) {
      this.container = container;
      this.currency = currency;
      this.initDatesAndChart();
    }

    CurrencyRenderer.prototype.chartTitle = function() {
      return this.currency + '/USD exchange rate';
    };

    CurrencyRenderer.prototype.chartSeriesName = function() {
      return 'exchange rate';
    };

    CurrencyRenderer.prototype.parseResponse = function(response) {
      return $.extend(response, {
        value: response.rates[this.currency]
      });
    };

    CurrencyRenderer.prototype.apiUrl = function(date) {
      return CurrencyRenderer.API_URL + 'historical/' + $.datepicker.formatDate('yy-mm-dd', date) + '.json?app_id=' + CurrencyRenderer.API_KEY;
    };

    return CurrencyRenderer;

  })(BaseRenderer);

  WeatherRenderer = (function(_super) {

    __extends(WeatherRenderer, _super);

    WeatherRenderer.API_KEY = 'e06c59f816e8caae';

    WeatherRenderer.API_URL = 'http://api.wunderground.com/api/';

    function WeatherRenderer(container, city) {
      this.container = container;
      this.city = city;
      this.initDatesAndChart();
    }

    WeatherRenderer.prototype.chartTitle = function() {
      return this.city + ' weather';
    };

    WeatherRenderer.prototype.chartSeriesName = function() {
      return 'average temperature';
    };

    WeatherRenderer.prototype.parseResponse = function(response) {
      return $.extend(response, {
        value: response.history.dailysummary.meantempm
      });
    };

    WeatherRenderer.prototype.apiUrl = function(date) {
      return WeatherRenderer.API_URL + WeatherRenderer.API_KEY + '/history_' + $.datepicker.formatDate('yymmdd', date) + '/q/' + this.city + '.json';
    };

    return WeatherRenderer;

  })(BaseRenderer);

  $(function() {
    $('#currencies .js-show').click(function() {
      return new CurrencyRenderer($('#currencies'), 'GBP').render();
    });
    return $('#weather .js-show').click(function() {
      return new WeatherRenderer($('#weather'), 'FR/Paris').render();
    });
  });

}).call(this);
