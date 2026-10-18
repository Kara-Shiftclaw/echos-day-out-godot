#!/bin/sh

PAUSE_SCROLL_EXT_RESOURCE='[ext_resource type="PackedScene" uid="uid://nvsrgf321lag" path="res://menu/pause/pause_scroll.tscn" id="3_d1bvw"]'
PAUSE_SCROLL_NODE='[node name="PauseScroll" parent="." instance=ExtResource("3_d1bvw")]
custom_minimum_size = Vector2(104, 42)
custom_maximum_size = Vector2(104, 42)'
PAUSE_SCROLL_RIGHT='offset_right = 108.0'
PAUSE_SCROLL_BOTTOM_LABEL_2='offset_bottom = 88.0

[node name="Label2" type="Label" parent="PauseScroll"]
layout_mode = 2
size_flags_horizontal = 3'


FILES=$(ls menu/pause/journal/entry/)

for FILE in $FILES; do
    FILE_PATH="menu/pause/journal/entry/$FILE"
    if grep 'PauseScroll' $FILE_PATH > /dev/null; then
	echo "File $FILE was already migrated"
    else
	IN_EXT_RESOURCES=
	IN_PAUSE_SCROLL=
	CONTENTS=
	while IFS= read -r TEXT; do
	    if [ "$CONTENTS" != '' ]; then
		CONTENTS="${CONTENTS}\n"
	    fi

	    if echo "$TEXT" | grep '^\[gd_scene' > /dev/null; then
		TEXT=$(echo "$TEXT" | sed -e 's/load_steps=3 //g')
		CONTENTS="${CONTENTS}${TEXT}"
	    elif echo "$TEXT" | grep '^\[ext_resource' > /dev/null; then
		IN_EXT_RESOURCES=true
		CONTENTS="${CONTENTS}${TEXT}"
	    elif [ "$IN_EXT_RESOURCES" != '' ]; then
		IN_EXT_RESOURCES=
		CONTENTS="${CONTENTS}${PAUSE_SCROLL_EXT_RESOURCE}\n${TEXT}"
	    elif echo "$TEXT" | grep '^\[node name="Label2"' > /dev/null; then
		IN_PAUSE_SCROLL=true
		CONTENTS="${CONTENTS}${PAUSE_SCROLL_NODE}"
	    elif [ "$IN_PAUSE_SCROLL" != '' ]; then
		if echo "$TEXT" | grep '^offset_right =' > /dev/null; then
		    CONTENTS="${CONTENTS}${PAUSE_SCROLL_RIGHT}"
		elif echo "$TEXT" | grep '^offset_bottom =' > /dev/null; then
		    CONTENTS="${CONTENTS}${PAUSE_SCROLL_BOTTOM_LABEL_2}"
		    IN_PAUSE_SCROLL=
		else
		    CONTENTS="${CONTENTS}${TEXT}"
		fi
	    else
		CONTENTS="${CONTENTS}${TEXT}"
	    fi
	done < $FILE_PATH

	echo "$CONTENTS" > $FILE_PATH
    fi
done
