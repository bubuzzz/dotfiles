;;; config-open.el --- -*- lexical-binding: t -*-

;; Route some file links to the desktop's own handler instead of opening
;; them in a buffer.  Rendered diagrams are the motivating case: inline
;; display is fine for reading, but zooming into a dense graph wants a real
;; image viewer.

(defvar org-file-apps)

(defvar config-open--openers
  '((darwin     . "open %s")
    (gnu/linux  . "xdg-open %s")
    (windows-nt . "start \"\" %s"))
  "Shell command per `system-type' that hands a file to the desktop.")

(defun config-open-command ()
  "Return the desktop open command for this system, or nil."
  (alist-get system-type config-open--openers))

(defun config-open-file (file)
  "Open FILE with the desktop handler.
Falls back to `find-file' on a system with no known opener."
  (interactive "fOpen externally: ")
  (let ((command (config-open-command))
        (path (expand-file-name file)))
    (if (not command)
        (find-file path)
      ;; `start-process-shell-command' keeps Emacs responsive and detaches the
      ;; viewer, so quitting Emacs does not take it down.
      (start-process-shell-command
       "config-open" nil (format command (shell-quote-argument path))))))

(defun config-open-set (extensions)
  "Make org open links whose file matches EXTENSIONS externally.
EXTENSIONS is a list of bare extensions, e.g. (\"png\" \"svg\")."
  (when-let* ((command (config-open-command))
              (regexp (concat "\\." (regexp-opt extensions t) "\\'")))
    (with-eval-after-load 'org
      ;; An entry earlier in `org-file-apps' wins, and the (auto-mode . emacs)
      ;; default would otherwise claim images first.
      (add-to-list 'org-file-apps (cons regexp command)))))

(provide 'config-open)
