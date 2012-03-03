; load-path の設定

(setq load-path (append (list
                         (expand-file-name "~/.emacs.d")
                         )
                        load-path))


; 一般的な設定

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

;; c-mode, c++-mode
(add-hook 'c-mode-common-hook
          '(lambda ()
             ;;; K&R のスタイルを使う
             (c-set-style "k&r")
             ;;; インデントには tab を使う
             (setq indent-tabs-mode t)
             ;;; インデント幅
             (setq c-basic-offset 4)
             ))
(setq auto-mode-alist
      (append
       '(("\\.c$" . c-mode))
       '(("\\.h$" . c++-mode))
       '(("\\.cpp$" . c++-mode))
       '(("\\.hpp$" . c++-mode))
       auto-mode-alist))
