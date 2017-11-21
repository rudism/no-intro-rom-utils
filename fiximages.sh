#!/bin/sh

for b in final/*_box.png; do
  convert "$b" -resize 500x500\> "$b"
done
optipng -fix final/*.png
