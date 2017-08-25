# ------------------------------------------------------------------------------
# SCM Breeze - Streamline your SCM workflow.
# Copyright 2011 Nathan Broadbent (http://madebynathan.com). All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Numbered shortcuts for git branch
# ------------------------------------------------------------------------------

# Function wrapper around 'll'
# Adds numbered shortcuts to output of ls -l, just like 'git status'
unalias $git_branch_alias > /dev/null 2>&1; unset -f $git_branch_alias > /dev/null 2>&1
function _scmb_git_branch_shortcuts {
  fail_if_not_git_repo || return 1

  # Fall back to normal git branch, if any unknown args given
  if [[ "$($_git_cmd branch | wc -l)" -gt 300 ]] || ([[ -n "$@" ]] && [[ "$@" != "-a" ]]); then
    exec_scmb_expand_args $_git_cmd branch "$@"
    return 1
  fi

  # @jsjason: DISABLE RUBY IMPLEMENTATION
  # Use ruby to inject numbers into ls output
  # ruby -e "$( cat <<EOF
  #   output = %x($_git_cmd branch --color=always $@)
  #   line_count = output.lines.to_a.size
  #   output.lines.each_with_index do |line, i|
  #     spaces = (line_count > 9 && i < 9 ? "  " : " ")
  #     puts line.sub(/^([ *]{2})/, "\\\1\033[2;37m[\033[0m#{i+1}\033[2;37m]\033[0m" << spaces)
  #   end
# EOF
# )"

  zsh_compat

  # Clear numbered env variables.
  local i
  for (( i=1; i<=$gs_max_changes; i++ )); do unset $git_env_char$i; done

  local curr_branch=`$_git_cmd branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  local num_lines="$($_git_cmd branch "$@" | wc -l)"

  # Set numbered file shortcut in variable
  local e=1
  IFS=$'\n'
  local c_dark="\033[2;37m"
  local c_rst="\033[0m"
  for branch in $($_git_cmd branch "$@" | sed "s/^[* ]\{2\}//"); do
    local curr
    local col
    if [ "$curr_branch" != "$branch" ]; then
      curr=" "
      col=$c_rst
    else
      curr="*"
      col="\033[0;32m"
    fi

    if [ $num_lines -ge 10 ] && [ $e -le 9  ] ; then
      local space="  "
    else
      local space=" "
    fi

    echo -e  ""$curr" $c_dark[$c_rst$e$c_dark]$c_rst$space$col"$branch"$c_rst"
    export $git_env_char$e="$branch"
    if [ "${scmbDebug:-}" = "true" ]; then echo "Set \$$git_env_char$e  => $file"; fi
    let e++
  done
  unset IFS
}

__git_alias "$git_branch_alias"              "_scmb_git_branch_shortcuts" ""
__git_alias "$git_branch_all_alias"          "_scmb_git_branch_shortcuts" "-a"
__git_alias "$git_branch_move_alias"         "_scmb_git_branch_shortcuts" "-m"
__git_alias "$git_branch_delete_alias"       "_scmb_git_branch_shortcuts" "-d"
__git_alias "$git_branch_delete_force_alias" "_scmb_git_branch_shortcuts" "-D"

# Define completions for git branch shortcuts
if [ "$shell" = "bash" ]; then
  for alias_str in $git_branch_alias $git_branch_all_alias $git_branch_move_alias $git_branch_delete_alias; do
    __define_git_completion $alias_str branch
    complete -o default -o nospace -F _git_"$alias_str"_shortcut $alias_str
  done
fi
