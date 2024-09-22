{ config, pkgs, lib, ... }:

{
  home.username = "rlggyp";
  home.homeDirectory = "/home/rlggyp";
  home.stateVersion = "24.05";
	home.packages = with pkgs; [
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
  #  /etc/profiles/per-user/rlggyp/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
		EDITOR = "nvim";
		VISUAL = "nvim";
		_JAVA_AWT_WM_NONREPARENTING = 1;
		_JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=gasp";
		QT_X11_NO_MITSHM = 1;
  };

	programs.zsh = {
		enable = true;
		enableCompletion = true;
		completionInit = "autoload -U compinit && compinit";
		shellAliases = {
			ls = "exa";
			l = "exa -al -g";
			vim = "nvim";
			cat = "bat --theme=base16 --style=plain --paging=never";
			bat = "bat --theme=base16 --style=plain --paging=never";
			rg = "rg --color=never";
			".." = "cd ..";
		};
		initExtra = lib.concatStrings [
			"ZINIT_HOME=\"\${XDG_DATA_HOME:-\${HOME}/.local/share}/zinit/zinit.git\"\n"
			"[ ! -d $ZINIT_HOME ] && mkdir -p \"$(dirname $ZINIT_HOME)\"\n"
			"[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git \"$ZINIT_HOME\"\n"
			"source \"\${ZINIT_HOME}/zinit.zsh\"\n"
			# Add in zsh plugins
			"zinit light zsh-users/zsh-completions\n"
			# History
			"HISTDUP=erase\n"
			"setopt appendhistory\n"
			"setopt sharehistory\n"
			"setopt hist_ignore_space\n"
			"setopt hist_ignore_all_dups\n"
			"setopt hist_save_no_dups\n"
			"setopt hist_ignore_dups\n"
			"setopt hist_find_no_dups\n"
			# Add in snippets
			"zinit snippet OMZP::git\n"
			# Completion styling
			"zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'\n"
			"zstyle ':completion:*' list-colors \"\${(s.:.)LS_COLORS}\"\n"
			# Keybinding
			"WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'\n"
			"bindkey '^[^?' backward-kill-word\n"
			"bindkey '^?' backward-delete-char\n"
			"bindkey '^E' end-of-line\n"
			"bindkey '^A' beginning-of-line\n"
			"bindkey '^[OA' history-search-backward\n"
			"bindkey '^[OB' history-search-forward\n"
			"bindkey '^[[1;5D' backward-word\n"
			"bindkey '^[[1;5C' forward-word\n"
      # Set the PS1 prompt
			"setopt PROMPT_SUBST\n"
      "PS1='%F{cyan}%1~%f $ '\n"
		];
	};

	programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
				"$directory"
				"$git_branch"
				"$git_status"
				"$character"
			];
			directory = {
				truncation_length = 1;
			};
			git_branch = {
				format = "[$branch]($style) ";
				style = "bold red";
			};
			git_status = {
				style = "bold yellow";
			};
    };
  };

	programs.tmux = {
		enable = true;
		mouse = true;
		newSession = true;
		terminal = "screen-256color";
		keyMode = "vi";
		prefix = "M-s";
		extraConfig = ''
			set -g base-index 1
			setw -g pane-base-index 1
			
			set-window-option -g mode-keys vi
			bind-key -T copy-mode-vi v send-keys -X begin-selection
			bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
			bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
			
			set-option -g status-position bottom
			set -g status-right ""
			set -g status-left '#{?client_prefix,#[fg=#7aa2f7],}● '
			
			set-window-option -g window-status-current-format " #I "
			set-window-option -g window-status-format " #I "
			
			set-option -g status-style bg='#1a1b26',fg='#1a1b26'
			set-option -g pane-border-style fg='#7aa2f7'
			set-option -g pane-active-border-style fg='#7aa2f7'
			set-option -g message-style bg='#1a1b26',fg='#c0caf5'
			set-option -g mode-style 'bg=blue,fg=black'
			set-window-option -g window-status-current-style bg='#7aa2f7',fg='#1a1b26'
			set-window-option -g window-status-style bg='#292e42',fg='#545c7e'
			
			bind-key -r C-Up resize-pane -U 5
			bind-key -r C-Down resize-pane -D 5
			bind-key -r C-Left resize-pane -L 5
			bind-key -r C-Right resize-pane -R 5
			
			bind-key -r f resize-pane -Z
		'';
		plugins = with pkgs.tmuxPlugins; [
			{ plugin = yank; }
			{ plugin = resurrect;
				extraConfig = ''
					set -g @resurrect-strategy-nvim 'session'
					set -g @resurrect-capture-pane-contents 'on'
				'';
			}
			{ plugin = sensible; }
			{ plugin = pain-control; }
		];
	};

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
