;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (gnu home)
             (gnu packages)
             (gnu services)
             (guix gexp)
             (gnu home services shells)
	     (gnu home services ssh))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
 (packages (specifications->packages (list
				      ;; gaming
				      "steam"
				      ;; "dolphin-emu"
				      "xrandr" ; for the primary_monitor script

				      ;; sys admin
                                      "parted"
                                      "stow"
				      "gnupg"
				      "openssh"
				      "pinentry"
				      "dunst"
				      
				      ;; browser
				      "firefox"
                                      "ungoogled-chromium"

				      ;; fonts/icons
				      "font-google-noto"
                                      "font-adobe-source-code-pro"
				      "font-awesome"
				      "breeze-icons"

				      ;; media
				      "pavucontrol"
				      
				      ;; programming
				      "cmake"
				      "gcc"
                                      "git"				   
				      "emacs"
				      "python"
				      
                                      "vim")))

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
