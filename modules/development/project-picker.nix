{
  config,
  lib,
  pkgs,
  ...
}: let
  enabled = builtins.elem config.personalHome.mode [
    "development"
    "desktop"
  ];
in {
  config = lib.mkIf enabled {
    home.packages = [
      pkgs.fzf
      (pkgs.writeShellApplication {
        name = "p";
        # Preserve the picker's intentional use of failing probes (for example,
        # checking whether a tmux session or git remote exists).
        bashOptions = [];
        runtimeInputs = with pkgs; [
          coreutils
          fzf
          gawk
          git
          gnugrep
          gnused
          tmux
        ];
        text = ''
          known_file="$HOME/.config/projects/known_projects"
          pending_action="$HOME/.config/projects/.pending_action"

          # tmux's target grammar is session:window.pane -- a bare '.' or ':'
          # in a session name gets misparsed as that separator. Project names
          # (and the "(path)" we append) can contain either, so the string we
          # actually hand tmux at *creation* time is always this sanitized id,
          # never the human-readable label.
          sanitize_key() {
            printf '%s' "$1" | tr '.:' '__'
          }

          # Resolves a session name to tmux's own opaque $N session id, which
          # is never subject to the ':'/'.' target-parsing ambiguity above --
          # this matters for sessions we didn't create ourselves (found via
          # `tmux list-sessions`) and might have arbitrary/unsafe names.
          find_session_id() {
            tmux list-sessions -F "#{session_id}$(printf '\t')#{session_name}" 2>/dev/null \
              | awk -F'\t' -v n="$1" '$2==n{print $1; exit}'
          }

          open_session() {
            id="$1"
            path="$2"
            sid=$(find_session_id "$id")
            if [ -z "$sid" ]; then
              tmux new-session -ds "$id" -c "$path"
              sid=$(find_session_id "$id")
            fi
            if [ -n "''${TMUX:-}" ]; then
              tmux switch-client -t "$sid"
            else
              tmux attach-session -t "$sid"
            fi
          }

          # Emits tab-separated: id, display text, path (empty path = a live
          # tmux session that isn't in the registry).
          list_projects() {
            known_ids=""
            if [ -s "$known_file" ]; then
              while IFS=$'\t' read -r name path; do
                [ -z "$name" ] && continue
                id=$(sanitize_key "$name ($path)")
                known_ids="$known_ids
          $id"
                if [ -n "$(find_session_id "$id")" ]; then
                  printf '%s\t[running]       %-20s %s\t%s\n' "$id" "$name" "$path" "$path"
                else
                  printf '%s\t[stopped]       %-20s %s\t%s\n' "$id" "$name" "$path" "$path"
                fi
              done <"$known_file"
            fi

            tmux list-sessions -F '#S' 2>/dev/null | while IFS= read -r session; do
              if ! printf '%s\n' "$known_ids" | grep -Fxq "$session"; then
                printf '%s\t[unregistered]  %s\t%s\n' "$session" "$session" ""
              fi
            done
          }

          register() {
            path="$PWD"
            mkdir -p "$(dirname "$known_file")"
            touch "$known_file"

            remote_url="$(git remote get-url origin 2>/dev/null)"
            if [ -n "$remote_url" ]; then
              default_name="$(basename -s .git "$remote_url")"
            else
              default_name="$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")"
            fi

            # Avoid Bash Readline here: its key handling can treat Return as
            # an escape sequence in terminals using enhanced keyboard modes.
            IFS= read -r -p "Project name [$default_name]: " name
            name="''${name:-$default_name}"

            label="$name ($path)"
            id=$(sanitize_key "$label")

            if awk -F'\t' -v p="$path" '$2==p{f=1} END{exit !f}' "$known_file"; then
              echo "Already registered as '$label'." >&2
            else
              printf '%s\t%s\n' "$name" "$path" >>"$known_file"
              echo "Registered '$label'." >&2
            fi

            open_session "$id" "$path"
          }

          # Runs from the ctrl-d / ctrl-x bindings: records which action the
          # y/n confirmation keys should dispatch ("rm" removes the registry
          # entry, "kill" only kills the tmux session).
          arm() {
            echo "$1" >"$pending_action"
          }

          # Dispatches the pending action (armed by arm) once
          # `y` confirms. Silent since it runs via execute-silent (no
          # terminal handoff to print to).
          confirm_yes() {
            id="$1"
            path="$2"
            action=$(cat "$pending_action" 2>/dev/null || echo rm)
            rm -f "$pending_action"

            if [ "$action" = kill ]; then
              sid=$(find_session_id "$id")
              [ -n "$sid" ] && tmux kill-session -t "$sid"
              return
            fi

            if [ -z "$path" ]; then
              sid=$(find_session_id "$id")
              [ -n "$sid" ] && tmux kill-session -t "$sid"
              return
            fi

            tmp_file="$(mktemp)"
            awk -F'\t' -v p="$path" '$2!=p' "$known_file" >"$tmp_file"
            mv "$tmp_file" "$known_file"
          }

          # Type to filter, ctrl-j/ctrl-k to move (fzf defaults), esc to quit.
          # ctrl-d / ctrl-x suspend the search input and arm the y/n keys,
          # which are otherwise unbound so they type into the query.
          pick() {
            selection=$(
              list_projects | fzf \
                --delimiter=$'\t' --with-nth=2 \
                --prompt='> ' \
                --bind='ctrl-d:execute-silent(p _arm rm)+disable-search+rebind(y,n)+change-prompt(Delete? [y/n]> )' \
                --bind='ctrl-x:execute-silent(p _arm kill)+disable-search+rebind(y,n)+change-prompt(Kill session? [y/n]> )' \
                --bind='y:execute-silent(p _confirm-yes {1} {3})+reload(p _list)+enable-search+unbind(y,n)+change-prompt(> )' \
                --bind='n:enable-search+unbind(y,n)+change-prompt(> )' \
                --bind='load:unbind(y,n)'
            )
            [ -z "$selection" ] && exit 0

            id=$(printf '%s' "$selection" | cut -f1)
            path=$(printf '%s' "$selection" | cut -f3)
            open_session "$id" "$path"
          }

          remove() {
            if [ ! -s "$known_file" ]; then
              echo "No known projects yet." >&2
              exit 1
            fi

            selection=$(list_projects | fzf --delimiter=$'\t' --with-nth=2 --prompt='Remove project> ' --multi)
            [ -z "$selection" ] && exit 0

            printf '%s\n' "$selection" | while IFS=$'\t' read -r id _ path; do
              [ -z "$id" ] && continue
              if [ -z "$path" ]; then
                echo "Skipping '$id' (not a registered project)." >&2
              else
                name=$(awk -F'\t' -v p="$path" '$2==p{print $1; exit}' "$known_file")
                label="$name ($path)"
                if [ -n "$(find_session_id "$id")" ]; then
                  echo "Removing '$label' (tmux session still running -- kill it with: tmux kill-session -t '$id')" >&2
                else
                  echo "Removing '$label'." >&2
                fi
              fi
            done

            selected_paths=$(printf '%s\n' "$selection" | cut -f3 | grep -v '^$')

            if [ -n "$selected_paths" ]; then
              tmp_file="$(mktemp)"
              awk -F'\t' -v paths="$selected_paths" '
                BEGIN { n = split(paths, arr, "\n"); for (i = 1; i <= n; i++) rm[arr[i]] = 1 }
                !($2 in rm)
              ' "$known_file" >"$tmp_file"
              mv "$tmp_file" "$known_file"
            fi
          }

          status() {
            list_projects | cut -f2
          }

          help() {
            cat <<'EOF'
          Usage: p [command]

            p            Pick a project (type to filter, ctrl-j/ctrl-k move,
                         esc quits, ctrl-d removes the highlighted entry,
                         ctrl-x kills its tmux session only -- both ask to
                         confirm with y/n)
            p new        Register the current directory as a known project
            p rm         Remove one or more known projects (multi-select)
            p status     List known projects and whether their tmux session is running
            p help       Show this help
          EOF
          }

          case "''${1:-}" in
            new) register ;;
            rm) remove ;;
            status) status ;;
            help | -h | --help) help ;;
            _list) list_projects ;;
            _arm) arm "$2" ;;
            _confirm-yes) confirm_yes "$2" "$3" ;;
            "") pick ;;
            *)
              echo "Unknown command: $1" >&2
              help >&2
              exit 1
              ;;
          esac
        '';
      })
    ];
  };
}
