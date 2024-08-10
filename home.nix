{ config, pkgs, inputs, ... }:

{
  nixpkgs.overlays = [ inputs.nur.overlay ];
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "rian";
  home.homeDirectory = "/home/rian";
  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.zed-editor
    pkgs.jetbrains-toolbox
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
  #  /etc/profiles/per-user/rian/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.gpg = {
    enable = true;
    settings = {
      armor = true;
    };
    publicKeys = [{
      source = ./yubikey.pub;
      trust = 5;
    }];
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 60;
    maxCacheTtl = 120;
  };

  programs.git = {
    enable = true;
    userName = "Florian Proksch";
    userEmail = "florian.proksch@protonmail.com";
    extraConfig = {
      push = {
        autoSetupRemote = true;
      };
      pull.rebase = true;
      github.user = "RianFuro";
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
    };
    ignores = [ "*.swp" ".vscode/" ".zed/" ".dir-locals.el" ];
    signing.key = null;
    signing.signByDefault = true;
  };

  programs.starship.enable = true;
  programs.fish.enable = true;
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ -z $NOFISH && $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  programs.kitty.enable = true;

  programs.emacs.enable = true;
  programs.neovim.enable = true;
  programs.neovim.plugins = [
    pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    {
      plugin = pkgs.vimPlugins.nvim-surround;
      config = ''
        packadd! nvim-surround
        lua << END
          require 'nvim-surround'.setup {}
        END
      '';
    }
    {
      plugin = pkgs.vimPlugins.neogit;
      config = ''
        packadd! neogit
        lua << END
          require 'neogit'.setup {}
        END
      '';
    }
  ];
  programs.firefox.enable = true;
  home.file."edgyarc-fr" = {
    target = ".mozilla/firefox/default/chrome/edgyarc-fr";
    source = "${inputs.edgyarc-fr}/chrome";
  };
  programs.firefox = {
    profiles.default = {
      id = 0;
      isDefault = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        bitwarden
        sidebery
        firefox-color
        react-devtools
      ];
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
        "layout.css.color-mix.enabled" = true;
        "layout.css.light-dark.enabled" = true;
        "layout.css.has-selector.enabled" = true;

        "uc.tweak.hide-tabs-bar" = true;
        "uc.tweak.hide-forward-button" = true;
        "uc.tweak.rounded-corners" = true;
        "uc.tweak.floating-tabs" = true;
      
      };
      userChrome = ''
        @import "edgyarc-fr/userChrome.css";
      '';
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
}
