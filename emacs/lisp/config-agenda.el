;;; config-agenda.el --- -*- lexical-binding: t -*-

;; Retrieval across task notes.  `SPC nt' creates or reopens today's note;
;; this module is how you get back to every *other* one.
;;
;; Two views, because task notes use plain `- [ ]' checkboxes rather than org
;; TODO keywords, and `org-agenda' only ever sees the latter:
;;
;;   `config-agenda-pending' greps the checkboxes -- works on the notes as
;;   they are written today.
;;   `config-agenda-tasks' is a real agenda over the same files, and starts
;;   paying off as soon as any note grows a TODO headline.

(defvar config-agenda--dir nil
  "Directory holding the task notes, as passed to `config-agenda-set'.")

(defvar config-agenda--buffer "*pending*")

(defvar config-agenda--pending-regexp "^[[:space:]]*[-+*][[:space:]]+\\[ \\][[:space:]]*\\(.*\\)$"
  "Match an unchecked list item, capturing its text.")

(defun config-agenda--files ()
  "Return the task note files, newest first."
  (when (and config-agenda--dir (file-directory-p config-agenda--dir))
    (nreverse (directory-files config-agenda--dir t "\\.org\\'"))))

(defun config-agenda--title (file)
  "Return FILE's #+title, or its base name when it has none."
  (with-temp-buffer
    (insert-file-contents file nil 0 4096)
    (goto-char (point-min))
    (if (re-search-forward "^#\\+title:[[:space:]]*\\(.*\\)$" nil t)
        (string-trim (match-string 1))
      (file-name-base file))))

(defun config-agenda--collect (file)
  "Return a list of (LINE . TEXT) for each unchecked item in FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (let (items)
      (while (re-search-forward config-agenda--pending-regexp nil t)
        (push (cons (line-number-at-pos (match-beginning 0))
                    (string-trim (match-string 1)))
              items))
      (nreverse items))))

(defun config-agenda--visit ()
  "Open the task note behind the item at point."
  (interactive)
  (if-let* ((file (get-text-property (point) 'config-agenda-file)))
      (let ((line (get-text-property (point) 'config-agenda-line)))
        (pop-to-buffer (find-file-noselect file))
        (when line
          (goto-char (point-min))
          (forward-line (1- line))))
    (user-error "No task note on this line")))

(defvar config-agenda-pending-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") #'config-agenda--visit)
    (define-key map (kbd "g") #'config-agenda-pending)
    map)
  "Keymap for `config-agenda-pending-mode'.")

(define-derived-mode config-agenda-pending-mode special-mode "Pending"
  "Major mode for the list of unchecked task items."
  (setq-local truncate-lines t))

(with-eval-after-load 'evil
  (evil-define-key 'normal config-agenda-pending-mode-map
    (kbd "RET") #'config-agenda--visit
    "g" #'config-agenda-pending
    "q" #'quit-window))

(defun config-agenda-pending ()
  "Show every unchecked `- [ ]' item across all task notes, newest first.
RET on a line opens that note at the item; `g' refreshes."
  (interactive)
  (let ((files (config-agenda--files))
        (total 0))
    (unless files
      (user-error "No task notes found in %s" (or config-agenda--dir "<unset>")))
    (with-current-buffer (get-buffer-create config-agenda--buffer)
      (let ((inhibit-read-only t))
        (erase-buffer)
        (dolist (file files)
          (when-let* ((items (config-agenda--collect file)))
            (insert (propertize (config-agenda--title file)
                                'face 'font-lock-keyword-face)
                    "\n")
            (dolist (item items)
              (setq total (1+ total))
              (insert (propertize (concat "  " (cdr item) "\n")
                                  'config-agenda-file file
                                  'config-agenda-line (car item))))
            (insert "\n")))
        (if (zerop total)
            (insert (propertize "Nothing pending.\n" 'face 'font-lock-comment-face))
          (goto-char (point-min))
          (insert (propertize (format "%d pending across %d notes\n\n" total (length files))
                              'face 'font-lock-comment-face))))
      (goto-char (point-min))
      (config-agenda-pending-mode))
    (pop-to-buffer config-agenda--buffer)))

(defun config-agenda-tasks ()
  "Open an agenda restricted to the task notes."
  (interactive)
  (require 'org-agenda)
  (let ((org-agenda-files (config-agenda--files)))
    (unless org-agenda-files
      (user-error "No task notes found in %s" (or config-agenda--dir "<unset>")))
    (org-agenda nil "t")))

(defun config-agenda-set (dir)
  "Configure task-note retrieval over the notes in DIR.
DIR is resolved against `my/notes-dir' when relative."
  (setq config-agenda--dir (expand-file-name dir))

  (with-eval-after-load 'org-agenda
    ;; Rebuilt on each call rather than frozen here, so notes created later in
    ;; the session show up without a restart.
    (setq org-agenda-files (config-agenda--files)
          org-agenda-window-setup 'current-window
          org-agenda-restore-windows-after-quit t
          org-agenda-span 'day
          org-agenda-start-on-weekday nil)))

(provide 'config-agenda)
