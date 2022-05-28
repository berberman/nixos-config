;;; init.el --- Emacs init -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:
(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)

(set-face-attribute 'default nil :font "VictorMono Nerd Font")

(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(column-number-mode)
(global-display-line-numbers-mode t)
(global-hl-line-mode 1)

(use-package ivy
  :diminish ivy-mode
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1))

(use-package doom-themes
  :init (load-theme 'doom-one t))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package counsel
  :bind (
    ("C-s" . swiper-isearch)
    ("M-x" . counsel-M-x)
    ("C-x C-f" . counsel-find-file)
    ("M-y" . counsel-yank-pop)
    ("<f1> f" . counsel-describe-function)
    ("<f1> v" . counsel-describe-variable)
    ("<f1> l" . counsel-find-library)
    ("<f2> i" . counsel-info-lookup-symbol)
    ("<f2> u" . counsel-unicode-char)
    ("<f2> j" . counsel-set-variable)
    ("C-x b" . ivy-switch-buffer)
    ("C-c v" . ivy-push-view)
    ("C-c V" . ivy-pop-view)))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind (([remap describe-function] . helpful-callable)
         ([remap describe-command] . helpful-command)
         ([remap describe-variable] . helpful-variable)
         ([remap describe-key] . helpful-key)
         ([remap describe-symbol] . helpful-symbol)))

(use-package projectile
  :diminish projectile-mode
  :init (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit)

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook (
	 ((haskell-literate-mode-hook haskell-mode-hook) . lsp-deferred)
	 (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp lsp-deferred)

(use-package lsp-ui :commands lsp-ui-mode)

(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)

(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

(use-package company
  :after lsp-mode
  :hook (prog-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection)
	      ("C-n" . #'company-select-next)
	      ("C-p" . #'company-select-previous))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common)))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package flycheck :hook (prog-mode . flycheck-mode))

(provide 'init)
;;; init.el ends here
