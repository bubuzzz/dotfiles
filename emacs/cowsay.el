;;; cowsay.el -*- lexical-binding: t; -*-
;;
;; A minimal startup splash: one cow saying a random bit of wisdom, centered
;; in the window — the Emacs counterpart to the nvim startify cow. Replaces the
;; default *scratch*/startup buffer via `initial-buffer-choice'.
;;
;; Loaded from init.el via `(load (locate-user-emacs-file "cowsay") nil t)'.

;; Declared here so it auto-installs on a fresh machine the first time Emacs
;; starts. Installed from the git source (via package-vc) rather than MELPA
;; because the MELPA build omits the bundled `cows/' directory; the git repo
;; includes it, so `cowsay-string' can word-wrap quotes into a real bubble.
(use-package cowsay
  :vc (:url "https://github.com/lassik/emacs-cowsay" :rev :newest)
  :defer t)

(defvar +cowsay-quotes
  '("Provide options, don't make lame excuses. Instead of excuses, provide options. Don't say it can't be done; explain what can be done."
    "Simplicity is prerequisite for reliability."
    "Premature optimization is the root of all evil."
    "Programs must be written for people to read, and only incidentally for machines to execute."
    "Make it work, make it right, make it fast."
    "Talk is cheap. Show me the code."
    "Weeks of coding can save you hours of planning."
    "There are only two hard things in computer science: cache invalidation and naming things."
    "First, solve the problem. Then, write the code.")
  "Quotes the startup cow may utter.")

(defvar +cowsay--cache nil
  "Cached cow string (pre-centering) so resizing doesn't change the quote.")

(defun +cowsay--fallback (quote)
  "Hand-rolled cow saying QUOTE, used if the cowsay package API differs."
  (let ((bar (make-string (+ 2 (string-width quote)) ?-)))
    (concat
     " " bar "\n"
     "< " quote " >\n"
     " " bar "\n"
     "        \\   ^__^\n"
     "         \\  (oo)\\_______\n"
     "            (__)\\       )\\/\\\n"
     "                ||----w |\n"
     "                ||     ||")))

(defun +cowsay--ensure-cows ()
  "Load the cows bundled with the cowsay package (no system cowsay here)."
  (require 'cowsay)
  (unless (assoc "default" cowsay-cows)
    (let ((dir (expand-file-name "cows"
                                 (file-name-directory (locate-library "cowsay")))))
      (when (file-directory-p dir)
        (cowsay-load-cows-directory dir)))))

(defun +cowsay--text ()
  "Return a cowsay string for a random quote, with a safe fallback."
  (random t)
  (let ((quote (nth (random (length +cowsay-quotes)) +cowsay-quotes)))
    (or (ignore-errors
          (+cowsay--ensure-cows)
          (cowsay-string quote "default"))
        (+cowsay--fallback quote))))

(defun +cowsay--center (text)
  "Center the TEXT block horizontally and vertically in the selected window."
  (let* ((lines (split-string text "\n"))
         (block-width (apply #'max 0 (mapcar #'string-width lines)))
         (left-pad (max 0 (/ (- (window-body-width) block-width) 2)))
         (top-pad (max 0 (/ (- (window-body-height) (length lines)) 2)))
         (pad (make-string left-pad ?\s)))
    (concat (make-string top-pad ?\n)
            (mapconcat (lambda (l) (concat pad l)) lines "\n"))))

(define-derived-mode +cowsay-mode special-mode "Cowsay"
  "Major mode for the startup cow splash."
  (setq-local mode-line-format nil
              cursor-type nil
              cursor-in-non-selected-windows nil
              display-line-numbers nil
              ;; Hide evil's box cursor in THIS buffer without leaving the evil
              ;; state the SPC leader needs. `(nil)' sets `cursor-type' to nil
              ;; when evil refreshes the cursor.
              evil-normal-state-cursor '(nil)
              evil-motion-state-cursor '(nil)))

;; Stay in motion state (read-only, navigable) so the SPC leader works here;
;; the cursor is hidden via the buffer-local cursor specs above.
(with-eval-after-load 'evil
  (evil-set-initial-state '+cowsay-mode 'motion))

(defun +cowsay--render (&optional regenerate)
  "Build (or recenter) the *cowsay* buffer and return it.
With REGENERATE non-nil, pick a fresh quote."
  (let ((buf (get-buffer-create "*cowsay*")))
    (when (or regenerate (null +cowsay--cache))
      (setq +cowsay--cache (+cowsay--text)))
    (with-current-buffer buf
      (unless (derived-mode-p '+cowsay-mode) (+cowsay-mode))
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert (+cowsay--center +cowsay--cache))
        (goto-char (point-min)))
      ;; `global-display-line-numbers-mode' re-enables itself on the major-mode
      ;; change above, so force it back off for this buffer.
      (when (bound-and-true-p display-line-numbers-mode)
        (display-line-numbers-mode -1))
      (setq-local display-line-numbers nil))
    buf))

(defun +cowsay--recenter-on-resize (_frame)
  "Re-center the cow (keeping the same quote) when its window is resized."
  (when-let ((win (get-buffer-window "*cowsay*" t)))
    (with-selected-window win
      (+cowsay--render nil))))

(add-hook 'window-size-change-functions #'+cowsay--recenter-on-resize)

(defun +cowsay-initial-buffer ()
  "Pick the startup buffer: the command-line file if one was opened, else the cow.
By the time `initial-buffer-choice' is consulted, any file given on
the command line has already been visited. Returning that buffer
\(which is already in the startup display list) makes Emacs show just
the file — no half-frame cow split. With no file, show the cow."
  (or (seq-find #'buffer-file-name (buffer-list))
      (+cowsay--render)))

;; Show the cow only when Emacs starts with no file arguments.
(setq initial-buffer-choice #'+cowsay-initial-buffer)
