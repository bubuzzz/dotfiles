;;; config-org.el --- -*- lexical-binding: t -*-

(require 'ob)
(require 'config-diagram)

(defun my/org-insert-jupyter-python-block ()
  "Insert a jupyter-python src block at point."
  (interactive)
  (let ((col (current-column)))
    (when (and (not (bolp))
               (save-excursion (beginning-of-line)
                               (looking-at-p "[[:space:]]*$")))
      (delete-horizontal-space))
    (unless (bolp) (newline))
    (insert "#+begin_src jupyter-python\n\n#+end_src\n")
    (forward-line -2)
    (move-to-column col)))

(defun config-org--refresh-inline-images ()
  "Redisplay inline images, discarding the cached copy of each file."
  (org-display-inline-images nil t))

(defun config-org--when-jupyter (orig &rest args)
  (when (executable-find "jupyter")
    (apply orig args)))

(defun config-org-set (headline-bullets item-bullets key-theme)
  (add-hook 'org-mode-hook #'org-superstar-mode)
  (add-hook 'org-mode-hook #'evil-org-mode)

  ;; Org is a large package; loading it lazily makes the first org file of a
  ;; session (e.g. via `SPC n s') take ~1s.  Warm it during idle time after
  ;; startup so the first real open is instant.
  (run-with-idle-timer
   1 nil (lambda () (require 'org) (require 'org-superstar) (require 'evil-org)
           (require 'olivetti)))

  (with-eval-after-load 'org
    (setq org-hide-emphasis-markers t
          org-auto-align-tags t
          org-hide-leading-stars t
          org-pretty-entities t
          org-use-sub-superscripts '{}
          org-catch-invisible-edits 'show-and-error
          org-startup-truncated nil
          org-startup-with-inline-images t
          org-fontify-whole-heading-line t)
    (add-hook 'org-babel-after-execute-hook #'config-org--refresh-inline-images)
    (dolist (face '(org-level-1 org-level-2 org-level-3 org-level-4
                    org-level-5 org-level-6 org-level-7 org-level-8
                    org-document-title))
      (face-spec-set face '((t (:height 1.0 :extend t))) 'face-override-spec))
    (dolist (face '(org-block-begin-line org-block-end-line))
      (face-spec-set face '((t (:extend t))) 'face-override-spec)))

  (with-eval-after-load 'org-superstar
    (setq org-superstar-headline-bullets-list headline-bullets
          org-superstar-item-bullet-alist item-bullets))

  (with-eval-after-load 'evil-org
    (evil-org-set-key-theme key-theme)))

(defun config-org-notebook-set (header-args resource-dir)
  (when (and (fboundp 'native-comp-available-p) (native-comp-available-p))
    (require 'comp-run nil t)
    (when (boundp 'native-comp-jit-compilation-deny-list)
      (add-to-list 'native-comp-jit-compilation-deny-list "jupyter")))

  (with-eval-after-load 'jupyter
    (setq jupyter-org-resource-directory resource-dir))

  (with-eval-after-load 'org
    (require 'jupyter)
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((emacs-lisp . t)
       (python . t)
       (jupyter . t)))
    (advice-add 'jupyter-kernelspecs :around #'config-org--when-jupyter)
    (setq org-babel-default-header-args:jupyter-python header-args
          org-confirm-babel-evaluate nil
          org-src-fontify-natively t)
    (add-to-list 'org-src-lang-modes '("jupyter-python" . python)))

  (with-eval-after-load 'pyvenv
    (add-hook 'pyvenv-post-activate-hooks
              (lambda ()
                (when (fboundp 'org-babel-jupyter-aliases-from-kernelspecs)
                  (org-babel-jupyter-aliases-from-kernelspecs t))))))

(defun config-org-diagram-set ()
  "Define an org-babel backend for each language in `config-diagram-langs'."
  (dolist (l (config-diagram-langs))
    (let ((lang l))
      (set (intern (format "org-babel-default-header-args:%s" lang))
           '((:results . "file") (:exports . "results")))
      (defalias (intern (format "org-babel-execute:%s" lang))
        (lambda (body params)
          (config-diagram-render lang body
                                 (or (cdr (assq :file params))
                                     (user-error "[diagram] :file is required")))
          ;; a nil result keeps org from overwriting the image with its own
          nil)
        (format "Render a %s block to its :file." lang)))))

(provide 'config-org)
