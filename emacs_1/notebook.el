;;; notebook.el -*- lexical-binding: t; -*-
;;
;; Org-mode + Jupyter: true inline notebook (Zed/Jupyter-style).
;; Ported from the old Doom config to vanilla Emacs.
;;
;; Write notebook-style work in .org files using `jupyter-python' source
;; blocks. Run with `C-c C-c' inside the block; text results AND matplotlib
;; plots render directly below the block. The kernel runs in your project's
;; uv-managed .venv: `pyvenv-auto' activates `<project-root>/.venv' when an
;; org file under a `pyproject.toml' root is opened, and the advice below
;; registers org-babel jupyter aliases against that venv's jupyter.
;;
;; Loaded from init.el via `(load (locate-user-emacs-file "notebook") nil t)'.
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
;; Work around an emacs-jupyter native-compilation bug
;; ---------------------------------------------------------------------------
;; In this emacs-jupyter snapshot, `jupyter-repl-sync-execution-state' fails
;; with (void-variable state) when *native*-compiled — a native-comp miscompile
;; of a closure that rebinds `state' via `pcase-let*'. It aborts REPL setup, so
;; `C-c C-c' relaunches the kernel and returns no result. The byte-compiled
;; version is correct, so exclude jupyter from native compilation (must run
;; before jupyter is loaded — notebook.el is loaded at startup).
(when (and (fboundp 'native-comp-available-p) (native-comp-available-p))
  (require 'comp-run nil t)
  (when (boundp 'native-comp-jit-compilation-deny-list)
    (add-to-list 'native-comp-jit-compilation-deny-list "jupyter")))

;; ---------------------------------------------------------------------------
;; Project venv auto-activation
;; ---------------------------------------------------------------------------
;; Auto-activate <project-root>/.venv when visiting any file under a
;; pyproject.toml root. Used by both python-mode (LSP, REPL) and org-mode
;; (jupyter kernel discovery via the venv's jupyter binary).
(use-package pyvenv-auto
  :hook ((python-mode python-ts-mode org-mode) . pyvenv-auto-run))

;; ---------------------------------------------------------------------------
;; emacs-jupyter (pulls in zmq, websocket, simple-httpd; zmq compiles a module)
;; ---------------------------------------------------------------------------
(use-package jupyter
  :after org
  :config
  ;; Render plots/images inline in the org buffer instead of separate windows.
  (setq jupyter-org-resource-directory "./.ob-jupyter/"))

;; ---------------------------------------------------------------------------
;; Org-babel + Jupyter setup
;; ---------------------------------------------------------------------------
(with-eval-after-load 'org
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
  ;; Native font-lock inside src blocks.
  (setq org-src-fontify-natively t)
  ;; Show inline images after evaluation.
  (add-hook 'org-babel-after-execute-hook #'org-display-inline-images)

  ;; Load ob-jupyter and register the `jupyter-python' language alias (which
  ;; creates `org-babel-execute:jupyter-python'). Eager registration matters
  ;; for *fontification*: org-src-fontify-natively looks up the babel language
  ;; to know which mode's font-lock to apply inside the block.
  (require 'ob-jupyter nil t)
  (org-babel-do-load-languages
   'org-babel-load-languages
   (append org-babel-load-languages
           '((jupyter . t)
             (python  . t))))
  ;; Register kernel aliases immediately if a jupyter is already on PATH; the
  ;; pyvenv-auto advice below re-runs this once a project venv activates.
  (when (fboundp 'org-babel-jupyter-aliases-from-kernelspecs)
    (ignore-errors (org-babel-jupyter-aliases-from-kernelspecs)))
  ;; Map `jupyter-python' blocks to python-mode for fontification even before
  ;; the babel alias is registered (first-frame race insurance).
  (add-to-list 'org-src-lang-modes '("jupyter-python" . python)))

;; ---------------------------------------------------------------------------
;; Insert a jupyter-python block + localleader binding
;; ---------------------------------------------------------------------------
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

;; `SPC m j' in org buffers (localleader defined in init.el's general block).
(with-eval-after-load 'general
  (my/localleader
    :keymaps 'org-mode-map
    "j" '(+org/insert-jupyter-python-block :which-key "insert jupyter block")))

;; ---------------------------------------------------------------------------
;; Register jupyter aliases from the active project venv
;; ---------------------------------------------------------------------------
;; Kernel aliases need `jupyter' on `exec-path'. We don't install jupyter
;; globally — it lives in each project's .venv. So when an org file is visited
;; and pyvenv-auto activates the project venv, prepend that venv's bin/ to
;; exec-path and (re-)register the jupyter language aliases.
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
