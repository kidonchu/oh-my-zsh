ERROR="$(tput setaf 1)ERROR: $(tput sgr0)"
PROCESS="$(tput setaf 5)PROCESSING: $(tput sgr0)"
SUCCESS="$(tput setaf 2)SUCCESS: $(tput sgr0)"
NOTICE="$(tput setaf 4)NOTICE: $(tput sgr0)"

function cd() {
    builtin cd "$@" && ls
}

function findfile() {
    find . -name '*'$1'*'
}

function gitcob7() {
    if [[ -z $1 ]]; then
        echo $ERROR"Incorrect Argument"
        return 1
    fi

    /usr/bin/git fetch ActiveCampaign
    /usr/bin/git co -b $1 ActiveCampaign/feature-7.9-contact-deals.7
    /usr/bin/git push origin --set-upstream $1
}

function gitbrd () {

	branches=($(/usr/bin/git br | grep -v '\*' | awk '{print $1}'))

    PS3='Choose branch to delete: '
    select branch in "${branches[@]}"
    do
        case $branch in
            *)
                /usr/bin/git br -d $branch
                break
                ;;
        esac
    done
}

function gitbrD () {

	branches=($(/usr/bin/git br | grep -v '\*' | awk '{print $1}'))

    PS3='Choose branch to delete: '
    select branch in "${branches[@]}"
    do
        case $branch in
            *)
                /usr/bin/git br -D $branch
                break
                ;;
        esac
    done
}

function gitcobr () {

	if [[ ! -z $1 ]]; then
		branches=($(/usr/bin/git br | grep -v '\*' | awk '{print $1}' | grep -iE $1))
	else
		branches=($(/usr/bin/git br | grep -v '\*' | awk '{print $1}'))
	fi

    PS3='Choose branch to checkout: '
    select branch in "${branches[@]}"
    do
        case $branch in
            *)
				_git_switch_branch "$branch"
                break
                ;;
        esac
    done
}

function gitcobra () {

	if [[ ! -z $1 ]]; then
		branches=($(/usr/bin/git br | grep -v '\*' | awk '{print $1}' | grep -iE $1))
	else
		branches=($(/usr/bin/git br | grep -v '\*' | awk '{print $1}'))
	fi

	PS3='Choose branch to checkout: '
	select branch in "${branches[@]}"
	do
		case $branch in
			*)
				currentDir=$(pwd)
				_echo_progress "Switching ember app branch"
				builtin cd ~/vagrant/dev/ember-app
				_git_switch_branch "$branch"
				_echo_progress "Switching Hosted branch"
				builtin cd ~/vagrant/dev/Hosted
				_git_switch_branch "$branch"
				builtin cd "$currentDir"
				break
				;;
		esac
	done
}

function gitrmnew() {
    newFiles=( $(/usr/bin/git st . | awk '/\?\?/ {print $2}') )
    filesToDelete=""
    for i in $newFiles
    do
        rm -rf $i
    done
}

function gp7() {
    /usr/bin/git fetch ActiveCampaign
    /usr/bin/git pull ActiveCampaign feature-7.9-contact-deals.7
}

function tt() {
    if [[ -z $1 ]]; then
        echo $ERROR"Incorrect Argument"
        return 1
    fi
    existingSession=( $(tmux list-sessions | awk -F: '{print $1}' | grep $1) )

    # if such session doesn't exist, creat new session
    if [[ -z $existingSession  ]]; then
        tmux new -s $1
    else
    	if [[ $#existingSession -eq 1 ]] && [[ $existingSession == $1 ]]; then
            tmux attach-session -t $1
        else
        	PS3='Choose session to create/attach: '
        	select sessionName in "${existingSession[@]}" "$1"
        	do
            	case $sessionName in
                	"$1")
                    	tmux new -s $1
                    	break
                    	;;
                	*)
                    	tmux attach-session -t $sessionName
                    	break
                    	;;
            	esac
        	done
    	fi
    fi
}

function vssh() {
    cd /Users/kchu/vagrant
    vagrant ssh
}

#####################
### private functions
#####################
_git_create_branch() {
	branch=$1
	currentBranch=$(git br | grep '\*' | awk '{print $2}')
	_echo_progress "$currentBranch => $branch"
	git add .
	_echo_progress 'Saving changes to stash'
	git stash save "$currentBranch"
	_echo_progress 'Creating target branch'
	git fetch ActiveCampaign
	git co -b "$branch" ActiveCampaign/feature-7.9-contact-deals.7
	git push origin --set-upstream "$branch"
}

_git_switch_branch() {
	branch=$1
	currentBranch=$(git br | grep '\*' | awk '{print $2}')
	_echo_progress "$currentBranch => $branch"
	git add .
	_echo_progress 'Saving changes to stash'
	git stash save "$currentBranch"
	_echo_progress 'Checking out target branch'
	git checkout $branch
	# check if there is any stash from previous edits
	_echo_progress 'Restoring stashed changes'
	_git_restore_stashed_changes "$branch"
}

_git_restore_stashed_changes() {
	branch=$1
	hasStash=$(git stash list |grep "$branch")
	if [[ ! -z "$hasStash" ]]; then
		stashed=$(echo "$hasStash" | awk -F':' '{print $1}')
		if [[ ! -z "$stashed" ]]; then
			git stash pop "$stashed"
		fi
	fi
}

_git_current_branch() {
	echo $(git br 2&> /dev/null | grep '\*' | awk '{print $2}')
}

_echo_progress() {
	echo
	echo "$PROCESS: "$1
}
