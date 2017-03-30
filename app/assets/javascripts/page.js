
jQuery(document).ready(function($){
	//set animation timing
	var lfsImg = ['http://lorempixel.com/1280/720/','http://lorempixel.com/1280/720/', 'http://lorempixel.com/1280/720/'];
	var lfsIndex = 0;
	var animationDelay = 2500,
		//loading bar effect
		barAnimationDelay = 3800,
		barWaiting = barAnimationDelay - 3000, //3000 is the duration of the transition on the loading bar - set in the scss/css file
		//letters effect
		lettersDelay = 50,
		//type effect
		typeLettersDelay = 150,
		selectionDuration = 500,
		typeAnimationDelay = selectionDuration + 800,
		//clip effect 
		revealDuration = 600,
		revealAnimationDelay = 1500;
	
	initHeadline();
    makeHoursGraph();
	

	function initHeadline() {
		//insert <i> element for each letter of a changing word
		singleLetters($('.cd-headline.letters').find('b'));
		//initialise headline animation
		animateHeadline($('.cd-headline'));
	}

	function singleLetters($words) {
		$words.each(function(){
			var word = $(this),
				letters = word.text().split(''),
				selected = word.hasClass('is-visible');
			for (i in letters) {
				if(word.parents('.rotate-2').length > 0) letters[i] = '<em>' + letters[i] + '</em>';
				letters[i] = (selected) ? '<i class="in">' + letters[i] + '</i>': '<i>' + letters[i] + '</i>';
			}
		    var newLetters = letters.join('');
		    word.html(newLetters).css('opacity', 1);
		});
	}

	function animateHeadline($headlines) {
		var duration = animationDelay;
		$headlines.each(function(){
			var headline = $(this);
			
			if(headline.hasClass('loading-bar')) {
				duration = barAnimationDelay;
				setTimeout(function(){ headline.find('.cd-words-wrapper').addClass('is-loading') }, barWaiting);
			} else if (headline.hasClass('clip')){
				var spanWrapper = headline.find('.cd-words-wrapper'),
					newWidth = spanWrapper.width() + 10
				spanWrapper.css('width', newWidth);
			} else if (!headline.hasClass('type') ) {
				//assign to .cd-words-wrapper the width of its longest word
				var words = headline.find('.cd-words-wrapper b'),
					width = 0;
				words.each(function(){
					var wordWidth = $(this).width();
				    if (wordWidth > width) width = wordWidth;
				});
				headline.find('.cd-words-wrapper').css('width', width);
			};

			//trigger animation
			setTimeout(function(){ hideWord( headline.find('.is-visible').eq(0) ) }, duration);
		});
	}

	function hideWord($word) {
		var nextWord = takeNext($word);
		
		if($word.parents('.cd-headline').hasClass('type')) {
			var parentSpan = $word.parent('.cd-words-wrapper');
			parentSpan.addClass('selected').removeClass('waiting');	
			setTimeout(function(){ 
				parentSpan.removeClass('selected'); 
				$word.removeClass('is-visible').addClass('is-hidden').children('i').removeClass('in').addClass('out');
			}, selectionDuration);
			setTimeout(function(){ showWord(nextWord, typeLettersDelay) }, typeAnimationDelay);
			
		
		} else if($word.parents('.cd-headline').hasClass('letters')) {
			var bool = ($word.children('i').length >= nextWord.children('i').length) ? true : false;
			hideLetter($word.find('i').eq(0), $word, bool, lettersDelay);
			showLetter(nextWord.find('i').eq(0), nextWord, bool, lettersDelay);

		}  else if($word.parents('.cd-headline').hasClass('clip')) {
			$word.parents('.cd-words-wrapper').animate({ width : '2px' }, revealDuration, function(){
				switchWord($word, nextWord);
				showWord(nextWord);
			});

		} else if ($word.parents('.cd-headline').hasClass('loading-bar')){
			$word.parents('.cd-words-wrapper').removeClass('is-loading');
			switchWord($word, nextWord);
			setTimeout(function(){ hideWord(nextWord) }, barAnimationDelay);
			setTimeout(function(){ $word.parents('.cd-words-wrapper').addClass('is-loading') }, barWaiting);

		} else {
			switchWord($word, nextWord);
			setTimeout(function(){ hideWord(nextWord) }, animationDelay);
		}
	}

	function showWord($word, $duration) {
		if($word.parents('.cd-headline').hasClass('type')) {
			showLetter($word.find('i').eq(0), $word, false, $duration);
			$word.addClass('is-visible').removeClass('is-hidden');

		}  else if($word.parents('.cd-headline').hasClass('clip')) {
			$word.parents('.cd-words-wrapper').animate({ 'width' : $word.width() + 10 }, revealDuration, function(){ 
				setTimeout(function(){ hideWord($word) }, revealAnimationDelay); 
			});
		}
	}

	function hideLetter($letter, $word, $bool, $duration) {
		$letter.removeClass('in').addClass('out');
		
		if(!$letter.is(':last-child')) {
		 	setTimeout(function(){ hideLetter($letter.next(), $word, $bool, $duration); }, $duration);  
		} else if($bool) { 
		 	setTimeout(function(){ hideWord(takeNext($word)) }, animationDelay);
		}

		if($letter.is(':last-child') && $('html').hasClass('no-csstransitions')) {
			var nextWord = takeNext($word);
			switchWord($word, nextWord);
		} 
	}

	function showLetter($letter, $word, $bool, $duration) {
		$letter.addClass('in').removeClass('out');
		
		if(!$letter.is(':last-child')) { 
			setTimeout(function(){ showLetter($letter.next(), $word, $bool, $duration); }, $duration); 
		} else { 
			if($word.parents('.cd-headline').hasClass('type')) { setTimeout(function(){ $word.parents('.cd-words-wrapper').addClass('waiting'); }, 200);}
			if(!$bool) { setTimeout(function(){ hideWord($word) }, animationDelay) }
		}
	}

	function takeNext($word) {
		return (!$word.is(':last-child')) ? $word.next() : $word.parent().children().eq(0);
	}

	function takePrev($word) {
		return (!$word.is(':first-child')) ? $word.prev() : $word.parent().children().last();
	}

	function switchWord($oldWord, $newWord) {
		$oldWord.removeClass('is-visible').addClass('is-hidden');
		$newWord.removeClass('is-hidden').addClass('is-visible');
	}

    /** FUNCTIONS FOR THE FAM SERVICE HOUR GRAPHS */
    function makeHoursGraph() {
        var totalHours = parseInt($('#hours-total').text());
        var alphaHours = parseInt($('#hours-Alpha').text());
        var omegaHours = parseInt($('#hours-Omega').text());
        var phiHours = parseInt($('#hours-Phi').text());
        var rhoHours = parseInt($('#hours-Rho').text());
        var piHours = parseInt($('#hours-Pi').text());
        var maxBarSize = $('#service-hours-panel').width() * 3/4;

	/* var famHours = [alphaHours.to_f, omegaHours.to_f, phiHours.to_f, rhoHours.to_f, piHours.to_f];
	famHours.sort(); */
	
        $('#bar-total').css("width", maxBarSize );
        
	var hours1 = alphaHours/totalHours * maxBarSize;
        if( hours1 == 0 ) hours = 1;
        $('#bar-Alpha').css("width", hours);
        var hours2 = phiHours/totalHours * maxBarSize;
        if( hours2 == 0 ) hours = 1;
        $('#bar-Phi').css("width", hours );
        var hours3 = omegaHours/totalHours * maxBarSize;
        if( hours3 == 0 ) hours = 1; 
        $('#bar-Omega').css("width", hours );
        var hours4 = rhoHours/totalHours * maxBarSize;
        if( hours4 == 0 ) hours = 1;
        $('#bar-Rho').css("width", hours );
        var hours5 = piHours/totalHours * maxBarSize;
        if( hours5 == 0 ) hours = 1;
        $('#bar-Pi').css("width", hours );
/*
	fam1 = Fam.new('AlphaFam', hours1);
	fam2 = Fam.new('PhiFam', hours2);
	fam3 = Fam.new('OmegaFam', hours3);
	fam4 = Fam.new('RhoFam', hours4);
	fam5 = Fam.new('PiFam', hours5);
	
	var famHours = [hours1, hours2, hours3, hours4, hours5];
	
	famHours.sort do |a, b|
		case
		when a.famHours < b.famHours
			-1
		when a.famHours > b.famHours
			1
		else
			a.famName <=> b.famName
		end
	end

	

	
*/	

    }
});
