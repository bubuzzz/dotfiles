;;; config-completion.el --- -*- lexical-binding: t -*-

(defun config-completion-set (count keys)
  (require 'vertico)
  (require 'vertico-directory)
  (setq vertico-count count)
  (vertico-mode 1)
  (dolist (key keys)
    (define-key vertico-map (kbd (car key)) (cdr key)))
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy))

(provide 'config-completion)
