;;; config-diagram.el --- -*- lexical-binding: t -*-

(defvar config-diagram--backends nil)
(defvar config-diagram--appearance nil)

(defun config-diagram-backend (lang)
  "Return the backend registered for LANG, or nil."
  (alist-get lang config-diagram--backends nil nil #'equal))

(defun config-diagram-langs ()
  "Return the list of registered backend languages."
  (mapcar #'car config-diagram--backends))

(defun config-diagram-render (lang body file)
  "Write BODY through the LANG backend to FILE.
The backend command line is an argv where the symbols `input' and
`output' stand for the temporary source file and the target image, and
`theme' for the :themes entry matching the appearance of the theme in
use.  Returns FILE."
  (let ((backend (or (config-diagram-backend lang)
                     (user-error "[diagram] no backend for %s" lang))))
    (let* ((argv (plist-get backend :command))
           (themes (plist-get backend :themes))
           (appearance (and config-diagram--appearance
                            (funcall config-diagram--appearance)))
           (theme (or (alist-get appearance themes) (cdar themes)))
           (dir (file-name-directory file))
           (in (make-temp-file "config-diagram-" nil ".txt"))
           (log (generate-new-buffer " *diagram*")))
      (when dir (make-directory dir t))
      (with-temp-file in (insert body))
      (unwind-protect
          (let* ((args (mapcar (lambda (a)
                                 (pcase a ('input in) ('output file)
                                        ('theme theme) (_ a)))
                               argv))
                 (code (apply #'call-process (car args) nil log nil (cdr args))))
            (unless (eq code 0)
              (message "%s" (with-current-buffer log (buffer-string)))
              (user-error "[diagram] %s exited with %s" (car args) code)))
        (delete-file in)
        (kill-buffer log))
      file)))

(defun config-diagram-set (backends appearance-function)
  "Register BACKENDS, an alist of (LANG :command ARGV :themes ALIST).
APPEARANCE-FUNCTION returns the key into ALIST for the theme in use."
  (setq config-diagram--backends backends
        config-diagram--appearance appearance-function))

(provide 'config-diagram)
