$('#embedcode').html('&lt;iframe src="' + document.URL + '" width="630" height="625" scrolling="no"&gt;&lt;/iframe&gt;');
$('#embedbox').css("display", "none");
$('#embed').bind("click", function (e) {
    $('#embedbox').css("display", "block");
});
$('#close').bind("click", function (e) {
    $('#embedbox').css("display", "none");
});

$('#slider').slider({
   value: 85,
   min: 0,
   max: 100
});

//remove those dumb rounded corners
$('.ui-corner-all').removeClass('ui-corner-all');

$('.ui-slider-handle').css({
    width: '5px',
    height: '12px',
    'margin-left': '-3px'
});

var tooltip = d3.select("body")
    .append("div")
    .attr("class", "tip")
	.style("position", "absolute")
	.style("z-index", "10")
	.style("visibility", "hidden");


