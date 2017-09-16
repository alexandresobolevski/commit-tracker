# commit-tracker
Write to file the number commits you have contributed to one or serveral repositories. Track and display that file to improve productivity.

### Usage

- Download or clone repository to directory `$(commit-tracker-directory)`.

- Add a cron job that runs the script

```bash
$ crontab -e
```

And assuming knowing the directory that contains the repositories that you wish to track `$(directory-with-repositories-to-track)`, add a new cron job at the end of the file that would look something like this:

```bash
*/1     *       *       *       *       
$(commit-tracker-directory)/.commitTracker.sh -d 
$(directory-with-repositories-to-track) -n Sobolevski > 
$(commit-tracker-directory)/.commitTracker.log 2>&1
```

- See total commits contributed since beginning of the day

`cat $(commit-tracker-directory)/.commitTally.txt`

- [RECOMMENDED] Use [BitBar](https://github.com/matryer/bitbar) to display the total number of commits in the menu bar. By creating a script `commits.1m.sh` in the BitBar folder with the following content:
```bash
#!/bin/bash
echo $(cat /Users/alexandresobolevski/Workstation/.commitTally.txt | awk 'END {print $NF}') 'Commit(s)'
```

### Examples

Display in the menu bar the number of commits contributed to a project
[Blog Post](https://wordpress.com/post/alexandresobolevski.blog/338)


### License 

MIT
