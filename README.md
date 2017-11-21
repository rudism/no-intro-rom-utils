Some scripts I used to do various things with no-intro rom sets:

- rename/retrieve box art for every game (named for ARC Browser)
  - uses [libretro-thumbnails](https://github.com/libretro/libretro-thumbnails) as a base, supplementing with thegamesdb.net api
- reduce to english-language only roms
- reduce multiple editions of roms down to one
  - prefer non-demo, non-prototype editions
  - prefer USA over foreign editions
  - prefer later revisions over earlier revisions

There's no documentation, so it's mainly here for informational purposes for anyone else looking to organize their own romsets via scripting.

Basic steps used:

1. `checkart.pl` to check existence of box art for the roms and retrieve box art if there is none
2. `sortroms.pl` to move undesirable roms into an ignore directory
3. `renamer.pl` to rename box art and screen shots based on ARC Browser naming conventions
4. `elimdupes.pl` to filter multiple editions of roms down to the most desirable single rom
5. `fiximages.sh` to reduce size of large cover art and run optipng on all images
