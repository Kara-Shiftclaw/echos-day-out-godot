IMPORT_IDS_BY_STANDARD_TEXT_SCENE=$(grep -r 'res://menu/dialogue/model/' ../ | grep -v '\.godot\|\.\./menu/dialogue/model\|text_tree\.tscn' | sed -E -e "s/^([^:]+):.*id=\"([a-zA-Z0-9_]+)\".*$/\1:\2/g")
STANDARD_TEXT_SCENES=$(echo "$IMPORT_IDS_BY_STANDARD_TEXT_SCENE" | sed -E -e 's/^([^:]+):.*$/\1/g' | uniq)
TRANSLATION="$(cat output.csv)"

for SCENE in $STANDARD_TEXT_SCENES; do
	FILE=$(awk '{printf "%s\\n", $0}' "$SCENE")
	TEXTS=$(echo "$FILE" | grep -Eo 'text = "([^"\\]*(\\"?)?)*"' | sed 's/text = //g')
	while IFS= read -r TEXT ; do
    ESCAPED_TEXT="$(echo "$TEXT" | sed -E -e 's/\\/\\\\/g')"
    TRANSLATION_TEXT="$(echo "$ESCAPED_TEXT" | sed -E -e 's/</(/g' -e 's/>/\)/g')"
    TRANSLATION_NAME="$(echo "${TRANSLATION}" | grep "$TRANSLATION_TEXT" | sed -E -e 's/^([A-Z0-9_]+),.*$/\1/g')"
		if [ "$TRANSLATION_NAME" != '' ]; then
      FILE="$(echo "$FILE" | sed -E -e "s/${ESCAPED_TEXT}/\"$TRANSLATION_NAME\"/g")"
	    echo "$ESCAPED_TEXT replaced with \"$TRANSLATION_NAME\""
    else
      echo "No translation for $TEXT"
		fi
  done <<< "$TEXTS"

  echo "$FILE" | sed -E -e 's/\\n/\
/g' > "$SCENE"
done
  
