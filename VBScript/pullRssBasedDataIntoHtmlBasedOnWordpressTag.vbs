				'	For info on this code, see the website http://markalexanderbain.suite101.com/using-vbscript-to-extract-data-from-a-web-page-a89800
				
				'Using VBScript to Obtain the Contents of a Web Page
				'	There is not a VBScript method for reading the contents of a web stage. Instead VBScript uses one of the many objects built into Microsoft Windows.
				'	In this case VBScript uses the XMLHTTP object to send a request to a web server for for a web page. The HTML returned from this web page will then be available in the XMLHTTP object's responseText property.
				sub process_html(up_http) 'start a sub process, we'll call it process_html(). It takes the argument up_http
					dim xmlhttp : set xmlhttp = createobject("msxml2.xmlhttp.3.0") 'declares a variable called xmlhttp and sets it to be an object of type XMLHTTP
					xmlhttp.open "get", up_http, false 'opens the connection
					xmlhttp.send
					
					dim response_array : response_array = split(xmlhttp.responseText, "<item>") 'turn our big ass webpage string into an array (using the opening <item> tag as the delimiter)
					
					dim re : Set re = new regexp 'defines the variable re and makes it a new regular expression
						re.Pattern = "<title>.*</title>" 'set up a regular expression to use for searching the items in our array. We're using it to search for the title tags.
						re.IgnoreCase = True 'regular expression search is case insensitive. Don't know why we can't just do this in the regexp itself.
						re.Global = True 'makes sure match applies to the entire string
					
					dim i 'declare a new variable, i. We'll use this to step through the items in the array
					for i = 1 to ubound(response_array) 'steps through the items in the array, starting at the position response_array(1) and continuing to the end of response_array. ubound seems to act a bit like .length, len(), etc. We start at position 1 instead of 0 so that we don't pick up matches from the stuff in the <channel> before the first <item>
						if re.Test(response_array(i)) then 'if the regular expression pattern defined earlier as re is found within the array item then do the following. re.Test() returns a boolean.
							Set Matches = re.Execute(response_array(i)) 'make a new array, this one called Matches. Created from the current item in response_array.
							for each Match in Matches 'for each item in this new Matches array ...
								title = Replace(Match.Value,"<title>","") 'remove the opening <title>
								title = Replace(title,"</title>","") 'remove the closing </title> tag
								dim reLink : Set reLink = new regexp 'new regular expression, this one is called reLink. We'll use it to search for the <link> tags
									reLink.Pattern = "<link>.*</link>" 'looking for the <link> tags
									reLink.IgnoreCase = True 'case insensitive
									reLink.Global = True 'search entire string
									Set linkMatches = reLink.Execute(response_array(i)) 'make a new array called linkMatches from the current item in response_array()
										for each linkMatch in linkMatches
											link = Replace(linkMatch.Value,"<link>","") 'remove the opening <link>
											link = Replace(link,"</link>", "") 'remove the closing </link>
										Next 'you get the idea...
								dim rePubDate : Set rePubDate = new regexp
									rePubDate.Pattern = "<pubDate>.*</pubDate>"
									rePubDate.IgnoreCase = True
									rePubDate.Global = True
									Set dateMatches = rePubDate.Execute(response_array(i))
										for each dateMatch in dateMatches
											pubDate = Replace(dateMatch.Value,"<pubDate>","")
											pubDate = Replace(pubDate,"</pubDate>","")
											pubDate = Left(pubDate,16) 'here, we're getting rid of the timestamp in the pubDate (we're only interested in the day).
										Next
								dim reContent : Set reContent = new regexp
									reContent.Pattern = "<description>.*</description>"
									reContent.IgnoreCase = True
									reContent.Global = True
									Set contentMatches = reContent.Execute(response_array(i))
										for each contentMatch in contentMatches
											content = contentMatch.Value
											content = Replace(content,"<description>","")
											content = Replace(content,"<![CDATA[","") 'pulling out CDATA markup
											content = Replace(content,"]]>","") 'the rest of the CDATA markup
											content = Replace(content,"</description>","")
											content = Replace(content,"[...]","<a href='" & link & "' title='read the full article, &ldquo;" & title & "&rdquo; on the blog'>[...]</a>") 'I like that as an indicator that there is more. This turns it into a link sending you to the blog post.
										Next
								response.write("<h2> <a href='" & link & "' title='read the full article, &ldquo;" & title & "&rdquo; on the blog'>" & title & "</a></h2>") 'build a header for this news/event item
								response.write("<p><strong>" & pubDate & "</strong> " & content & "</p>")
							Next
						else
							response.write("<p>Hmm&hellip; no event. That can&rsquo;t be right. Please <a href='mailto:webmaster@advisicon.com?subject=Something broke!' title='email the webmaster'>send us an email</a> to let us know that something has gone wonkey.</p>")
						end if
					next 'use a for loop to use the regular expression on the array. The output from the loop will be the line(s) containing the search pattern
					
					set re = nothing
					set xmlhttp = nothing
					
				end sub 'free up any memory used by the process
				
				process_html("http://www.advisiconblog.com/tag/event/feed/") 'point the subprocess to the webpage you want to access
