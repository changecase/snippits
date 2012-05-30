// Loads google's Feed API
// uses form google.load(module, version, package), where 
//   module calls the specific API module you wish to use on your page (in this case, elements)
//   version is the version number of the module you wish to load (in this case, 1)
//   package specifies the specific elements package you wish to load, in this cae Feed
// If you need to find out more about google.load, visit https://developers.google.com/loader/

// Everything in here that is in additon to the base google load script is written my yours truely (Jeff Jacobson-Swartfager)... probably terribly.
    
    google.load("feeds", "1");
	
	// Grabs the first and last name of our author
	var firstName = $(".given-name")[0].innerHTML;
	var lastName = $(".family-name")[0].innerHTML;
	
	
	// Transfers the names to URL kosher strings
	function makeURL(inputArray) {
		var outputString = "";
		for (var i=0; i<inputArray.length; i++) {
			if (i === 0) {
				outputString = inputArray[i].toLowerCase();
			} else if (i<inputArray.length && i !== 0){
				outputString += "-" + inputArray[i].toLowerCase();
			}
		}
		// Encodes the string (that now has hyphens replacing any spaces that were in it) into URL form. We do this
		// because I haven't been able to figure out how to grep for the diacritics/character entities/whatever. 
		// I can't tell how they are being encoded. Ideally, I'll eventually figure this out so that we don't have
		// to do this in-elgant transformation.
		// The problem is that for characters using diacritics, the diacritic entity is encoded into URL form too.
		outputString = encodeURI(outputString);
		// As a result of the encoding, we can know search and replace known URI encoded characters.
		// Check out http://www.javascripter.net/faq/escape-encodeuri-upper-ascii.htm for a list of the encodings.
		// This one replaces à, á, â, ã, ä, å, À, Á, Â, Ã, Ä, and Å with a.
		outputString = outputString.replace(/%C3(%A[1|2|3|4|5]|%8[0|1|2|3|4|5])/gi, 'a');
		// This one replaces è, é, ê, ë, È, É, Ê, and Ë with e.
		outputString = outputString.replace(/%C3(%A[8|9|A]|%8[8|9|A|B])/gi, 'e');
		// This one replaces æ and Æ with ae.
		outputString = outputString.replace(/%C3(%86|%A6)/gi, 'ae');
		// Returns the result so that we can save the result of the function to a variable.
		return outputString;
	}
	var firstNameURL = makeURL(firstName.split(" "));
	var lastNameURL = makeURL(lastName.split(" "));
    
    // Our callback function, for when a feed is loaded.
    function feedLoaded(result) {
      if (!result.error) {
        // Grab the container we will put the results into
        var container = document.getElementById("feedContent");
        container.innerHTML = '';
		
		if (result.feed.entries.length > 0) { // Check to see if this author has written any blog posts
			// Since author has written a blog post,
			// Loop through the feeds, putting the titles onto the page.
			// Check out the result object for a list of properties returned in each entry.
			// http://code.google.com/apis/ajaxfeeds/documentation/reference.html#JSON
			for (var i = 0; i < result.feed.entries.length; i++) {
			  var entry = result.feed.entries[i];
			  var li = document.createElement("li");
			  li.innerHTML = '<a href="' + entry.link + '">' + entry.title + '</a>';
			  container.appendChild(li);
			}
		} else {
			// Since author has not written any blog posts,
			// Display a message for why no entries are showing up.
			container.innerHTML = '<li>' + firstName + ' hasn\'t published any blog posts yet. Check out the <a href="http://www.advisiconblog.com/" title="The Advisicon blog">Advisicon blog</a> instead.</li>';
		}
		
      } else { // If loading the feed results in an error, show a link to the Advisicon blog instead.
        var container = document.getElementById("feedContent");
		container.innerHTML = '<li>Error loading posts. <a href="http://www.advisiconblog.com" title="View the Advisicon blog">Read the Advisicon blog</a> instead.</li><li>Error source: ' + firstNameURL + '-' + lastNameURL + '</li>';
	  }
    }

    function OnLoad() {
      // Create a feed instance that will grab the author's advisiconblog.com feed.
	  var feed = new google.feeds.Feed('http://www.advisiconblog.com/author/' + firstNameURL + '-' + lastNameURL + '/feed/');
    
      // Calling load sends the request off.  It requires a callback function.
      feed.load(feedLoaded);
    }
    
    google.setOnLoadCallback(OnLoad);