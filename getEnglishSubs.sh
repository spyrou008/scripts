#!/bin/bash

# v0.1 - init
# v0.2 - printf work in progress + mkv fix + NAS commands fix
# v1.0 - First version ready for Production 

# getEnglishSubs.sh
# Script pour trouver les soustitres English de plusiseurs videos.  
# Le script doit se situer (et etre lancer) dans le repertoire PARENT a la video. c est a dire juste avant, pour qu'il scanne toutes les videos a trouver. 
# Arborescence:
# 	+ script
# 	+ FOLDER_1
# 		+ FOLDER_Subs
# 			+ 2_English.srt
# 		+ video.mp4
# 	+ FOLDER_2
# 		+ FOLDER_Subs
# 			+ FOLDER_Subs1
# 				+ 2_English.srt
# 				+ 3_English.srt
# 			+ FOLDER_Subs2
# 				+ 2_English.srt
# 				+ 3_English.srt
# 		+ video1.mp4
# 		+ video2.mp4
# 		+ other_files
# Usage: $ ./getEnglishSubs.sh DIRECTORY



# ## Prepa
# cd ./Downloads/sub_script/
# cp -r ./template ./testfolder

# ## find Video files
# [NAS_OK] find by extension regardless of the case:
# find testfolder -type f | grep -iE "\.webm$|\.flv$|\.vob$|\.ogg$|\.ogv$|\.drc$|\.gifv$|\.mng$|\.avi$|\.mov$|\.qt$|\.wmv$|\.yuv$|\.rm$|\.rmvb$|/.asf$|\.amv$|\.mp4$|\.m4v$|\.mp*$|\.m?v$|\.svi$|\.3gp$|\.flv$|\.f4v$"

# !NAS_NOK! find . -type f -exec file -N -i -- {} +
# !NAS_NOK! find . -type f -exec file -N -i -- {} + | grep video
# ./original true/The.Real.Housewives.of.Beverly.Hills.S11E03.WEBRip.x264-ION10/The.Real.Housewives.of.Beverly.Hills.S11E03.WEBRip.x264-ION10.mp4: video/mp4; charset=binary

# !NAS_NOK! only filenames:
# !NAS_NOK! find . -type f -exec file -N -i -- {} + | sed -n 's!: video/[^:]*$!!p'
# ./original true/The.Real.Housewives.of.Beverly.Hills.S11E03.WEBRip.x264-ION10/The.Real.Housewives.of.Beverly.Hills.S11E03.WEBRip.x264-ION10.mp4


# ## find the new filename of the SRT file (hardcoded)
# [NAS_OK] find testfolder -type f | grep -iE "\.webm$|\.flv$|\.vob$|\.ogg$|\.ogv$|\.drc$|\.gifv$|\.mng$|\.avi$|\.mov$|\.qt$|\.wmv$|\.yuv$|\.rm$|\.rmvb$|/.asf$|\.amv$|\.mp4$|\.m4v$|\.mp*$|\.m?v$|\.svi$|\.3gp$|\.flv$|\.f4v$" | grep Love | head -1 | sed 's/\.mp4/\.srt/g'


# ## find sub titles files
# find by extension regardless of the case:
# [NAS_OK] find testfolder -type f | grep -iE "\.srt$|\.srt$" | grep -iE "eng"


# ## find sub titles files : the biggest English
# !NAS_NOK! find testfolder/The.Real.Housewives.of.Beverly.Hills.S11E03.WEBRip.x264-ION10 -type f -printf "%s\t%p\n" | sort -n | grep -iE "\.srt$|\.srt$" | grep -iE "eng" | tail -1
# [NAS_OK]  du -ab ./Subs/Dr.Death.S01E08.WEBRip.x264-ION10/ | sort -n -r | grep -iE "\.srt$|\.srt$" | grep -iE "eng" | tail -1



