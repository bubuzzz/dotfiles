;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
(setq doom-font (font-spec :family "JetBrains Mono" :size 15)
      doom-big-font (font-spec :family "JetBrains Mono" :size 20))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)
;; (setq doom-theme 'doom-badger)
;; (setq doom-theme 'doom-moonlight)
(setq doom-theme 'doom-homage-black)

;; GUI Emacs.app on macOS launches without the shell's PATH, so binaries from
;; homebrew, uv-managed venvs, and ~/.local/bin aren't visible. Pull PATH from
;; an interactive shell once at startup so `jupyter', `uv', `ipython', lsp
;; servers, etc. are discoverable. Skip in TTY (we already have shell env).
(use-package! exec-path-from-shell
  :when (memq window-system '(mac ns x))
  :config
  (setq exec-path-from-shell-variables '("PATH" "MANPATH" "VIRTUAL_ENV"))
  (exec-path-from-shell-initialize))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Soft-wrap long lines at word boundaries in every buffer. File contents are
;; unchanged — just visual. Toggle per-buffer with `SPC t w'.
(+global-word-wrap-mode +1)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(setq treemacs-position 'right)
(setq doom-themes-treemacs-theme "doom-colors")

(custom-set-faces!
  '(nerd-icons-dblue :foreground "#4B8BBE")
  '(nerd-icons-dyellow :foreground "#FFD43B"))

(use-package! xclip
  :unless (display-graphic-p)
  :config (xclip-mode +1))

(use-package! eat
  :commands (eat eat-project +eat/toggle)
  :config
  (setq eat-kill-buffer-on-exit t
        eat-enable-mouse t)
  (add-hook 'eshell-load-hook #'eat-eshell-mode)
  (add-hook 'eshell-load-hook #'eat-eshell-visual-command-mode))

;; Open EAT as a bottom popup, like Doom's vterm popup.
(set-popup-rule! "^\\*eat\\*"
  :side 'bottom
  :size 0.3
  :select t
  :quit t
  :ttl nil
  :modeline nil)
;; set eat term to xterm otherwise mac will use eat-truecolors
(setq eat-term-name "xterm-256color")

(defun +eat/toggle ()
  "Toggle an EAT terminal in a bottom popup."
  (interactive)
  (require 'eat)
  (let* ((buf (get-buffer "*eat*"))
         (win (and buf (get-buffer-window buf))))
    (cond
     (win (delete-window win))
     (buf (pop-to-buffer buf))
     (t   (eat)))))

(map! :leader
      (:prefix-map ("o" . "open")
       :desc "Toggle EAT popup"        "t" #'+eat/toggle
       :desc "EAT terminal in project" "T" #'eat-project))


;; ---------------------------------------------------------------------------
;; Org-mode + Jupyter: true inline notebook (Zed/Jupyter-style)
;;
;; Write notebook-style work in .org files using `jupyter-python' source
;; blocks. Run with `C-c C-c` inside the block; text results AND matplotlib
;; plots render directly below the block. The kernel runs in your project's
;; uv-managed .venv: `pyvenv-auto' activates `<project-root>/.venv' when an
;; org file under a `pyproject.toml' root is opened, and the advice further
;; below registers org-babel jupyter aliases against that venv's jupyter.
;;
;; Minimal template to drop into a new .org file:
;;
;;   #+PROPERTY: header-args:jupyter-python :session py :async yes :results raw drawer :pandoc t
;;
;;   * Scratch
;;   #+begin_src jupyter-python
;;   import pandas as pd, numpy as np, matplotlib.pyplot as plt
;;   plt.plot(np.random.randn(100).cumsum()); plt.gcf()
;;   #+end_src
;; ---------------------------------------------------------------------------

;; Auto-activate <project-root>/.venv when visiting any file under a
;; pyproject.toml root. Used by both python-mode (LSP, REPL) and org-mode
;; (jupyter kernel discovery via the venv's jupyter binary).
(use-package! pyvenv-auto
  :hook ((python-mode org-mode) . pyvenv-auto-run))

(after! org
  ;; Default header args for jupyter-python blocks: persistent session,
  ;; async execution (so long cells don't block Emacs), results in a drawer
  ;; (collapsible), pandoc-rendered markdown output.
  (setq org-babel-default-header-args:jupyter-python
        '((:session . "py")
          (:async . "yes")
          (:kernel . "python3")
          (:results . "raw drawer")
          (:pandoc . t)
          (:exports . "both")))
  ;; Don't ask "Evaluate this code block?" every single time.
  (setq org-confirm-babel-evaluate nil)
  ;; Show inline images after evaluation.
  (add-hook 'org-babel-after-execute-hook #'org-display-inline-images))

;; Insert an empty `jupyter-python' src block and drop the cursor inside it.
(defun +org/insert-jupyter-python-block ()
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

(map! :after org
      :map org-mode-map
      :localleader
      :desc "Insert jupyter-python block" "j" #'+org/insert-jupyter-python-block)

(after! jupyter
  ;; Render plots/images inline in the org buffer instead of separate windows.
  (setq jupyter-org-resource-directory "./.ob-jupyter/"))

;; Force-load ob-jupyter when org loads and register the `jupyter-python'
;; language alias (which creates `org-babel-execute:jupyter-python').
;; Doom's contrib tries to lazy-load this but it doesn't always fire.
(after! org
  (require 'ob-jupyter nil t)
  (org-babel-do-load-languages
   'org-babel-load-languages
   (append org-babel-load-languages
           '((jupyter . t)
             (python  . t)))))

;; Kernel aliases need `jupyter' on `exec-path'. We don't install jupyter
;; globally — it lives in each project's .venv. So when an org file is
;; visited and pyvenv-auto activates the project venv, prepend that venv's
;; bin/ to exec-path and (re-)register the jupyter language aliases.
(defun +jupyter/register-aliases-from-venv ()
  "Find jupyter in the active venv and register org-babel jupyter aliases."
  (when-let* ((venv (or (getenv "VIRTUAL_ENV") (bound-and-true-p pyvenv-virtual-env)))
              (venv-bin (expand-file-name "bin/" venv))
              (jupyter-bin (concat venv-bin "jupyter")))
    (when (file-executable-p jupyter-bin)
      ;; Make sure exec-path and PATH see the venv's bin.
      (add-to-list 'exec-path venv-bin)
      (setenv "PATH" (concat venv-bin ":" (getenv "PATH")))
      (require 'ob-jupyter nil t)
      (when (fboundp 'org-babel-jupyter-aliases-from-kernelspecs)
        (ignore-errors (org-babel-jupyter-aliases-from-kernelspecs))))))

;; Run after pyvenv-auto activates a venv in an org buffer.
(with-eval-after-load 'pyvenv-auto
  (advice-add 'pyvenv-auto-run :after
              (lambda (&rest _) (+jupyter/register-aliases-from-venv))))


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


