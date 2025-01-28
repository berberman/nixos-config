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

(use-package haskell-mode)

(use-package elpy
  :ensure t
  :init
  (setq python-shell-interpreter "python3"
      python-shell-interpreter-args "-i")
  (elpy-enable))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook (
	 ((haskell-literate-mode haskell-mode) . lsp-deferred)
	 (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp lsp-deferred
  :config
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map))

(use-package lsp-ui :commands lsp-ui-mode)

(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)

(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

(use-package lsp-haskell)

(use-package company
  :hook (after-init . global-company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection)
	      ("C-n" . #'company-select-next)
	      ("C-p" . #'company-select-previous)))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package flycheck :hook (prog-mode . flycheck-mode))

(use-package nix-mode
  :mode (".nix\\'" . nix-mode)
  :init (setq nix-indent-function 'nix-indent-line))

(use-package markdown-mode
  :mode (("\\.md\\'" . gfm-mode)
         ("\\.markdown\\'" . gfm-mode)))

(use-package yaml-mode)

(use-package racket-mode
  :hook
  (racket-mode . racket-xp-mode))

(use-package diff-hl
  :hook ((after-init . global-diff-hl-mode)
	 (dired-mode . diff-hl-dired-mode)
	 (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (diff-hl-flydiff-mode 1))

(use-package dired
  :ensure nil
  :config
  (setq dired-recursive-deletes 'always
        dired-recursive-copies 'always))

(use-package diredfl
  :init (diredfl-global-mode 1))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode))

(use-package telega
  :commands (telega))

(electric-pair-mode 1)
(show-paren-mode 1)
(save-place-mode 1)
(delete-selection-mode 1)
(global-auto-revert-mode 1)

(use-package wakatime-mode
  :diminish
  :config
  (global-wakatime-mode t))

(load-file (let ((coding-system-for-read 'utf-8))
	     (shell-command-to-string "agda-mode locate")))

(provide 'init)
;;; init.el ends here
