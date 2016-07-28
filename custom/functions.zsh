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

	branches=($(/usr/bin/git br | grep -v '\*' | awk '{print $1}'))

    PS3='Choose branch to checkout: '
    select branch in "${branches[@]}"
    do
        case $branch in
            *)
                /usr/bin/git checkout $branch
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
