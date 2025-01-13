#!/usr/bin/python3

import os
import subprocess

desktop = configuration(
    pacman_packages = [
        # system
        "mesa",
        "wireplumber",
        "pipewire",
        "tailscale",

        #admin,
        "yazi",
        "zoxide",
        "starship",
        

        #browsers
        "firefox",

        #editors
        "emacs-wayland",
        "helix",

        #window manager/DE
        "sway",
        "wofi",
        "waybar",

        #programming
        "python",
        "python-lsp-server",
        "rustup",

        #gaming,
        "steam",
        "retroarch",
        "libretro-desmume",
        "libretro-mgba",
        "libretro-citra",
        "libretro-pcsx2",
        "lutris",
    ],
    services = [],
    post_commands = [],
    symlinks = [],
    config_files = [],
)

basement = configuration(
    pacman_packages = [],
    services = [],
    post_commands = [],
    symlinks = [],
    config_files = [],
)


class symlink(object):
    def __init__(self, source_file, destination_file):
        self.source_file = source_file
        self.destination_file = destination_file

class config_file(object):
    def __init__(self, file_location, content):
        self.file_location = file_location
        self.content = content

class configuration(object):
    def __init__(self, pacman_packages=[], apt_packages=[], services=[], post_commands=[], symlinks=[], config_files=[]):
        self.pacman_packages = pacman_packages
        self.apt_packages = apt_packages
        self.services = services
        self.post_commands = post_commands
        self.symlinks = symlinks
        self.config_files = config_files

class cig(object):
    def __init__ (self, conf: configuration, computer="desktop"):
        self.conf = configuration
        self.computer = computer

    def sync_pacman(self):
        subprocess.run(["sudo", "pacman", "-Sy"])
        subprocess.run(["sudo", "pacman", "-S"] + self.conf.pacman_packages)

    def sync_apt(self):
        subprocess.run(["sudo", "apt-get", "update"])
        subprocess.run(["sudo", "apt-get", "install"] + self.conf.apt_packages)

    def systemd_services(self):
        for service in self.conf.services:
            assert type(service) == str
            subprocess.run(["sudo", "systemctl", "enable", "--now", service])

    def post_commands(self):
        # commands that run post install
        for com in self.conf.post_commands:
            subprocess.run(com)

    def symlinks(self):
        for sym in self.conf.symlinks:
            assert type(sym) == symlink

            # check that the desired parent directories exist
            dest_directory = os.path.dirname(sym.destination_file)
            if not os.path.exists(dest_directory):
                os.makedirs(dest_directory)
                
            # create symlink
            os.symlink(sym.source_file, sym.destination_file)

    def config_files(self):
        # generates config files from text
        for config in self.conf.config_file:
            # check that the desired parent directories exist
            dest_directory = os.path.dirname(config.file_location)
            if not os.path.exists(dest_directory):
                os.makedirs(dest_directory)

            # create file
            with open(config.file_location, "w") as cfile:
                cfile.write(config.content)
            
    def sync(self):
        self.sync_pacman()
        self.sync_apt()
        self.config_files()
        self.symlinks()
        self.systemd_services()
        self.post_commands()

        
if __name__ == "__main__":
    import sys

    help_text = """
    Usage:
    cigar desktop
    cigar basement
    """
    # Check if there are any command-line arguments
    if len(sys.argv) > 1:
        # sys.argv[1] is the first argument after the script name
        if sys.argv[1] == 'desktop':
            c = cig(desktop, computer="desktop")
        if sys.argv[1] == 'basement':
            c = cig(desktop, computer="basement")
        else:
            print(help_text)
    else:
        print(help_text)
    
