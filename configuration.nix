# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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
        src = /home/d/repos/dwm;
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
      steam
      steam-tui
      protonup-qt
      protontricks
      lutris
      # Media
      freetube # YT client
      # Communication
      slack
      telegram-desktop
      signal-desktop
      discord
      # Convenience
      autojump # Better 'cd'
      neofetch # Show system info
      speedtest-cli # Internet speed test
      progress # Shows progress of CLI data transfer
      trash-cli # Trash functionality in CLI
      tldr # Better 'man'
      lm_sensors # Monitoring sensors
      btop # Better 'top'
      htop # Better 'top'
      lsd # Better 'ls'
      bat # Better 'cat'
      gdu # Disk usage analyser
      ripgrep # Better 'grep'
      fzf # Fuzzy finder
      meld # Visual diff and merge tool
      # Software development
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
  };

  # Font config
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "SourceCodePro" "Hack" ]; })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Basic utils
    kitty # Terminal with GPU acceleration
    udiskie
    vim_configurable 
    wget
    curl
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
    networkmanagerapplet
    networkmanager_dmenu
    dmenu-bluetooth
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
    # Documents
    zathura # Pdf viewer
    # Audio
    pipewire
    pavucontrol
    mpd # CLI audio player
    ncmpcpp # TUI mpd client
    # Images
    sxiv # Image viewer
    flameshot # Screenshots
    imagemagick # Image editing
    # Video
    mpv # Video player
    ffmpeg # CLI video editing
    # Package managers
    flatpak
    # DWM
    xwallpaper
    xcompmgr
    harfbuzz
    (dmenu.overrideAttrs {
      src = /home/d/repos/dmenu;
    })
    (dwmblocks.overrideAttrs {
      src = /home/d/repos/dwmblocks;
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




