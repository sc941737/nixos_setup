alias aliases='[ -z $EDITOR ] || ($EDITOR $HOME/.bash_aliases && source $HOME/.bash_aliases)'
alias bashrc='[ -z $EDITOR ] || ($EDITOR $HOME/.bashrc && source $HOME/.bashrc)'
alias updaterc='source $HOME/.bashrc'
# Shortcuts for basic commands:
alias svim='sudo vim'
alias rm='trash'
alias javr='java -jar'
alias x='exit'
alias pkill='pkill -ei'
alias mkin='sudo make clean install'

# Directory aliases:
alias dircount='echo $(( $(dirs | awk "{ print NF }") - 1 ))'
alias cd='popd -0 &>/dev/null; pushd . &>/dev/null; cd'
alias docs='cd ~/Documents'
alias down='cd ~/Downloads'
alias trashdir='cd .local/share/Trash/files'
alias sl='cd $HOME/.config/suckless'

# Convenience utils:
alias cpo="fc -s | sed -z '$ s/\n$//' | xclip -sel clipboard" # Rerun last command, remove trailing newline from output, copy output to clipboard

# Shortcuts for specific app run configurations:
alias ms='mullvad status -l'
alias mcon='mullvad connect && mullvad lockdown-mode set on'
alias mdis='mullvad lockdown-mode set off && mullvad disconnect'

# Utilities:
alias findcmd='dpkg -l | grep'
alias myip='curl http://ipecho.net/plain; echo'
alias fixbt='sudo rmmod btusb && sudo modprobe btusb'
alias fixau='pulseaudio -k; sudo alsa force-reload'

# Git:
alias gc='git commit'
alias gd='git diff'
alias gre='git restore'
alias gres='git restore --staged'
alias grt='git reset'
alias gdh='git diff HEAD'
alias gdl='git diff HEAD~1'
alias gds='git diff --compact-summary'
alias gco='git-checkout-last'
alias gs='git status'
alias gp='git pull'
alias gm='git merge'
alias gb='git branch'
alias gf='git fetch origin'
alias gfm='git fetch origin master:master' # Update master branch from any other branch without checkout.
alias gfd='git fetch origin develop:develop'
alias grem='gfm && git rebase master'
alias gred='gfd && git rebase develop'
alias gbl='git branch --list'
alias gbr='git branch --remote'
alias gl='git log'
alias ga='git add'
alias gac='git add . && git commit -a -m'
alias gA='git add --all'
alias gtime='git reflog --date=iso'
alias gpsu='git push --set-upstream origin $(git branch --show-current)'
alias glog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"
alias glm='git log master.. --oneline --no-merges'
alias gcoo='git checkout --ours'
alias gcot='git checkout --theirs'
alias gcob='git-checkout-last -b'
alias gmlc='git-merge-last-commits'
alias git-reset-remote='git fetch origin && git reset --hard origin/$(git branch --show)'
