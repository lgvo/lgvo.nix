{
  config,
  lib,
  pkgs,
  ...
}: let
  development = builtins.elem config.personalHome.mode [
    "development"
    "desktop"
  ];

  cheatsheet = pkgs.writeText "tmux-cheatsheet.txt" ''
    tmux cheat sheet                                   prefix = C-a

    Panes & windows
      "  / %       split pane vertically / horizontally
      \  / -       same, no shift needed
      c            new window
      h j k l      move between panes
      H J K L      resize pane
      a            this cheat sheet
      C-a          send a literal C-a through to the app
      d            detach from the session
      z            toggle zoom on the current pane
      ]            paste the last yanked/killed buffer
      s            interactive session picker
      w            interactive window picker
      ,            rename current window
      $            rename session
      n  / p       next / previous window
      x            kill current pane
      r            reload tmux config

    Copy mode (vi keys, since keyMode = vi)
      [            enter copy mode
      v            start selection (rebound; stock default is rectangle-toggle)
      y            copy selection and exit (rebound; stock default is unbound)
      C-v          toggle rectangle/block selection
      Enter        copy selection and exit (stock default, still works)
      q            exit copy mode

    Mouse: enabled. Windows renumber on close. Base index 1 (panes + windows).

    ${lib.optionalString development ''
      Project picker ("p" run standalone, or via prefix f)
        p            pick a project (type to filter, C-j/C-k move, esc quits,
                     C-d remove entry, C-x kill session -- confirm y/n)
        p new        register cwd as a known project
        p rm         remove known project(s)
        p status     list known projects + running state

      Git (forgit -- aliases pass args through to plain git)
        gsw / gcb    switch/checkout branch (type to filter, C-j/C-k move)
        ga           stage files (tab multi-select, diff preview; `ga .` = git add .)
        glo          browse log with diff preview
        gd           browse working-tree diff
        gss / gsp    stash viewer / stash push selector
        grh          unstage files
        gbd          delete branches
        gst gc gp    plain status / commit -v / push
    ''}
    press q to close
  '';
in {
  programs.tmux = {
    enable = true;
    shortcut = "a";
    keyMode = "vi";
    mouse = true;
    customPaneNavigationAndResize = true;
    baseIndex = 1;
    terminal = "tmux-256color";
    historyLimit = 10000;

    extraConfig = ''
      set -ag terminal-overrides ",*256col*:Tc"
      set -g renumber-windows on

      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind \\ split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      ${lib.optionalString development ''bind f display-popup -E -w 80% -h 80% "p"''}
      bind a display-popup -E -w 70% -h 60% "less -R ${cheatsheet}"
      bind r source-file ${config.home.homeDirectory}/.config/tmux/tmux.conf \; display-message "tmux config reloaded"

      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel

      set -g status-style 'bg=#1D1C19,fg=#C5C9C5'
      set -g status-left '#[bg=#8ba4b0,fg=#181616,bold] #{s/ \(.*//:session_name} '
      set -g status-left-length 20
      set -g status-right '#[fg=#a6a69c] #{s|${config.home.homeDirectory}|~|:pane_current_path} #[fg=#54546d]· #[fg=#a6a69c]#h #[fg=#54546d]· #[fg=#C5C9C5]%Y-%m-%d %H:%M '
      set -g status-right-length 80

      setw -g window-status-current-style 'bg=#8ba4b0,fg=#181616,bold'
      setw -g window-status-current-format ' #I:#W '
      setw -g window-status-format ' #I:#W '

      set -g pane-border-style 'fg=#54546d'
      set -g pane-active-border-style 'fg=#8ba4b0'
      set -g message-style 'bg=#8ba4b0,fg=#181616'
    '';
  };
}
