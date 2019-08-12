#!/bin/bash -eux

echo "----- started encoding @`date +%Y/%m/%d/%H:%M:%S` -----"
echo $1

CHINACHU_HOME="${HOME}/chinachu"
FFMPEG_HOME="${HOME}/ffmpeg/ffmpeg"
DUMP_SITE="${CHINACHU_HOME}/recorded"
start=`date +%s`

raw=$1
tmp=${1%.*}.tmp.mp4
out=${1%.*}.mp4
tune=$([ "$(echo $2 | jq -r '.category')" = 'anime' ] && echo 'animation' || echo 'film')
audio_map=`${FFMPEG_HOME}/ffmpeg -i "$1" 2>&1 | grep 'Audio' | grep -o -e 0:[0-9] | sed -e 's/0:/-map 0:/'`
${FFMPEG_HOME}/ffmpeg -v 24 -y -i "$raw" \
-s 1280x720 \
-c:v libx264 \
-preset veryfast \
-tune $tune \
-vf yadif \
-c:a aac \
-map 0:0 $audio_map \
"$tmp"

mkdir -p $DUMP_SITE
mv "$tmp" "$out"
mv "$out" $DUMP_SITE

end=`date +%s`
echo "----- finished encoding @`date +%Y/%m/%d/%H:%M:%S`, about $((($end - $start) / 60)) min. -----"
echo