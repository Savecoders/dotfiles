# !SAVE ZSH Theme
# user names
function Users_name() {
    
    if  [[ ${GIT_INFO} == "" ]];
        then
        echo "%{$fg_bold[white]%}%n%{$reset_color%}"
    elif [[ $(git_current_user_name) == "" ]]; 
        then
        echo "%{$fg_bold[white]%}%n%{$reset_color%}"
    else        
    echo "%{$fg_bold[white]%}% $(git_current_user_name)%{$reset_color%}"
    fi
}
# directory
function directory() {
    if [[ ${GIT_INFO} == "" ]];
        then
        echo "%{$fg_bold[cyan]%} %c%{$reset_color%}";
    else 
        echo "%{$fg_bold[cyan]%} %c%{$reset_color%}";  
    fi     
}
# time
function real_time() {
    local color="%{$fg_no_bold[blue]%}";                   
    local time="神$(date +%H:%M:%S)";
    local reset_color="%{$reset_color%}";
    echo "${color}${time}${reset_color}";
}
# line 
function line_index(){
    local color="%{$fg_bold[blue]%}"; 
    local simbol=" ";
    local reset_color="%{$reset_color%}";
    echo "${color}${simbol}${reset_color}";
    
}
# final line
function line_final(){
    local color="%{$fg_bold[blue]%}"; 
    local simbol="";
    local reset_color="%{$reset_color%}";
    echo "${color}${simbol}${reset_color}";    
}

# git Info 
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%} %{$fg_bold[red]%}  ";
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} ";
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_bold[blue]%}";
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[yellow]%} Commit %{$fg_bold[cyan]%}";
#git Info Status 
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[red]%} ";
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%} "; #%{$fg_bold[magenta]%}🔥
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%} ";
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[yellow]%}Merge %{$fg_bold[cyan]%}";

# update git status
function update_git_status() {
    GIT_STATUS=$(git_prompt_status);
    
}
# update git info
function update_git_info() {
    GIT_INFO=$(git_prompt_info);
}
# print git status
function git_status() {
    echo "${GIT_STATUS}"
}
# pint git info
function git_info() {
    echo "${GIT_INFO}"
}

# command
function update_command_status() {
    local user="";
    local line="";
    local default="";
    local color_reset="%{$reset_color%}";
    local reset_font="%{$fg_no_bold[white]%}";

    if $1;
    then
        user="%{$fg_bold[yellow]%} ";
        line="%{$fg_bold[green]%} ";# 
    else
        user="%{$fg_bold[red]%} ";
        line="%{$fg_bold[red]%} ";#
    fi
    default="${user}$(Users_name)${line}";
    COMMAND_STATUS="${default}${reset_font}${color_reset}";
}
update_command_status true;

function command_status() {
    echo "${COMMAND_STATUS}"
}

current_time_millis() {
    local time_millis;
    if [[ "$OSTYPE" == "linux-gnu" ]]; 
        then
        time_millis="$(date +%s.%3N)";
    elif [[ "$OSTYPE" == "darwin"* ]]; 
        then
        time_millis="$(gdate +%s.%3N)";
    else
        # Unknown.
    fi
    echo $time_millis;
}
preexec() {
    COMMAND_TIME_BEIGIN="$(current_time_millis)";
}
precmd() {
    # last_cmd
    local last_cmd_return_code=$?;
    local last_cmd_result=true;
    if [ "$last_cmd_return_code" = "0" ];
    then
        last_cmd_result=true;
    else
        last_cmd_result=false;
    fi
    # update_git_status
    update_git_status;
     # update_git_info
    update_git_info;
    # update_command_status
    update_command_status $last_cmd_result;
}
# set option
setopt PROMPT_SUBST;
TMOUT=1;

TRAPALRM() {
    if [ "$WIDGET" = "" ] || [ "$WIDGET" = "accept-line" ] ; then
        zle reset-prompt;
    fi
}
#The new Line
_linestop=$'\n';
_lineup=$'\e[1A';
_linedown=$'\e[1B';
#PROMPTS

PROMPT='$(command_status) $(directory)$(git_info)$(git_status)$_linestop';
RPROMPT='%{${_lineup}%}$(real_time)%{${_linedown}%}';
RPROMPT+='$(line_final)'
PROMPT+='$(line_index)';
