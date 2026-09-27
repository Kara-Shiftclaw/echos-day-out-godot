STANDARD_TEXT_SCENES=$(ls ../menu/pause/journal/entry)
OUTPUT="output.csv"

for SCENE in $STANDARD_TEXT_SCENES; do
	FILE=$(awk '{printf "%s\\n", $0}' "../menu/pause/journal/entry/${SCENE}")
  NAME=$(echo "$SCENE" | sed -E -e 's/^([a-z_]+).tscn$/\U\1/g')
	TEXTS=$(echo "$FILE" | grep -Eo 'text = "([^"\\]*(\\"?)?)*"' | sed 's/text = //g')
  IS_NAME=1
	while IFS= read -r TEXT ; do
		if [[ $IS_NAME == 1 ]]; then
			IS_NAME=
			TRANSLATION_NAME="JOURNAL_${NAME}_NAME"
		else
			TRANSLATION_NAME="JOURNAL_${NAME}_DESC"
		fi
    
    ESCAPED_TEXT="$(echo "$TEXT" | sed -E -e 's/\\/\\\\/g')"
    TRANSLATION_TEXT="$(echo "$ESCAPED_TEXT" | sed -E -e 's/</(/g' -e 's/>/\)/g')"
		if [ "$TRANSLATION_NAME" != '' ]; then
      SED_ESCAPED_TEXT="$(echo "$ESCAPED_TEXT" | sed -E -e 's/\?/\\?/g')"
      FILE="$(echo "$FILE" | sed -E -e "s/text = ${SED_ESCAPED_TEXT}/text = \"$TRANSLATION_NAME\"/g")"
      echo "$TRANSLATION_NAME,$TRANSLATION_TEXT" >> "$OUTPUT"
	    echo "$ESCAPED_TEXT replaced with \"$TRANSLATION_NAME\""
    else
      echo "No translation for $ESCAPED_TEXT"
		fi
  done <<< "$TEXTS"

  echo "$FILE" | sed -E -e 's/[\\n]+$//g' -e 's/\\n/\
/g' > "../menu/pause/journal/entry/${SCENE}"
done
  
