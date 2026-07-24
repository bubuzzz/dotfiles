;;; config-shortcut.el --- -*- lexical-binding: t -*-

(defvar config-shortcut--leader nil)
(defvar config-shortcut--shortcuts nil)
(defvar config-shortcut--buffer "*shortcuts*")

(defun config-shortcut--cells ()
  "Turn the flat shortcut plist into a list of (KEY . COMMAND) labels."
  (let ((rest config-shortcut--shortcuts)
        cells)
    (while rest
      (let ((key (pop rest))
            (command (pop rest)))
        (push (cons (concat config-shortcut--leader " " (mapconcat #'string key " "))
                    (replace-regexp-in-string "\\`\\(config-\\|my/\\)" ""
                                              (symbol-name command)))
              cells)))
    (nreverse cells)))

(defun config-shortcut--render (width)
  "Return the shortcut table laid out for a window of WIDTH columns."
  (let* ((cells (config-shortcut--cells))
         (kw (apply #'max (mapcar (lambda (c) (length (car c))) cells)))
         (cw (apply #'max (mapcar (lambda (c) (length (cdr c))) cells)))
         (cols (max 1 (min (length cells) (/ (- width 2) (+ kw cw 4)))))
         (rows (ceiling (length cells) cols))
         lines)
    (dotimes (row rows)
      (let ((line "  "))
        (dotimes (col cols)
          (when-let* ((cell (nth (+ row (* col rows)) cells)))
            (setq line (concat line
                               (propertize (string-pad (car cell) kw)
                                           'face 'font-lock-keyword-face)
                               "  "
                               (propertize (string-pad (cdr cell) cw)
                                           'face 'font-lock-comment-face)
                               "  "))))
        (push (string-trim-right line) lines)))
    (string-join (nreverse lines) "\n")))

(defun config-shortcut-show ()
  "Toggle a bottom side window listing the leader shortcuts."
  (interactive)
  (if-let* ((window (get-buffer-window config-shortcut--buffer)))
      (quit-window nil window)
    (let ((buffer (get-buffer-create config-shortcut--buffer)))
      (with-current-buffer buffer
        (let ((inhibit-read-only t))
          (erase-buffer)
          (insert (config-shortcut--render (frame-width))))
        (goto-char (point-min))
        (special-mode)
        (setq-local mode-line-format nil))
      (display-buffer-in-side-window
       buffer '((side . bottom)
                (window-height . fit-window-to-buffer)
                (preserve-size . (nil . t)))))))

(defun config-shortcut-set (leader shortcuts mode-shortcuts)
  (require 'general)
  (general-evil-setup)

  (setq config-shortcut--leader leader
        config-shortcut--shortcuts shortcuts)

  (apply #'general-define-key
         :states '(normal visual motion)
         :keymaps 'override
         :prefix leader
         :global-prefix (concat "C-" leader)
         shortcuts)

  (dolist (spec mode-shortcuts)
    (apply #'general-define-key
           :states '(normal visual motion)
           :keymaps (car spec)
           :prefix leader
           (cdr spec))))

(provide 'config-shortcut)
