#
# Sets directory options.
#
# Based on zprezto's directory module:
# https://github.com/sorin-ionescu/prezto/blob/master/modules/directory/init.zsh
#

setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
