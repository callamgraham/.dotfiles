;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

;; some utilities courtesy of David Wilson, for pulling manifests
(define (read-manifest manifest-path)
  (with-input-from-file manifest-path
    (lambda ()
      (read))))

(define (gather-manifest-packages manifests)
  (if (pair? manifests)
      (begin
        (let ((manifest (read-manifest (string-append
                                        "/home/callam/.dotfiles/.manifests/"
                                        (symbol->string (car manifests))
                                        ".scm"))))

          (append (map specification->package+output
                       (cadadr manifest))
                  (gather-manifest-packages (cdr manifests)))))
      '()))



(use-modules (gnu home)
             (gnu packages)
             (gnu services)
             (guix gexp)
             (gnu home services shells)
	     (gnu home services ssh))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
 (packages
  (append (gather-manifest-packages '(emacs))
  (specifications->packages (list
				      ;; gaming
				      "steam"
				      ;; "dolphin-emu"
				      "xrandr" ; for the primary_monitor script
				      "sdl" ; for running some games like cs:go in wayland
				      
				      ;; sys admin
                                      "parted"
                                      "stow"
				      "gnupg"
				      "openssh"
				      "pinentry"
				      "dunst"
				      "flatpak"
				      ;; "nix"
				      "ntfs-3g" ; for ntfs drives
				      "zip"
				      "unzip"
				      "xdg-user-dirs"
				      "p7zip"
				      "neofetch" ; shows user info
				      "pantalaimon" ; for ement encrypted
				      
				      ;; browser
				      "firefox"

				      ;; office
				      "libreoffice"
				      "evince"
				      
				      ;; fonts/icons
				      "font-google-noto"
                                      "font-adobe-source-code-pro"
				      "font-awesome"
				      "breeze-icons"

				      ;; media
				      "qpwgraph"
				      "pavucontrol"
				      "handbrake"
				      "mpv" ;
				      "feh"
				      
				      ;; programming
				      "cmake"
				      "gcc-toolchain"
				      "gcc-objc:lib"
                                      "git"				   
				      "python"

				      ;; other...
                                      "vim"))))

  ;; Below is the list of Home services.  To search for available
  ;; services, run 'guix home search KEYWORD' in a terminal.
  (services
   (list (service home-bash-service-type
                  (home-bash-configuration
                   (aliases '(("grep" . "grep --color=auto") ("ll" . "ls -l")
                              ("ls" . "ls -p --color=auto")))
                   (bashrc (list (local-file
                                  "/home/callam/.dotfiles/.config/guix/.bashrc"
                                  "bashrc")))))

	 (service home-ssh-agent-service-type)
	 )))
