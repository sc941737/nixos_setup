# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  machineIdDirContents = builtins.readDir /etc/nixos/machine_id;
  machineIds = builtins.attrNames machineIdDirContents;
  machineId = builtins.head machineIds;
in
{
  imports = [ # Include the results of the hardware scan.
    ./hardware/${machineId}/hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # OpenGL setup
  hardware.opengl.extraPackages = with pkgs; [
    rocmPackages.clr.icd # OpenCL
  ];
  hardware.opengl.enable = true;

  # Configure X11, DM, WM
  services.xserver = {
    enable = true;
    dpi = 96;
    layout = "us";
    xkbVariant = "";
    displayManager = {
      lightdm.enable = true;
      autoLogin = {
        enable = true;
        user = "d";
      };
      sessionCommands = "dwmblocks &";
    };
    desktopManager.wallpaper.mode = "scale";
    windowManager.dwm = {
      enable = true;
      package = pkgs.dwm.overrideAttrs {
	# src = /home/d/repos/dwm;
        src = pkgs.fetchFromGitHub {
	  owner = "sc941737";
	  repo = "dwm";
	  rev = "a5a21bdd95f587268f135fe9aa2308290eb49ebb";
	  sha256 = "sha256-pxeN3RGkOB/QTRzFwyXrouN7SYBqaVjClz/S9iU4jxY=";
	};
      };
    };
    libinput = {
      enable = true;
      touchpad = {
        accelSpeed = "1";
        disableWhileTyping = true;
      };
    };
  };

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    extraConfig = "
      load-module module-switch-on-connect
    ";
  };

  # Automount drives
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;

  # VPN
  services.mullvad-vpn = {
    enable = true;
    enableExcludeWrapper = false;
  };

  # GTK
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*"; # Temporary fallback to old behaviour pre v1.7, should specify portal backend
  };

  # Global file search
  services.locate = {
    enable = true;
    interval = "hourly";
    package = pkgs.mlocate;
    localuser = null;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.d = {
    isNormalUser = true;
    description = "d";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # Browsers
      ungoogled-chromium
      brave
      librewolf
      firefox
      mullvad-browser
      # Virtualisation
      wine
      winetricks
      qemu_kvm
      # Games
      steam-tui
      protonup-qt
      protontricks
      lutris
      # Media
      freetube # YT client GUI
      ytfzf # YT client TUI
      ani-cli # Anime client TUI
      mangal # Manga client TUI
      mov-cli # Movies and series client TUI
      # Communication
      slack
      telegram-desktop
      signal-desktop
      discord
      betterdiscordctl
      # Convenience
      autojump # Better 'cd'
      neofetch # Show system info
      speedtest-cli # Internet speed test
      progress # Shows progress of CLI data transfer
      trash-cli # Trash functionality in CLI
      tldr # Better 'man'
      lm_sensors # Monitoring sensors
      inotify-tools # Monitoring changes to file and directories
      btop # Better 'top'
      htop # Better 'top'
      lsd # Better 'ls'
      bat # Better 'cat'
      viddy # Better 'watch'
      ripgrep # Better 'grep'
      ugrep # Better 'grep' with a TUI
      redo # Wrap commands from history into a function
      gdu # Disk usage analyser
      fzf # Fuzzy finder
      meld # Visual diff and merge tool
      # Software development
      bandwhich # Monitoring network requests
      so # TUI for StackOverflow and similar
      cargo # Rust package manager
      nodejs # JS package manager
      jetbrains-toolbox # Jetbrains IDEs
      neovim # Text editor
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.variables = {
    GDK_SCALE="2";
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "kitty";
    MANGAL_READER_PDF="zathura";
  };

  # Font config
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "SourceCodePro" "Hack" ]; })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Basic utils
    nixFlakes
    kitty # Terminal with GPU acceleration
    udiskie
    vim_configurable 
    wget
    curl
    jq
    fx
    git
    git-lfs
    ed
    xclip
    p7zip
    unzip
    # Fonts
    nerdfonts
    fontconfig
    # Notifications
    libnotify
    dunst # Notification daemon
    # Network
    networkmanager_dmenu
    # Privacy
    mullvad-vpn
    # Email todo
    # Filesystem formatting tools
    gparted
    exfat
    exfatprogs
    # File manager
    ranger # TUI file manager
    ueberzugpp # Allows ranger to view images
    ripdrag # Terminal drag and drop
    # Documents
    groff # Language for writing docs
    zathura # Pdf viewer
    # Audio
    pipewire
    pulsemixer # Audio settings TUI
    pavucontrol # Audio settings GUI
    moc # TUI music player
    # Images
    sxiv # Image viewer
    flameshot # Screenshots
    imagemagick # Image editing
    # Video
    mpv # Video player
    ffmpeg # CLI video editing
    # Date/time
    calcure
    # Package managers
    flatpak
    # DWM
    xdotool
    xwallpaper
    xcompmgr
    harfbuzz
    (dmenu.overrideAttrs {
      # src = /home/d/repos/dmenu;
      src = fetchFromGitHub {
        # installFlags = [ "sysconfdir=$out/etc" "localstatedir=$out/var" ];
	owner = "sc941737";
	repo = "dmenu";
	rev = "04bc4e6dd557a26da12688adb4ffcf3ce16ac859";
	sha256 = "sha256-/UbjnxECN59tLwliUQDoVEOPL90sorSQYQpCpdq5oyg=";
      };
    })
    (dwmblocks.overrideAttrs {
      # src = /home/d/repos/dwmblocks;
      src = fetchFromGitHub {
	owner = "sc941737";
	repo = "dwmblocks";
	rev = "1af342f3a1d66a1295c4e05223cbe623fd8f8628";
	sha256 = "sha256-bum9mYaFtj4nvzL0bhxqFyr/wuE+9BW/wt+i0m4qh40=";
      };
    })
    xdg-desktop-portal-gtk
    xorg.libX11
    xorg.libX11.dev
    xorg.libxcb
    xorg.libXft
    xorg.libXinerama
    xorg.xinit
    xorg.xinput
    glxinfo
    gcc
    gnumake
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.steam = {
    enable = true;
  };


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}

