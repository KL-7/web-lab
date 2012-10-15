setDate = (element) ->
  date = element.data('daysAgo')
  element.datepicker('setDate', if date != 0 then date else new Date())

$ ->
  $('button').button()

  $('.js-datepicker').datepicker().each -> setDate($(@))