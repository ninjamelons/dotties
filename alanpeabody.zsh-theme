local user='%{$fg[magenta]%}%n@%{$fg[magenta]%}%m%{$reset_color%}'
local pwd='%{$fg[blue]%}%~%{$reset_color%}'
local return_code='%(?..%{$fg[red]%}%? ↵%{$reset_color%})'
local git_branch='$(git_prompt_status)%{$reset_color%}$(git_prompt_info)%{$reset_color%}'
local start_symbol='%{$fg[green]%}% $%{$reset_color%}'

ZSH_THEME_RVM_PROMPT_OPTIONS="i v g"
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} ✚"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} ✹"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖️"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} ➜"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} ═"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭"

ZSH_THEME_RUBY_PROMPT_PREFIX="%{$fg[green]%}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%{$reset_color%}"

NEWLINE=$'\n'

KUBE_CONTEXT=""
get_kube_context() {
    #KUBE_CONTEXT=$(kubectl config current-context)
    if [[ $KUBE_CONTEXT == 2869 ]]
    then
        KUBE_CONTEXT="test"
        KUBE_CONTEXT="%{$fg[yellow]%}% ${KUBE_CONTEXT}%{$reset_color%}"

    elif [[ $KUBE_CONTEXT == 3619 ]]
    then
        KUBE_CONTEXT="prod"
        KUBE_CONTEXT="%{$fg[red]%}% ${KUBE_CONTEXT}%{$reset_color%}"
    fi

    PROMPT="╭─$(virtualenv_prompt_info)${user} ${pwd} ${KUBE_CONTEXT}
╰─${start_symbol} "
}
precmd_functions+=(get_kube_context)

RPROMPT="${return_code} ${git_branch} $(ruby_prompt_info)"
