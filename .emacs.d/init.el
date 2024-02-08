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

;; Transparency
;; (set-frame-parameter nil 'alpha-background 70)
;; (add-to-list 'default-frame-alist '(alpha-background . 70))

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

;; kill whole lines
(setq kill-whole-line t)

; windows settings ---------------------------------------------------
; enable CUA mode so hotkeys act like windows
(cua-mode t)
(delete-selection-mode 1)

;; use pinentry on linux
(when (eq system-type 'gnu/linux)
  (setq epa-pinentry-mode 'loopback)
  (pinentry-start))

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
(when (eq system-type 'gnu/linux)
  (global-set-key (kbd "<f9>")  'vterm))
(when (eq system-type 'windows-nt)
  (global-set-key (kbd "<f9>")  'eat))

(global-set-key (kbd "TAB")  'indent-according-to-mode)
(global-set-key (kbd "C-M-b")  'comment-line)
(global-set-key (kbd "C-M-S-d") 'dired-jump)
(global-set-key (kbd "C-s")   'save-buffer)
(global-set-key (kbd "C-a")   'mark-whole-buffer)
(global-set-key (kbd "C-M-c <home>")   'back-to-indentation)

;; Macro keybindings
(global-set-key (kbd "C-M-S-v")   'kmacro-start-macro)
(global-set-key (kbd "C-M-v")   'kmacro-end-macro)
(global-set-key (kbd "C-M-g")   'kmacro-call-macro)

;; Window management
(global-set-key (kbd "C-M-c v")   'split-window-vertically)
(global-set-key (kbd "C-M-c h")   'split-window-horizontally)
(global-set-key (kbd "C-M-c <up>")   'windmove-up)
(global-set-key (kbd "C-M-c <down>")   'windmove-down)
(global-set-key (kbd "C-M-c <left>")   'windmove-left)
(global-set-key (kbd "C-M-c <right>")   'windmove-right)

;; directory hotkeys
;; dired "~/Projects/"
;; (global-set-key (kbd "C-M-c d p") (lambda () (interactive) (dired "~/Projects")))

(defun add-surrounding-char (char)
  ;; "Add the specified character to the start and end of the currently highlighted text."
  (interactive "cEnter a character: ")
  (when (region-active-p)
    (let ((start (region-beginning))
          (end (region-end)))
      (goto-char start)
      (insert-char char)
      (goto-char (+ end 1))
      (if (char-equal char ?\()
          (insert-char ?\))
        (insert-char char))
      )))

(defun insert-matching-parenthesis ()
  "Insert a matching parenthesis in programming modes and move the cursor back by one character."
  (interactive)
  (insert "()")
  (backward-char))

(defun insert-matching-brackets ()
  "Insert a matching parenthesis in programming modes and move the cursor back by one character."
  (interactive)
  (insert "[]")
  (backward-char))

(defun insert-matching-quotations ()
  "Insert a matching parenthesis in programming modes and move the cursor back by one character."
  (interactive)
  (insert "''")
  (backward-char))

(defun insert-matching-doublequotations ()
  "Insert a matching parenthesis in programming modes and move the cursor back by one character."
  (interactive)
  (insert "\"\"")
  (backward-char))

(defun insert-matching-curlybrackets ()
  "Insert a matching parenthesis in programming modes and move the cursor back by one character."
  (interactive)
  (insert "{}")
  (backward-char))

(add-hook 'prog-mode-hook
          (lambda ()
            (local-set-key (kbd "(") 'insert-matching-parenthesis)
	    (local-set-key (kbd "[") 'insert-matching-brackets)
	    (local-set-key (kbd "'") 'insert-matching-quotations)
	    (local-set-key (kbd "\"") 'insert-matching-doublequotations)
	    (local-set-key (kbd "{") 'insert-matching-curlybrackets)))


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
    (setq use-package-always-ensure nil) ; switching to arch
  
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
           ("C-M-c r"     . consult-ripgrep)          ;; ripgrep - will need windows alternative
	   ("C-M-c f"     . consult-find)             ;; find files
           ;; ("C-x C-SPC"   . consult-global-mark)      ;; shows the global-mark-ring, will need to figure out
           ;; ("C-x M-:"     . consult-complex-command)  ;; consult's version of C-x?
           ;; ("C-c n"       . consult-org-agenda)       ;; consult's org agenda view
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
  ;; :defer 0
  ;; :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.3))


;; hydra -- used to create quick functions assigned to keybindings this may be worth further exploration?
(use-package hydra)

(defhydra hydra-open-projects-dired (:color blue)
  "Open Projects Dired"

  (when (eq system-type 'gnu/linux)
    ("p" (lambda () (interactive) (dired "~/Projects")) "Projects" :exit t)
    ("d" (lambda () (interactive) (dired "~/Documents")) "Documents" :exit t)
    ("n" (lambda () (interactive) (dired "~/Documents/Notes")) "Notes" :exit t)
    ("s" (lambda () (interactive) (dired "/extra/ssd1")) "SSD" :exit t)
    ("n" (lambda () (interactive) (dired "/extra/nvme1")) "NVME" :exit t)
    ("q" nil "Quit" :exit t))
  (when (eq system-type 'windows-nt)
    ("d" (lambda () (interactive) (dired "H:/65z/Database")) "Database" :exit t)
    ("t" (lambda () (interactive) (dired "H:/65z/Database/Reports/Top_Rates")) "Top Rates" :exit t)
    ("r" (lambda () (interactive) (dired "H:/65z/Database/Reports")) "Reports" :exit t)
    ("x" (lambda () (interactive) (dired (concat (getenv "USERDIR") "/xltdfm"))) "xltdfm" :exit t)
    ("i" (lambda () (interactive) (dired (concat (getenv "USERDIR") "/Daily_Imports"))) "Daily Imports" :exit t)
    ("s" (lambda () (interactive) (dired (getenv "USERDIR"))) "s_id folder" :exit t)
    ("b" (lambda () (interactive) (dired "H:/65z/Private Client Admin/MPP Models & Trading/Mutual Fund Bulk Orders")) "Reports" :exit t)
    ("q" nil "Quit" :exit t))
  
  )

(global-set-key (kbd "C-M-c d") 'hydra-open-projects-dired/body)



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
  :config
  (require 'tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)))

;; flycheck for checking errors
(use-package flycheck
  :init (global-flycheck-mode))


; lsp keybindings
(global-set-key (kbd "C-M-c C-z") 'lsp-find-definition)
(global-set-key (kbd "C-M-c C-v") 'lsp-describe-thing-at-point)

(use-package lsp-mode
  :commands lsp
  :hook
  ((python-mode . lsp))
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

;; python stuff
;; (add-hook 'python-mode-hook
;;           (lambda ()
;;             (local-set-key (kbd "TAB") 'python-indent-right)
;;             (local-set-key (kbd "M-TAB") 'dired-find-file)))

;; Rust
(use-package rustic)

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
      `((avy-goto-char . ,(number-sequence ?1 ?9))
        (avy-goto-line . ,(number-sequence ?1 ?9))))

;; Eshell ------------------------------------------------------------------------------------
(use-package eshell
  :bind ("<f7>" . eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim"))) ; these commands get run in an external terminal
  )

;; Vterm
(when (eq system-type 'gnu/linux)
  (use-package vterm
    :bind (:map vterm-mode-map ("C-v" . vterm-yank))
    ))

;; eat
(when (eq system-type 'windows-nt)
  (use-package eat
    :ensure t
    :config
    (eat-eshell-mode)
    (setq eshell-visual-commands '()))
  )

;; Dired Options ------------------------------------------------------------------------------------
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

; default to hide files
;; (setq dired-omit-mode 1)
(setq dired-omit-mode 1)

(add-hook 'dired-mode-hook
          (lambda ()
	    (dired-hide-details-mode 1)
	    (setq dired-omit-mode 1)
            (local-set-key (kbd ".") 'dired-omit-mode)
	    (local-set-key (kbd "<home>") '(find-alternate-file "~/"))
            (local-set-key (kbd "<left>") 'my-dired-up-directory)
            (local-set-key (kbd "<right>") 'dired-open-file)))

(setq dired-kill-when-opening-new-dired-buffer t) ; opening dired will kill existing dired buffers

(use-package dired-single
  :ensure t ;; no guix
  :commands (dired dired-jump))

;; (use-package all-the-icons-dired
  ;; :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv")
				("MOV" . "mpv")
				("mp4" . "mpv"))))


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

(use-package denote
  :config
  ;; Remember to check the doc strings of those variables.
  (setq denote-directory (expand-file-name "~/Documents/Notes/"))
  (when (eq system-type 'windows-nt)
    (setq denote-known-keywords '("PC Meeting" "Condo Meeting" "Investment Committee" "Client Call" "Misc")))
  (when (eq system-type 'gnu/linux)
    (setq denote-known-keywords '("journal")))
  (setq denote-infer-keywords t)
  (setq denote-sort-keywords t)
  (setq denote-file-type nil) ; Org is the default, set others here
  (setq denote-prompts '(title keywords))
  (setq denote-excluded-directories-regexp nil)
  (setq denote-excluded-keywords-regexp nil)

  ;; Pick dates, where relevant, with Org's advanced interface:
  (setq denote-date-prompt-use-org-read-date t)


  ;; Read this manual for how to specify `denote-templates'.  We do not
  ;; include an example here to avoid potential confusion.

  (setq denote-date-format nil) ; read doc string
  
  ;; By default, we do not show the context of links.  We just display
  ;; file names.  This provides a more informative view.
  (setq denote-backlinks-show-context t)
  
  ;; Also see `denote-link-backlinks-display-buffer-action' which is a bit
  ;; advanced.
  
  ;; If you use Markdown or plain text files (Org renders links as buttons
  ;; right away)
  (add-hook 'find-file-hook #'denote-link-buttonize-buffer)
  
  ;; We use different ways to specify a path for demo purposes.
  ;; (setq denote-dired-directories
	;; (list denote-directory
              ;; (thread-last denote-directory (expand-file-name "attachments"))
              ;; (expand-file-name "~/Documents/books")))
  
  ;; Generic (great if you rename files Denote-style in lots of places):
  ;; (add-hook 'dired-mode-hook #'denote-dired-mode)
  ;;
  ;; OR if only want it in `denote-dired-directories':
  (add-hook 'dired-mode-hook #'denote-dired-mode-in-directories)


  ;; Automatically rename Denote buffers using the `denote-rename-buffer-format'.
  (denote-rename-buffer-mode 1)

  ;; Denote DOES NOT define any key bindings.  This is for the user to
  ;; decide.  For example:
  (let ((map global-map))
    (define-key map (kbd "C-c n n") #'denote)
    (define-key map (kbd "C-c n c") #'denote-region) ; "contents" mnemonic
    (define-key map (kbd "C-c n N") #'denote-type)
    (define-key map (kbd "C-c n d") #'denote-date)
    (define-key map (kbd "C-c n z") #'denote-signature) ; "zettelkasten" mnemonic
    (define-key map (kbd "C-c n s") #'denote-subdirectory)
    (define-key map (kbd "C-c n t") #'denote-template)
    ;; If you intend to use Denote with a variety of file types, it is
    ;; easier to bind the link-related commands to the `global-map', as
    ;; shown here.  Otherwise follow the same pattern for `org-mode-map',
    ;; `markdown-mode-map', and/or `text-mode-map'.
    (define-key map (kbd "C-c n i") #'denote-link) ; "insert" mnemonic
    (define-key map (kbd "C-c n I") #'denote-add-links)
    (define-key map (kbd "C-c n b") #'denote-backlinks)
    (define-key map (kbd "C-c n f f") #'denote-find-link)
    (define-key map (kbd "C-c n f b") #'denote-find-backlink)
    ;; Note that `denote-rename-file' can work from any context, not just
    ;; Dired bufffers.  That is why we bind it here to the `global-map'.
    (define-key map (kbd "C-c n r") #'denote-rename-file)
    (define-key map (kbd "C-c n R") #'denote-rename-file-using-front-matter))
  
  ;; Key bindings specifically for Dired.
  (let ((map dired-mode-map))
    (define-key map (kbd "C-c C-d C-i") #'denote-link-dired-marked-notes)
    (define-key map (kbd "C-c C-d C-r") #'denote-dired-rename-files)
    (define-key map (kbd "C-c C-d C-k") #'denote-dired-rename-marked-files-with-keywords)
    (define-key map (kbd "C-c C-d C-R") #'denote-dired-rename-marked-files-using-front-matter))
  
  (with-eval-after-load 'org-capture
    (setq denote-org-capture-specifiers "%l\n%i\n%?")
    (add-to-list 'org-capture-templates
		 '("n" "New note (with denote.el)" plain
                   (file denote-last-path)
                   #'denote-org-capture
                   :no-save t
                   :immediate-finish nil
                   :kill-buffer t
                   :jump-to-captured t)))
  
  ;; Also check the commands `denote-link-after-creating',
  ;; `denote-link-or-create'.  You may want to bind them to keys as well.
  

  ;; If you want to have Denote commands available via a right click
  ;; context menu, use the following and then enable
  ;; `context-menu-mode'.
  (add-hook 'context-menu-functions #'denote-context-menu)
  )


;; chat stuff -----------------------------------------------------------------------------------
(when (eq system-type 'gnu/linux)
;; matrix client
  (use-package ement))

;; Guix ------------------------------------------------------------------------------------
(when (eq system-type 'gnu/linux)
(use-package geiser-guile)
(use-package guix))


;; Element Chat -----------------------------------------------------------------------------------

;; TODO need to add element, but only load if SHELL_LEVEL is set to zero (if not its in a shell)
