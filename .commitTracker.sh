#!/bin/bash

#TODO: Add verbose option
usage() { echo "Usage: $0 -d /Users/username/repo_dir -n YourGithubName" 1>&2; exit 1; }

while getopts ":d:n:" o; do
	case "${o}" in
		d)
			d=${OPTARG}
			;;
		n)
			n=${OPTARG}
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

if [ -z "${d}" ] || [ -z "${n}" ]; then
	usage
fi

echo "d = ${d}"
echo "n = ${n}"

cd $d

name="$n"
output=".commitHistory.txt"
tallyOutput=".commitTally.txt"

today=$(date +%Y-%m-%d)
sum=0

function getLastEntry {
	last_entry=$(cat "$output" | grep " $1 " | tail -n -1)
	echo "$last_entry"
}

function lastNoCommits {
	lastNumber=$(getLastEntry $1 | egrep -o " [0-9]+")
    if [ -z $lastNumber ]; then
        lastNumber="0"
    fi
	echo "$lastNumber"
}

function gitShortlogCustom {
	echo "$(git --no-pager shortlog -ns HEAD | grep $name | egrep -o "[0-9]+")"
}

function getUserCommitsForProject {
	cd "$d/$1"
	commits=$(gitShortlogCustom)
	cd ..
	if [ -z $commits ]; then
		commits="0"
	fi
	echo "$commits"
}

function newCount {
	# For each project foler in the current dir
	for folder in */; do
		echo ">>> $folder <<<"
		project=${folder%?}
		# Obtain the number of commits for the project
		commits=$(getUserCommitsForProject $folder)
		# Get the date of the latests number of commits
		# if date is not the same, update the commits file for
		# this project
		latest=$(getLastEntry "$project")
		latestDate=${latest:0:10}
		echo "found $commits"
		if [[ $latestDate != $today ]]; then
			echo "$today $project $commits" >> "$output"
		fi
		echo "last number of commits $(lastNoCommits $project)"
		difference=$(expr $commits - $(lastNoCommits $project))
		echo "difference $difference"
		sum=$(expr $difference + $sum)
	done
}

sum=0
echo "*************************"
echo "Your commits for today..."
newCount
message="Total commits submitted today: $sum"
echo "$message"
echo "$(date) - $message" > "$tallyOutput"
