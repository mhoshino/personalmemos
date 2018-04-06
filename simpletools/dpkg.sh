#!/bin/bash

for dpkg in dpkg_V_all dpkg_l_all
do
   ls ${dpkg} > horizontal.txt
   :> vertical_tmp.txt
   
   cat horizontal.txt | while read server
   do
           
           if [[ $dpkg == "dpkg_l_all" ]]
           then
             sed "1,/+++-=============/d" ${dpkg}/$server | awk '{print $2}' >> vertical_tmp.txt
           else
             sed "1d" ${dpkg}/$server | awk '{print $3}' >> vertical_tmp.txt
           fi
   done
   sort vertical_tmp.txt | uniq > vertical.txt
   
   # create first line
   perl -pe 's/^/,/g'  horizontal.txt | perl -pe 's/\n//g' | perl -pe 's/$/\n/g' > ${dpkg}.csv
   
   while read pkg
   do
   	line=$pkg
           found=0
           server_tmp=""
           installed_tmp=""
           while read server
           do
                   if [[ $dpkg == "dpkg_l_all" ]]
                   then
                       installed=`awk '$2=="'"$pkg"'"{print($1"_"$3"_"$4)}' ${dpkg}/$server`
                       if [[ -n ${installed} ]]
                       then
                          ((found=found+1))
                          if [[ -n ${server_tmp} ]]
                          then
                             if [[ ${installed_tmp} != ${installed} ]]
                             then
                                echo "$server has different $pkg version ($installed) installed compared to $server_tmp ($installed_tmp)" >>${dpkg}_diff.txt
                             fi
                          else
                             server_tmp=$server
                             installed_tmp=$installed
                          fi
                       fi 
                   else
                       installed=`awk '$3=="'"$pkg"'"{print}' ${dpkg}/$server`
                   fi
           	line="$line,$installed"
           
           done < horizontal.txt
           if [[ $found -eq 1 ]]
           then
                 echo "$server_tmp is the only server to have $pkg $installed_tmp installed" >>${dpkg}_diff.txt
           fi
           echo $line >> ${dpkg}.csv
   done < vertical.txt
done
