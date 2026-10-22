# ~/.zshenv

#  ┬  ┬┌─┐┬─┐┌─┐
#  └┐┌┘├─┤├┬┘└─┐
#   └┘ ┴ ┴┴└─└─┘

export LESSCHARSET=utf-8

# less color
export LESS=-R+Gg
export LESS_TERMCAP_mb=$'\E[01;31m'    # begin blink
export LESS_TERMCAP_md=$'\E[01;33m'    # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[01;04;32m' # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline
# and so on

# 控制 ls 显示的时间格式
export TIME_STYLE='+%Y/%m/%d %H:%M:%S'

export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'

# The FIGNORE environment variable is nice when you want TAB completion
# to ignore files or folders with certain suffixes, e.g.:
export FIGNORE=~:.o:.svn:.git:.bak:.swp:.elc:.swa:.pyc:.a:.class:.la:.mo:.obj:.pyo

# @See https://stackoverflow.com/questions/799576/tput-unknown-terminal
export TERMINFO=/usr/lib/terminfo

# @See https://wiki.archlinuxcn.org/wiki/Sudo#%E5%BD%A9%E8%89%B2%E5%AF%86%E7%A0%81%E6%8F%90%E7%A4%BA
export SUDO_PROMPT="$(tput setab 1 setaf 7 bold)[sudo]$(tput sgr0) $(tput setaf 6)password for$(tput sgr0) $(tput setaf 5)%p$(tput sgr0): "

#{{ history
# @see http://www.talug.org/events/20030709/cmdline_history.html
# If you include the expression "[ \t]*" in the HISTIGNORE string,
# you cansuppress history recording at will for any given command
# just by starting with a space!
# Larger bash history (allow 32³ entries; default is 500)
export HISTFILESIZE=10000        # increase history file size (default is 500)
export HISTSIZE=${HISTFILESIZE}  # increase history size (default is 500)
export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"   # mem/file sync

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
# leading space hides commands from history
export HISTCONTROL=$HISTCONTROL:ignorespace
# no duplicate entries
export HISTCONTROL=$HISTCONTROL:ignoredups

export HISTIGNORE="history:man:ls:ll:la:l:ls *:cd:cd -:pwd;exit:date:* --help"
#}}

#{{ XDG Base Directory 规范
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
#}}

export PATH="$PATH:$HOME/.local/bin"

#################
# starship      #
#################

export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml

#################
# FZF           #
#################

export FZF_DEFAULT_COMMAND="fd --hidden --follow -I --exclude={Pods,.git,.idea,.sass-cache,node_modules,build} --type f"
export FZF_DEFAULT_OPTS="
--color=dark
--color=fg:#707a8c,bg:-1,hl:#3e9831,fg+:#cbccc6,bg+:#434c5e,hl+:#5fff87
--color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
--height 60%
--layout reverse
--preview-window 'hidden:right:60%'
--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -N -C {}) 2> /dev/null | head -500'
--bind ',:toggle-preview'
--border
--cycle
"
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_CTRL_T_OPTS=$FZF_DEFAULT_OPTS
export FZF_CTRL_R_OPTS="
--layout=reverse
--sort
--exact
--preview 'echo {}'
--preview-window down:3:hidden:wrap
--bind ',:toggle-preview'
--cycle
"

export FZF_ALT_C_OPTS="--preview 'tree -N -C {} | head -500'"
export FZF_TMUX_OPTS="-d 60%"
export FZF_COMPLETION_TRIGGER='**'

###############
# Perl5       #
###############

PATH="$HOME/bin/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="$HOME/bin/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/bin/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"$HOME/bin/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/bin/perl5"; export PERL_MM_OPT;

#################
# golang        #
#################
export GOARCH=amd64
export GOOS=linux

# GOROOT is the location where Go package is installed on your system.
export GOROOT=/usr/lib/go

# GOPATH is the location of your work directory.
export GOPATH=$HOME/projects/golang

# 安装目录的 bin 文件夹，须要加入 PATH 变量
export GOBIN=$GOPATH/bin
export PATH="$PATH:$(go env GOROOT)/bin:$(go env GOBIN)"

