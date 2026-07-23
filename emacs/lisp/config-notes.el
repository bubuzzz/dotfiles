;;; config-notes.el --- -*- lexical-binding: t -*-

(defun my/notes-scratch ()
  "Open a quick scratchpad note in the denote directory.

Creates (or revisits) a single org file per day named like a normal
denote note, so it is searchable and linkable alongside everything else."
  (interactive)
  (require 'denote)
  (let* ((today (format-time-string "%Y-%m-%d"))
         (existing (car (denote-directory-files (concat "scratch-" today)))))
    (if existing
        (find-file existing)
      (denote (concat "scratch " today) '("scratch")))))

(defun config-notes-set (dir keywords)
  "Configure denote to store notes in DIR with default KEYWORDS."
  (with-eval-after-load 'denote
    (setq denote-directory (expand-file-name dir)
          denote-known-keywords keywords
          denote-file-type 'org
          denote-prompts '(title keywords)
          denote-date-prompt-use-org-read-date t)
    (make-directory denote-directory t)
    ;; Fontify [[denote:...]] links wherever they appear.
    (add-hook 'find-file-hook #'denote-fontify-links-mode-maybe)
    (denote-rename-buffer-mode 1)))

(provide 'config-notes)
