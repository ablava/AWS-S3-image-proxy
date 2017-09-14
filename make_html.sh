#!/bin/sh

# Script to generate crude HTML pages in "pages/" as proof of concept
# Uses awscli utility to get the list of (yesterday's) images from S3
# Replace [BUCKET] with your S3 bucket name

# Define how many thumbs to show per page and the size
imgsperpage=6
width=462
hight=260

cd /usr/share/nginx/html

# If date passed as an argument, e.g. 2017-09-12, use it, or set it to YESTERDAY
if [ $# -eq 0 ]
  then
    DATE=`date -d "yesterday 13:00" '+%Y-%m-%d'`
  else
    DATE=$1
fi

# Get the listing of images from S3 for that date
aws s3 ls s3://[BUCKET]/images/$DATE/jpg/ --no-paginate | tr -s ' ' | cut -d ' ' -f4 > images-$DATE.txt

# Count the number of images
images=`wc -l images-$DATE.txt | cut -f1 -d' '`

# Decide how many pages of 6 thumbs to create
pages=$(expr `wc -l images-$DATE.txt | cut -f1 -d' '` / $imgsperpage)

# Need to add one more page if there is a division remainder
if [ "$(expr `wc -l images-$DATE.txt | cut -f1 -d' '` % $imgsperpage)" -ne "0" ]; then
        pages=$(expr $pages + 1)
fi

# Start the $DATE.html page
echo '<html><body>' > pages/$DATE.html

# Keep track of the current image in the listing
image_pos=1

# Start outer loop for each subpage
i=1
while [ $i -le $pages ]; do

        # Start the subpage
        outfile=pages/$DATE-$i.html
        echo '<html><body><div style="text-align:center;float:left">Camera snaps for '$DATE' - page '$i' out of '$pages'<br>'>$outfile

        # Exit inner loop when it reaches 6 iterations or the end of image listing
        j=0
        listofpics=''
        while read pic; do
                let j+=1
                # Skip to next image until reaching the right one
                if [ $j -lt $image_pos ]; then
                        continue
                fi
                # Stop when on the 6th image or at the end of the listing
                if [ $j -ge $(($image_pos + $imgsperpage)) ] || [ $j -gt $images ]; then
                        break
                fi
                
                # Place the thumbnail on the subpage
                echo '<a href="'../s3images/images/$DATE/jpg/$pic'"'' target="_blank"''><img src="'../s3images/resize/$width'x'$hight/images/$DATE/jpg/$pic'" width="'$width'" height="'$hight'"border="1" style="padding-top:2px;padding-bottom:2px;padding-left:2px;padding-right:2px;margin-top:5px;margin-bottom:5px;margin-left:5px;margin-right:5px;"></a>'

                # Remember all the pictures on this subpage
                listofpics="$listofpics $pic"
        done <<< "$(cat images-$DATE.txt)" >>$outfile

        # Advance the current image position by 6 and close the subpage
        let image_pos+=$imgsperpage
        echo '</div></body></html>'>>$outfile

        # Add the link for this new subpage to the index file for the date,
        # include the list of thumbnails on that subpage (listofpics): 20170912-1.html: pic1, pic2
        echo '<a href="'$DATE-$i.html'">'$DATE-$i.html'</a>: '$listofpics'<br>' >> pages/$DATE.html

        # Increment page counter and return to create another subpage
        let i+=1
done

# Close the $DATE.html page when done with all images
echo '</body></html>' >> pages/$DATE.html

# Add the link for the date page to the index.html for the site
sed -i '$ d' index.html
echo '<a href="pages/'$DATE.html'">'$DATE.html'</a><br>' >> index.html
echo '</body></html>' >> index.html
