;;; config-llm.el --- -*- lexical-binding: t -*-

(require 'json)
(require 'url)

(defvar config-llm--endpoint nil)
(defvar config-llm--model nil)
(defvar config-llm--options nil)
(defvar config-llm--actions nil)
(defvar config-llm--say-command nil)

(defun config-llm--input (cword)
  "Return (TEXT MARKER) from the region, or the word at point when CWORD."
  (cond
   ((use-region-p)
    (let ((text (buffer-substring-no-properties (region-beginning) (region-end)))
          (marker (save-excursion (goto-char (region-end))
                                  (copy-marker (line-end-position)))))
      (deactivate-mark)
      (list text marker)))
   (cword
    (let ((word (thing-at-point 'word t)))
      (when word (list word (copy-marker (line-end-position))))))))

(defun config-llm--insert (buffer marker header content)
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (save-excursion
        (goto-char marker)
        (insert "\n\n" header "\n" (string-trim content) "\n"))
      (set-marker marker nil))))

(defun config-llm--post (payload callback)
  (let ((url-request-method "POST")
        (url-request-extra-headers '(("Content-Type" . "application/json")))
        (url-request-data (encode-coding-string (json-encode payload) 'utf-8)))
    (url-retrieve
     config-llm--endpoint
     (lambda (status)
       (let ((response (current-buffer)))
         (unwind-protect
             (cond
              ((plist-get status :error)
               (message "[llm] request failed: %S" (plist-get status :error)))
              (t
               (goto-char (point-min))
               (if (not (re-search-forward "\r?\n\r?\n" nil t))
                   (message "[llm] malformed response")
                 (let* ((body (decode-coding-string
                               (buffer-substring-no-properties (point) (point-max))
                               'utf-8))
                        (data (ignore-errors
                                (json-parse-string body :object-type 'alist)))
                        (content (alist-get 'content (alist-get 'message data))))
                   (if (and (stringp content) (not (string-empty-p content)))
                       (funcall callback content)
                     (message "[llm] empty response"))))))
           (kill-buffer response))))
     nil t t)))

(defun config-llm--run (name)
  (let* ((spec (alist-get name config-llm--actions))
         (input (config-llm--input (plist-get spec :cword))))
    (unless input
      (user-error "[llm] no text selected"))
    (pcase-let* ((`(,text ,marker) input)
                 (buffer (current-buffer))
                 (header (plist-get spec :header))
                 (max-words (plist-get spec :max-words))
                 (prompt (concat (plist-get spec :prefix) text)))
      (when max-words
        (setq prompt (format "Answer in at most %d words.\n\n%s" max-words prompt)))
      (message "[llm] %s…" name)
      (config-llm--post
       `((model . ,config-llm--model)
         (stream . :json-false)
         (options . ,config-llm--options)
         (messages . [((role . "system") (content . ,(plist-get spec :system)))
                      ((role . "user") (content . ,prompt))]))
       (lambda (content)
         (config-llm--insert buffer marker header content)
         (message "[llm] %s done" name))))))

(defun config-llm-say ()
  "Pronounce the region, or the word at point."
  (interactive)
  (let ((text (if (use-region-p)
                  (buffer-substring-no-properties (region-beginning) (region-end))
                (thing-at-point 'word t))))
    (unless text (user-error "[llm] no word at point"))
    (deactivate-mark)
    (apply #'start-process "config-llm-say" nil
           (car config-llm--say-command)
           (append (cdr config-llm--say-command) (list text)))))

(defun config-llm-set (endpoint model options actions say-command)
  (setq config-llm--endpoint endpoint
        config-llm--model model
        config-llm--options options
        config-llm--actions actions
        config-llm--say-command say-command)
  (dolist (action actions)
    (let ((name (car action)))
      (defalias (intern (format "config-llm-%s" name))
        (lambda ()
          (interactive)
          (config-llm--run name))
        (plist-get (cdr action) :header)))))

(provide 'config-llm)
