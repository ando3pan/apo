$(document).ready(function() {
	var $calendar = $('#calendar');

  $calendar.fullCalendar({
  	displayEventEnd: true,
  	eventRender: 
    	function(event, element) { 
        element.find('.fc-time').append("<br/>");
        if (event.description !== '')
        	element.find('.fc-title').append("<br/>"+event.description);
      },
    timeFormat: 'h:mmt',
		events: '/events_feed',
		defaultView: 'month',
		allDaySlot: false,
    header: {
      left: 'title',
      right: 'today prev,next'
    }
  });
});
