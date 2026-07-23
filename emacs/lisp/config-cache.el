;;; config-cache.el --- -*- lexical-binding: t -*-

(defun config-cache-set (dir)
  (let ((backups        (expand-file-name "backup/" dir))
        (autosaves      (expand-file-name "auto-save/" dir))
        (locks          (expand-file-name "lock/" dir))
        (auto-save-list (expand-file-name "auto-save-list/" dir))
        (transient      (expand-file-name "transient/" dir)))
    (dolist (d (list backups autosaves locks auto-save-list transient))
      (make-directory d t))

    (setq backup-directory-alist         `((".*" . ,backups))
          auto-save-file-name-transforms `((".*" ,autosaves t))
          lock-file-name-transforms      `((".*" ,locks t))
          backup-by-copying t)

    (setq auto-save-list-file-prefix  (expand-file-name ".saves-" auto-save-list)
          savehist-file               (expand-file-name "history" dir)
          recentf-save-file           (expand-file-name "recentf" dir)
          eshell-directory-name       (expand-file-name "eshell/" dir)
          tramp-persistency-file-name (expand-file-name "tramp" dir)
          url-configuration-directory (expand-file-name "url/" dir)
          transient-history-file      (expand-file-name "history.el" transient)
          transient-values-file       (expand-file-name "values.el" transient)
          transient-levels-file       (expand-file-name "levels.el" transient))))

(provide 'config-cache)
