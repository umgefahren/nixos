{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
    inputs.walker.homeManagerModules.default
  ];
  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-macchiato;
  catppuccin = {
    enable = true;
    flavor = "macchiato";
  };
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "hannesf";
  home.homeDirectory = "/home/hannesf";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

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
    pkgs.icomoon-feather
    pkgs.monaspace
    pkgs.wl-clipboard
    pkgs.socat
    pkgs.pamixer
    pkgs.fira-code-nerdfont
    pkgs.libnotify
    pkgs.brightnessctl
    pkgs.vlc
    pkgs.mpv
    pkgs.ffmpeg
    pkgs.hyprland-activewindow
    pkgs.prismlauncher
    pkgs.libdecor
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
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/hannesf/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
    NIXOS_OZONE_WL = "1";
  };

  services.mako = {
    enable = true;
    defaultTimeout = 10000;
  };

  services.lorri.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = [
      pkgs.gcc
      pkgs.lua-language-server
      pkgs.nixd
      pkgs.alejandra
      pkgs.vscode-langservers-extracted
      pkgs.nil
      pkgs.pyright
    ];
  };
  xdg.configFile.nvim.source = ./extra/nvim;
  programs.fish = {
    enable = true;
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.yt-dlp.enable = true;

  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
      	shopt -q login_shell && LOGIN_OPTIONS="--login" || LOGIN_OPTIONS=""
      	exec ${pkgs.fish}/bin/fish $LOGIN_OPTIONS
      fi
    '';
  };
  programs.kitty = {
    enable = true;
    catppuccin.enable = true;
    font = {
      name = "Monaspace Neon Var";
      size = 10;
    };
    settings = {
      font_family = "Monaspace Neon Var";
      window_padding_width = 2;
    };
  };
  programs.firefox.enable = true;
  programs.brave.enable = true;
  programs.starship = {
    enable = true;
  };
  programs.bottom.enable = true;
  programs.eww = {
    enable = true;
    configDir = ./extra/eww-bar;
  };
  programs.jq.enable = true;
  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.walker = {
    enable = true;
    runAsService = true;
    package = pkgs.walker;
  };
  programs.hyprlock = {
    enable = true;
    extraConfig = builtins.readFile ./hyprlock.conf;
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  services.hypridle = {
    enable = false;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 150;
          on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
          on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
        }
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
          on-resume = "${pkgs.hyprland}/bini/hyprctl dispatch dpms on";
        }
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  wayland.windowManager.hyprland.enable = true;

  wayland.windowManager.hyprland.settings = {
    exec-once = "${pkgs.eww}/bin/eww daemon && ${pkgs.eww}/bin/eww open bar";
    "$mod" = "SUPER";
    general = {
      resize_on_border = true;
      gaps_in = 2;
      gaps_out = 3;
    };
    decoration = {
      rounding = 4;
      inactive_opacity = 0.80;
    };
    monitor = [
      "HDMI-A-1, 1920x1080, 0x0, 1"
      "DP-2, 1920x1080, 1920x0, 1"
    ];
    bind =
      [
        "$mod, Q, exec, kitty"
        "$mod, B, exec, brave"
        "$mod, SPACE, exec, walker"
        "$mod CTRL, L, exec, hyprlock"
        "$mod, F, exec, firefox"
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"
        "$mod, w, killactive"
        "$mod SHIFT, j, movewindow, mon:HDMI-A-1"
        "$mod SHIFT, k, movewindow, mon:DP-2"
        ", XF86AudioRaiseVolume, exec, pamixer -i 2"
        ", XF86AudioLowerVolume, exec, pamixer -d 2"
        ", XF86AudioMute, exec, pamixer -m"
      ]
      ++ (
        builtins.concatLists (builtins.genList (
            i: let
              ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9)
      );
  };
  wayland.windowManager.hyprland.plugins = [
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
