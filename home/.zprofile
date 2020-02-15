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
export PATH=`brew --prefix coreutils`/libexec/gnubin:`brew --prefix binutils`/bin:$PATH:$HOME/bin
## MANPATH
export MANPATH=`brew --prefix coreutils`/libexec/gnuman:$MANPATH
## PYENV
export PYENV_ROOT=/usr/local/var/pyenv
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

sh -c "rm -f ~/.zsh_history.* 2> /dev/null"

eval `ssh-agent`
