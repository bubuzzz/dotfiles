;;; config-dired.el --- -*- lexical-binding: t -*-

(defun config-dired-create (name)
  "Create NAME in the current directory.
NAME is a directory when it ends in a slash, otherwise an empty file.
Missing parent directories are created as needed."
  (interactive
   (list (read-file-name "Create (end with / for a directory): "
                         (dired-current-directory)))
   dired-mode)
  (if (directory-name-p name)
      (dired-create-directory name)
    (dired-create-empty-file name)))

(defun config-dired-set ()
  (with-eval-after-load 'dired
    (define-key dired-mode-map [remap dired-create-directory] #'config-dired-create)))

(provide 'config-dired)
