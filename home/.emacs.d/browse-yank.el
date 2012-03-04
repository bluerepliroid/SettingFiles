;From mende@athos.rutgers.edu Mon Oct  3 14:20:43 1988
;From: mende@athos.rutgers.edu (Bob Mende Pie)
;Newsgroups: gnu.emacs,comp.emacs
;Subject: Kill-Ring-Browser browse-yank.el
;Keywords: here it is...
;Date: 27 Sep 88 17:39:52 GMT
;Organization: Yows `R' us
;
;
;   I have received a lot of requests for my kill-ring-browser, so I will
;post it here...  Please mail me all comments and suggestions.  Also, rms
;pointed out that there is the yank-pop command (which is M-y by default...
;I bind browse-yank to M-y).  yank-pop acts can act as a kill-ring-browser,
;but it can be confusing as well. 

;; browse-yank.el
;;
;; A major mode for the browsing, editing, and selectively inserting
;; elements of the kill-ring.
;;
;; Written by Robert Mende  mende@rutgers.edu
;; send all bugs/suggestions to author
;;  suggested binding:  M-y

;; Copyright (C) 1985, 1986 Free Software Foundation, Inc.
;; This file is not officialy part of GNU Emacs.
;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY.  No author or distributor
;; accepts responsibility to anyone for the consequences of using it
;; or for whether it serves any particular purpose or works at all,
;; unless he says so in writing.  Refer to the GNU Emacs General Public
;; License for full details.

;; Everyone is granted permission to copy, modify and redistribute
;; GNU Emacs, but only under the conditions described in the
;; GNU Emacs General Public License.   A copy of this license is
;; supposed to have been given to you along with GNU Emacs so you
;; can know your rights and responsibilities.  It should be in a
;; file named COPYING.  Among other things, the copyright notice
;; and this notice must be preserved on all copies.


(defmacro for (i lb ub &rest body)
"Iterative \"for\" loop, in the form (for I LB UB BODY).  I is locally
set to each number between LB and UB inclusive.  Boundary points LB
and UB evaluated once.  BODY not evaluated if boundary test fails.
Returns nil."

  (list 'let (list (list i lb)
		   (list '__%__UB__%__ ub))
	(append (list 'while (list '<= i '__%__UB__%__))
		body
		(list (list 'setq i (list '1+ i))))))


(defvar browse-yank-buffer "*Browse Yank*"
  "name of the buffer in which the kill-ring is browsed.")

(defvar browse-yank-barf-message "Can't browse-yank an empty kill-ring."
  "Error message displayed when an attempt is made to browse an empty
kill-ring.   Raison d'etre stems from the ludicrous jests poked at the
command's name by people much less mature than you and I.")

(defvar browse-yank-height 5
  "number of lines in the browse-yank window")

(defvar browse-yank-inserted-p nil)

(defvar browse-yank-orig-window-config nil
  "Window configuration prior to splitting off the browse-yank window.")

(defvar browse-yank-cur 0
"The ordinal position in the kill-ring, starting from the most recent
kill (position 1).")

(defvar browse-yank-cur-txt "0"
  "As browse-yank-cur, but a string suitable for display in the
mode-line.")

(defvar browse-yank-max 0
"The ordinal position of the last element of the kill-ring.")

(defvar browse-yank-max-txt "0"
"As browse-yank-max, but a string suitable for display in the
mode-line.")


(defvar browse-yank-mode-map (make-sparse-keymap)
  "the keymap in used in browse-yank-mode.")
(define-key browse-yank-mode-map "\C-g" 'browse-yank-abort)
(define-key browse-yank-mode-map "\C-x\C-m" 'browse-yank-insert)
(define-key browse-yank-mode-map "?"    'describe-mode)
(define-key browse-yank-mode-map ">"    'browse-yank-goto-last)
(define-key browse-yank-mode-map "<"    'browse-yank-goto-first)
(define-key browse-yank-mode-map "s"    'browse-yank-search-forward)
(define-key browse-yank-mode-map "r"    'browse-yank-search-backward)
(define-key browse-yank-mode-map "q"    'browse-yank-quit)
(define-key browse-yank-mode-map "p"    'browse-yank-previous-yank)
(define-key browse-yank-mode-map "n"    'browse-yank-next-yank)
(define-key browse-yank-mode-map "m"    'browse-yank-yanks-saved)
(define-key browse-yank-mode-map "l"    'browse-yank-locate-regexp)
(define-key browse-yank-mode-map "j"    'browse-yank-goto-yank)
(define-key browse-yank-mode-map "i"    'browse-yank-insert)
(define-key browse-yank-mode-map "h"    'browse-yank-help)
(define-key browse-yank-mode-map "g"    'browse-yank-to-register)
(define-key browse-yank-mode-map "e"    'browse-yank-edit)



(defvar browse-yank-edit-mode-map (copy-keymap text-mode-map)
  "Keymap in use in browse-yank-edit-mode.")
(define-key browse-yank-edit-mode-map "\C-c\C-c" 'browse-yank-cease-edit)
(define-key browse-yank-edit-mode-map "\C-c\C-]" 'browse-yank-abort-edit)



;; define a mode that is only used when executing a browse-yank
(defun browse-yank-mode ()
  "Major mode for browsing, editing, and inserting elements of the
kill-ring.  This is a browse-yank specific facility, and should be
only used by the function browse-yank (see browse-yank).  Commands
are:
\\{browse-yank-mode-map}"

  (kill-all-local-variables)
  (make-local-variable 'mode-line-process)
  (make-local-variable 'minor-mode-alist)
  (mapcar '(lambda (minmode) 
	     (set (car minmode) nil))
	  minor-mode-alist)
  (use-local-map browse-yank-mode-map)  
  (setq mode-name "Browse Yank")
  (setq mode-line-process (concat ": "
				  browse-yank-cur-txt
				  "/"
				  browse-yank-max-txt))
  (setq buffer-read-only t)
  (setq major-mode 'browse-yank-mode)
  (goto-char (point-min))
  (run-hooks 'browse-yank-hook))

;; browse-yank ... The command that this whole thing is about
(defun browse-yank (arg)
  "An interactive kill-ring browsing, editing, and yanking utility.

See function browse-yank-mode for more details.

Author's gripe:

     When evaluated, the window split is messy, and I don't like the
lossage in the window configuration during the actual browse-yank.
I'm not sure who's to blame for the appearance.  Pop-to-buffer?
Split-window?  Myself?  I cant not have a window 'pop' to the top 
(or bottom) of the screen and not mess up the order of the buffers.
If you dont like it, please re-write it, and if you dont want to 
do that ....    see figure 1."

  (interactive "P") 
  (if (= 0 
	 (length kill-ring))
      (progn
	(ding)
	(message browse-yank-barf-message))
    (progn
      (setq browse-yank-orig-window-config (current-window-configuration))
      (pop-to-buffer (get-buffer-create browse-yank-buffer))
      (browse-yank-mode)
      (enlarge-window (- browse-yank-height (window-height)))
      (setq browse-yank-cur 0)
      (browse-yank-make-txt)
      (browse-yank-display 0))))

(defun browse-yank-abort ()
  "Abort a browse-yank."
  (interactive)
  (ding)
  (browse-yank-quit))

(defun browse-yank-quit ()
  "Quit gracefully from a browse-yank"
  (interactive)
  (set-window-configuration browse-yank-orig-window-config)
  (kill-buffer browse-yank-buffer)
  (if browse-yank-inserted-p
      (pop-to-buffer browse-yank-inserted-p)))

(defun browse-yank-insert ()
  "`Yank' the contents of the browse-yank-buffer (an element of the
