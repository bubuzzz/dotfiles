;;; config-dashboard.el --- -*- lexical-binding: t -*-

(defun config-dashboard-set (banner items)
  "Show the dashboard on startup with BANNER (a text-file path) and ITEMS.
ITEMS is a `dashboard-items' alist like ((recents . 5) (projects . 5))."
  (require 'dashboard)
  (setq dashboard-startup-banner   banner
        dashboard-center-content   t
        dashboard-vertically-center-content t
        dashboard-items            items
        dashboard-projects-backend 'project-el
        dashboard-set-heading-icons nil
        dashboard-set-file-icons   nil
        initial-major-mode         'fundamental-mode
        initial-scratch-message    nil
        initial-buffer-choice      #'dashboard-open)

  (add-hook 'server-after-make-frame-hook #'dashboard-open)

  (dashboard-setup-startup-hook))

(provide 'config-dashboard)
