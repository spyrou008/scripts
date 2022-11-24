#!/bin/bash
## FYI: Bash is the default Shell in Ubuntu

# v0.1 - init
# v0.2 - fix copy bug - an incomplete copy shall prevent the deletion of the original folder

# car-music-ordered.sh
# Script made for the Citroen C4 to oreder the music properly
# when a folder gets copied in the USB drive for the Citroen, the car re-shuffle the music files (mp3)
# in fact they are ordered by the inode number. 
# the inode number is a unique id given to any file to store its metadata. 
# the inode number can be seen using the command: `ls -i *` or `ls -i file.mp3`
# the purpose of this script is to fix the inode number for these file, 
#  by making a copy of them , in a new folder , one by one, in the right order. 
# It is important to have a new folder name , as the same old folder name + same old filename will not work. even if they are copied. 
#  this may be due to internal cache of the USB content. 
# the script will do :
#   mkdir '<OLD FOLDER><NEW SUFFIX>'
#   cp './<OLD FOLDER>/file1.mp3' './<OLD FOLDER><NEW SUFFIX>/file1.mp3'
#   rm '<OLD FOLDER>'

# To make this execuatable
## chmod +x ./car-music-ordered.sh 

# to use me: 
## launch the script to the lowest folder of the USB which contains albums. 
## i.e. only one folder level , before hitting the music files
## eg.: car-music-ordered.sh ./DIRECTORY
##   folder-01
##   +-> folder-11
##       +-> 01-file.mp3
##       +-> 02-file.mp3
##       +-> 03-file.mp3
##   +-> folder-12
##       +-> 01-file.mp3
##       +-> 02-file.mp3
##       +-> 03-file.mp3
##   +-> folder-13
##       +-> folder-130

folderToScan="" # init 
NewSuffix=" ORDERED" # Suffix for the new folder to be created and contain the files. 
deleteOLD="YES" # The value "YES" to delete the old folder . anything else will keep the old folder.

if [ $# = 1 ]; then
	# echo "Found parameter: ""$1"
	if [ -d "$1" ] 
	then
		# echo "Directory $1 exists." 
		folderToScan="$1"
	else
		echo "car-music-ordered: The directory $1 does not exists"
		echo "Usage: car-music-ordered.sh DIRECTORY"
		echo " DIRECTORY can be a relative path or absolute path"
		echo ""
		echo " Example: $ ./car-music-ordered.sh ./music/albums"
		exit -2 # die with error code -2
	fi
else
	# echo "car-music-ordered: missing parameter"
	echo "Usage: car-music-ordered.sh DIRECTORY"
	echo " DIRECTORY can be a relative path or absolute path"
	echo ""
	echo " Example: $ ./car-music-ordered.sh ./music/albums"
	exit -1 # die with error code -1
fi

echo " 1. Manage music folder: ""$folderToScan"

for f in "$folderToScan"/*; do
	if [[ -d "$f" && ! -L "$f" ]]; then # exclude files and symlinks
        # $f is a directory
		## counting the folders in $f. Subs is already one , so it will be greater than 1 always
		nbSubsFolder=$(find "$f"/ -maxdepth 1 -type d -print| wc -l)
		# echo "    Directory ""$f"" has ""$nbSubsFolder"" folder."
		if [ "x""$nbSubsFolder""x" = "x1x" ]; then
		# No sub folder in $f : Continue
			# check if the folder is emtpy or not
			if [ "$(ls -A "$f")" ] ; then
				# check if the folder already contains the suffix or NOT. 
				orderedCheck=$(echo "$f" | grep "$NewSuffix" | wc -l)
				# echo "    Directory ""$f"" has ""$orderedCheck"" ordered."
				if [ "x""$orderedCheck""x" = "x0x" ]; then # to do
					echo ""
					echo "Enter ""$f"
					# test if the New folder already exists:
					if [[ -d "$f""$NewSuffix" ]]; then # it already exist ? let's skip
						echo "  INFO: Skipping '$f' as there is a folder with the '$NewSuffix' suffix."
					else
						echo "  Create the suffix and copy the files into: ""$f""$NewSuffix"
						mkdir "$f""$NewSuffix"
						# init $cpCheck variable to fix copy bug - an incomplete copy shall prevent the deletion of the original folder
						cpCheck=/tmp/$$.nbCpErr.tmp
						echo 0 > $cpCheck
						ls "$f" | sort | while read musicFileWithRelPath
						do
							echo "    Copy $musicFileWithRelPath"
							cp "$f"/"$musicFileWithRelPath" "$f""$NewSuffix"/"$musicFileWithRelPath"
							if [ $? -ne 0 ] ; then
								CountErr=$[$(cat $cpCheck) + 1]
								echo $CountErr > $cpCheck
								echo -e "\e[0;31m" "  ERROR num ""$CountErr"" while copy of the file: ""$musicFileWithRelPath" "\e[0m" # Error in red
							fi
						done
						echo ""
						ls -1 -i "$f""$NewSuffix"
						CountErr=$(cat $cpCheck)
						if [ "x""$CountErr""x" = "x0x" ]; then # all the files have been correctly copied
							if [ "$deleteOLD" = "YES" ]; then # delete old folder ? Yes
								echo -e "\e[0;31m" "  ╚══>  Deleting OLD folder: ""$f" "\e[0m" # Message in red
								rm -rf "$f"
							else # Keeping OLD folder:
								echo -e "\e[0;31m" "  ╚══>  Keeping OLD folder: ""$f" "\e[0m" # Message in red
							fi
						else # at least one error in the copy of the files
							echo -e "\e[0;31m" "  ╚══>  Keeping OLD folder, due to ""$CountErr"" CP error(s): ""$f" "\e[0m" # Message in red
						fi
					fi
				else # folder already ordered , as it contains the suffix
					echo ""
					echo "INFO: Skipping '$f' as it has the suffix '$NewSuffix'."
				fi
			else # empty folder
				echo ""
				echo "INFO: Skipping '$f' as it is empty."
			fi
		else # if the directory $f has at least one folder: No
			echo ""
			echo "INFO: Skipping '$f' as it has sub folder(s)."
		fi
	else # if $f is not a directory
		echo ""
		echo "INFO: Skipping '$f' as it is not a folder."
	fi
done

exit 0
