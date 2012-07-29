# 環境変数

## LANG
export LANG=ja_JP.UTF-8
## misc
export USER=$USERNAME
export HOSTNAME=$HOST
## history
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=50000
export SAVEHIST=50000
## EDITOR
foreach editor ( vim vi )
if ( which $editor >& /dev/null ) then
    export EDITOR=$editor
    break
fi
end
## PATH
export PATH=`brew --prefix coreutils`/libexec/gnubin:`brew --prefix`/bin:$PATH:$HOME/bin
## MANPATH
export MANPATH=$MANPATH:/usr/man:/usr/local/man

## ls の表示色
if ( which dircolors >& /dev/null ) then
    eval `dircolors --sh ~/.dircolors`
    export LS_COLORS="${LS_COLORS}:*~=01;42:*#=01;42:*%=01;42"
fi
export ZLS_COLORS=$LS_COLORS
## 補完候補を色付け
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zmodload -ui complist

sh -c "rm -f ~/.zsh_history.* 2> /dev/null"
