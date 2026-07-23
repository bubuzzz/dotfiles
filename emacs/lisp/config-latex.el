;;; config-latex.el --- -*- lexical-binding: t -*-

(defun config-latex-set (pdf-process)
  (with-eval-after-load 'ox-latex
    (setq org-latex-pdf-process pdf-process)))

(provide 'config-latex)
