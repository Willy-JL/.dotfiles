# Note: This shell config is a mix of the Garuda defaults,
# some of my configs and othe stuff I found online


# Set $PATH if ~/.local/bin exist
if [ -d "$HOME/.local/bin" ]; then
    export PATH=$HOME/.local/bin:$PATH
fi


###########
# ALIASES #
###########


# Alias paru to yay if only one is present (ensures we have paru for the next command alias)
which yay > /dev/null 2>&1 && ! which paru > /dev/null 2>&1 && alias paru='yay'

# Interactive yay -R (actually uses paru, but yay sounds better)
yay() {
    local command
    command="${1:-}"
    if [ "$#" -gt 0 ]; then
        shift
    fi

    case "$command" in
        "-R")
            pacman-R "$@"
            ;;
        "")
            command paru
            ;;
        *)
            command paru "$command" "$@"
            ;;
    esac
}

# Replace ls with exa
alias ls='exa -alF --git --color=always --group-directories-first --icons' # preferred listing
alias la='exa -a --color=always --group-directories-first --icons'         # all files and dirs
alias ll='exa -l --color=always --group-directories-first --icons'         # long format
alias lt='exa -aT --color=always --group-directories-first --icons'        # tree listing
alias l.="exa -a | egrep '^\.'"                                            # show only dotfiles

# Cd shows ls
function cd {
    builtin cd "$@" && ls -F
}

# Shorthands
alias q="exit"
alias py="python"

# Python virtual env
function pyvenv {
    [ ! -d "venv" ] && python -m venv venv
    source venv/bin/activate
}

# Human readable file and dir size
alias sizeof="du -sh"

# List file attributes only showing the non default ones
alias lsattrdiff="lsattr -R 2>/dev/null | grep -P '^(-*?[^-\s\.m]-*?)*?\s'"

# Delete pacman database lock
alias fixpacman="sudo rm /var/lib/pacman/db.lck"

# Continue partial download
alias wget='wget -c '

# Colored grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Short hardware info
alias hw='hwinfo --short'

# Sort installed packages according to size in MB
alias big="expac -H M '%m\t%n' | sort -h | nl"

# Get fastest mirrors 
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist" 

# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# Recent installed packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# Suspend, resume and reload kwin
alias compsuspend="qdbus org.kde.KWin /Compositor suspend"
alias compresume="qdbus org.kde.KWin /Compositor resume"
alias compreload="qdbus org.kde.KWin /KWin reconfigure"

# Make and restore backup of a file as .bak
backup() {
    if [ "$#" -eq 1 ]; then
        cp "$1" "$1.bak"
    fi
}
restore() {
    if [ "$#" -eq 1 ]; then
        cp "$1" "${1:0:-4}"
    fi
}

# Aliases with sudo
alias sudo='sudo '


##########
# CONFIG #
##########



# History
HISTFILE=~/.zhistory
HISTSIZE=50000
SAVEHIST=10000

