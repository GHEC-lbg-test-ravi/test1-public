############################################################################      
#  Author        : Saranya K                                               #
#  Description   : The script will check the Metadata(no.of columns) in    #
#                  header,trailer,detail records of the file arrived       # 
#                 and creates exception when fails in metadata validation  #
############################################################################
#!/usr/bin/sh
# Check the count of arguments for the script.
if [ $# -ne '5' ] ; then
    	echo "Insufficient Arguments"
        echo "Usage: <PROCESSING_DIR> <TEMP_DIR> <REJECT_DIR> <UNPROCESSED_DIR> <TOMAIL>"
        exit 1
fi

#Assigning variables.

PROCESSING_DIR=$1
TEMP_DIR=$2
REJECT_DIR=$3
UNPROCESSED_DIR=$4
TOMAIL=$5

#-------------------------------------------------------#
#  To Get the files from processing directory           #
#-------------------------------------------------------#

cd  $PROCESSING_DIR

NEWFILE=DETAIL_FILE.txt

ls AEH_* | cut -d "/" -f7 > ${TEMP_DIR}${NEWFILE}

FileCount=`cat $TEMP_DIR$NEWFILE | wc -l | sed 's/ //g'`

#echo "FILECOUNT=$FileCount"

if [[ $FileCount = '0' ]] ; then

	echo "No files to process"
	exit 1

else 

	file=`cat $TEMP_DIR$NEWFILE`

#--------------------------------------------------------------------------#
#  To check for the expected no. of columns in a file                      #
#--------------------------------------------------------------------------#

		for i in $file
		do
		CurrentFile=`echo $i`
		cont_date=`head -1 $CurrentFile | cut -d "," -f4`
 	#echo cont_date=$cont_date
 	date_len=`echo $cont_date | wc -c | sed 's/ //g'`
 	#echo date_len=$date_len
 	
	if [ $date_len -ne 1 ]; then
	INDIC_CONTRIB_DATE="$cont_date"
	else
	INDIC_CONTRIB_DATE='Indicative Contribution Date cannot be determined'
	fi
 		
			HEADER_COL_CNT=`awk 'NF!=9{print "1"}' FS="," "HEADER_"$CurrentFile`
					
			TRAILER_COL_CNT=`awk 'NF!=8{print "1"}' FS="," "TRAILER_"$CurrentFile`
									
			TEMPFILE=Metadata.txt
				
		        awk 'NF!=21{print "1"}' FS="," $CurrentFile > ${TEMP_DIR}${TEMPFILE}
				
			DETAIL_COL_CNT=`head -1 ${TEMP_DIR}${TEMPFILE}`
						
			touch ${TEMP_DIR}METADATA_REJ_FILE.txt
	
	                      EXCPNAME=`echo ${CurrentFile} | cut -d "." -f1`
								 						        
			      EXCPFILEEXT=`echo ${CurrentFile} | cut -d "." -f2`
								 		   
			      EXPNAME=${EXCPNAME}"."$EXCPFILEEXT"_TFRMEXCP.csv"
			      
			      FILE_DATE=`echo ${CurrentFile} | cut -d "_" -f5`	

#--------------------------------------------------------------------------#
#  To check for the expected no. of columns in header record in a file     #
#--------------------------------------------------------------------------#	

			if [[ $HEADER_COL_CNT = "1" ]]; then
			 
			echo "Missing Excepted no. of columns in Header record of $CurrentFile. Hence not processing"
			
#------------------------------------------------------#
#  To create exception file for header record          #
#------------------------------------------------------#
			
			HEADER_REC=`awk 'NF!=9{print $0}' FS="," "HEADER_$CurrentFile"`
				 
                     		   
				Record_Type=01
				EXCEPT_SERVICE=AEH
				EXCEPT_GEN_PLATFORM=TFRM
				EXCEPT_ORIG_SYSTEM=`echo ${CurrentFile} | cut -d "_" -f3`
				EXCEPTION_ENTITY=CONT
				EXCEPT_NUMBER=001
				EXCEPT_SEVERITY=E
				EXCEPTION_INPUT_REC_NO=NA
				EXCEPT_MESSAGE="Invalid Record format received for Header" 
				EXCEPT_OLD_KEY=NA
				EXCEPT_NEW_KEY=NA
				EXCEPT_DATA_VALUE='"'$HEADER_REC'"'
				EXCEPT_SOURCE_DATA_REF=NA
				EXCEPT_TARGET_DATA_REF=NA
				EXCEPT_JS_NAME=NA
				EXCEPT_JB_NAME=NA
				EXCEPT_FILE_DET=${CurrentFile}
				
		echo $Record_Type,$EXCEPT_SERVICE,$EXCEPT_GEN_PLATFORM,$EXCEPT_ORIG_SYSTEM,$EXCEPTION_ENTITY,$EXCEPT_NUMBER,$EXCEPT_SEVERITY,$EXCEPTION_INPUT_REC_NO,$EXCEPT_MESSAGE,$EXCEPT_OLD_KEY,$EXCEPT_NEW_KEY,$EXCEPT_DATA_VALUE,$EXCEPT_SOURCE_DATA_REF,$EXCEPT_TARGET_DATA_REF,$EXCEPT_JS_NAME,$EXCEPT_JB_NAME,$EXCEPT_FILE_DET > ${REJECT_DIR}Temp_rej_header.txt
		   				
			echo '00,'${EXPNAME}','$FILE_DATE',001' > ${REJECT_DIR}$EXPNAME
			cat ${REJECT_DIR}Temp_rej_header.txt >> ${REJECT_DIR}$EXPNAME
			echo '99,1' >> ${REJECT_DIR}$EXPNAME
				  
				   
			cat ${PROCESSING_DIR}HEADER_${CurrentFile} > ${UNPROCESSED_DIR}${CurrentFile}
			cat ${PROCESSING_DIR}${CurrentFile} >> ${UNPROCESSED_DIR}${CurrentFile} 
			cat ${PROCESSING_DIR}TRAILER_${CurrentFile} >> ${UNPROCESSED_DIR}${CurrentFile}
			
				   
			rm -f ${PROCESSING_DIR}HEADER_${CurrentFile} 
			rm -f ${PROCESSING_DIR}${CurrentFile} 
			rm -f ${PROCESSING_DIR}TRAILER_${CurrentFile}
			rm -f ${REJECT_DIR}Temp_rej_header.txt
				 							 
	 		echo ${CurrentFile} >> ${TEMP_DIR}METADATA_REJ_FILE.txt
	 		

#--------------------------------------------------------------------------#
#  To check for the expected no. of columns in trailer record in a file    #
#--------------------------------------------------------------------------#	 		
			
			elif [[ $TRAILER_COL_CNT = "1" ]]; then
						 
			echo "Missing Excepted no. of columns in Trailer record of $CurrentFile. Hence not processing"
			
#------------------------------------------------------#
#  To create exception file for trailer record         #
#------------------------------------------------------#
			
			TRAILER_REC=`awk 'NF!=8{print $0}' FS="," "TRAILER_$CurrentFile"`							 
					   
			        Record_Type=01
				EXCEPT_SERVICE=AEH
				EXCEPT_GEN_PLATFORM=TFRM
				EXCEPT_ORIG_SYSTEM=`echo ${CurrentFile} | cut -d "_" -f3`
				EXCEPTION_ENTITY=CONT
				EXCEPT_NUMBER=002
				EXCEPT_SEVERITY=E
				EXCEPTION_INPUT_REC_NO=NA
				EXCEPT_MESSAGE="Invalid Record format received for Trailer" 
				EXCEPT_OLD_KEY=NA
           			EXCEPT_NEW_KEY=NA
				EXCEPT_DATA_VALUE='"'$TRAILER_REC'"'
				EXCEPT_SOURCE_DATA_REF=NA
				EXCEPT_TARGET_DATA_REF=NA
				EXCEPT_JS_NAME=NA
				EXCEPT_JB_NAME=NA
				EXCEPT_FILE_DET=${CurrentFile}
			
            echo $Record_Type,$EXCEPT_SERVICE,$EXCEPT_GEN_PLATFORM,$EXCEPT_ORIG_SYSTEM,$EXCEPTION_ENTITY,$EXCEPT_NUMBER,$EXCEPT_SEVERITY,$EXCEPTION_INPUT_REC_NO,$EXCEPT_MESSAGE,$EXCEPT_OLD_KEY,$EXCEPT_NEW_KEY,$EXCEPT_DATA_VALUE,$EXCEPT_SOURCE_DATA_REF,$EXCEPT_TARGET_DATA_REF,$EXCEPT_JS_NAME,$EXCEPT_JB_NAME,$EXCEPT_FILE_DET > ${REJECT_DIR}Temp_rej_trailer.txt
					   								   				   		  
											   
				echo '00,'${EXPNAME}','$FILE_DATE',001' > ${REJECT_DIR}$EXPNAME
				cat ${REJECT_DIR}Temp_rej_trailer.txt >> ${REJECT_DIR}$EXPNAME
				echo '99,1' >> ${REJECT_DIR}$EXPNAME
											    
				cat ${PROCESSING_DIR}HEADER_${CurrentFile} > ${UNPROCESSED_DIR}${CurrentFile}
				cat ${PROCESSING_DIR}${CurrentFile} >> ${UNPROCESSED_DIR}${CurrentFile} 
				cat ${PROCESSING_DIR}TRAILER_${CurrentFile} >> ${UNPROCESSED_DIR}${CurrentFile}
			
							   
				rm -f ${PROCESSING_DIR}HEADER_${CurrentFile} 
				rm -f ${PROCESSING_DIR}${CurrentFile} 
				rm -f ${PROCESSING_DIR}TRAILER_${CurrentFile}
				rm -f ${REJECT_DIR}Temp_rej_trailer.txt
							 							 
				echo ${CurrentFile} >> ${TEMP_DIR}METADATA_REJ_FILE.txt	

#--------------------------------------------------------------------------#
#  To check for the expected no. of columns in detail record in a file     #
#--------------------------------------------------------------------------#				
			
			elif [[ $DETAIL_COL_CNT = "1" ]]; then
	
				echo "Missing Excepted no. of columns in Detail record of $CurrentFile. Hence not processing"
	        		
	        					
	     awk 'NF!=21{print "Record No",NR,"has",NF-1,"columns"}' FS="," $CurrentFile > ${TEMP_DIR}STATUS_REC.txt
								
	     awk 'NF!=21{print $0}' FS="," $CurrentFile > ${TEMP_DIR}DATA_REC.txt
								      		
#------------------------------------------------------#
#  To create exception file for detail record          #
#------------------------------------------------------#
	      			for j in `cat ${TEMP_DIR}${TEMPFILE}`
					
				do 
		   	           
					VALUE=`head -1 ${TEMP_DIR}STATUS_REC.txt`
		   	           		   	           
					DETAIL_REC=`head -1 ${TEMP_DIR}DATA_REC.txt`		
		   
					Record_Type=01
					EXCEPT_SERVICE=AEH
		   	  		EXCEPT_GEN_PLATFORM=TFRM
		   	  		EXCEPT_ORIG_SYSTEM=`echo ${CurrentFile} | cut -d "_" -f3`
		   	  		EXCEPTION_ENTITY=CONT
		   	  		EXCEPT_NUMBER=003
		   	  		EXCEPT_SEVERITY=E
		   	 		EXCEPTION_INPUT_REC_NO=NA
		   	  		EXCEPT_MESSAGE=${VALUE}  
		   	  		EXCEPT_OLD_KEY=NA
		   	  		EXCEPT_NEW_KEY=NA
		   	  		EXCEPT_DATA_VALUE='"'$DETAIL_REC'"'
		   	  		EXCEPT_SOURCE_DATA_REF=NA
		   	  		EXCEPT_TARGET_DATA_REF=NA
		   	  		EXCEPT_JS_NAME=NA
		   	  		EXCEPT_JB_NAME=NA
		   	  		EXCEPT_FILE_DET=${CurrentFile}
		   	   	 	      
		   echo $Record_Type,$EXCEPT_SERVICE,$EXCEPT_GEN_PLATFORM,$EXCEPT_ORIG_SYSTEM,$EXCEPTION_ENTITY,$EXCEPT_NUMBER,$EXCEPT_SEVERITY,$EXCEPTION_INPUT_REC_NO,$EXCEPT_MESSAGE,$EXCEPT_OLD_KEY,$EXCEPT_NEW_KEY,$EXCEPT_DATA_VALUE,$EXCEPT_SOURCE_DATA_REF,$EXCEPT_TARGET_DATA_REF,$EXCEPT_JS_NAME,$EXCEPT_JB_NAME,$EXCEPT_FILE_DET >> ${REJECT_DIR}Temp_detail_rej.txt
	    	   sed '1d' ${TEMP_DIR}DATA_REC.txt > ${TEMP_DIR}DATA_REC_TEMP.txt
		   cat ${TEMP_DIR}DATA_REC_TEMP.txt > ${TEMP_DIR}DATA_REC.txt
		   	  	  
		   sed '1d' ${TEMP_DIR}STATUS_REC.txt > ${TEMP_DIR}STATUS_REC_TEMP.txt
		   cat ${TEMP_DIR}STATUS_REC_TEMP.txt > ${TEMP_DIR}STATUS_REC.txt
	
	      done
	      
	   			F3_COUNT=`cat ${TEMP_DIR}${TEMPFILE} | wc -l | sed 's/ //g'`
	   
	   			echo '00,'${EXPNAME}','$FILE_DATE',001' > ${REJECT_DIR}$EXPNAME
	   			cat ${REJECT_DIR}Temp_detail_rej.txt >> ${REJECT_DIR}$EXPNAME
	   			echo '99,'$F3_COUNT >> ${REJECT_DIR}$EXPNAME

	    	  		cat ${PROCESSING_DIR}HEADER_${CurrentFile} > ${UNPROCESSED_DIR}${CurrentFile}
	   	 		cat ${PROCESSING_DIR}${CurrentFile} >> ${UNPROCESSED_DIR}${CurrentFile}
	           		cat ${PROCESSING_DIR}TRAILER_${CurrentFile} >> ${UNPROCESSED_DIR}${CurrentFile}
	           
	          		   
	   	   		rm -f ${PROCESSING_DIR}HEADER_${CurrentFile} 
	            		rm -f ${PROCESSING_DIR}${CurrentFile} 
	 			rm -f ${PROCESSING_DIR}TRAILER_${CurrentFile}
	 			rm -f ${TEMP_DIR}${TEMPFILE}
	 			rm -f ${REJECT_DIR}Temp_detail_rej.txt
	 			rm -f ${TEMP_DIR}DATA_REC_TEMP.txt
	 			rm -f ${TEMP_DIR}DATA_REC.txt
	 			rm -f ${TEMP_DIR}STATUS_REC_TEMP.txt
	 			rm -f ${TEMP_DIR}STATUS_REC.txt
	 		
	 
	 			echo ${CurrentFile} >> ${TEMP_DIR}METADATA_REJ_FILE.txt
	 		else 

				echo "$CurrentFile has expected no of columns"
	
			fi	 		
	 	done
	 
fi
	 

#----------------------------#
#   Send mail function       #
#----------------------------#

	Count=`ls ${PROCESSING_DIR}$FILENAME | wc -l | sed 's/ //g'`
	echo "FileCount=$Count"
	
	if [[ $Count -eq 0 ]] ; then
	echo 'This is an automated mail to alert that Contribution source files have exceptions' > ${TEMP_DIR}mail.txt
	ls ${REJECT_DIR}*TFRMEXCP.csv | cut -d "/" -f7 >> ${TEMP_DIR}mail.txt
	
	MAIL=`cat ${TEMP_DIR}mail.txt`
	echo "$MAIL" | mail -s "ACTION REQIRED -- STP Contribution Exception" $TOMAIL
	rm -f ${TEMP_DIR}mail.txt
	fi
	
	
if [ $? = 0 ] ; then
	echo "Metadata check Script executed successfully"
	exit 0
else
	echo "Metadata check Script failed"
	exit 1
fi