# add personal bin to PATH
export PATH=$PATH:/home/callam/.bin:/home/callam/.nix-profile/bin

# set location for the guix sandbox (for steam)
export GUIX_SANDBOX_HOME=/extra/nvme1/sandbox

# bug fix for dolphin
export QT_XCB_NO_X12=1 

# source the emacs profile
source /home/callam/.guix-extra-profiles/emacs/etc/profile
