;;; config-org.el --- -*- lexical-binding: t -*-

(defun config-org-set (headline-bullets item-bullets key-theme)
  (add-hook 'org-mode-hook #'org-superstar-mode)
  (add-hook 'org-mode-hook #'evil-org-mode)

  (with-eval-after-load 'org
    (setq org-hide-emphasis-markers t
          org-auto-align-tags t
          org-hide-leading-stars t
          org-pretty-entities t
          org-use-sub-superscripts '{}
          org-catch-invisible-edits 'show-and-error
          org-startup-truncated nil)
    (dolist (face '(org-level-1 org-level-2 org-level-3 org-level-4
                    org-level-5 org-level-6 org-level-7 org-level-8
                    org-document-title))
      (face-spec-set face '((t (:height 1.0))) 'face-override-spec)))

  (with-eval-after-load 'org-superstar
    (setq org-superstar-headline-bullets-list headline-bullets
          org-superstar-item-bullet-alist item-bullets))

  (with-eval-after-load 'evil-org
    (evil-org-set-key-theme key-theme)))

(provide 'config-org)
