;;; package -- Summary
;; Commentary:
; Emacs configuration for cig

;; setup proxy information for windows
(when (eq system-type 'windows-nt)
  (setq proxy-file "~/.emacs.d/proxy.el")
  (load proxy-file))

;;; Code:
; Disable the startup message and screen ie.  Emacs welcome
(setq inhibit-startup-message t)
(setq inhibit-startup-screen t)
;; UI settings --------------------------------------------------------
; Disable visible scrollbar ie. scroll bar on the right
(scroll-bar-mode -1)

;; Disable the top of screen stuff
(tool-bar-mode -1) ; ie. the icons at the top
;; (tooltip-mode -1)  ; Disable tooltips
(menu-bar-mode -1) ; Disable the menu bar
(set-fringe-mode 10) ; Give some breathing room
(setq warning-minimum-level :error) ; only show warning buffer on errors
(set-default-coding-systems 'utf-8)

(setq visible-bell t); Set up the visible bell

;; ;; Enable line numbers in all buffers
;; (global-linum-mode t)

;; ;; Disable line numbers in eshell buffers
;; (add-hook 'eshell-mode-hook (lambda () (display-line-numbers-mode 0)))

;; (setq display-line-numbers-type 'relative) ; use relative line numbers
(define-key key-translation-map (kbd "ESC") (kbd "C-g")) ; use escape to quit stuff

; other general stuff
; use text-based prompts rather than using GUI windows
(setq use-dialog-box nil)

; turn off the ringing bell feature
(setq ring-bell-function 'ignore)

; window focusing - windows must be manually clicked to focus
(setq mouse-autoselect-window nil
      focus-follows-mouse nil)

; send deleted files to trash
(setq delete-by-moving-to-trash t
      create-lockfiles nil)


; recenter cursor on scroll
;; (setq scroll-preserve-screen-position t)
(defun my-scroll-up ()
  "Scroll up and recenter."
  (interactive)
  (scroll-up)
  (recenter))

(defun my-scroll-down ()
  "Scroll down and recenter."
  (interactive)
  (scroll-down)
  (recenter))

(global-set-key [next] 'my-scroll-up)
(global-set-key [prior] 'my-scroll-down)

;; backup files
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

; windows settings ---------------------------------------------------
; enable CUA mode so hotkeys act like windows
(cua-mode t)
(delete-selection-mode 1)


; use line for the cursor
(setq-default cursor-type 'bar)

; some 'other general' keybindings
; global prefix key:
(define-prefix-command 'my-prefix-map)
(global-set-key (kbd "C-M-c") 'my-prefix-map)
(global-set-key (kbd "<f2>")  'recenter)
(global-set-key (kbd "<f4>")  'execute-extended-command)
(global-set-key (kbd "<f5>")  'delete-other-windows)
(global-set-key (kbd "<f6>")  'magit-status)
(global-set-key (kbd "<f8>")  'kill-buffer)
(global-set-key (kbd "<f7>")  'eshell)
(global-set-key (kbd "<f9>")  'vterm)

(global-set-key (kbd "TAB")  'indent-according-to-mode)
(global-set-key (kbd "C-M-b")  'comment-line)
(global-set-key (kbd "C-M-S-d") 'dired-jump)
(global-set-key (kbd "C-s")   'save-buffer)
(global-set-key (kbd "C-a")   'mark-whole-buffer)

;; Macro keybindings
(global-set-key (kbd "C-M-S-v")   'kmacro-start-macro)
(global-set-key (kbd "C-M-v")   'kmacro-end-macro)
(global-set-key (kbd "C-M-g")   'kmacro-call-macro)

(defun add-surrounding-char (char)
  ;; "Add the specified character to the start and end of the currently highlighted text."
  (interactive "cEnter a character: ")
  (when (region-active-p)
    (let ((start (region-beginning))
          (end (region-end)))
      (goto-char start)
      (insert-char char)
      (goto-char (+ end 1))
      (insert-char char))))

(global-set-key (kbd "C-M-c s") 'add-surrounding-char)

;; Font Setup --------------------------------------------------------
; Linux font
(when (eq system-type 'gnu/linux)
  (set-face-attribute 'default nil
                    :family "JetBrains Mono"
                    :height '120
                    :weight 'light
                    ))
; Windows font
(when (eq system-type 'windows-nt)
  (set-face-attribute 'default nil
                    :family "Consolas"
                    :height '120
                    :weight 'normal
                    :width 'normal))

;; ------------------------------------------------------------------------------------
;; PACKAGES
;; ------------------------------------------------------------------------------------

; Make sure we have the "Package" package
(require 'package)

; Set up package repos
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

; initialize the package system
(package-initialize)

;; I'll be using "use-package" for package management
;; make sure the use-package package is installed
(if (eq system-type 'gnu/linux)
    ;; using Guix for linux
    (setq use-package-always-ensure nil)
  
  (setq use-package-always-ensure t)
  )

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; a couple other settings for use-package to help with memory and start time
(eval-when-compile (require 'use-package))
(setq use-package-verbose t
      comp-async-report-warnings-errors nil
      comp-deferred-compilation t)

;;;; Packages -----------------------------------------------------------------------------
(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
     `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

;; ASYNC
;; helps improve performance
(use-package async
  :defer t ; defer loading until needed, not sure if this line is necessary given use-package settings above
  :init
  (dired-async-mode 1) ; allow dired to load stuff asynchroniosly, which should help on windows
  (async-bytecomp-package-mode 1) ; allows emacs lisp code to be compiled asynchroniosly
  :custom (async-bytecomp-allowed-packages '(all))) ; all packages are allowed to use async

;;; COMPLETION ---------------------------------------------------
;; vertico provides the minibuffer completion framework
;; orderless, consult, and marginalia all make use of vertico and are
;; loaded along with it
(use-package vertico
  :init
  ; orderless allows for fuzzy completions
  (use-package orderless
    :commands (orderless)
    :custom (completion-styles '(orderless flex)))

  ;; Consult provides extra completion functions, such as buffer switching,
  ;; line searching, and general fuzzy finding
  (use-package consult
    :bind (("C-M-c C-M-c" . consult-buffer)           ;; buffer switchign
           ("C-M-c g"       . consult-kmacro)           ;; run macro from the macro-rink
	   ("C-M-d"       . consult-mark)             ;; jump through mark ring
           ("M-y"         . consult-yank-pop)         ;; pull up the yank-pop list (ie. kill-ring)
           ("C-M-c C-c"   . consult-imenu)            ;; looks like object search? should look into this..
           ("C-f"         . consult-line)             ;; line searching
           ("M-s L"       . consult-line-multi)       ;; apparently allows selection of multiple lines?
	   ("C-M-c C-x"   . consult-lsp-diagnostics)  ;; diagnostics consult menu
           ("M-s u"       . consult-focus-lines)      ;; hides all lines except lines that fit a search
           ;; ("M-s M-g"     . consult-ripgrep)       ;; ripgrep - will need windows alternative
           ("C-x C-SPC"   . consult-global-mark)      ;; shows the global-mark-ring, will need to figure out
           ("C-x M-:"     . consult-complex-command)  ;; consult's version of C-x?
           ("C-c n"       . consult-org-agenda)       ;; consult's org agenda view
           :map dired-mode-map
           ("O" . consult-file-externally)
           :map help-map
           ("a" . consult-apropos)          ;; adds consult apropos to the help-map (C-h)
           :map minibuffer-local-map
           ("M-r" . consult-history))
    :custom
    (completion-in-region-function #'consult-completion-in-region)
    :config
    (add-hook 'completion-setup-hook #'hl-line-mode)
    (recentf-mode t))

  (use-package marginalia ; marginalia adds additional information to completions
    :custom
    (marginalia-annotators
     '(marginalia-annotators-heavy marginalia-annotators-light nil))
    :init
    (marginalia-mode))

;; Enable vertico using the vertico-flat-mode
  (require 'vertico-directory)
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)
  (vertico-mode t)
  :config
  ;; Used for the vertico-directory extension
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)
  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

;; give the consult minibuffer a diagnostics picker
(use-package consult-lsp)

;;;; Code Completion
(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                 ; Allows cycling through candidates
  (corfu-auto t)                  ; Enable auto completion
  (corfu-auto-prefix 2)           ; enable completion after 2 characters have been typed
  (corfu-auto-delay 0.0)          ; set the suggestion delay to 0
  (corfu-echo-documentation 0.25) ; Enable documentation for completions
  (corfu-preview-current 'insert) ; Do not preview current candidate
  (corfu-preselect-first nil)
  (corfu-on-exact-match nil)      ; Don't auto expand tempel snippets

  ;; Optionally use TAB for cycling, default is `corfu-complete'.
  :bind (:map corfu-map
              ("M-SPC" . corfu-insert-separator)
              ("TAB"     . corfu-next)
              ([tab]     . corfu-next)
              ("S-TAB"   . corfu-previous)
              ([backtab] . corfu-previous)
              ("<right>" . corfu-insert)
              ("RET"     . nil) ;; leave my enter alone!
              )

  :init
  (global-corfu-mode)
  (corfu-history-mode)
  :config
  ;; (setq tab-always-indent 'complete) ; sets tab to code completion. Not sure I want that yet...
  (add-hook 'eshell-mode-hook
            (lambda () (setq-local corfu-quit-at-boundary t ; Quits completion if the cursor is at the beginning or end of a word.
				   corfu-quit-no-match t ; Quits completion if no matches are found.
                              corfu-auto nil) ; Disables auto completion.
              (corfu-mode)))) ; enables corfu mode in eshell
; Add extensions
(use-package cape
  :defer 10
  :bind ("C-c f" . cape-file)
  :init
  ;; Add `completion-at-point-functions', used by `completion-at-point'.
  (defalias 'dabbrev-after-2 (cape-capf-prefix-length #'cape-dabbrev 2))
  (add-to-list 'completion-at-point-functions 'dabbrev-after-2 t)
  (cl-pushnew #'cape-file completion-at-point-functions)
  :config
  ;; Silence then pcomplete capf, no errors or messages!
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)

  ;; Ensure that pcomplete does not write to the buffer
  ;; and behaves as a pure `completion-at-point-function'.
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify))

;; Templates takes advantage of emacs's tempo
;; (use-package tempel
;;   :defer 10
;;   :hook ((prog-mode text-mode) . tempel-setup-capf)
;;   :bind (("M-+" . tempel-insert) ;; Alternative tempel-expand
;;          :map tempel-map
;;          ([remap keyboard-escape-quit] . tempel-done)
;;          ;; ("TAB" . tempel-next)
;;          ;; ("<backtab>" . tempel-previous)
;;          :map corfu-map
;;          ("C-M-i" . tempel-expand))
;;   :init
;;   ;; Setup completion at point
;;   (defun tempel-setup-capf ()
;;     (setq-local completion-at-point-functions
;;                 (cons #'tempel-complete
;;                       completion-at-point-functions)))
;;   (add-hook 'prog-mode-hook 'tempel-setup-capf)
;;   (add-hook 'text-mode-hook 'tempel-setup-capf)
;;   (add-hook 'lsp-mode-hook 'tempel-setup-capf)
;;   (add-hook 'sly-mode-hook 'tempel-setup-capf)
;;   :config
;;   (defun tempel-include (elt)
;;     (when (eq (car-safe elt) 'i)
;;       (if-let (template (alist-get (cadr elt) (tempel--templates)))
;;           (cons 'l template)
;;         (message "Template %s not found" (cadr elt))
;;         nil)))
;;   (add-to-list 'tempel-user-elements #'tempel-include))

;; projectile helps navigate around "Projects" using some built-in heuristics
(use-package project
  :bind (("C-M-c c" . project-find-file)
         ("C-M-c C-M-p" . project-switch-project))
  )

; expand region - for selecting "inside stuff"
(use-package expand-region
  :bind ("C-M-n" . er/expand-region))

;; Theme stuff ------------------------------------------------------------------------------------

(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-palenight t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; also use the Doom mode line to make it a bit more pretty
;; (use-package doom-modeline
;;   :init (doom-modeline-mode 1) ; 1 is the default mode line - set to "t" for the alternative
;;   :custom ((doom-modeline-height 20)))

;; may consider using powerline?
(use-package powerline
  :config
  ;; Configure powerline
  (powerline-default-theme))

;; which key - shows key commands
(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.3))

;;
;; ;; hydra -- used to create quick functions assigned to keybindings this may be worth further exploration?
;; (use-package hydra)

;; ;; here's an example of a hydra that zooms in and out. ie. scales text
;; (defhydra hydra-text-scale (:timeout 4) ; this is the function with a timeout of 4 seconds (which is optional)
;;   "scale text"
;;   ("j" text-scale-increase "in")
;;   ("k" text-scale-decrease "out")
;;   ("f" nil "finished" :exit t))
;; ;; it is now bound to the leader key plus "ts" for text scale
;; (cig/leader-keys
;;   "ts" '(hydra-text-scale/body :which-key "scale text"))

;;Beacon - light up the cursor line on switches
(use-package beacon
  :config (beacon-mode 1))

;; magit for git
(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; todo list for magit window
(use-package magit-todos
  :config (magit-todos-mode 1))

;; Languages ------------------------------------------------------------------------------------

;; Tree Sitter for highlighting and navigation
(when (eq system-type 'gnu/linux)
(use-package tree-sitter-langs)
(use-package tree-sitter
  :ensure t
  :config
  (require 'tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)))

;; flycheck for checking errors
(use-package flycheck
  :init (global-flycheck-mode))


; unfortunately will be using different LSPs for the different OS's --------------
(when (eq system-type 'windows-nt) ; eglot for windows
  (global-set-key (kbd "C-M-c C-z") 'xref-find-definitions)
    (global-set-key (kbd "C-M-c C-v") 'lsp-describe-thing-at-point))

(when (eq system-type 'gnu/linux) ; lsp-mode for linux
  (global-set-key (kbd "C-M-c C-z") 'lsp-find-definition)
    (global-set-key (kbd "C-M-c C-v") 'lsp-describe-thing-at-point))

(when (eq system-type 'windows-nt) ; eglot for windows
  (use-package eglot
    :config
    (add-to-list 'eglot-server-programs '(python-mode . ("pylsp")))
    :hook
    (python-mode . eglot-ensure)
  ))

(when (eq system-type 'gnu/linux) ; lsp-mode for linux
  (use-package lsp-mode
  :commands lsp
  :custom
  ;; what to use when checking on-save. "check" is default, I prefer clippy
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-eldoc-render-all t)
  (lsp-idle-delay 0.6)
  ;; enable / disable the hints as you prefer:
  (lsp-rust-analyzer-server-display-inlay-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil)
  (lsp-rust-analyzer-display-closure-return-type-hints t)
  (lsp-rust-analyzer-display-parameter-hints nil)
  (lsp-rust-analyzer-display-reborrow-hints nil)
  :config
  (add-hook 'lsp-mode-hook 'lsp-ui-mode))

(use-package lsp-ui
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable nil))
  )

;; python stuff
;; (add-hook 'python-mode-hook
;;           (lambda ()
;;             (local-set-key (kbd "TAB") 'python-indent-right)
;;             (local-set-key (kbd "M-TAB") 'dired-find-file)))

;; Rust - only for linux
(when (eq system-type 'gnu/linux)
  (use-package rustic)
  )

;; can't seem to get this to work with use-package so putting it here
(add-hook 'rustic-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-c r") 'rustic-cargo-run)     ; swap run and rm
            (local-set-key (kbd "C-c C-c C-r") 'rustic-cargo-rm)
	    (local-set-key (kbd "C-c C-c b") 'rustic-cargo-build)   ; swap build and bench
            (local-set-key (kbd "C-c C-c C-b") 'rustic-cargo-bench)
	    (local-set-key (kbd "C-c C-c c") 'rustic-cargo-check)   ; swap check and clean
            (local-set-key (kbd "C-c C-c C-k") 'rustic-cargo-clean)
	    (local-set-key (kbd "C-c C-c t") 'rustic-cargo-test)    ; rebind test

	    )
	  )

;; avy movement
(use-package avy
  :bind (("C-M-a" . avy-goto-char)
         ("C-M-'" . avy-goto-line))
  )

(setq avy-keys-alist
      `((avy-goto-char . (?a ?s ?e ?t ?i ?r ?c ?m ?n ?o ?u))
        (avy-goto-line . ,(number-sequence ?1 ?9))))

;; Eshell ------------------------------------------------------------------------------------
(defun efs/configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell-git-prompt
  :ensure t ; no guix?
  :after eshell)

(use-package eshell
  :hook (eshell-first-time-mode . efs/configure-eshell)
  :bind ("<f7>" . eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim"))) ; these commands get run in an external terminal

  (eshell-git-prompt-use-theme 'powerline))

;; Vterm
(when (eq system-type 'gnu/linux)
 (use-package vterm))

;; Dired Options ------------------------------------------------------------------------------------
(use-package dired
  :commands (dired dired-jump)
  :custom ((dired-listing-switches "-agho --group-directories-first")))

(require 'dired-x)

(setq dired-omit-files
    (rx (or (seq bol (? ".") "#")     ;; emacs autosave files
        (seq bol "." (not (any "."))) ;; dot-files
        (seq "~" eol)                 ;; backup-files
        (seq bol "CVS" eol)           ;; CVS dirs
        )))

;; some dired settings from david wilson
(setq dired-listing-switches "-agho --group-directories-first"
      dired-omit-verbose nil
      dired-hide-details-hide-symlink-targets nil
      delete-by-moving-to-trash t)

(defun my-dired-up-directory ()
  "Move up one directory in Dired mode."
  (interactive)
  (dired-single-up-directory)
  (recenter))

(add-hook 'dired-mode-hook
          (lambda ()
	    (dired-omit-mode 1)
	    (dired-hide-details-mode 1)
            (local-set-key (kbd ".") 'dired-omit-mode)
            (local-set-key (kbd "<left>") 'my-dired-up-directory)
            (local-set-key (kbd "<right>") 'dired-find-file)))

(setq dired-kill-when-opening-new-dired-buffer t) ; opening dired will kill existing dired buffers

(use-package dired-single
  :ensure t ;; no guix
  :commands (dired dired-jump))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

;; (use-package dired-hide-dotfiles)

;; (defun my-dired-mode-hook ()
;;   ;; To hide dot-files by default
;;   (dired-hide-dotfiles-mode))

;; ;; To toggle hiding
;; (define-key dired-mode-map "." #'dired-hide-dotfiles-mode)
;; (add-hook 'dired-mode-hook #'my-dired-mode-hook)

;; Org stuff ------------------------------------------------------------------------------------
(use-package org)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)


;; chat stuff -----------------------------------------------------------------------------------

;; matrix client
(use-package ement)

;; Guix ------------------------------------------------------------------------------------
(use-package geiser-guile)
(use-package guix)


;; Element Chat -----------------------------------------------------------------------------------

;; TODO need to add element, but only load if SHELL_LEVEL is set to zero (if not its in a shell)
