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

function getLastEntry {
	last_entry=$(cat "$output" | grep " $1 " | tail -n -1)
	echo "$last_entry"
}

function lastNoCommits {
	lastNumber=$(getLastEntry $1 | egrep -o " [0-9]+")
  # echo "last number $lastNumber"
  if [[ -z $lastNumber ]]; then
      lastNumber="0"
  fi
	echo "$lastNumber"
}

function gitShortlogCustom {
	echo "$(git --no-pager shortlog -ns HEAD | grep "$name" | egrep -o "[0-9]+")"
}

function getUserCommitsForProject {
	cd "$d/$1"
	commits=$(gitShortlogCustom)
	cd ..
	if [[ -z $commits ]]; then
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
		latestCommits=$(getUserCommitsForProject $folder)
    echo "latest commit tally: |$latestCommits|"
		# Get the date of the latests number of commits
		# if date is not the same, update the commits file for
		# this project
		lastEntry=$(getLastEntry "$project")
    echo "lastEntry |$lastEntry|"
		lastEntryDate=${lastEntry:0:10}
		if [[ $lastEntryDate != $today ]]; then
			echo "$today $project $latestCommits" >> "$output"
		fi

    currentNoCommits=$(lastNoCommits "$project")
		echo "current commit tally: |$currentNoCommits|"
    difference="$latestCommits $currentNoCommits"
    echo "difference string |$difference|"
		difference=`expr $latestCommits + $currentNoCommits`
		echo "difference $difference"
  	if [[ ! -z $difference ]]; then
      sum=$(expr ${difference} + ${sum})
  	fi
	done
}

sum="0"
echo "*************************"
echo "Your commits for today..."
newCount
message="Total commits submitted today: $sum"
echo "$message"
echo "$(date) - $message" > "$tallyOutput"