kill-ring) at the point's last location outside of the buffer,
completing the browse-yank."
  (interactive)
  (save-window-excursion
    (delete-window)
    (setq browse-yank-inserted-p (buffer-name))
    (insert-buffer browse-yank-buffer))
  (browse-yank-quit))

(defun browse-yank-display (browse-yank-yank-to-display)
  "Display the kill-ring ELEMENT in the browse-yank buffer, updating
the mode-line."
  (setq buffer-read-only nil)
  (erase-buffer)
  (goto-char (point-min))
  (insert (nth browse-yank-yank-to-display
	       kill-ring))
  (goto-char (point-min))
  (setq mode-line-process (concat ": "
				  browse-yank-cur-txt
				  "/"
				  browse-yank-max-txt))
  (setq buffer-read-only t))

(defun browse-yank-make-txt ()
  "Update the textual versions of the counters used by browse-yank
       (see browse-yank-cur and browse-yank-max)."
  (setq browse-yank-cur-txt (int-to-string (1+ browse-yank-cur)))
  (setq browse-yank-max (1- (length kill-ring)))
  (setq browse-yank-max-txt (int-to-string (1+ browse-yank-max))))

(defun browse-yank-goto-first ()
  "Goto first element of kill-ring in browse-yank-mode."
  (interactive)
  (browse-yank-goto-yank 1))

