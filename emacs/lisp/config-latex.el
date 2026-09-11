;;; config-latex.el --- -*- lexical-binding: t -*-

(defun config-latex-set (pdf-process)
  (with-eval-after-load 'ox-latex
    (setq org-latex-pdf-process pdf-process)
    ;; Block paragraphs: no first-line indent, a small gap between paragraphs
    ;; instead.  The parskip package sets both, and unlike a bare
    ;; \setlength{\parindent}{0pt} it also keeps list spacing sane.
    (add-to-list 'org-latex-packages-alist '("" "parskip" t))))

(provide 'config-latex)
