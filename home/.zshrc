## エイリアスコマンド
source ~/.zaliases

## ファイル・ディレクトリの生成マスク
umask 022

## プロンプト
setopt prompt_subst
HOST=`hostname -s`
PROMPT='%{[1m%}$USER@$HOST:%4~%(!.#.$)%{[m%} '

## キーバインド
### emacs
bindkey -e

bindkey "^[[3~" delete-char

## コマンド入力補完
autoload -U compinit
compinit
## コマンドの途中から履歴を呼び出す
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
## コマンド名を訂正
#setopt correct
## ファイル名を訂正
#setopt correct_all
## 複数のターミナルでコマンド履歴を共有
setopt share_history
## コマンドの開始時間、経過時間を履歴に保存
setopt extended_history  
## コマンドの不要な空白を削除して履歴に追加
setopt hist_reduce_blanks
## 直前と同じコマンドを履歴に追加しない
setopt hist_ignore_dups
## history コマンド自身を履歴に追加しない
setopt hist_no_store
## スペースで始まるコマンドを履歴に追加しない
setopt hist_ignore_space

## 補完候補をスッキリ表示
setopt list_packed
## ファイル名中の数字を数字としてソート
setopt numeric_glob_sort
## 日本語のファイル名も補完リストで表示
setopt print_eight_bit
## TAB で順次補完候補を切り換える
setopt auto_menu 
## 括弧の対応を自動的に補完
setopt auto_param_keys
setopt no_list_ambiguous

## rm で * を使う際に聞き返してこない
setopt rm_star_silent

## 変数をディレクトリパスとして利用する
setopt auto_name_dirs
## 変数を区切る空白の解釈を sh と同義にする
setopt sh_word_split

## cd コマンドで自動的に pushd する
setopt auto_pushd
## pushd でスタックの内容を表示しない
setopt pushd_silent
## pushd の重複を防ぐ
setopt pushd_ignore_dups 

## 親プロセスが死んでも子プロセスが死なない
setopt nohup

## ビープ音を鳴らさない
setopt no_beep

[[ $EMACS = t ]] && unsetopt zle
