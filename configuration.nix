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
  services.blueman.enable = true;

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
    };
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
      # Media
      freetube
      # Communication
      slack
      telegram-desktop
      signal-desktop
      discord
      # Convenience
      autojump
      neofetch
      fzf
      speedtest-cli
      progress
      trash-cli
      tldr
      lm_sensors
      btop
      htop
      lsd
      bat
      gdu
      ripgrep
      fzf
      meld
      flameshot
      # Software development
      jetbrains-toolbox
      neovim
      gcc
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Basic utils
    kitty
    udiskie
    vim_configurable 
    wget
    curl
    git
    git-lfs
    ed
    libnotify
    xclip
    p7zip
    fontconfig
    # Network
    networkmanagerapplet
    networkmanager_dmenu
    # Privacy
    mullvad-vpn
    # Email todo
    # Filesystem formatting tools
    gparted
    exfat
    exfatprogs
    # File manager
    ranger
    ueberzugpp
    # Documents
    zathura
    # Audio
    pipewire
    pavucontrol
    mpd
    # Images
    sxiv
    # Video
    mpv
    ffmpeg
    # Package managers
    flatpak
    # DWM
    xwallpaper
    xcompmgr
    harfbuzz
    (dmenu.overrideAttrs {
      src = /home/d/repos/dmenu;
    })
    (st.overrideAttrs (oldAttrs: rec {
      buildInputs = oldAttrs.buildInputs ++ [ harfbuzz ];
      src = /home/d/repos/st;
    }))
    xdg-desktop-portal-gtk
    xorg.libX11
    xorg.libX11.dev
    xorg.libxcb
    xorg.libXft
    xorg.libXinerama
    xorg.xinit
    xorg.xinput
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

