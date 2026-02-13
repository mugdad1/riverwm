if status is-interactive
# Commands to run in interactive sessions can go here
function vi
    micro $argv
end
set -gx EDITOR micro
# Set default theme on startup
end
