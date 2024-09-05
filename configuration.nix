# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-unstable, ... }:
let
  machineIdDirContents = builtins.readDir /etc/nixos/machine_id;
  machineIds = builtins.attrNames machineIdDirContents;
  machineId = builtins.head machineIds;
in
{
  imports = [
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

  virtualisation.docker.enable = true;

  # Configure X11, DM, WM
  services.xserver = {
    enable = true;
    upscaleDefaultCursor = true;
    dpi = 124;
    xkb = {
      layout = "pl";
      variant = "legacy";
    };
    displayManager = {
      lightdm.enable = true;
      sessionCommands = "dwmblocks &";
    };
    desktopManager.wallpaper.mode = "scale"; # ~/.background-image
    windowManager.dwm = {
      enable = true;
      package = pkgs.dwm.overrideAttrs {
      # When revising, add new rev, then change sha to 52 zeros, and the new sha will appear in the error message.
	# src = /home/d/repos/dwm;
        src = pkgs.fetchFromGitHub {
	  owner = "sc941737";
	  repo = "dwm";
	  rev = "ae484733958785294d9ec3489dd34f5ad98b7b9c";
	  sha256 = "sha256-1XGBkQP0xam+LEMS+fPnicUFn/m2wHu27fGsV18Lotg=";
	};
      };
    };
  };
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "d";
    };
  };
  services.libinput = {
    enable = true;
    touchpad = {
      accelSpeed = "1";
      accelProfile = "flat";
      disableWhileTyping = true;
    };
  };
  security.sudo.extraRules = [
    { 
      groups = [ "wheel" ];
      commands = [ { 
	command = "/home/d/repos/nixos_setup/scripts/blocks-brightness";
        options = [ "NOPASSWD" ];
      } ];
    }
  ];
  # Configure console keymap
  console.keyMap = "pl2";

  # Theme for QT apps
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  # Font config
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    (nerdfonts.override { fonts = [ "SourceCodePro" "Hack" ]; })
  ];

  # Enable sound
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    EDITOR = "nvim";
    BROWSER = "brave";
    FILE_MANAGER = "yazi";
    TERMINAL = "kitty";
    MANGAL_READER_PDF="zathura";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.d = {
    isNormalUser = true;
    description = "d";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = (with pkgs; [
      # Browsers
      # librewolf declared in home-manager
      # ungoogled-chromium declared in home-manager
      # brave declared in home-manager
      firefox
      mullvad-browser
      # Virtualisation
      wine
      wine64
      winetricks
      qemu_kvm
      # Games
      protonup-qt
      protontricks
      lutris
      # Media
      mangal # Manga client TUI
      # Communication
      slack
      telegram-desktop
      signal-desktop
      discord
      betterdiscordctl
      # Convenience
      fd # Better 'find'
      neofetch # Show system info
      speedtest-cli # Internet speed test
      progress # Shows progress of CLI data transfer
      trash-cli # Trash functionality in CLI
      tldr # Better 'man'
      lm_sensors # Monitoring sensors
      inotify-tools # Monitoring changes to file and directories
      btop # Better 'top'
      nvtopPackages.amd # 'top' for GPU
      lsd # Better 'ls'
      bat # Better 'cat'
      viddy # Better 'watch'
      ripgrep # Better 'grep'
      ugrep # Better 'grep' with a TUI
      redo # Wrap commands from history into a function
      gdu # Disk usage analyser
      fzf # Fuzzy finder
      jqp # Interactive 'jq'
      meld # Visual diff and merge tool
      usbutils # lsusb and similar
      # Software development
      android-tools # adb and the like
      bandwhich # Monitoring network requests
      so # TUI for StackOverflow and similar
      cargo # Rust package manager
      nodejs # JS package manager
      jetbrains-toolbox # Jetbrains IDEs
      neovim # Text editor
      sbcl # Steel Bank Common Lisp
      clisp # GNU Common Lisp
      asdf # Common Lisp build system
      cl-launch # Common Lisp CLI launcher
    ])
    ++ 
    (with pkgs-unstable; [
      # Media
      freetube # YT client GUI
      ytfzf # YT client TUI
      ani-cli # Anime client TUI
      mov-cli # Movies and series client TUI
      jan # Local GPT-like AI
    ]);
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
    # System Services
    sysz # TUI fzf for systemctl
    # Notifications
    libnotify
    dunst # Notification daemon
    # Network
    networkmanager_dmenu
    bluetuith
    # Privacy
    mullvad-vpn
    # Email todo
    # Filesystem formatting tools
    gparted
    exfat
    exfatprogs
    # File manager
    yazi # TUI file manager
    exiftool # Allows yazi to show EXIF metadata
    mediainfo # Allows yazi to show media metadata
    ueberzugpp # Allows yazi to view images
    ripdrag # Terminal drag and drop
    # Documents
    groff # Language for writing docs
    zathura # Pdf viewer
    pdfgrep # Better grep for pdfs
    ocrmypdf # Text recognition for pdfs
    visidata # Spreadsheets (.csv)
    sc-im # Spreadsheets (.ods, .xslx and others)
    # Audio
    pipewire
    pulsemixer # Audio settings TUI
    pavucontrol # Audio settings GUI
    moc # TUI music player
    # Images
    sxiv # Image viewer
    flameshot # Screenshots
    tesseract
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
	rev = "2cbd1a40556b032de3cf8b5bed267ff6236454d6";
	sha256 = "sha256-3gb8UelDoiSKkBhkwlAGC0MAJPCDvkC9eHd61jGdjlg=";
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

  programs.java.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 
    44001 # Docker Local AI
  ];
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

