;; Force-load dired up front. Without this, invoking `dired-jump' from the
;; dashboard (before any project/file has been opened) fails with
;; "Symbol's function definition is void: dired-read-dir-and-switches"
;; because dired.el hasn't been required yet.
(require 'dired)

;; Unified create in dired: trailing `/' makes a directory, otherwise an
;; empty file. Nested paths (a/b/c.txt) get parent dirs created automatically.
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

(map! :after dired
      :map dired-mode-map
      :n "+" #'+dired/create)
