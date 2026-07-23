;;; config-lsp.el --- -*- lexical-binding: t -*-

(defun config-lsp--ensure-in-project ()
  (when (project-current)
    (eglot-ensure)))

(defun config-lsp-set (servers keys)
  (with-eval-after-load 'eglot
    (dolist (server servers)
      (add-to-list 'eglot-server-programs server)))

  (dolist (server servers)
    (dolist (mode (ensure-list (car server)))
      (add-hook (intern (format "%s-hook" mode)) #'config-lsp--ensure-in-project)))

  (with-eval-after-load 'evil
    (dolist (key keys)
      (define-key evil-normal-state-map (kbd (car key)) (cdr key))))

  (with-eval-after-load 'pyvenv
    (pyvenv-mode 1)
    (add-hook 'pyvenv-post-activate-hooks
              (lambda ()
                (when (bound-and-true-p eglot--managed-mode)
                  (eglot-reconnect))))))

(provide 'config-lsp)