(defun browse-yank-goto-last ()
  "Goto last element of kill-ring in browse-yank-mode."
  (interactive)
  (browse-yank-goto-yank (length kill-ring)))

(defun browse-yank-locate-regexp (string)
  "Display all elements of kill-ring that contain REGEXP, in
browse-yank-mode."
  (interactive (list 
		 (read-from-minibuffer 
		   (concat "Regexp to locate ["
			   search-last-regexp
			   "]: "))))
  (if (zerop (length string))
      (setq string search-last-regexp)
    (setq search-last-regexp string))
  (if (zerop (length string))
      (error "Cant search for NULL string")
    (let ((wherebe (mapcar '(lambda (el)
			      (if (string-match string el)
				  t))
			   kill-ring))
	  (loc ""))
      (for i 0 (length wherebe) 
	   (if (car (nthcdr i wherebe))
	       (setq loc (concat loc
			    (prin1-to-string (1+ i))
			    ","))))
      (if (zerop (length loc))
	  (progn (ding)
		 (message "String not found in any yanks."))
	(setq loc (substring loc
			     0 
			     (1- (length loc))))
	(message (concat "Found in yanks: "
			 loc
			 "."))))))


(defun browse-yank-search-backward (string)
  "Search backward in kill ring for REGEXP, in browse-yank-mode."
  (interactive (list (read-from-minibuffer 
		       (concat "Search backwards for regexp ["
			       search-last-regexp
			       "]: "))))
  (cond ((zerop (length string))
	  (setq string search-last-regexp)
	  (setq search-last-regexp string))
        ((zerop (length string))
	  (nil))
	(t
	  (let ((loc (1+ (regexp-search-list string
					     (nthcdr (- (length kill-ring) 
							browse-yank-cur)
						     (reverse kill-ring))))))
	    (if (<= loc browse-yank-cur)
	      (progn
		(browse-yank-next-yank loc)
		(goto-char (1+ (string-match string 
					     (buffer-substring (point-min)
							       (point-max))))))
	      (error "Search failed: \"%s\"" string))))))
  

(defun browse-yank-search-forward (string)
  "Search forward for a occurance of REGEXP in kill-ring, for
browse-yank."
  (interactive (list (read-from-minibuffer 
		       (concat "Search forward for regexp ["
			       search-last-regexp
			       "]: "))))
  (if (zerop (length string))
      (setq string search-last-regexp)
    (setq search-last-regexp string))
  (if (zerop (length string))
	(nil)
    (let ((loc (regexp-search-list string 
				   kill-ring
				   (1+ browse-yank-cur))))
      (if (= loc (length kill-ring))
	  (error "Search failed: \"%s\"" string)
	(browse-yank-goto-yank (1+ loc)))
      (goto-char (1+ (string-match string 
				   (buffer-substring (point-min)
						     (point-max))))))))

(defun browse-yank-goto-yank (arg)
  "Display the supplied kill-ring position in the browse-yank-buffer."
  (interactive "nGoto yank: ")
  (cond ((< arg 1)
	  (error "Argument must be positive."))
        ((> arg (length kill-ring))
	  (error "Argument exceeds the length of kill-ring."))
        (t
	  (setq browse-yank-cur (1- arg))
	  (browse-yank-make-txt)
	  (browse-yank-display browse-yank-cur))))

(defun browse-yank-next-yank (arg)
  "Goto the next element of the kill-ring in browse-yank buffer."
  (interactive "p")
  (let ((temp-pos (- browse-yank-cur arg)))
    (cond ((< temp-pos 0)
	    (error "No following item in kill-ring."))
          ((> temp-pos (- (length kill-ring) 1))
	    (error "No preceding item in kill-ring."))
	  (t
	    (setq browse-yank-cur (- browse-yank-cur arg))
	    (browse-yank-make-txt)
	    (browse-yank-display browse-yank-cur)))))

