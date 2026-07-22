;;; extension.el -*- lexical-binding: t; -*-
;;
;; Small editor extensions, ported from the old Doom config.
;; Loaded from init.el via `(load (locate-user-emacs-file "extension") nil t)'.

;; Make sure dired is loaded.
(require 'dired)

;; Unified create in dired: trailing `/' makes a directory, otherwise an empty
;; file. Nested paths (a/b/c.txt) get their parent dirs created automatically.
(defun +dired/create (name)
  "Create file or directory in current dired dir.
Trailing `/' means directory; otherwise empty file."
  (interactive (list (read-string "Create (end with / for dir): ")))
  (require 'dired)
  (let ((path (expand-file-name name (dired-current-directory))))
    (if (directory-name-p name)
        (make-directory path t)
      (make-directory (file-name-directory path) t)
      (write-region "" nil path))
    (revert-buffer)
    (dired-goto-file (directory-file-name path))))

;; Bind `+' in dired normal state (general override, so it wins over
;; evil-collection's default `dired-create-directory').
(with-eval-after-load 'dired
  (general-define-key
   :states 'normal
   :keymaps 'dired-mode-map
   "+" #'+dired/create))
