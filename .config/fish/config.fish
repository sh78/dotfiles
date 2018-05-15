# Path to Oh My Fish install.
set -gx OMF_PATH "$HOME/.local/share/omf"

# Customize Oh My Fish configuration path.
#set -gx OMF_CONFIG "$HOME/.config/omf"

# iTerm fish shell integration
test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

# Load oh-my-fish configuration.
source $OMF_PATH/init.fish

