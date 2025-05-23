{ config, pkgs, pkgs-unstable, ... }:

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
    BT_MENU_CMD = "dmenu -fn Hack-14 -c -i -l 30";
    GTK_THEME = "Adwaita-dark";
  };

  home.sessionPath = [
    "$HOME/repos/nixos_setup/scripts"
  ];

  home.shellAliases = {
    sys-rebuild = "sudo nixos-rebuild switch --flake ~/repos/nixos_setup --impure";
    home-rebuild = "home-manager switch --flake ~/repos/nixos_setup --impure";
    full-rebuild = "sys-rebuild && home-rebuild";
    nix-clean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2 && sudo nix-collect-garbage -d";
  };

  home.pointerCursor = {
    x11.enable = true;
    package = pkgs.quintom-cursor-theme;
    name = "Quintom_Ink";
    size = 40;
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
    vpn-location = (app "VPN Location Settings" "bash mullvad-relay-dmenu");
    bt = (app "Bluetooth Settings" "kitty -e bluetuith"); 
    network = (app "Network Settings" "networkmanager_dmenu"); 
    audio = (tui-app "Audio Settings" "kitty -e pulsemixer");  
    files = (tui-app "File Manager" "kitty -e yazi");  
    calendar = (tui-app "Calendar" "kitty -e calcure");  
    editor = (tui-app "Text Editor" "kitty -e nvim");  
    btop = (tui-app "System Monitor" "kitty -e btop");  
    nvtop = (tui-app "GPU Monitor" "kitty -e nvtop");  
    services = (tui-app "System Services" "kitty -e sysz");  
    music = (tui-app "Music Player" "kitty -e mocp");  
    jetbrains-toolbox = (app "JetBrains Toolbox" "jetbrains-toolbox");
    screenshot = (app "Flameshot" "flameshot gui");
    screenshot2txt = (app "Flameshot + Tesseract" "${pkgs.writeScript "screenshot2txt" '' 
    ${pkgs.flameshot}/bin/flameshot gui --raw | ${pkgs.tesseract}/bin/tesseract - - | ${pkgs.xclip}/bin/xclip -sel clip
    ''}");
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
    "audio/*" = [ "music.desktop" ]; 
    # "application/zip" = [ "unzip.desktop" ];
  };

  # X compositor
  services.picom = {
    enable = true;
    shadow = false;
    fade = false;
    opacityRules = [
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
      use-damage = false; # Fixes glitching after sleep in recent versions, may reduce performance
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
    zoxide.enable = true;
    # File manager
    yazi = {
      package = pkgs-unstable.yazi;
      enable = true;
      keymap = {
	manager.prepend_keymap = [
	  { on = "f"; run = "search --via=fd"; }
	  { on = "F"; run = "filter --smart"; }
	  { on = "s"; run = "search --via=rg"; }
	  { on = "S"; run = "search --via=rga"; }
	  { on = "z"; run = "plugin zoxide"; }
	  { on = "Z"; run = "plugin fzf"; }
	];
      };
      settings = {
	manager = {
	  mouse_events = [ "click" "scroll" "move" "drag" ];
	};
	opener = {
	  edit = [
	    { run = "kitty -e $EDITOR \"$@\""; orphan = true; desc = "Edit"; }
	  ];
	  play_video = [
	    { run = "mpv \"$@\""; orphan = true; desc = "Play in mpv"; }
	  ];
	  play_audio = [
	    { run = "kitty -e mocp \"$@\""; orphan = true; desc = "Play in mocp"; }
	  ];
	  view_doc = [
	    { run = "zathura \"$@\""; orphan = true; desc = "View"; }
	  ];
	  view_image = [
	    { run = "sxiv \"$@\""; orphan = true; desc = "View"; }
	  ];
	  gallery_view = [
	    { run = "sxiv \"$1/\""; orphan = true; desc = "View gallery"; }
	  ];
	  open_browser = [
	    { run = "$BROWSER \"$@\""; orphan = true; desc = "Open in browser"; }
	  ];
	  sc-im = [
	    { run = "kitty -e sc-im \"$1\""; orphan = true; desc = "Open in sc-im"; }
	  ];
	  visidata = [
	    { run = "kitty -e visidata \"$1\""; orphan = true; desc = "Open in visidata"; }
	  ];
	};
	open = {
	  prepend_rules = [
	    # Spreadsheets 
	    { name = "*.xlsx"; use = [ "sc-im" "visidata" "edit" "exif" "reveal" ]; }
	    { name = "*.xls"; use = [ "sc-im" "visidata" "edit" "exif" "reveal" ]; }
	    { name = "*.csv"; use = [ "sc-im" "visidata" "edit" "exif" "reveal" ]; }
	    { name = "*.tsv"; use = [ "sc-im" "visidata" "edit" "exif" "reveal" ]; }
	    { name = "*.ods"; use = [ "sc-im" "visidata" "edit" "exif" "reveal" ]; }
	    # Documents 
	    { name = "*.pdf"; use = [ "view_doc" "open_browser" "exif" "reveal" ]; }
	    { name = "*.djvu"; use = [ "view_doc" "open_browser" "exif" "reveal" ]; }
	    { name = "*.epub"; use = [ "view_doc" "open_browser" "exif" "reveal" ]; }
	    # Media
	    { mime = "image/*"; use = [ "view_image" "exif" "reveal" ]; }
	    { mime = "audio/*"; use = [ "play_audio" "play_video" "exif" "reveal" ]; }
	    # Code
	    { name = "*.html"; use = [ "edit" "open_browser" "exif" "reveal" ]; }
	    # Directories
	    { mime = "inode/directory"; use = [ "edit" "gallery_view" "open" "exif" "reveal" ]; }
	  ];
	};
      };
    };
    # Editor
    nixvim = {
      enable = true;
      vimAlias = true;
      defaultEditor = true;
      globals.mapleader = " "; # Space
      globals.maplocalleader = " "; 
      colorschemes.dracula.enable = true;
      clipboard.providers.xclip.enable = true;
      opts = {
        number = true;
        relativenumber = true;
        shiftwidth = 4;
	cmdheight = 2; # Need this to avoid annoying messages interrupting flow
      };
      autoCmd = let
	nix = e: cmd: {
	  event = [ e ];
	  pattern = [ "*.nix" ];
	  command = cmd;
	};
	groff = e: cmd: {
	  event = [ e ];
	  pattern = [ "*.ms" "*.mm" "*.mom" "*.man" ];
	  command = "!${cmd} %";
	};
	neorg = e: cmd: {
	  event = [ e ];
	  pattern = [ "*.org" "*.norg" ];
	  command = cmd;
	};
      in [
	(nix "BufEnter" "set shiftwidth=2")
	(nix "BufLeave" "set shiftwidth=4")
     	(groff "BufEnter" "groff-open-preview")
     	(groff "BufLeave" "groff-close-preview")
     	(groff "VimLeave" "groff-close-preview")
      	(groff "BufWritePost" "groff-compile-preview")
	(neorg "BufEnter" "set conceallevel=3")
	(neorg "BufLeave" "set conceallevel=0")
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
	# Navigate between windows
	(kmap "wincmd j" "<c-j>") 
	(kmap "wincmd k" "<c-k>") 
	(kmap "wincmd h" "<c-h>") 
	(kmap "wincmd l" "<c-l>") 
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
	# Need to package the below plugins for neorg to work
	# See: https://github.com/nix-community/nixvim/issues/1395
	(pkgs.vimUtils.buildVimPlugin {
	  inherit (pkgs.luaPackages.lua-utils-nvim) pname version src;
	})
	(pkgs.vimUtils.buildVimPlugin {
	  inherit (pkgs.luaPackages.pathlib-nvim) pname version src;
	})
	(pkgs.vimUtils.buildVimPlugin {
	  inherit (pkgs.luaPackages.nvim-nio) pname version src;
	})
      ];
      plugins = {
	conjure.enable = true;
        lualine.enable = true; # Fancy indicators in nvim line
	neorg = {
	  enable = true;
	  modules = {
	    "core.defaults" = {
	      __empty = null;
	    };
	    "core.pivot" = {};
	    "core.journal" = {};
	    "core.qol.todo_items" = {
	      config = {
		create_todo_items = true;
		create_todo_parents = true;
	      };
	    };
	    "core.concealer" = {
	      config = {
		icon_preset = "diamond";
	      };
	    };
	    "core.dirman" = {
	      config = {
		index = "index.norg";
		workspaces = {
		  notes = "~/notes";
		};
		default_workspace = "notes";
	      };
	    };
	  }; 
	};
	quickmath.enable = true; # Built-in calculator with variables and functions
	surround.enable = true; # Add/change/delete surrounding characters
        telescope = {
	  enable = true;
	  extensions.fzf-native.enable = true;
	}; # Search
	nvim-tree.enable = true; # File tree column
	auto-save.enable = true; # Auto save changes
        oil.enable = true; # Buffer-like file system editing
        treesitter.enable = true;
	comment.enable = true; # Easy commenting
	parinfer-rust.enable = true; # Auto managed brackets
	rainbow-delimiters.enable = true;
	bufferline = {
	  enable = true; # Editor tabs
	  numbers = "ordinal"; # Ensures buffers are numbered in order
	};
	gitsigns.enable = true; # Git hunk integration
	fugitive.enable = true; # Git integration
        luasnip.enable = true; # Code snippets
	cmp = {
	  settings = {
	    sources = [
	      { name = "nvim_lsp"; }
	      { name = "path"; }
	      { name = "buffer"; }
	    ];
	    mapping = {
	      "<CR>" = "cmp.mapping.confirm({ select = true })";
	      "<Tab>" = ''
		function(fallback)
	       	  if cmp.visible() then
		    cmp.select_next_item()
		  else 
		    fallback()
		  end
		end
	      '';
	    };
	  };
          enable = true;
          autoEnableSources = true;
        };
        lsp = {
          enable = true;
          servers = {
            lua-ls.enable = true;
            nil-ls.enable = true;
            bashls.enable = true;
            clangd.enable = true;
            tsserver.enable = true;
            html.enable = true;
	    cssls.enable = true;
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
      enable = true;
      options = {
        selection-clipboard = "clipboard";
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
    # Browsers
    chromium = {
      package = pkgs.ungoogled-chromium;
      enable = true;
      commandLineArgs = [ "--force-device-scale-factor=1.2" ];
    };
    brave = {
      package = pkgs.brave;
      enable = true;
      commandLineArgs = [ "--force-device-scale-factor=1.2" ];
      extensions = [
	# uBlock Origin
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
	# DarkReader
	{ id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; }
	# Vimium
	{ id = "dbepggeogbaibhgnhhndojpepiihcmeb"; }
      ];
    };
    librewolf = {
      enable = true;
      settings = let
	ext = name: "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
      in {
	  # Extensions
	  "browser.policies.runOncePerModification.extensionsInstall" =
	    "[${(ext "ublock-origin")}, ${(ext "darkreader")}, ${(ext "vimium-ff")}]";
	  # Home
	  "browser.startup.homepage" = "https://mullvad.net";
	  # Theme
	  "extensions.activeThemeID" = "firefox-compact-dark@mozilla.Origin";
	  # Security (safebrowsig disabled for privacy)
	  "dom.security.https_only_mode_ever_enabled" = true;
	  "browser.dom.window.dump.enabled" = false;
	  "browser.safebrowsing.malware.enabled" = false;
	  "browser.safebrowsing.phishing.enabled" = false;
	  "browser.safebrowsing.blockedURIs.enabled" = false;
	  "browser.safebrowsing.downloads.enabled" = false;
	  # Privacy
	  "webgl.disabled" = true;
	  "layout.spellcheckDefault" = 0;
	  "browser.translations.enable" = false;
	  "browser.contentblocking.category" = "strict";
	  "privacy.query_stripping.enabled" = true;
	  "privacy.query_stripping.enabled.pbmode" = true;
	  "browser.sessionstore.resume_from_crash" = false;
	  "browser.warnOnQuitShortcut" = false;
	  "browser.newtabpage.enabled" = false;
	  "privacy.donottrackheader.enabled" = false;
	  "privacy.globalprivacycontrol.enabled" = false;
	  "privacy.clearOnShutdown.history" = true;
	  "privacy.clearOnShutdown.downloads" = true;
	  "privacy.clearOnShutdown.cookies" = true;
	  "privacy.clearOnShutdown.cache" = true;
	  "privacy.clearOnShutdown.offlineApps" = true;
	  "privacy.trackingprotection.emailtracking.enabled" = true;
	  "privacy.trackingprotection.enabled" = true;
	  "privacy.trackingprotection.socialtracking.enabled" = true;
	  "privacy.trackingprotection.fingerprinting.enabled" = true;
	  "privacy.fingerprintingProtection" = true;
	  "privacy.resistFingerprinting" = true;
	  "privacy.resistFingerprinting.letterboxing" = true;
      };
    };
  };

  # Non-home-manager configs
#  home.file.".bashrc".source = ./.bashrc;
  home.file.".bash_aliases".source = ./.bash_aliases;
  home.file.".config/networkmanager-dmenu/config.ini".source = ./config/networkmanager-dmenu/config.ini;
  home.file.".config/sxiv/exec/key-handler".source = ./config/sxiv/key-handler;
  home.file.".config/BetterDiscord/themes/DarkMatter.theme.css".source = ./config/discord/DarkMatter.theme.css;
  home.file.".moc/config".source = ./config/moc/config;
  home.file.".moc/keymap".source = ./config/moc/keymap;
  home.file.".moc/themes/black_orange".source = ./config/moc/black_orange;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
