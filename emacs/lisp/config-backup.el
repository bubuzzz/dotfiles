;;; config-backup.el --- -*- lexical-binding: t -*-

(defun config-backup-set (dir)
  (let ((backups   (expand-file-name "backup/" dir))
        (autosaves (expand-file-name "auto-save/" dir))
        (locks     (expand-file-name "lock/" dir)))
    (dolist (d (list backups autosaves locks))
      (make-directory d t))
    (setq backup-directory-alist        `((".*" . ,backups))
          auto-save-file-name-transforms `((".*" ,autosaves t))
          lock-file-name-transforms      `((".*" ,locks t))
          backup-by-copying t)))

(provide 'config-backup)
