updateDateLimits = (date) ->
  # run with delay to prevend datapicker blinking
  setTimeout ( =>
    datepicker = $(@)
    if datepicker.attr('name') == 'from'
      datepicker.siblings('.js-datepicker[name=to]').datepicker('option', 'minDate', date)
    else
      datepicker.siblings('.js-datepicker[name=from]').datepicker('option', 'maxDate', date)
  ), 1000

  console.log(date)

defaultStartDate = -3
defaultEndDate   = -1

$ ->
  $('button').button()
  $('.js-datepicker').each ->
    datepicker = $(@)
    if datepicker.attr('name') == 'from'
      datepicker.datepicker(dateFormat: 'dd/mm/yy', maxDate: defaultEndDate, onClose: updateDateLimits).datepicker('setDate', defaultStartDate)
    else
      datepicker.datepicker(dateFormat: 'dd/mm/yy', minDate: defaultStartDate, maxDate: defaultEndDate, onClose: updateDateLimits).datepicker('setDate', defaultEndDate)
