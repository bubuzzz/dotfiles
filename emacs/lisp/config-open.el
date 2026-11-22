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

(defun config-open--environment ()
  "Return `process-environment' with the selected frame's display variables.
Emacs often runs as a daemon started before the graphical session, so its
own environment has no DISPLAY.  Without it xdg-open thinks there is no
desktop and falls back to terminal viewers (the file shows up as bytes).
Frames made by emacsclient carry the client's environment, so take
DISPLAY and friends from there."
  (let ((env (copy-sequence process-environment))
        (frame-env (frame-parameter nil 'environment))
        (frame-display (frame-parameter nil 'display)))
    (dolist (var '("DISPLAY" "WAYLAND_DISPLAY" "XAUTHORITY"
                   "XDG_RUNTIME_DIR" "DBUS_SESSION_BUS_ADDRESS"))
      (let ((val (or (getenv-internal var frame-env)
                     (and (equal var "DISPLAY") (stringp frame-display)
                          frame-display))))
        (when val
          (setq env (cons (concat var "=" val) env)))))
    env))

(defun config-open-file (file &rest _)
  "Open FILE with the desktop handler.
Falls back to `find-file' on a system with no known opener.  Extra
arguments are ignored so this can be used directly in `org-file-apps'."
  (interactive "fOpen externally: ")
  (let ((command (config-open-command))
        (path (expand-file-name file)))
    (if (not command)
        (find-file path)
      ;; `start-process-shell-command' keeps Emacs responsive and detaches the
      ;; viewer, so quitting Emacs does not take it down.
      (let ((process-environment (config-open--environment))
            (process-connection-type nil))
        (start-process-shell-command
         "config-open" nil (format command (shell-quote-argument path)))))))

(defvar config-open--regexp nil
  "File-name regexp of the extensions given to `config-open-set'.")

(defun config-open-external-p (file)
  "Non-nil when FILE should open in the desktop viewer."
  (and config-open--regexp (config-open-command)
       (string-match-p config-open--regexp file)))

(defun config-open-set (extensions)
  "Make org open links whose file matches EXTENSIONS externally.
EXTENSIONS is a list of bare extensions, e.g. (\"png\" \"svg\").
Markdown uses the same list, see `config-markdown-open'."
  (setq config-open--regexp
        (concat "\\." (regexp-opt extensions t) "\\'"))
  (when-let* (((config-open-command))
              (regexp config-open--regexp))
    (with-eval-after-load 'org
      ;; An entry earlier in `org-file-apps' wins, and the (auto-mode . emacs)
      ;; default would otherwise claim images first.
      ;; A function rather than the command string, so the opener gets the
      ;; frame's DISPLAY (see `config-open--environment').
      (add-to-list 'org-file-apps (cons regexp #'config-open-file)))))

(provide 'config-open)
