;;; config-notes.el --- -*- lexical-binding: t -*-

(defun config-notes--quick (name daily)
  "Create a note keyworded NAME inside the NAME subdirectory.

Denote will not create the subdirectory itself and silently falls back
to the root when it is missing, so make it first.  When DAILY, reuse
today's note instead of creating a second one."
  (require 'denote)
  (let ((dir (expand-file-name name (denote-directory))))
    (make-directory dir t)
    (if (not daily)
        (denote (denote-title-prompt) (list name) nil dir)
      (let* ((today (format-time-string "%Y-%m-%d"))
             (existing (car (denote-directory-files (format "%s-%s" name today)))))
        (if existing
            (find-file existing)
          (denote (format "%s %s" name today) (list name) nil dir))))))

(defun config-notes-set (dir keywords quick)
  "Configure denote to store notes in DIR with default KEYWORDS.
QUICK is an alist of (NAME . PLIST); each entry defines a
`config-notes-NAME' command filing into the NAME subdirectory."
  (with-eval-after-load 'denote
    (setq denote-directory (expand-file-name dir)
          denote-known-keywords keywords
          denote-file-type 'org
          denote-prompts '(title keywords)
          denote-date-prompt-use-org-read-date t)
    (make-directory denote-directory t)
    ;; Fontify [[denote:...]] links wherever they appear.
    (add-hook 'find-file-hook #'denote-fontify-links-mode-maybe)
    (denote-rename-buffer-mode 1))

  (dolist (entry quick)
    (let ((name (car entry))
          (daily (plist-get (cdr entry) :daily)))
      (defalias (intern (format "config-notes-%s" name))
        (lambda ()
          (interactive)
          (config-notes--quick name daily))
        (format "Create or visit a %s note in the %s/ subdirectory." name name)))))

(provide 'config-notes)