# ## Move the biggest file !!! WIP !!!
# find testfolder/The.Real.Housewives.of.Beverly.Hills.S11E03.WEBRip.x264-ION10 -type f -printf "%s\t%p\n" | sort -n | grep -iE "\.srt$|\.srt$" | grep -iE "eng" | tail -1 | xargs bash -c 'echo $1'


# ## rename the srt into the right name:
# mv testfolder/Love.Death.and.Robots/rename_me.srt 

# for file in *.srt
# do
#  mv "${file}" "`echo $file | sed 's/mp4\./srt./'`"
# done


# ## Loop - Example. get all the files .ext1 and rename them into *.ext2
# find . -name "*.ext1" -print0 | while read -d $'\0' file
# do
#    mv $file "${file%.*}.ext2"
# done


## Commandes DANGEUREUSES : 
# rm
# rmdir
# mv


# echo "Start of: getEnglishSubs"
# .
# bla	<- Error
# ./
# ./test\ folder/
# ./test\ folder/No Subtitle here/
# ./test\ folder/No Subtitle here
# test\ folder/
# test\ folder/No Subtitle here/
# test\ folder/No Subtitle here
# "test folder"/
# "test folder/No Subtitle here"/
# "test folder/No Subtitle here"
# test\ folder/No\ Subtitle\ here/
# test\ folder/No\ Subtitle\ here
# /home/chris/Downloads/sub_script/test folder/
# /home/chris/Downloads/sub_script/test folder/No Subtitle here/
# /home/chris/Downloads/sub_script/test folder/No Subtitle here
#
# launch from different folder as script
# launch from same folder as script


folderToScan=""
folderCurrent=$(pwd)

