;;; config-notebook.el --- -*- lexical-binding: t -*-

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

(defun config-notebook-set (header-args resource-dir)
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
    (setq org-babel-default-header-args:jupyter-python header-args
          org-confirm-babel-evaluate nil
          org-src-fontify-natively t)
    (add-hook 'org-babel-after-execute-hook #'org-display-inline-images)
    (add-to-list 'org-src-lang-modes '("jupyter-python" . python)))

  (with-eval-after-load 'pyvenv
    (add-hook 'pyvenv-post-activate-hooks
              (lambda ()
                (when (fboundp 'org-babel-jupyter-aliases-from-kernelspecs)
                  (org-babel-jupyter-aliases-from-kernelspecs t))))))

(provide 'config-notebook)
