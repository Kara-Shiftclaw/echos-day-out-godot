IMPORT_IDS_BY_STANDARD_TEXT_SCENE=$(grep -r 'res://menu/dialogue/model/' ../ | grep -v '\.godot\|\.\./menu/dialogue/model\|text_tree\.tscn' | sed -E -e "s/^([^:]+):.*id=\"([a-zA-Z0-9_]+)\".*$/\1:\2/g")
OUTPUT='output.csv'
echo 'keys,en_us' > "$OUTPUT"

STANDARD_TEXT_SCENES=$(echo "$IMPORT_IDS_BY_STANDARD_TEXT_SCENE" | sed -E -e 's/^([^:]+):.*$/\1/g' | uniq)

for SCENE in $STANDARD_TEXT_SCENES; do
  IMPORT_IDS=$(echo "$IMPORT_IDS_BY_STANDARD_TEXT_SCENE" | grep "$SCENE" | sed -E -e 's/^[^:]+:(.*)$/\1/g')
  for IMPORT_ID in $IMPORT_IDS; do
    grep -A 1 "ExtResource(\"$IMPORT_ID\")" $SCENE | grep 'text = ' | sed -E -e 's/^[a-z_]*text = (.*)$/\1/g' -e 's/</(/g' -e 's/>/)/g' >> "$OUTPUT"
  done
done