if [ $# = 1 ]; then
	# echo "Found parameter: ""$1"
	# echo "Current folder : ""$folderCurrent"
	if [ -d "$1" ] 
	then
		# echo "Directory $1 exists." 
		folderToScan="$1"
	else
		echo "getEnglishSubs: The directory $1 does not exists"
		echo "Usage: getEnglishSubs.sh DIRECTORY"
		echo " DIRECTORY can be a relative path or absolute path"
		exit -2 # die with error code -2
	fi
else
	# echo "getEnglishSubs: missing parameter"
	echo "Usage: getEnglishSubs.sh DIRECTORY"
	echo " DIRECTORY can be a relative path or absolute path"
	echo ""
	echo " Example: $ /share/CACHEDEV1_DATA/Download/out/getEnglishSubs.sh /share/CACHEDEV1_DATA/Download/out/test me"
	exit -1 # die with error code -1
fi

echo " 1. Search for Video files in: ""$folderToScan"



### tmpNbTotalWarning : Nb of warning in total to raise awareness
tmpNbTotalWarning=/tmp/$$.nbTW.tmp
echo 0 > $tmpNbTotalWarning

find "$folderToScan" -type f | grep -iE "\.webm$|\.flv$|\.mkv$|\.vob$|\.ogg$|\.ogv$|\.drc$|\.gifv$|\.mng$|\.avi$|\.mov$|\.qt$|\.wmv$|\.yuv$|\.rm$|\.rmvb$|/.asf$|\.amv$|\.mp4$|\.m4v$|\.mp*$|\.m?v$|\.svi$|\.3gp$|\.flv$|\.f4v$" | while read videoFileWithRelPath
do
	## Video file
	echo ""
	echo "    Next video file:"
	echo "     ""$videoFileWithRelPath"
	## folder
	videoFileRelPath=$(dirname "$videoFileWithRelPath")


	## DELETE if present : RARBG_DO_NOT_MIRROR.exe
	fileToDelete="$videoFileRelPath""/RARBG_DO_NOT_MIRROR.exe"
	if [ -e "$fileToDelete" ]; then
		echo "    + Bonus: Delete the file with: rm ""$fileToDelete"
		rm "$fileToDelete"
	fi
	## DELETE if present : RARBG.txt
	fileToDelete="$videoFileRelPath""/RARBG.txt"
	if [ -e "$fileToDelete" ]; then
		echo "    + Bonus: Delete the file with: rm ""$fileToDelete"
		rm "$fileToDelete"
	fi
	## DELETE if present : WWW.YIFY-TORRENTS.COM.jpg
	fileToDelete="$videoFileRelPath""/WWW.YIFY-TORRENTS.COM.jpg"
	if [ -e "$fileToDelete" ]; then
		echo "    + Bonus: Delete the file with: rm ""$fileToDelete"
		rm "$fileToDelete"
	fi
	## DELETE if present : WWW.YTS.RE.jpg
	fileToDelete="$videoFileRelPath""/WWW.YTS.RE.jpg"
	if [ -e "$fileToDelete" ]; then
		echo "    + Bonus: Delete the file with: rm ""$fileToDelete"
		rm "$fileToDelete"
	fi
	## DELETE if present : www.YTS.AM.jpg
	fileToDelete="$videoFileRelPath""/www.YTS.AM.jpg"
	if [ -e "$fileToDelete" ]; then
		echo "    + Bonus: Delete the file with: rm ""$fileToDelete"
		rm "$fileToDelete"
	fi
	## DELETE if present : Torrent Downloaded From ExtraTorrent.cc.txt
	fileToDelete="$videoFileRelPath""/Torrent Downloaded From ExtraTorrent.cc.txt"
	if [ -e "$fileToDelete" ]; then
		echo "    + Bonus: Delete the file with: rm ""$fileToDelete"
		rm "$fileToDelete"
	fi
	## DELETE if present :  sample.avi
	fileToDelete="$videoFileRelPath""/sample.avi"
	if [ -e "$fileToDelete" ]; then
		echo "    + Bonus: Delete the file with: rm ""$fileToDelete"
		echo "!"
		echo "!!! !!! !!! WARNING: Deleting the file: ""$fileToDelete"
		echo "!"
		rm "$fileToDelete"
		COUNTERTW=$[$(cat $tmpNbTotalWarning) + 1]
		echo $COUNTERTW > $tmpNbTotalWarning
	fi


	videoFileName=$(basename -- "$videoFileWithRelPath")
	# echo "t1. ""$videoFileName"
	videoFileExtension0="${videoFileName##*.}"
	# echo "t2. ""$videoFileExtension0"
	videoFileExtension=$(basename -- "${videoFileWithRelPath##*.}")
	# echo "t2. ""$videoFileExtension"
	videoFileNameNoExtension0="${videoFileName%.*}"
	# echo "t3. ""$videoFileNameNoExtension0"
	videoFileNameNoExtension=$(basename -- "${videoFileWithRelPath%.*}")
	# echo "t3. ""$videoFileNameNoExtension"
	dummySrtFileName0="${videoFileName%.*}.srt"
	# echo "t4. ""$dummySrtFileName0"
	dummySrtFileName=$(basename -- "${videoFileWithRelPath%.*}.srt")
	# echo "t4. ""$dummySrtFileName"
	videoFileWithRelPathNoExtension="${videoFileWithRelPath%.*}"
	# echo "t5. ""$videoFileWithRelPathNoExtension"
	dummySrtFileWithRelPath="${videoFileWithRelPath%.*}.srt"
	# echo "t6. ""$dummySrtFileWithRelPath"
	# echo "    Does dummy srt file exist ?"



	if [ -s "$dummySrtFileWithRelPath" ]; then
		echo "    To SKIP because SRT already present"
	else
		# echo "    Continue because no SRT present by default"
		# echo " 2. find Subtitles files in :""$videoFileRelPath"
		# echo "    ""$videoFileRelPath"
		## let's count the number of subtitle found : 0 or 1 ?
		## le fichier portera le nom du PID du batch. Example: /tmp/123465.tmp
		tmpNbSrtFound=/tmp/$$.tmp
		echo 0 > $tmpNbSrtFound

		if [ "$(dirname "$videoFileRelPath")" = "$(dirname "$folderToScan")" ]; then
			echo "!"
			echo "!!! !!! !!! WARNING: The video file is in the Search Folder: ""$videoFileRelPath"
			echo "!"
			COUNTERTW=$[$(cat $tmpNbTotalWarning) + 1]
			echo $COUNTERTW > $tmpNbTotalWarning
		fi
		
		# tmpNbWarningFoundVideo: Count nb warning for this video file , to avoid looking for subtitles if the Method 3 has been triggered
		tmpNbWarningFoundVideo=/tmp/$$.nbWV.tmp
		echo 0 > $tmpNbWarningFoundVideo

		if [ -d "$videoFileRelPath""/Subs" ]; then
			# echo "    Directory ""$videoFileRelPath""/Subs exists."
			## counting the folders in Subs. Subs is already one , so it will be greater than 1 always
			nbSubsFolder=$(find "$videoFileRelPath"/Subs -maxdepth 1 -type d -print| wc -l)
			# echo "    Directory ""$videoFileRelPath""/Subs has ""$nbSubsFolder"" folder."
			if [ "x""$nbSubsFolder""x" = "x1x" ]; then

				## Method for a potential subtitle per main Sub folder
				# echo "    -> Method 1"
				du -ab "$videoFileRelPath""/Subs" | sort -n | grep -iE "\.srt$|\.srt$" | grep -iE "eng" | tail -1 | while read subtFileWithRelPath
				do
					## Biggest SRT file found in this SUB folder without other folders
					# echo "    -> ""$subtFileWithRelPath"
					COUNTER=$[$(cat $tmpNbSrtFound) + 1]
					echo $COUNTER > $tmpNbSrtFound

					tmpStrSrtFound=/tmp/$$.string.tmp
					echo "$subtFileWithRelPath" > $tmpStrSrtFound
					subtFileWithRelPath2=$(cut -f 2 "$tmpStrSrtFound")
					# echo "    -> ""$subtFileWithRelPath2"
					rm $tmpStrSrtFound

					echo "    mv ""$subtFileWithRelPath2"" ""$dummySrtFileWithRelPath"
					mv "$subtFileWithRelPath2" "$dummySrtFileWithRelPath"
					### NE PAS supprimer le repertoire Subs , car un autre fichier video pourrait en avoir besoin plus tard!
					### echo " 4. rmdir ""$videoFileRelPath""/Subs"
					### rmdir "$videoFileRelPath""/Subs"

				done

			else
				## Method for multiple subtitle folderS per SUBS folder
				if [ -d "$videoFileRelPath""/Subs/""$videoFileNameNoExtension" ]; then
					# echo "     Info: Found a specific folder for that video file in Subs"
					# echo "    -> Method 2"
					du -ab "$videoFileRelPath""/Subs/""$videoFileNameNoExtension" | sort -n | grep -iE "\.srt$|\.srt$" | grep -iE "eng" | tail -1 | while read subtFileWithRelPath
					do
						## Biggest SRT file found in this SUB folder without other folders
						# echo "    -> ""$subtFileWithRelPath"
						COUNTER=$[$(cat $tmpNbSrtFound) + 1]
						echo $COUNTER > $tmpNbSrtFound
						tmpStrSrtFound=/tmp/$$.string.tmp
						echo "$subtFileWithRelPath" > $tmpStrSrtFound
						subtFileWithRelPath2=$(cut -f 2 "$tmpStrSrtFound")
						# echo "    -> ""$subtFileWithRelPath2"
						rm $tmpStrSrtFound
						echo "    mv ""$subtFileWithRelPath2"" ""$dummySrtFileWithRelPath"
						mv "$subtFileWithRelPath2" "$dummySrtFileWithRelPath"
						### NE PAS supprimer le repertoire Subs , car un autre fichier video pourrait en avoir besoin plus tard!
						### echo " 4. rmdir ""$videoFileRelPath""/Subs"
						### rmdir "$videoFileRelPath""/Subs"

					done
				else
					# echo "    -> Method 3 ???"
					### ICI, plusieurs repertoires dans le dossier "Subs". Par contre , je ne trouve pas de repertoire associe a mon fichier video
					echo "!"
					echo "!!! !!! !!! WARNING: I DO NOT KNOW WHAT TO DO HERE ! also a wrong file could be moved below !!! !!! !!! "
					echo "!"
					COUNTERWV=$[$(cat $tmpNbWarningFoundVideo) + 1]
					echo $COUNTERWV > $tmpNbWarningFoundVideo
					COUNTERTW=$[$(cat $tmpNbTotalWarning) + 1]
					echo $COUNTERTW > $tmpNbTotalWarning
				fi

			fi
		else
			# echo "    Info: Directory ""$videoFileRelPath""/Subs does not exists."
			
			## Method for one subtitle per main folder
			# echo "    -> Method 1b"
			du -ab "$videoFileRelPath" | sort -n | grep -iE "\.srt$|\.srt$" | grep -iE "eng" | tail -1 | while read subtFileWithRelPath
			do
				## Biggest SRT file found in this SUB folder without other folders
				# echo "    -> ""$subtFileWithRelPath"
				COUNTER=$[$(cat $tmpNbSrtFound) + 1]
				echo $COUNTER > $tmpNbSrtFound
				tmpStrSrtFound=/tmp/$$.string.tmp
				echo "$subtFileWithRelPath" > $tmpStrSrtFound
				subtFileWithRelPath2=$(cut -f 2 "$tmpStrSrtFound")
				# echo "    -> ""$subtFileWithRelPath2"
				rm $tmpStrSrtFound
				echo "!   mv ""$subtFileWithRelPath2"" ""$dummySrtFileWithRelPath"
				mv "$subtFileWithRelPath2" "$dummySrtFileWithRelPath"
			done
		fi
		# echo "     Found $[$(cat $tmpNbSrtFound)] subtitle"
		

		if [ "x""$[$(cat $tmpNbWarningFoundVideo)]""x" != "x0x" ]; then
			# echo "     Found $[$(cat $tmpNbWarningFoundVideo)] Warning from method 3 for this Video"
			# Do nothing here
			:
		else
			### If no method 3 warning , then let's try something crazy
			if [ "x""$[$(cat $tmpNbSrtFound)]""x" = "x0x" ]; then
				# echo "      Test de derniere chance, pas de filtre sur ENG dans le nom du srt:"
				# echo "    -> Method 1c"
				du -ab "$videoFileRelPath" | sort -n | grep -iE "\.srt$|\.srt$" | tail -1 | while read subtFileWithRelPath
				do
					## Biggest SRT file found in this SUB folder without other folders
					# echo "    -> ""$subtFileWithRelPath"
					COUNTER=$[$(cat $tmpNbSrtFound) + 1]
					echo $COUNTER > $tmpNbSrtFound
					tmpStrSrtFound=/tmp/$$.string.tmp
					echo "$subtFileWithRelPath" > $tmpStrSrtFound
					subtFileWithRelPath2=$(cut -f 2 "$tmpStrSrtFound")
					# echo "    -> ""$subtFileWithRelPath2"
					rm $tmpStrSrtFound
					echo "!!  mv ""$subtFileWithRelPath2"" ""$dummySrtFileWithRelPath"
					mv "$subtFileWithRelPath2" "$dummySrtFileWithRelPath"
				done
			fi


		fi
		rm $tmpNbWarningFoundVideo


		echo "     Found $[$(cat $tmpNbSrtFound)] subtitle"
		rm $tmpNbSrtFound
	fi
	echo
done

if [ "x""$[$(cat $tmpNbTotalWarning)]""x" != "x0x" ]; then
	echo "!"
	echo "!!!  Found $[$(cat $tmpNbTotalWarning)] Warning(s) in total"
	echo "!"
	echo "and Check the mv commands"
else
	echo "Success: No warning. But Check the !! mv commands "
fi
rm $tmpNbTotalWarning

# echo "End   of: getEnglishSubs"







