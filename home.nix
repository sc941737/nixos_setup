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
    (pkgs.buildEnv {
      name = "my-scripts";
      paths = [ ./scripts ];
    })

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
    BT_MENU_CMD = "dmenu -fn Hack-22 -c -i -l 30";
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
  xdg.desktopEntries = let 
    app = name: cmd: {
      name = name;
      exec = cmd;
      type = "Application";
    };
    tui-app = name: cmd: {
      inherit (app name cmd) name exec type;
      terminal = true;
    };
  in {
    bt = (app "Bluetooth Settings" "bash bluetooth_dmenu"); 
    network = (app "Network Settings" "networkmanager_dmenu"); 
    audio = (tui-app "Audio Settings" "kitty -e pulsemixer");  
    files = (tui-app "File Manager" "kitty -e ranger");  
    calendar = (tui-app "Calendar" "kitty -e calcure");  
    editor = (tui-app "Text Editor" "kitty -e nvim");  
    btop = (tui-app "System Monitor" "kitty -e btop");  
    music = (tui-app "Music Player" "kitty -e mocp");  
    # Not usable on their own:
    zathura = (app "Reader" "zathura");
    sxiv = (app "Pictures" "sxiv");
    mpv = (app "Video Player" "mpv");
  };
  xdg.mimeApps.defaultApplications = {
    "application/pdf" = [ "zathura.desktop" ];
    "application/ebup+zip" = [ "zathura.desktop" ];
    "application/json" = [ "editor.desktop" ];
    "application/xml" = [ "editor.desktop" ];
    "text/*" = [ "editor.desktop" ];
    "image/*" = [ "sxiv.desktop" ];
    "video/*" = [ "mpv.desktop" ];
    "audio/*" = [ "music.desktop" ]; # todo: Need an audio player
    # "application/zip" = [ "unzip.desktop" ];
  };

  # X compositor
  services.picom = {
    enable = true;
    shadow = false;
    fade = false;
    opacityRules = [
      # "80:class_g = 'kitty' && focused"
      # "70:class_g = 'kitty' && !focused"
      "100:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_FULLSCREEN'"
      "100:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_MODAL'"
      "100:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_ABOVE'"
      "100:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_DEMANDS_ATTENTION'"
    ];
    activeOpacity = 0.8;
    inactiveOpacity = 0.7;
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
        "alt+k" = "scroll_line_up";
        "alt+j" = "scroll_line_down";
        "shift+alt+k" = "scroll_page_up";
        "shift+alt+j" = "scroll_page_down";
      };
    };
    # Editor
    nixvim = {
      enable = true;
      globals.mapleader = " ";
      colorschemes.dracula.enable = true;
      clipboard.providers.xclip.enable = true;
      options = {
        number = true;
        relativenumber = true;
        shiftwidth = 4;
	cmdheight = 2; # Need this to avoid annoying messages interrupting flow
      };
      autoCmd = let
	groff = e: cmd: {
	  event = [ e ];
	  pattern = [ "*.ms" "*.mm" "*.mom" "*.man" ];
	  command = "!${cmd} %";
	};
      in [
     	(groff "BufEnter" "groff-open-preview")
     	(groff "BufLeave" "groff-close-preview")
     	(groff "VimLeave" "groff-close-preview")
      	(groff "BufWritePost" "groff-compile-preview")
      ];
      keymaps = let
	lib = pkgs.lib;
	range = lib.range;
	altkey = key: "<M-${key}>";
	kmap = (cmd: key: {
	  action = "<cmd>${cmd}<CR>";
	  key = "${key}";
	});
	bufferBindings = range: map 
	    (n: let 
		s = toString n; 
	    in kmap "lua switch_buffer(${s})" (altkey s))
	    range;
	pkmap = (plugin: cmd: key: kmap "${plugin} ${cmd}" "<leader>${key}");
        telescope = pkmap "Telescope";
	gitsigns = pkmap "Gitsigns";
      in # Lists to be concatenated
	(bufferBindings (range 1 9)) ++ # Go to tab/buffer with selected ordinal (alt+n)
      [
        # Buffer navigation
	(kmap "bdelete" "<C-w>") # Close tab/buffer
	(kmap "blast" (altkey (toString 0))) # Go to last tab/buffer
	(kmap "bnext" "<M-Tab>") # Go to next tab/buffer
	(kmap "bprev" "<M-S-Tab>") # Go to previous tab/buffer
	# Telescope
        (telescope "grep_string" "fs")
        (telescope "live_grep" "fg")
        (telescope "find_files" "ff")
	# Gitsigns
        (gitsigns "blame_line" "hb")
        (gitsigns "stage_hunk" "hs")
        (gitsigns "reset_hunk" "hr")
        (gitsigns "preview_hunk_inline" "hp")
        (gitsigns "undo_stage_hunk" "hu")
        (gitsigns "stage_buffer" "hS")
        (gitsigns "reset_buffer" "hR")
        (gitsigns "toggle_deleted" "td")
        (gitsigns "diffthis" "hd")
      ];
      extraConfigLua = ''
        require("gitsigns").setup({
	  _signs_staged_enable = true, -- experimental
	})
	function switch_buffer(bindex)
	  local len = 0
	  local bfrs = {}
	  for i, bfr in ipairs(vim.api.nvim_list_bufs()) do 
	    if vim.api.nvim_buf_get_option(bfr, 'buflisted') then
		table.insert(bfrs, bfr) 
	    end
	  end
	  vim.cmd("buffer " .. bfrs[bindex])
	end
      '';
      extraPlugins = with pkgs.vimPlugins; [
        {
          plugin = vim-visual-multi;
	  # config = "";
	}
      ];
      plugins = {
        lualine.enable = true; # Fancy indicators in nvim line
	surround.enable = true; # Add/change/delete surrounding characters
        telescope = {
	  enable = true;
	  extensions.fzf-native.enable = true;
	}; # Search
	nvim-tree.enable = true; # File tree column
	nvim-autopairs.enable = true; # Pairing quotes, brackets etc.
	auto-save.enable = true; # Auto save changes
        oil.enable = true; # Buffer-like file system editing
        treesitter.enable = true;
	comment-nvim.enable = true; # Easy commenting
	bufferline = {
	  enable = true; # Editor tabs
	  numbers = "ordinal"; # Ensures buffers are numbered in order
	};
	gitsigns.enable = true; # Git hunk integration
	fugitive.enable = true; # Git integration
        luasnip.enable = true; # Code snippets
        nvim-cmp = {
          enable = true;
          autoEnableSources = true;
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
	  mapping = {
	    "<CR>" = "cmp.mapping.confirm({ select = true })";
	    "<Tab>" = {
	      action = ''
	        function(fallback)
		  if cmp.visible() then
		    cmp.select_next_item()
		  else 
		    fallback()
		  end
		end
	      '';
	      modes = [ "i" "s" ];
	    };
	  };
        };
        lsp = {
          enable = true;
          servers = {
            lua-ls.enable = true;
            nil_ls.enable = true;
            bashls.enable = true;
            clangd.enable = true;
            tsserver.enable = true;
            html.enable = true;
            jsonls.enable = true;
            kotlin-language-server.enable = true;
            java-language-server.enable = true;
            clojure-lsp.enable = true;
          };
        };
      };
    };
    # Document reader
    zathura = {
      options = {
        selection_clipboard = "clipboard";
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

  # Non-home-manager configs
#  home.file.".bashrc".source = ./.bashrc;
  home.file.".bash_aliases".source = ./.bash_aliases;
  home.file.".config/networkmanager-dmenu/config.ini".source = ./config/networkmanager-dmenu/config.ini;
  home.file.".config/sxiv/exec/key-handler".source = ./config/sxiv/key-handler;
  home.file.".config/ranger/rc.conf".source = ./config/ranger/rc.conf;
  home.file.".config/ranger/rifle.conf".source = ./config/ranger/rifle.conf;
  home.file.".config/BetterDiscord/themes/DarkMatter.theme.css".source = ./config/discord/DarkMatter.theme.css;
  home.file.".moc/config".source = ./config/moc/config;
  home.file.".moc/keymap".source = ./config/moc/keymap;
  home.file.".moc/themes/black_orange".source = ./config/moc/black_orange;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
