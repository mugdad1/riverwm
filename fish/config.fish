if status is-interactive
# Commands to run in interactive sessions can go here
alias g='cd ~/riverwm && git fetch && git pull && git add . && git commit -m "nothing" && git push'
alias u='bash ~/riverwm/install.bash'
set -gx EDITOR nvim
set -x JAVA_HOME /usr/lib/jvm/openjdk25
set -x PATH $JAVA_HOME/bin $PATH

# Set default theme on startup
end



# Intel VPL Environment (QSV)
set -gx ONEVPL_PRIORITY_PATH /opt/vpl-gpu-rt/build/__bin/release
set -gx LD_LIBRARY_PATH $ONEVPL_PRIORITY_PATH $LD_LIBRARY_PATH
