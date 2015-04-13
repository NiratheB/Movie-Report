#INIT
FILENAME="Report.html"
OUTPUT=""
IFS=$'\n'

#BEGIN HTML DOC ###################################################
OUTPUT=$OUTPUT"<!DOCTYPE html>
<html><script src=\"sorttable.js\"></script>
<body>"

#BEGIN TABLE ####################################################
OUTPUT=$OUTPUT"<table class=\"sortable\" border=\"1\" style=\"width:100%\">"

#PRINT HEADER IN TABLE ####################################
OUTPUT=$OUTPUT"<tr><th>Movie Name</th><th>Release Year</th><th>Genre</th><th>Rating</th></tr>"

#Take all folder names separated by newline
IFS=$'\n'
DIR=$(ls movies)
declare -i t=0
for FOLDER in $DIR
do
	
	#ELIMINATE FROM BRACKETS
	FOLDER=${FOLDER%%[/[/(]*}

	#ELIMINATE FROM YEAR
	FOLDER=${FOLDER%%[0-9][0-9][0-9][0-9]*}

	#ELIMINATE FROM 720p..
	FOLDER=${FOLDER%%720p*}

	#ELIMINATE FROM 1080p..
	FOLDER=${FOLDER%%1080p*}

	#ELIMINATE FROM DvDRip
	FOLDER=${FOLDER%%[A-Z][a-zA-Z][A-Z][Rr]ip*}

	#ELIMINATE FROM BRBrip
	FOLDER=${FOLDER%%[A-Z][A-Z][Rr]ip*}
	
	#EILIMINATE FROM EXTENDED
	FOLDER=${FOLDER%%Extended*}

	#EILIMINATE FROM Franchise
	FOLDER=${FOLDER%%Franchise*}

	#Eliminate dots
	FOLDER=${FOLDER//./ }

	#PRINT MOVIE NAME
	#echo $FOLDER
	#ELIMINATE TRAILING SPACES
	FOLDER=${FOLDER%% }

	#SEARCH MOVIE IN imdb.com
	SITE=${FOLDER// /+}
	SITE="http://www.imdb.com/find?q="$SITE
	#echo $SITE
	curl $SITE > search.html

	#GET THE FIRST RESULT
	SITE=$(cat search.html | grep -io ".*findResult odd.*")
	SITE=${SITE%%</a>*}
	SITE=${SITE%%\" ><img*}
	SITE=${SITE##*href=\"}

	MOVIE=$FOLDER
	RATE="Not Found!"
	GENRE_STRING="Not Found!"
	DATE="Not Found!"
	if [ ! -z "$SITE" ]; then
		SITE="http://www.imdb.com"$SITE
		#echo $SITE
		SITE=${SITE%%\?*}
		#echo $SITE
		curl $SITE > search.html

		#GET MOVIE NAME
		MOVIE=$(cat search.html | grep "<title>.*</title>")
		MOVIE=${MOVIE##*<title>}
		MOVIE=${MOVIE%-*}
		DATE=$MOVIE
		MOVIE=${MOVIE%%\(*}
		MOVIE=${MOVIE##\"}
		MOVIE=${MOVIE##*[A-Za-z]\;}
		#echo $MOVIE

		#GET RELEASE DATE
		#echo $DATE
		DATE=${DATE##*\(}
		DATE=${DATE##*[A-Za-z]}
		DATE=${DATE%%\)*}
		#echo $DATE

		#GET RATING
		RATE=$(cat search.html | grep -io ".*<div class=\"titlePageSprite star-box-giga-star\">.*")
		RATE=${RATE%%</*}
		RATE=${RATE##*>}
		#echo $RATE

	
		#GET LIST OF GENRE IT BELONGS TO
		GENRE_LIST=$(cat search.html | grep -io "^<a href=\"/genre.*?ref_=tt_ov_inf")
		GENRE_STRING=""
		for WORD in $GENRE_LIST
		do
			WORD=${WORD%%\?*}
			WORD=${WORD##*genre/}
			GENRE_STRING=$GENRE_STRING" | "$WORD
	
		done

		#echo $GENRE_STRING
	fi


	#PRINT MOVIE REPORT IN TABLE ####################################
	OUTPUT=$OUTPUT"<tr><td>${MOVIE}</td><td>${DATE}</td><td>${GENRE_STRING}</td><td>${RATE}</td></tr>"

	t=$t+1
	echo ${t}" COMPLETED"

done


#END TABLE ####################################################
OUTPUT=$OUTPUT"</table>"

#END HTML DOC ###################################################
OUTPUT=$OUTPUT"
</body>
</html>"

#FINAL OUTPUT TO FILE
echo $OUTPUT > $FILENAME
