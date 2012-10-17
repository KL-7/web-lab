class BaseRenderer

  initDatesAndChart: ->
    @chart = @container.children('.js-chart')
    @from = @getDate(@container, 'from')
    @to = @getDate(@container, 'to')

  getDate: (container, dateType) ->
    container.children('input[name=' + dateType + ']').datepicker('getDate')

  nextDate: (date) ->
    new Date(date.getTime() + 24 * 60 * 60 * 1000)

  render: ->
    @showSpinner()

    rangeData = @withPrediction(@getDateRangeData())

    if rangeData.error
      @showError(rangeData.message)
    else
      @chart.empty()
      @showHighChart(rangeData)

    @hideSpinner()

  showHighChart: (rangeData) ->
    new Highcharts.Chart
      chart:
        type: 'spline'
        renderTo: @chart[0]
        marginBottom: 40
        marginTop: 70
        marginRight: 30
        marginLeft: 90
      title:
        text: @chartTitle()
        y: 30
      xAxis:
        categories: (data.date for data in rangeData)
      yAxis:
        title:
          text: @chartSeriesName()
      series: [
        name: @chartSeriesName()
        data: (data.value for data in rangeData)
      ]
      legend:
        enabled: false
      plotOptions:
        series:
          color: 'yellow'
      tooltip:
        backgroundColor: '#BDBDBD'

  getDateRangeData: ->
    rangeData = []
    date = @from

    while date <= @to
      dayData = @getDayData(date)

      if dayData.error
        return dayData
      else
        rangeData.push(dayData)
        date = @nextDate(date)

    rangeData

  getDayData: (date) ->
    result = null

    $.ajax
      url: @apiUrl(date)
      async: false
      dataType: 'json'
      success: (response) => result = @parseResponse(response)
      error: -> result =
        error: true
        message: 'Failed to fetch data for ' + $.datepicker.formatDate('dd/mm/yy', date) + '.'

    $.extend(result, date: $.datepicker.formatDate('dd/mm/yy', date))

  showError: (error) ->
    @chart.empty().append($('<div>', class: 'error', text: error))

  showSpinner: ->
    @spinner = new Spinner().spin(@container[0])
    @container.append($('<div>', class: 'overlay'))

  hideSpinner: ->
    if @spinner
      @spinner.stop()
      @spinner = null

    @container.children('.overlay').remove()

  withPrediction: (rangeData) ->
    # TODO: implement prediction for two days
    rangeData

  chartTitle: ->
    throw 'not implemented'

  chartYAxisTitle: ->
    throw 'not implemented'

  chartSeriesName: ->
    throw 'not implemented'

  parseResponse: (response) ->
    throw 'not implemented'

  apiUrl: (date) ->
    throw 'not implemented'


class CurrencyRenderer extends BaseRenderer

  @API_KEY = '902f65f28d5f4348a6974942a4775eb8'
  @API_URL = 'http://openexchangerates.org/api/'

  constructor: (@container, @currency) ->
    @initDatesAndChart()

  chartTitle: ->
    @currency + '/USD exchange rate'

  chartSeriesName: ->
    'exchange rate'

  parseResponse: (response) ->
    $.extend(response, value: response.rates[@currency])

  apiUrl: (date) ->
    CurrencyRenderer.API_URL + 'historical/' + $.datepicker.formatDate('yy-mm-dd', date) + '.json?app_id=' + CurrencyRenderer.API_KEY


class WeatherRenderer extends BaseRenderer

  @API_KEY = 'e06c59f816e8caae'
  @API_URL = 'http://api.wunderground.com/api/'

  constructor: (@container, @city) ->
    @initDatesAndChart()

  chartTitle: ->
    @city + ' weather'

  chartSeriesName: ->
    'average temperature'

  parseResponse: (response) ->
    $.extend(response, value: response.history.dailysummary.meantempm)

  apiUrl: (date) ->
    WeatherRenderer.API_URL + WeatherRenderer.API_KEY + '/history_' + $.datepicker.formatDate('yymmdd', date) + '/q/' + @city + '.json'


$ ->
  $('#currencies .js-show').click -> new CurrencyRenderer($('#currencies'), 'GBP').render()
  $('#weather .js-show').click -> new WeatherRenderer($('#weather'), 'FR/Paris').render()