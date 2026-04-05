#!/bin/bash
## FYI: Bash is the default Shell in Ubuntu

# v0.1 - init
# v0.2 - The convert command is deprecated in IMv7, use "magick" instead

# split-wallpaper-multiple-monitors.sh
## Split a wallpaper for multiple monitors on GNU/Linux

# to use me: 
## launch the script and give the directory where all the wallpapers to split are located. 
## eg.: bash ~/github/scripts/split-wallpaper-multiple-monitors.sh ./DIRECTORY
##   folder-01
##   +-> file-11.jpg
##   +-> file-12.jpg
##   +-> file-13.png

folderToScan="" # init 

if [ $# = 1 ]; then
	# echo "Found parameter: ""$1"
	if [ -d "$1" ] 
	then
		# echo "Directory $1 exists." 
		folderToScan="$1"
	else
		echo "split-wallpaper-multiple-monitors: The directory $1 does not exists"
		echo "Usage: split-wallpaper-multiple-monitors.sh DIRECTORY"
		echo " DIRECTORY can be a relative path or absolute path"
		echo ""
		echo " Example: $ ./split-wallpaper-multiple-monitors.sh ~/Pictures/wallpaper-3840x1080/"
		exit -2 # die with error code -2
	fi
else
	# echo "split-wallpaper-multiple-monitors: missing parameter"
	echo "Usage: split-wallpaper-multiple-monitors.sh DIRECTORY"
	echo " DIRECTORY can be a relative path or absolute path"
	echo ""
	echo " Example: $ ./split-wallpaper-multiple-monitors.sh ~/Pictures/wallpaper-3840x1080/"
	exit -1 # die with error code -1
fi

echo "Scanning wallpaper folder: ""$folderToScan"

for f in "$folderToScan"/*; do
	if [[ -f "$f" && ! -d "$f" ]]; then # I want a file that exists not a folder
		echo "" # && echo "file exists."
		echo " Splitting the file: ""$f"	# full filename with path
		DIR=$(dirname "$f")
		filename=$(basename -- "$f") # remove folder path
		extension="${filename##*.}" # get only extension
		filenameNoExt="${filename%.*}" # get filename without extension
		# echo "  $ magick ""$DIR""/""$filename"" -crop 50%x100% +repage ""$DIR""/""$filenameNoExt""_%d.""$extension"
		magick "$DIR"/"$filename" -crop 50%x100% +repage "$DIR"/"$filenameNoExt"_%d."$extension"
	else 
		echo ""
		echo -e "\e[0;33m"" Warning: ""\e[0m""$f"" is not a file." # Warning in Brown
	fi
done
exit 0