(defun browse-yank-previous-yank (arg)
  "Goto the previous element of the kill-ring in browse-yank buffer."
  (interactive "p")
  (browse-yank-next-yank (- arg)))

(defun buffer-to-register (char)
"Set the contents of the current buffer into register CHAR."
  (interactive "cCopy to register: ")
  (set-register char (buffer-substring (point-min) (point-defun))))
(fset 'browse-yank-to-register
      (symbol-function 'buffer-to-register))

(defun browse-yank-help ()
  "Spit out a simple help message for browse-yank-mode."
  (interactive)
  (message "(e)dit (i)nsert (j)ump (l)ocate (n)ext (p)revious (q)uit (?)describe-mode"))

(defun browse-yank-yanks-saved (string)
  "Set kill-ring-max to a user defined value and make sure that
displayed information is valid and sane."
  (interactive (list (read-from-minibuffer
		       (concat "Number of elements in kill-ring ["
			       kill-ring-max
			       "]: "))))
  (if (not (zerop (length string)))
      (let ((size (string-to-int string)))
	(if (or (not (numberp size))
		(<= size 0))
		   (error "Please give a positive number."))
	(setq kill-ring-max size)	       	
	(if (> (length kill-ring) kill-ring-max)
	    (setcdr (nthcdr (1- kill-ring-max) kill-ring) nil))	
	(setq kill-ring-yank-pointer kill-ring)
	(if (< size (1+ browse-yank-max))
	    (progn
	      (setq browse-yank-max size)
	      (if (< size (1+ browse-yank-cur))
		  (progn
		    (setq browse-yank-cur browse-yank-max)
		    (browse-yank-goto-yank browse-yank-cur))
		(browse-yank-goto-yank (1+ browse-yank-cur))))))))

(defun browse-yank-edit-mode ()
  "Major mode for editing the contents of a Yank Buffer
The editing commands are the same as in Text mode, together with two commands
to return to regular Browse Yank Mode:
\\{browse-yank-edit-mode-map}?

This mode runs the contents of browse-yank-edit-mode-hook if it exists."
  (use-local-map browse-yank-edit-mode-map)
  (setq major-mode 'browse-yank-edit-mode)
  (setq mode-name "Browse Yank Edit")
  (run-hooks 'browse-yank-edit-mode-hook))

(defun browse-yank-edit ()
  "Edit the browse-yank buffer; switch to browse-yank-edit-mode."
  (interactive)
  (browse-yank-edit-mode)
  (setq buffer-read-only nil)
  (set-buffer-modified-p (buffer-modified-p))
  (setq mode-line-process (concat "ing: " 
				  browse-yank-cur-txt))
  (message "Editing: Type C-c C-c to return to Browse Yank, C-c C-] to abort."))

(defun browse-yank-cease-edit ()
  "Finish editing message; switch back to Browse Yank proper."
  (interactive)
  (rplaca (nthcdr browse-yank-cur kill-ring) 
	  (buffer-substring (point-min)
			    (point-max)))
  (setq buffer-read-only t)
  (browse-yank-mode)
  (browse-yank-display browse-yank-cur))

(defun browse-yank-abort-edit ()
  "Abort edit of browse-yank buffer; restore original contents."
  (interactive)
  (setq buffer-read-only t)
  (browse-yank-mode)
  (browse-yank-display browse-yank-cur))

(defun regexp-search-list (re l &optional start)
  "Return position of first occurence of REGEXP in LIST starting
at position START (optional)."
  (if (null start)
      (setq start 0))
  (+ start
     (- (length (nthcdr start l))
	(length (memq t (mapcar '(lambda (el)
				   (if (string-match re
						     el)
				       t))
				(nthcdr start l)))))))



;					/Bob...
;-- 
;{...}!rutgers!mende	  mende@aramis.rutgers.edu	   mende@zodiac.bitnet
;
;STEVEN SPEILBERG has a hangnail on his left foot, I am so envious!

(provide 'browse-yank)
