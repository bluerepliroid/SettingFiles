; load-path の設定

(setq load-path (append (list
                         (expand-file-name "~/.emacs.d")
                         )
                        load-path))


; 起動時の設定

;; emacsclient からのファイルオープンを受け付ける
(server-start)
;; 初期画面を表示させない
(setq inhibit-startup-screen t)
;; scratch バッファに何も表示しない
(setq initial-scratch-message "")
;; Message バッファを表示させない
(setq message-log-max nil)
;; バックアップファイルが生成されないようにする
(setq backup-inhibited t)


; 言語の設定

;; 日本語表示の設定
(set-language-environment 'Japanese)
(prefer-coding-system 'utf-8)


; 見た目の設定

;; フォントの設定
(cond (window-system
       (set-default-font "September-16")
       (set-fontset-font (frame-parameter nil 'font)
                         'japanese-jisx0208
                         '("September" . "unicode-bmp"))
       ))
;; フレームパラメータ初期値の設定
(setq default-frame-alist
      (append (list
               ;; default color
               '(background-color . "black")
               '(foreground-color . "white")
               ;; cursor
               '(cursor-color . "gray")
               '(cursor-type . box)
               '(cursor-height . 4)
               ;; mouse cursor
               '(mouse-color . "white")
               ;; border
               '(border-color . "black")
               ;; size
               '(width . 80)  ; 横幅(桁数)
               '(height . 40) ; 高さ(行数)
               ;; location
               '(left . 0) ; 左上隅 x 座標
               '(top . 0)  ; 左上隅 y 座標
               )
              default-frame-alist))

;; cursor を点滅させない
(blink-cursor-mode nil)

;; menu bar を表示させない
(menu-bar-mode -1)
(cond (window-system
       ;; tool bar を表示させない
       (tool-bar-mode 0)
       ;; scroll bar を表示させない
       (scroll-bar-mode -1)
       ))

;; 行番号・桁番号を modeline に表示する
(line-number-mode t)   ; 行番号
(column-number-mode t) ; 桁番号

;; 色の設定
(global-font-lock-mode t)
(require 'face-list)
;; region
(transient-mark-mode t)
(set-face-background 'region "cornflower blue")
(set-face-foreground 'region "snow")
;; modeline
(set-face-background 'modeline "dark slate gray")
(set-face-foreground 'modeline "snow")
(set-face-bold-p 'modeline nil)
;; comment
(set-face-foreground 'font-lock-comment-face "MediumPurple1")

;; search している単語を highlight する
(setq search-highlight t)
;; replace するときに highlight する
(setq query-replace-highlight t)

;; cursor 位置の face を調べる関数
(defun describe-face-at-point ()
  "Return face used at point."
  (interactive)
  (message "%s" (get-char-property (point) 'face)))


; 各種 mode の設定

;; text-mode
(add-hook 'text-mode-hook
          '(lambda ()
             (progn
               ;; 整形時の列数
               (set-fill-column 76)
               )))

;; c/c++-mode
(add-hook 'c-mode-common-hook
          '(lambda ()
             ;; K&R のスタイルを使う
             (c-set-style "k&r")
             ;; インデントには tab を使う
             (setq indent-tabs-mode t)
             ;; インデント幅
             (setq c-basic-offset 4)
             ))
(setq auto-mode-alist
      (append
       '(("\\.c$" . c-mode))
       '(("\\.h$" . c++-mode))
       '(("\\.cpp$" . c++-mode))
       '(("\\.hpp$" . c++-mode))
       auto-mode-alist))

;; asm-mode
(add-hook 'asm-mode-hook
          '(lambda ()
             ;; インデントには tab を使う
             (setq indent-tabs-mode t)
             ;; インデント幅
             (setq tab-width 8)
             ))
;; コメント開始文字
(setq asm-comment-char ?#)

;; makefile-gmake-mode
(setq auto-mode-alist
      (append
       '(("\\.mk$" . makefile-gmake-mode))
       '(("[Mm]akefile*$" . makefile-gmake-mode))
       auto-mode-alist))


; global key の設定

(global-set-key "\M-p" 'backward-paragraph)
(global-set-key "\M-n" 'forward-paragraph)
(global-set-key [delete] 'delete-char)
(global-set-key "\C-h" 'delete-backward-char)
(defun kill-line-twice (&optional numlines)
  "Acts like normal kill except kills entire line if at beginning."
  (interactive "p")
  (cond ((or (= (current-column) 0)
             (> numlines 1))
         (kill-line numlines))
        (t (kill-line))))
(global-set-key "\C-k" 'kill-line-twice)
(global-set-key "\C-x\C-d" nil)
(global-set-key "\C-u" nil)

(global-set-key "\M-s" 'delete-trailing-whitespace)
(global-set-key "\M-r" 'replace-string)
(global-set-key "\M-\C-r" 'query-replace)
(global-set-key "\C-x\C-q" 'toggle-read-only)
(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-c\C-c" 'comment-region)
(global-set-key "\C-u\C-c" 'uncomment-region)
(global-set-key "\M-?" 'help-for-help)
(global-set-key "\C-x\C-e" 'eval-buffer)


; 一般的な設定

;; tab ではなく space を使う
(setq-default indent-tabs-mode nil)
;; tab 幅を 4 に設定
(setq-default tab-width 4)
;; バッファの最後の行で next-line しても新しい行を作らない
(setq next-line-add-newlines nil)
;; narrowing を禁止
(put 'narrow-to-region 'disabled nil)
;; スクロールステップを 1 に設定
(setq scroll-step 1)
;; マウスホイールでスクロール
(defun scroll-down-with-lines ()
  "Scroll down by multiple lines."
  (interactive)
  (scroll-down 5))
(defun scroll-up-with-lines ()
  "Scroll up by multiple lines."
  (interactive)
  (scroll-up 5))
(global-set-key [mouse-4] 'scroll-down-with-lines)
(global-set-key [mouse-5] 'scroll-up-with-lines)
;; マウスカーソルがあるバッファをスクロール
(setq mouse-wheel-follow-mouse t)


; その他の emacs-lisp の設定

;; undo
(global-set-key "\C-z" 'undo)
;; redo: undo のキャンセル
(require 'redo)
(global-set-key "\M-z" 'redo)

;; browse-yank: 過去の kill-ring の内容を表示しながら貼付
;; p: previous
;; n: next
;; i: insert
(require 'browse-yank)
(global-set-key "\M-y" 'browse-yank)

;; migemo: 日本語検索
;; C-s, C-r: migemo isearch
;; C-u C-s, C-u C-r: isearch
(require 'migemo)
(setq migemo-command "cmigemo")
(setq migemo-options '("-q" "--emacs"))
(setq migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict")
(setq migemo-user-dictionary nil)
(setq migemo-regex-dictionary nil)
(setq migemo-coding-system 'utf-8-unix)
(setq migemo-use-pattern-alist t)          ; キャッシュを利用
(setq migemo-use-frequent-pattern-alist t) ; 頻出パターンをキャッシュ
(setq migemo-pattern-alist-length 1000)    ; 履歴の数
(make-face 'migemo-message-prefix)         ; prefix の色
(face-spec-set 'migemo-message-prefix
               '((t (:foreground "gray"))))
(setq migemo-message-prefix-face 'migemo-message-prefix)
(migemo-init)                              ; 初期化
(set-process-query-on-exit-flag migemo-process nil)
