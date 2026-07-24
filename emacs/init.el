;;; init.el --- -*- lexical-binding: t -*-

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(unless package-activated-list (package-initialize))

(defvar my/packages
  '(evil
    evil-collection
    general
    doom-themes
    kanagawa-themes
    vertico
    org-superstar
    evil-org
    pyvenv
    jupyter
    xclip
    denote
    dashboard))

(dolist (pkg my/packages)
  (unless (package-installed-p pkg)
    (package-initialize)
    (unless package-archive-contents (package-refresh-contents))
    (package-install pkg)
    (package-quickstart-refresh)))

(add-to-list 'load-path (locate-user-emacs-file "lisp"))

(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file) (load custom-file nil t))

;;; ---------------------------------------------------
;;; ------------------ Machine-local ------------------
;;; ---------------------------------------------------

(defvar my/local-file (locate-user-emacs-file "local.el"))
(when (file-exists-p my/local-file) (load my/local-file nil t))

;;; ---------------------------------------------------
;;; ------------------ Configuration ------------------
;;; ---------------------------------------------------

(defvar my/font "JetBrainsMono Nerd Font-14")

(defvar my/leader "SPC")

(defvar my/shortcuts
  '("ee" dired-jump
    "ff" find-file
    "fs" save-buffer
    "bb" switch-to-buffer
    "bd" kill-current-buffer
    "pp" project-switch-project
    "pf" project-find-file
    "pb" project-switch-to-buffer
    "pd" project-dired
    "pa" config-project-add-current
    "pr" config-project-forget
    "va" pyvenv-activate
    "vd" pyvenv-deactivate
    "ns" my/notes-scratch
    "nn" denote
    "nc" denote-subdirectory
    "nf" denote-open-or-create
    "ni" denote-link
    "nb" denote-backlinks
    "nd" denote-dired
    "q"  save-buffers-kill-terminal))

(defvar my/mode-shortcuts
  '((org-mode-map
     "oj" my/org-insert-jupyter-python-block)))

(defvar my/completion-count 15)

(defvar my/completion-keys
  '(("DEL"   . vertico-directory-delete-char)
    ("M-DEL" . vertico-directory-delete-word)
    ("RET"   . vertico-directory-enter)))

(defvar my/project-list-file (expand-file-name "projects" my/cache-dir))
(defvar my/project-markers '(".project"))
(defvar my/project-switch-command 'project-find-file)

(defvar my/themes '(kanagawa-dragon doom-homage-black))
(defvar my/theme-toggle-key "<f5>")

(defvar my/lsp-servers
  '(((python-mode python-ts-mode) . ("basedpyright-langserver" "--stdio"))))

(defvar my/lsp-keys
  '(("g d"   . xref-find-definitions)
    ("g r"   . xref-find-references)
    ("K"     . eldoc)
    ("C-c r" . eglot-rename)
    ("C-c a" . eglot-code-actions)))

(defvar my/org-headline-bullets '("◉" "○" "✸" "✿" "♦"))

(defvar my/org-item-bullets
  '((?+ . "•")
    (?- . "◦")
    (?* . "•")))

(defvar my/org-key-theme '(navigation insert textobjects additional calendar))

(defvar my/jupyter-header-args
  '((:session . "py")
    (:async . "yes")
    (:kernel . "python3")
    (:results . "raw drawer")
    (:pandoc . t)
    (:exports . "both")))

(defvar my/jupyter-resource-dir "./.ob-jupyter/")

(defvar my/latex-pdf-process '("tectonic -X compile %f --outdir %o"))

(defvar my/notes-dir "~/notes/")
(defvar my/notes-keywords
  '("scratch"
    "blog"
    "programming"
    "project-management"
    "task"))

(defvar my/dashboard-items nil)

(defvar my/dashboard-widgets
  '(dashboard-insert-newline
    dashboard-insert-newline
    dashboard-insert-banner-title
    dashboard-insert-newline
    dashboard-insert-init-info
    dashboard-insert-items
    dashboard-insert-newline
    dashboard-insert-footer))

;;; ---------------------------------------------------

(dolist (module '(config-cache
                  config-dashboard
                  config-ui
                  config-evil
                  config-shortcut
                  config-completion
                  config-project
                  config-theme
                  config-statusline
                  config-lsp
                  config-org
                  config-notes
                  config-notebook
                  config-latex))
  (require module))

(config-cache-set my/cache-dir)
(config-ui-set my/font)
(config-evil-set)
(config-dashboard-set my/dashboard-items my/dashboard-widgets)
(config-shortcut-set my/leader my/shortcuts my/mode-shortcuts)
(config-completion-set my/completion-count my/completion-keys)
(config-project-set my/project-list-file my/project-markers my/project-switch-command)
(config-theme-set my/themes my/theme-toggle-key)
(config-statusline-set)
(config-lsp-set my/lsp-servers my/lsp-keys)
(config-org-set my/org-headline-bullets my/org-item-bullets my/org-key-theme)
(config-notes-set my/notes-dir my/notes-keywords)
(config-notebook-set my/jupyter-header-args my/jupyter-resource-dir)
(config-latex-set my/latex-pdf-process)
