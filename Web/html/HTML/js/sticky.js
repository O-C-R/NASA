// side panel part:
var animationTime = 400;
$('#bus').click(function() {
	var base = 0;
	var farLeft = 500;

	var currentLeft = $('#bus').css('left');
	if (currentLeft == '0px') {
		openBus();
	} else {
		closeBus();
	}
});

function openBus() {
	$('#bus').animate({
		left : $('#busContent').css('width')
	}, animationTime);
	$('#busContent').animate({
		opacity : '.9'
	}, animationTime);
	// close the cat if the cat is open
	var currentCatLeft = $('#cat').css('left');
	if (currentCatLeft != '0px') {
		closeCat();
	}
}

function closeBus() {
	$('#bus').animate({
		left : '0px'
	}, animationTime);
	$('#busContent').animate({
		opacity : '0'
	}, animationTime);
}


$('#cat').click(function() {
	var base = 0;
	var farLeft = 300;
	var currentLeft = $('#cat').css('left');
	if (currentLeft == '0px') {
		openCat();
	} else {
		closeCat();
	}
});

function openCat() {
	$('#cat').animate({
		left : $('#catContent').css('width')
	}, animationTime);
	$('#catContent').animate({
		opacity : '.9'
	}, animationTime);
}

function closeCat() {
	$('#cat').animate({
		left : '0px'
	}, animationTime);
	$('#catContent').animate({
		opacity : '0'
	}, animationTime);
}


