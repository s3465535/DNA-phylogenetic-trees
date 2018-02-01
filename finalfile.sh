#! /bin/bash

#################################Information####################################
#This program is used to build a phylogenetic tree based on the species entered by the user. 
#The DNA sequences are gained from NCBI(GenBank)

#Written by: Tamara Gademann & Boukje Heidstra
#Written during the course Practical BioInformatics for Biologists
#Latest revision: 1-2-2018

#Please read the whole script before use.

#Make sure to make the script executable by the user with the following command: chmod u+r finalfile.sh

#The in- and outputfiles are created inside the ~/Documents directory.
#If you want to run this script, set your working directory to the Documents folder by:
#cd ~/Documents

#Before you run the script, make sure Edirect is installed (see Step 1)

####################################STEP 1######################################
##Downloading DNA sequences from the database (NCBI) 
#and creating a masterfile with all the DNA sequences of the requested species.

#The DNA sequences will be derived from the NCBI database by using Edirect.
#First install Edirect by entering the website below and following the instructions:
#https://www.ncbi.nlm.nih.gov/books/NBK179288/

#Ask user to enter species name
read -p "Enter species name: " specname1

#Print species name while waiting for next steps to be run (file to be created)
echo -e "Getting $specname1 DNA"

#For entered species name, download DNA sequences from database (NCBI/GenBank) and create a fastafile per species.
esearch -db Nucleotide -query "$specname1" | efetch -format fasta >> ~/Documents/"$specname1".fasta

#Ask if there are more species to be entered using while loop
while [ -z "$REPLY" ] ; do 
	if [ -z "$1" ] ; then 
		read -p "Do you want to enter another species?(Yes/No): "
		else
			REPLY=$1
			set --
	fi
	#Use case statement to process commandline for either yes (new species) or no (continue script).
	case $REPLY in
		[Yy]es) #if Yes, repeat DNA search for newly entered species
			read -p "Enter species name: " specname2
			echo -e "Getting $specname2 DNA"
			esearch -db Nucleotide -query "$specname2" | efetch -format fasta >> ~/Documents/"$specname2".fasta
			unset REPLY ;;
		[Nn]o) #if no more species to be entered, continue with rest of script
			echo -e "Continuing...\n"
			#Print an overview of the number of sequences in each file
			echo "Number of sequences per file: "
			grep -c ">" ~/Documents/*.fasta
			#Print the next steps that will be run
			echo "Combining all species into one file and starting alignment"
	esac
done

#Rename all files; replace all spaces in filenames by underscores, to make it possible to search for
#-f: Overwrite: allow existing files to be overwritten
rename -f 's/ /_/g' ~/Documents/*.fasta

#Combine all species DNA into one file
cat ~/Documents/*.fasta > ~/Documents/allseq.fasta

####################################STEP 2#####################################
##Clustalw is used to align the DNA sequences and create an outputfile for estimating the tree
#Make sure clustalw is installed
#if not, type 'clustalw' in the command line and follow instructions

clustalw -INFILE=allseq.fasta -TYPE=DNA -OUTFILE=out_allseq.phy -OUTPUT=PHYLIP

####################################STEP 3######################################
##Phyml estimates the most suitable tree.
#Make sure phyml is installed.
#If not, install by typing 'phyml' in the command line and follow instructions.
phyml -i out_allseq.phy -d nt -n 1 -m HKY85

####################################STEP 4######################################
##Plotting and saving the tree with R (go to Rscript)
Rscript plotTree.r


###End of script