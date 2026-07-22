;;; config-project.el --- -*- lexical-binding: t -*-

(defun config-project-add-current ()
  "Mark `default-directory' as a project and remember it."
  (interactive)
  (require 'project)
  (let* ((dir (expand-file-name default-directory))
         (marker (expand-file-name ".project" dir)))
    (unless (file-exists-p marker)
      (make-empty-file marker t))
    (let ((pr (or (project-current nil dir) (cons 'transient dir))))
      (project-remember-project pr)
      (message "Project: %s" (project-root pr)))))

(defun config-project-forget (dir)
  "Forget project DIR and delete its .project marker."
  (interactive (progn (require 'project) (list (project-prompt-project-dir))))
  (let ((marker (expand-file-name ".project" dir)))
    (when (file-exists-p marker)
      (delete-file marker))
    (project-forget-project dir)
    (message "Forgot project: %s" (abbreviate-file-name dir))))

(defun config-project-set (list-file markers switch-command)
  (with-eval-after-load 'project
    (setq project-list-file list-file
          project-vc-extra-root-markers markers
          project-switch-commands switch-command)))

(provide 'config-project)
