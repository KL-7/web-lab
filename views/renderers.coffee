class BaseRenderer

  @PREDICTION_COEFFICIENT = 0.4
  @PREDICTION_COEFFICIENT_STEP = 0.1
  @PREDICTION_ELEMENTS = 5

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

    rangeData = @getDateRangeData()

    console.log(rangeData)

    if rangeData.error
      @showError(rangeData.message)
    else
      @chart.empty()
      @showHighChart(@withPrediction(rangeData))

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
        categories: ($.datepicker.formatDate('dd/mm/yy', data.date) for data in rangeData)
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
      success: (response) => result = response
      error: -> result =
        error: true
        message: 'Failed to fetch data for ' + $.datepicker.formatDate('dd/mm/yy', date) + '.'

    $.extend(result, date: date)

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
    @predict(@predict(rangeData))

  predict: (data) ->
    delta = 0
    coefficient = BaseRenderer.PREDICTION_COEFFICIENT

    last = data.slice(-BaseRenderer.PREDICTION_COEFFICIENT)

    for current, index in last.slice(1)
      previous = last[index]

      console.log([index, previous.value, current.value])

      delta += coefficient * (current.value - previous.value)
      coefficient -= BaseRenderer.PREDICTION_COEFFICIENT_STEP

    data.concat([{ date: @nextDate(data.last().date), value: data.last().value + delta / (1.0 - coefficient) }])

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

  constructor: (@container, @currency) ->
    @initDatesAndChart()

  chartTitle: ->
    @currency + '/USD exchange rate'

  chartSeriesName: ->
    'exchange rate'

  apiUrl: (date) ->
    '/currency/' + @currency + '/' + $.datepicker.formatDate('yy-mm-dd', date) + '.json'


class WeatherRenderer extends BaseRenderer

  constructor: (@container, @city) ->
    @initDatesAndChart()

  chartTitle: ->
    @city.split('_').last() + ' weather'

  chartSeriesName: ->
    'average temperature'

  apiUrl: (date) ->
    '/weather/' + @city + '/' + $.datepicker.formatDate('yymmdd', date) + '.json'


$ ->
  $('#currency .js-show').click -> new CurrencyRenderer($('#currency'), 'GBP').render()
  $('#weather .js-show').click -> new WeatherRenderer($('#weather'), 'FR_Paris').render()