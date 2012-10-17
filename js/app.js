(function() {
  var defaultEndDate, defaultStartDate, updateDateLimits;

  updateDateLimits = function(date) {
    var _this = this;
    setTimeout((function() {
      var datepicker;
      datepicker = $(_this);
      if (datepicker.attr('name') === 'from') {
        return datepicker.siblings('.js-datepicker[name=to]').datepicker('option', 'minDate', date);
      } else {
        return datepicker.siblings('.js-datepicker[name=from]').datepicker('option', 'maxDate', date);
      }
    }), 1000);
    return console.log(date);
  };

  defaultStartDate = -3;

  defaultEndDate = -1;

  $(function() {
    $('button').button();
    return $('.js-datepicker').each(function() {
      var datepicker;
      datepicker = $(this);
      if (datepicker.attr('name') === 'from') {
        return datepicker.datepicker({
          maxDate: defaultEndDate,
          onClose: updateDateLimits
        }).datepicker('setDate', defaultStartDate);
      } else {
        return datepicker.datepicker({
          minDate: defaultStartDate,
          maxDate: defaultEndDate,
          onClose: updateDateLimits
        }).datepicker('setDate', defaultEndDate);
      }
    });
  });

}).call(this);
