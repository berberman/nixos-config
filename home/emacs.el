;; -*- lexical-binding: t; -*-

;; use use-package
(setq use-package-always-ensure t)
(eval-when-compile
  (require 'use-package))

(package-initialize)

(require 'cl-lib)
(use-package diminish)
(use-package bind-key)

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode))

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t) 
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config)
)

(use-package zoom-window
  :bind* ("C-- C-+" . zoom-window-zoom))

(use-package company
  :init
    (setq company-idle-delay 0)
    (setq company-minimum-prefix-length 1))

(use-package paren
  :config
  (show-paren-mode 1))

(use-package hl-line
  :hook (after-init . global-hl-line-mode)
)

(use-package magit
  :bind (("C-x g" . magit-status)))