# Starship prompt + matching sudo prompt
eval "$(starship init zsh)"
export SUDO_PROMPT="$(echo -e "\e[0m\n \e[0;31m╭─\e[1;31mSUDO\e[0m: \e[1;33mpassword\e[0m for \e[1;31m$USER\e[0m@\e[31m$(cat /etc/hostname)\e[0m\n \e[0;31m╰─\e[1;31mλ\e[0m ")"

# Arch Linux command-not-found support, you must have package pkgfile installed
[[ -e /usr/share/doc/pkgfile/command-not-found.zsh ]] && source /usr/share/doc/pkgfile/command-not-found.zsh

# Options
setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt auto_pushd                                               # Push pwd onto stack (cd -)
setopt pushd_ignore_dups                                        # No duplicates in pwd stack
setopt pushd_minus                                              # Allow multiple cd - (cd -2)
stty susp undef                                                 # Disable ctrl+z

# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:descriptions' format '%U%F{cyan}%d%f%u'

# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zcache

# Automatically load bash completion functions
autoload -U +X bashcompinit && bashcompinit

# Autosuggestion
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# History substring search
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# Syntax highlighting
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets regexp)
typeset -A ZSH_HIGHLIGHT_REGEXP
ZSH_HIGHLIGHT_REGEXP+=(' -{1,2}[a-zA-Z0-9_-]*' fg=000,bold)
ZSH_HIGHLIGHT_REGEXP+=('^sudo' fg=red,underline,bold)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[precommand]=fg=red,underline,bold    
ZSH_HIGHLIGHT_STYLES[arg0]=fg=blue,bold

# Use fzf for history search and completions
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh


########
# KEYS #
########


# Use emacs key bindings
bindkey -e

# [PageUp] - Up a line of history
if [[ -n "${terminfo[kpp]}" ]]; then
    bindkey -M emacs "${terminfo[kpp]}" up-line-or-history
    bindkey -M viins "${terminfo[kpp]}" up-line-or-history
    bindkey -M vicmd "${terminfo[kpp]}" up-line-or-history
fi
# [PageDown] - Down a line of history
if [[ -n "${terminfo[knp]}" ]]; then
    bindkey -M emacs "${terminfo[knp]}" down-line-or-history
    bindkey -M viins "${terminfo[knp]}" down-line-or-history
    bindkey -M vicmd "${terminfo[knp]}" down-line-or-history
fi

# Start typing + [Up-Arrow] - fuzzy find history forward
if [[ -n "${terminfo[kcuu1]}" ]]; then
    autoload -U up-line-or-beginning-search
    zle -N up-line-or-beginning-search

    bindkey -M emacs "${terminfo[kcuu1]}" up-line-or-beginning-search
    bindkey -M viins "${terminfo[kcuu1]}" up-line-or-beginning-search
    bindkey -M vicmd "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
# Start typing + [Down-Arrow] - fuzzy find history backward
if [[ -n "${terminfo[kcud1]}" ]]; then
    autoload -U down-line-or-beginning-search
    zle -N down-line-or-beginning-search

    bindkey -M emacs "${terminfo[kcud1]}" down-line-or-beginning-search
    bindkey -M viins "${terminfo[kcud1]}" down-line-or-beginning-search
    bindkey -M vicmd "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# [Home] - Go to beginning of line
if [[ -n "${terminfo[khome]}" ]]; then
    bindkey -M emacs "${terminfo[khome]}" beginning-of-line
    bindkey -M viins "${terminfo[khome]}" beginning-of-line
    bindkey -M vicmd "${terminfo[khome]}" beginning-of-line
fi
# [End] - Go to end of line
if [[ -n "${terminfo[kend]}" ]]; then
    bindkey -M emacs "${terminfo[kend]}"  end-of-line
    bindkey -M viins "${terminfo[kend]}"  end-of-line
    bindkey -M vicmd "${terminfo[kend]}"  end-of-line
fi

# [Shift-Tab] - move through the completion menu backwards
if [[ -n "${terminfo[kcbt]}" ]]; then
    bindkey -M emacs "${terminfo[kcbt]}" reverse-menu-complete
    bindkey -M viins "${terminfo[kcbt]}" reverse-menu-complete
    bindkey -M vicmd "${terminfo[kcbt]}" reverse-menu-complete
fi

# [Backspace] - delete backward
bindkey -M emacs '^?' backward-delete-char
bindkey -M viins '^?' backward-delete-char
bindkey -M vicmd '^?' backward-delete-char
# [Delete] - delete forward
if [[ -n "${terminfo[kdch1]}" ]]; then
    bindkey -M emacs "${terminfo[kdch1]}" delete-char
    bindkey -M viins "${terminfo[kdch1]}" delete-char
    bindkey -M vicmd "${terminfo[kdch1]}" delete-char
else
    bindkey -M emacs "^[[3~" delete-char
    bindkey -M viins "^[[3~" delete-char
    bindkey -M vicmd "^[[3~" delete-char

    bindkey -M emacs "^[3;5~" delete-char
    bindkey -M viins "^[3;5~" delete-char
    bindkey -M vicmd "^[3;5~" delete-char
fi

# Make sure the terminal is in application mode when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start { echoti smkx }
    function zle_application_mode_stop { echoti rmkx }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi
