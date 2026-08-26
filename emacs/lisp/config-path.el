;;; config-path.el --- -*- lexical-binding: t -*-

;; A GUI Emacs started from Finder or the Dock inherits launchd's environment,
;; not the shell's, so tools installed under $HOME (nodenv shims, homebrew,
;; cargo) are invisible to `call-process' and `executable-find'.  Rather than
;; spawning a login shell at startup to copy PATH out of it, the directories
;; are listed explicitly and merged in.

(defun config-path--dirs (dirs)
  "Return the existing directories among DIRS, expanded, without duplicates."
  (delete-dups
   (delq nil
         (mapcar (lambda (d)
                   (let ((d (expand-file-name d)))
                     (and (file-directory-p d) d)))
                 dirs))))

(defun config-path-set (dirs)
  "Prepend DIRS to `exec-path', $PATH, and the dynamic library search path.
Directories that do not exist are skipped, so one list can be shared by
machines that have different tools installed."
  (let ((found (config-path--dirs dirs)))
    ;; `exec-path' is what `executable-find' and `call-process' consult;
    ;; $PATH is what a subprocess sees once it is running.  Both need it.
    (setq exec-path (delete-dups (append found exec-path)))
    (setenv "PATH" (string-join (delete-dups
                                 (append found
                                         (split-string (or (getenv "PATH") "")
                                                       path-separator t)))
                                path-separator))
    found))

(provide 'config-path)
