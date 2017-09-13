#!/bin/sh

# Script to generate crude HTML pages as proof of concept
# Uses awscli utility to get the list of (yesterday's) images from S3
# Replace [BUCKET] with your S3 bucket name

cd /usr/share/nginx/html

# If date passed as an argument, e.g. 2017-09-12, use it, or set it to YESTERDAY
if [ $# -eq 0 ]
  then
    DATE=`date -d "yesterday 13:00" '+%Y-%m-%d'`
  else
    DATE=$1
fi

#Get the listing of images from S3 for that date
aws s3 ls s3://[BUCKET]/images/$DATE/jpg/ --no-paginate | tr -s ' ' | cut -d ' ' -f4 > images-$DATE.txt

# count the number of images
images=`wc -l images-$DATE.txt | cut -f1 -d' '`

#decide how many pages of 6 thumbs to create
pages_images=$(expr `wc -l images-$DATE.txt | cut -f1 -d' '` / 6)

# Need to add one more page if there is a division remainder
if [ "$(expr `wc -l images-$DATE.txt | cut -f1 -d' '` % 6)" -ne "0" ]; then
        pages_images=$(expr $pages_images + 1)
fi

#start the $DATE.html page
echo '<html><body>' > pages/$DATE.html

# keep track of the current image in the listing
image_pos=1

# start outer loop for each subpage
i=1
while [ $i -le $pages_images ]; do

        # start the subpage
        outfile=pages/$DATE-$i.html
        echo '<html><body><div style="text-align:center;float:left">Camera snaps for '$DATE' - page '$i' out of '$pages_images'<br>'>$outfile

        # start another counter and exit inner loop when it reaches 6 or the end of images
        j=0
        listofpics=''
        while read pic; do
                let j+=1
                if [ $j -lt $image_pos ]; then
                        continue
                fi
                if [ $j -ge $(($image_pos + 6)) ] || [ $j -gt $images ]; then
                        break
                fi
                
                echo '<a href="'../s3images/images/$DATE/jpg/$pic'"'' target="_blank"''><img src="'../s3images/resize/462x260/images/$DATE/jpg/$pic'" width="462" height="260"border="1" style="padding-top:2px;padding-bottom:2px;padding-left:2px;padding-right:2px;margin-top:5px;margin-bottom:5px;margin-left:5px;margin-right:5px;"></a>'

                listofpics="$listofpics $pic"
        done <<< "$(cat images-$DATE.txt)" >>$outfile

        # advance the current image position by 6 and close the subpage
        let image_pos+=6
        echo '</div></body></html>'>>$outfile

        #add the link for this new page to the index file for the date
        # include the list of images on that subpage (listofpics): 20170912-1.html: pic1, pic2
        echo '<a href="'$DATE-$i.html'">'$DATE-$i.html'</a>: '$listofpics'<br>' >> pages/$DATE.html

        # increment page counter and return to create another subpage
        let i+=1
done

#close the $DATE.html page
echo '</body></html>' >> pages/$DATE.html

# add the link for the date page to the index.html for the site
sed -i '$ d' index.html
echo '<a href="pages/'$DATE.html'">'$DATE.html'</a><br>' >> index.html
echo '</body></html>' >> index.html
