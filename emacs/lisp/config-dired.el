;;; config-dired.el --- -*- lexical-binding: t -*-

(defun config-dired-create (name)
  "Create NAME in the current directory.
NAME is a directory when it ends in a slash, otherwise an empty file.
Surrounding whitespace is trimmed; missing parents are created as needed."
  (interactive
   (list (read-file-name "Create (end with / for a directory): "
                         (dired-current-directory)))
   dired-mode)
  (let* ((trimmed (string-trim-right name))
         (dirp (directory-name-p trimmed))
         (bare (directory-file-name trimmed))
         (path (expand-file-name
                (string-trim (file-name-nondirectory bare))
                (file-name-directory bare))))
    (if dirp
        (dired-create-directory path)
      (dired-create-empty-file path))))

(defun config-dired-set ()
  (with-eval-after-load 'dired
    (define-key dired-mode-map [remap dired-create-directory] #'config-dired-create)))

(provide 'config-dired)
