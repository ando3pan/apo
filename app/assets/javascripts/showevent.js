function initMap() {
  var geocoder = new google.maps.Geocoder();
  var map = new google.maps.Map(document.getElementById('map-canvas'), {
    center: {lat: 32.879408, lng: -117.236817}, // default to school
    zoom: 16
  });
  geocodeAddress(geocoder, map);
}

function geocodeAddress(geocoder, resultsMap) {
  var address = $('#mapsaddress').html();
  geocoder.geocode({'address': address}, function(results, status) {
    if (status === google.maps.GeocoderStatus.OK) {
      resultsMap.setCenter(results[0].geometry.location);
      var marker = new google.maps.Marker({
        map: resultsMap,
        position: results[0].geometry.location
      });
    } else {
      if (status !== "ZERO_RESULTS") {
        console.log('Geocode failed for the following reason: ' + status);
      }
    }
  });
}

$(".event-signup").click(function() {
  if (!$(this).hasClass("disabled") &&
    ($("#chair-required").length === 0 || $("#will-chair:checked").length === 1) &&
    ($("#driver-required").length === 0 || $("#can-drive:checked").length === 1)) {
    $(this).val("Loading");
    $(this).removeClass("orange green red");
    $(this).addClass("disabled");
  }
});

$("#will-chair").click(function() {
  if ($("#will-chair:checked").length == 1) {
    $("#chair-required").hide();
    $("#hide-unless-chair").attr('style', '');
  } else {
    $("#chair-required").show();
    $("#hide-unless-chair").attr('style', 'display: none;');
  }
});

$("#can-drive").click(function() {
  if ($("#can-drive:checked").length == 1) {
    $("#driver-required").hide();
    $("#hide-unless-drive").attr('style', '');
  } else {
    $("#driver-required").show();
    $("#hide-unless-drive").attr('style', 'display: none;');
  }
});

$("#signup-form").submit(function (e) {
  if ($("#chair-required").length > 0 && $("#will-chair:checked").length == 0)
    e.preventDefault(); //prevent default form submit
});
