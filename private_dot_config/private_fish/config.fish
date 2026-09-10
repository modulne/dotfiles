if status is-interactive
    # Commands to run in interactive sessions can go here
end

zoxide init fish | source
# atuin init fish | source

set -gx EDITOR nvim

alias x 'codex --dangerously-bypass-approvals-and-sandbox'

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
