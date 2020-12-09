chmod +x ./scrape_news.sh
#!/bin/bash
#access source code on ynetnews and print it in an external file 
wget -O output.txt -q https://www.ynetnews.com/category/3082
#find wanted different links and put them in a file ready for access
grep -o -P 'https://www.ynetnews.com/article/\w{9}\"' output.txt|uniq >tmp.txt
grep -o -P 'https://www.ynetnews.com/article/\w{9}\#' output.txt|uniq >>tmp.txt
sed 's/[" #]//' tmp.txt > links.txt
#overwrite and update the results file with number of links to be analyzed
links_num=$(ls -l | grep -c 'http' links.txt)
echo $links_num > results.csv
#go over every link in the links file
for (( i=1; i<=$links_num; i++ )); do
	link=$(ls -l | sed -n $i\p links.txt)
	wget -q -O link_content.txt $link
	net_num=0
	gan_num=0
	#count the repitions of each name
	net_num=$(ls -l | grep -c 'Netanyahu' link_content.txt)
	gan_num=$(ls -l | grep -c 'Gantz' link_content.txt)
	#print results only if at least one of the names appear in the article
	if [[ ($net_num -gt 0) || ($gan_num -gt 0) ]]; then
		echo "$link, Netanyahu, $net_num, Gantz, $gan_num" >> results.csv
	else
		echo "$link, -" >> results.csv
	fi
done
#remove extra unwanted files produced on the way
rm links.txt
rm output.txt
rm tmp.txt
rm link_content.txt
