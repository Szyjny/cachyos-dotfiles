# source /usr/share/cachyos-zsh-config/cachyos-config.zsh

# Theme
eval "$(starship init zsh)"

# Oh-my-zsh
export ZSH="/usr/share/oh-my-zsh"
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZSH/oh-my-zsh.sh

export EDITOR="nvim"

alias n="nvim"
alias cd="z"
alias ff="fastfetch"
alias boo="ghostty +boo"
alias ls="eza --icons"
alias lg="lazygit"
alias ls="eza -lh --group-directories-first --icons=auto"
alias l="ls -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="lt -a"
alias ":q"="exit"

alias b="cd .."
alias b2="cd ../.."
alias b3="cd ../../.."
alias b4="cd ../../../.."

export HISTCONTROL=ignoreboth
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

autoload -U colors && colors

# Disable vi mode
bindkey -e

# Edit command in Nvim via Ctrl+D
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^D' edit-command-line

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  local cwd
  yazi "$@" --cwd-file="$tmp"
  # POPRAWKA: Używamy "\"" zamiast dwóch apostrofów, aby Nix nie zamykać stringa
  IFS= read -r -d "" cwd < "$tmp"
  if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

function cpp() {
    local main_file="${1}"
    shift
    g++ "$main_file" -o "output"
    ./"output" "$@"
    rm ./"output"
}

function tmux-new() {
  local session_name="$1"
  if [ -z "$session_name" ]; then
    return 1
  fi
  tmux has-session -t "$session_name" 2>/dev/null
  if [ $? -eq 0 ]; then
    :
  else
    tmux new-session -d -s "$session_name" || return 1
  fi
  tmux switch-client -t "$session_name"
}


# shellcheck shell=bash

# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd() {
    \builtin pwd -L
}

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd() {
    # shellcheck disable=SC2164
    \builtin cd -- "$@"
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
function __zoxide_hook() {
    # shellcheck disable=SC2312
    \command zoxide add -- "$(__zoxide_pwd)"
}

# Initialize hook.
\builtin typeset -ga precmd_functions
\builtin typeset -ga chpwd_functions
# shellcheck disable=SC2034,SC2296
precmd_functions=("${(@)precmd_functions:#__zoxide_hook}")
# shellcheck disable=SC2034,SC2296
chpwd_functions=("${(@)chpwd_functions:#__zoxide_hook}")
chpwd_functions+=(__zoxide_hook)

# Report common issues.
function __zoxide_doctor() {
    [[ ${_ZO_DOCTOR:-1} -ne 0 ]] || return 0
    [[ $- == *i* ]] || return 0
    [[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] || return 0

    _ZO_DOCTOR=0
    \builtin printf '%s\n' \
        'zoxide: detected a possible configuration issue.' \
        'Please ensure that zoxide is initialized right at the end of your shell configuration file (usually ~/.zshrc).' \
        '' \
        'If the issue persists, consider filing an issue at:' \
        'https://github.com/ajeetdsouza/zoxide/issues' \
        '' \
        'Disable this message by setting _ZO_DOCTOR=0.' \
        '' >&2
}

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function __zoxide_z() {
    __zoxide_doctor
    if [[ "$#" -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ "$#" -eq 1 ]] && [[ "$1" = '-' ]]; then
        __zoxide_cd "${OLDPWD}"
    elif [[ "$#" -eq 1 ]] && { [[ "$1" =~ ^[-+][0-9]+$ ]] || (\builtin cd -q -- "$1") &>/dev/null; }; then
        __zoxide_cd "$1"
    elif [[ "$#" -eq 2 ]] && [[ "$1" = "--" ]]; then
        __zoxide_cd "$2"
    else
        \builtin local result
        # shellcheck disable=SC2312
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" && __zoxide_cd "${result}"
    fi
}

# Jump to a directory using interactive search.
function __zoxide_zi() {
    __zoxide_doctor
    \builtin local result
    result="$(\command zoxide query --interactive -- "$@")" && __zoxide_cd "${result}"
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

function z() {
    __zoxide_z "$@"
}

function zi() {
    __zoxide_zi "$@"
}

# Completions.
if [[ -o zle ]]; then
    __zoxide_result=''

    function __zoxide_z_complete() {
        # Only show completions when the cursor is at the end of the line.
        # shellcheck disable=SC2154
        [[ "${#words[@]}" -eq "${CURRENT}" ]] || return 0

        if [[ "${#words[@]}" -eq 2 ]]; then
            # Show completions for local directories.
            _cd -/

        elif [[ "${words[-1]}" == '' ]]; then
            # Show completions for Space-Tab.
            # shellcheck disable=SC2086
            __zoxide_result="$(\command zoxide query --exclude "$(__zoxide_pwd || \builtin true)" --interactive -- ${words[2,-1]} 2>/dev/null)" || __zoxide_result=''

            # Set a result to ensure completion doesn't re-run
            compadd -Q -S "" -- ""

            # Bind '\e[0n' to helper function.
            \builtin bindkey '\e[0n' '__zoxide_z_complete_helper'
            # Sends query device status code, which results in a '\e[0n' being sent to console input.
            \builtin printf '\e[5n'

            # Report that the completion was successful, so that we don't fall back
            # to another completion function.
            return 0
        fi
    }

    function __zoxide_z_complete_helper() {
        if [[ -n "${__zoxide_result}" ]]; then
            # shellcheck disable=SC2034,SC2296
            BUFFER="z ${(q-)__zoxide_result}"
            __zoxide_result=''
            \builtin zle reset-prompt
            \builtin zle accept-line
        else
            \builtin zle reset-prompt
        fi
    }
    \builtin zle -N __zoxide_z_complete_helper

    [[ "${+functions[compdef]}" -ne 0 ]] && \compdef __zoxide_z_complete z
fi

# =============================================================================
#
# To initialize zoxide, add this to your shell configuration file (usually ~/.zshrc):
#
eval "$(zoxide init zsh)"

# Fzf
source <(fzf --zsh)
