<?php if (get_the_author_meta('description') != NULL) {
	echo '<div id="author-bio">';
		$firstNameString = get_the_author_meta("first_name"); // stores the value of the author's first name
		$lastNameString = get_the_author_meta("last_name"); // stores the value of the author's last name
		
		// creates a new function called makeURL that preps strings to be url (and human) friendly.
		// in other words, rather than encoding characters like С, it replaces the character with the nearest
		// approximation in the standard English alphabet (like A) and then outputs the string in all lowercase.
		// this also replaces spaces with hyphens and removes periods entirely
		function makeURL($inputArray) {
			$ts = array("/[Р-Х]/u","/Ц/u","/Ч/u","/[Ш-Ы]/u","/[Ь-Я]/u","/а/u","/б/u","/[в-жи]/u","/з/u","/[й-м]/u","/[н-п]/u","/[р-х]/u","/ц/u","/ч/u","/[ш-ы]/u","/[ь-я]/u","/№/u","/ё/u","/[ђ-іј]/u","/ї/u","/[љ-ќ]/u","/[§-џ]/u", "/ /u", "/\./u"); // the characters to replace. The /u flag indicates that the characters are unicode. Without this, the replacement is imperfect.
			$tn = array("a","ae","c","e","i","d","n","o","x","u","y","a","ae","c","e","i","d","n","o","x","u","y", "-", ""); // the characters to replace with
			$outputString = preg_replace($ts,$tn, $inputArray); // performs the actual replacement
			return strtolower($outputString); // return the replaced string in lowercase
		}
		
		$firstName = makeURL($firstNameString); // makeURL the first name string
		$lastName = makeURL($lastNameString); // makeURL the last name string

		$descriptionParagraphs = explode("\n", get_the_author_meta("description")); // turns the user's description into an array. Each item in the array is a paragraph (splits the string at the newline character)
		echo '<a title="view '.$firstName.'\'s profile on Advisicon\'s website" href="http://www.advisicon.com/staff_bios/'.$firstName.'-'.$lastName.'.htm" class="authorPic">
			<img src="http://advisicon.com/pix/biopics/' . $firstName . '-' . $lastName . '.jpg" alt="'.the_author.'" width="107" height="161" />
		</a>'; // adds a profile picture to the author description and makes it a hyperlink, linking to the author's staff bio on the advisicon.com site
		foreach ($descriptionParagraphs as $value) {
			echo '<p>'.$value.'</p>'; // spits the author's bio back out, now surrounded by paragraph tags.
		}
		unset($value); // clears the value variable for use elsewhere
	echo '</div><!-- end author-bio -->';
} ?>