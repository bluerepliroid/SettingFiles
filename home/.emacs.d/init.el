; load-path の設定

(setq load-path (append (list
                         (expand-file-name "~/.site-lisp")
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