export GO111MODULE=on
export GOPROXY="https://goproxy.cn,direct"
export GOSUMDB=goproxy.cn/sumdb/sum.golang.org

#################
# Python        #
#################

# 禁用字节码(.pyc)文件
export PYTHONDONTWRITEBYTECODE=1

#################
# Node.js       #
#################

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

#################
# dotnet-sdk    #
#################

export DOTNET_ROOT=$HOME/bin/dotnet

# podman
export SUPPRESS_BOLTDB_WARNING=true

#################
# rustup        #
#################

# 长期启用镜像源加速 rustup 下载
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

export PATH="$PATH:$HOME/.cargo/bin"

##############
# Java Setup #
##############

# VERSIONS #
# Oracle JDK 8
# export JAVA_8_HOME=$HOME/bin/java/jdk1.8.0_212
# Oracle JDK 17
# export JAVA_17_HOME=$HOME/bin/java/jdk-17.0.6
# Azul Zulu Builds of OpenJDK
# Java 8 (LTS)
export JAVA_8_HOME=$HOME/bin/java/zulu8.90.0.19-ca-jdk8.0.472-linux_x64
# Java 11 (LTS)
export JAVA_11_HOME=$HOME/bin/java/zulu11.84.17-ca-jdk11.0.29-linux_x64
# Java 17 (LTS)
export JAVA_17_HOME=$HOME/bin/java/zulu17.62.17-ca-jdk17.0.17-linux_x64
# Java 21 (LTS)
export JAVA_21_HOME=$HOME/bin/java/zulu21.46.19-ca-jdk21.0.9-linux_x64
# Java 25 (LTS)
export JAVA_25_HOME=$HOME/bin/java/zulu25.30.17-ca-jdk25.0.1-linux_x64

# default JDK is 25
export JAVA_HOME=$JAVA_25_HOME
export JRE_HOME=$JAVA_25_HOME/jre

export PATH="$PATH:$JAVA_HOME/bin"

export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib

# Gradle Setup
export GRADLE_OPTS="-Xmx2g -XX:ReservedCodeCacheSize=512m"
# 不添加HOME环境变量，软链接到 /usr/local/bin
# ln -s $HOME/bin/java/gradle-6.7/bin/gradle /usr/local/bin

# Maven Setup
export MAVEN_OPTS="-Xmx2g -XX:ReservedCodeCacheSize=512m"
# 不添加HOME环境变量，软链接到 /usr/local/bin
# ln -s $HOME/bin/java/apache-maven-3.9.12/bin/mvn /usr/local/bin

#################
# Android Setup #
#################
# export ANDROID_HOME="/opt/android-sdk-linux"
# export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH"

#################
# claude        #
#################

export PATH="$PATH:$HOME/.claude/bin"

## [ECC]

# 通过环境变量
export CLAUDE_PACKAGE_MANAGER=pnpm

## [ECC] Runtime Hook Controls

# 钩子严格度配置文件（默认值：standard）
# minimal | standard | strict (default: standard)
export ECC_HOOK_PROFILE=standard

# Disable specific hook IDs (comma-separated)
export ECC_DISABLED_HOOKS="session-start:plan-canvas-sessions,stop:plan-canvas-pending,stop:desktop-notify"

# Cap SessionStart additional context (default: 8000 chars)
export ECC_SESSION_START_MAX_CHARS=4000

# Disable SessionStart additional context entirely
export ECC_SESSION_START_CONTEXT=off

#################
# grok          #
#################

export PATH="$HOME/.grok/bin:$PATH"
fpath=($HOME/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C

#################
# opencode      #
#################

# >>> oh-my-opencode-slim background subagents >>>
export OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true
export OPENCODE_ENABLE_EXA=1
# <<< oh-my-opencode-slim background subagents <<<

# ripgrep
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/.ripgreprc

PROJECT_PATHS=($HOME/projects/ai-coding/ $HOME/projects/private/ $HOME/projects/working/)

# zsh will load $ZDOTDIR/.zshrc automatically
