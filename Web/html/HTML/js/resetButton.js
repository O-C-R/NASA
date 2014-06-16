// side panel part:
var animationTime = 400;

// matrix fun
//$('#matrix').click(function() {
$('#panzoom-parent').find('.panzoom').on('panzoomend', function(e, panzoom, matrix, changed) {
	var ar = $('#panzoom-parent').find('.panzoom').panzoom("getMatrix");
	var windowWidth = window.innerWidth;
	var windowHeight = window.innerHeight;
	var mapWidth = parseFloat($('#mapBlank').width());
	var mapHeight = $('#mapBlank').height();
	var centerX = windowWidth / 2;
	var centerY = windowHeight / 2;

	var ulx = ((1 - ar[0]) * (windowWidth / 2) + parseFloat(ar[4]));
	var uly = ((1 - ar[0]) * (windowHeight / 2) + parseFloat(ar[5]));
	var llx = ((1 - ar[0]) * (windowWidth / 2) + parseFloat(ar[4]));
	var lly = ((1 - ar[0]) * (windowHeight / 2) + (parseFloat(ar[5])) + mapHeight * ar[0]);
	var urx = ((1 - ar[0]) * (windowWidth / 2) + (parseFloat(ar[4])) + mapWidth * ar[0]);
	var ury = uly;
	var lrx = urx;
	var lry = lly;

	//alert("scale: " + ar[0] + " x: " + ar[4] + " y: " + ar[5] + " display x: " + lrx + " display y: " + lry + " mapBlank.height: " + $('#mapBlank').height());
	// actual x / window/2 = (1 - scale)
	//(1 - scale) * (window/2) = actual x

	// find the target reset button opacity
	// get the nearest corner
	var resetPadding = 100;
	var targetX = ulx;
	var targetY = uly;
	var debugLabel = "ul";
	var existingOpacity = $('.reset').css('opacity');
	var shouldProbablyFadeIn = false;

	// slow... but eh
	var closestDistance = Math.abs(targetX - centerX) + Math.abs(targetY - centerY);
	if (Math.abs(llx - centerX) + Math.abs(lly - centerY) < closestDistance) {
		targetX = llx;
		targetY = lly;
		closestDistance = Math.abs(llx - centerX) + Math.abs(lly - centerY);
		debugLabel = "ll";
	}
	if (Math.abs(urx - centerX) + Math.abs(ury - centerY) < closestDistance) {
		targetX = urx;
		targetY = ury;
		closestDistance = Math.abs(urx - centerX) + Math.abs(ury - centerY);
		debugLabel = "ur";
	}
	if (Math.abs(lrx - centerX) + Math.abs(lry - centerY) < closestDistance) {
		targetX = lrx;
		targetY = lry;
		closestDistance = Math.abs(lrx - centerX) + Math.abs(lry - centerY);
		debugLabel = "lr";
	}

	if (debugLabel == 'ul') {
		if (targetX > windowWidth - resetPadding || targetY > windowHeight - resetPadding) {
			shouldProbablyFadeIn = true;
		}
	} else if (debugLabel == 'll') {
		if (targetX > windowWidth - resetPadding || targetY < resetPadding) {
			shouldProbablyFadeIn = true;
		}
	} else if (debugLabel == 'ur') {
		if (targetX < resetPadding || targetY > windowHeight - resetPadding) {
			shouldProbablyFadeIn = true;
		}
	} else if (debugLabel == 'lr') {
		if (targetX < resetPadding || targetY < resetPadding) {
			shouldProbablyFadeIn = true;
		}
	}

	if (shouldProbablyFadeIn && existingOpacity == 0) {
		showReset();
	} else if (!shouldProbablyFadeIn && existingOpacity > 0) {
		hideReset();
	}

});

/*
 if (changed) {
 // deal with drags or touch moves
 } else {
 // deal with clicks or taps
 }
 });
 */

var resetAnimationTime = 200;
var resetFullOpacity = .9;
function showReset() {
	$('.reset').animate({
		opacity : resetFullOpacity,
		left : '0',
	}, resetAnimationTime);
}

function hideReset() {
	var resetLeft = 0 - parseFloat($('.reset').css('width'));
	$('.reset').animate({
		opacity : '0',
		left : resetLeft,
	}, resetAnimationTime);
}

// reset the graphic
//$('#reset').click(function(type) {
function resetMap(type) {
	var newX = -400;
	var newY = -400;
	var newScale = .3;
	if (type == 'resetIPad') {
		newX = -278;
		newY = -210;
		newScale = .7;
	}
	// only if the opacity > 0
	if ($('.reset').css('opacity') > 0) {
		$('#panzoom-parent').find('.panzoom').panzoom("reset", {
			animate : true,
			contain : false
		});

		// zoom
		$('#panzoom-parent').find('.panzoom').panzoom("zoom", newScale, {
			silent : true
		});
		$('#panzoom-parent').find('.panzoom').panzoom("pan", newX, newY, {
			relative : false
		});
	}
	hideReset();
	//});
};

