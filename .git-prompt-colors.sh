# Custom git prompt theme
# Note: KUBE_PS1 is injected in the prompt by a function called `prompt_callback`. You should find this in ~/.bash_functions
override_git_prompt_colors() {
  GIT_PROMPT_THEME_NAME="Custom"


  GIT_PROMPT_COMMAND_OK="${Green}[\! ✔]"    # indicator if the last command returned with an exit code of 0
  GIT_PROMPT_COMMAND_FAIL="${Red}[\! ✘-_LAST_COMMAND_STATE_]"    # indicator if the last command returned with an exit code of other than 0
  GIT_PROMPT_END_USER=" \n$ "
  GIT_PROMPT_END_ROOT=" \n# "
}

reload_git_prompt_colors "Custom"
