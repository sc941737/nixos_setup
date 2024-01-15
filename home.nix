{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "d";
  home.homeDirectory = "/home/d";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/d/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # DMENU_BLUETOOTH_LAUNCHER = "dmenu -c -i -l 20";
  };

  home.sessionPath = [
    "$HOME/repos/nixos_setup/scripts"
  ];

  home.shellAliases = {
    sys-rebuild = "sudo nixos-rebuild switch --flake ~/repos/nixos_setup --impure";
    home-rebuild = "home-manager switch --flake ~/repos/nixos_setup --impure";
    full-rebuild = "sys-rebuild && home-rebuild";
  };

  # Desktop apps
  xdg.desktopEntries = {
    bt = {
      name = "bt";
      type = "Application";
      exec = "dmenu-bluetooth -fn Hack-22 -l 30";
    };
    network = {
      name = "network";
      type = "Application";
      exec = "networkmanager_dmenu";
    };
    files = {
      name = "files";
      type = "Application";
      terminal = true;
      exec = "kitty -e ranger";
    };
    editor = {
      name = "nvim";
      type = "Application";
      exec = "kitty -e nvim";
      terminal = true;
    };
    btop = {
      name = "btop";
      type = "Application";
      exec = "btop";
      terminal = true;
    };
  };
  xdg.mimeApps.defaultApplications = {
    "application/pdf" = [ "zathura.desktop" ];
    "application/ebup+zip" = [ "zathura.desktop" ];
    "application/json" = [ "editor.desktop" ];
    "application/xml" = [ "editor.desktop" ];
    "text/*" = [ "editor.desktop" ];
    "image/*" = [ "sxiv.desktop" ];
    "video/*" = [ "mpv.desktop" ];
    "audio/*" = [ "mpv.desktop" ]; # todo: Need an audio player
    # "application/zip" = [ "unzip.desktop" ];
  };

  # X compositor
  services.picom = {
    enable = true;
    shadow = false;
    fade = false;
    opacityRules = [
      "80:class_g = 'kitty' && focused"
      "70:class_g = 'kitty' && !focused"
    ];
    vSync = true;
    backend = "glx";
    settings = {
      blur = {
        method = "dual_kawase";
      };
    };
  };

  programs = {
    # Shells
    bash = {
      enable = true;
      bashrcExtra = ''
        . /home/d/repos/nixos_setup/.bashrc
      '';
    };
    # Terminal
    kitty = {
      enable = true;
      font = {
        size = 16;
        name = "Hack";
      };
      settings = {
        confirm_os_window_close = -1;
        scrollback_lines = 10000;
        enable_audio_bell = false;
        linux_display_server = "x11";
      };
      keybindings = {
        "alt+c" = "copy_to_clipboard";
        "alt+v" = "paste_from_clipboard";
      };
    };
    # Version control
    git = {
      enable = true;
      userEmail = "sergiusz.cichosz@proton.me";
      userName = "sc941737";
      attributes = [
        "*.pdf diff=pdf"
      ];
      ignores = [
        "*~"
        "*.swp"
      ];
      lfs.enable = true;
    };
    # CLI tools
    autojump.enable = true;
  };

#  home.file.".bashrc".source = ./.bashrc;
  home.file.".config/networkmanager-dmenu/config.ini".source = /home/d/repos/nixos_setup/nm-dmenu-config.ini;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
