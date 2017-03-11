# tcsh completion support for core Git.
#
# Copyright (C) 2017 Marc Khouzam <marc.khouzam@gmail.com>
# Distributed under the MIT License (MIT)
#
# When sourced, this script will generate a new script that uses
# the git-completion.bash script provided by core Git.  This new
# script can be used by tcsh to perform git completion.
# The current script also issues the necessary tcsh 'complete'
# commands.
#
# To use this completion script:
#
#    0) You need tcsh 6.16.00 or newer.
#    1) Copy both this file and the bash completion script to ${HOME}.
#       You _must_ use the name ${HOME}/.git-completion.bash for the
#       bash script.
#       (e.g. ~/.git-completion.tcsh and ~/.git-completion.bash).
#    2) Add the following line to your .tcshrc/.cshrc:
#        source ~/.git-completion.tcsh
#    3) For completion similar to bash, it is recommended to also
#       add the following line to your .tcshrc/.cshrc:
#        set autolist=ambiguous
#       It will tell tcsh to list the possible completion choices.

# Usage: source tcsh-completion.tcsh <toolBinary> <toolBashScript>
#        e.g. source tcsh-completion.tcsh git /usr/share/bash-completion/completions/git

# This file must be sourced and not executed.
# Add
#     source <thisFile>
# to your .tcshrc or .cshrc file

set __script_location = ${HOME}/git/tcsh-completion/completions

# Check that tcsh is modern enough for completion
set __tcsh_version = `\echo ${tcsh} | \sed 's/\./ /g'`
if ( ${__tcsh_version[1]} < 6 || \
     ( ${__tcsh_version[1]} == 6 && \
       ${__tcsh_version[2]} < 16 ) ) then
  unset __tcsh_version
  echo "ERROR: Your version of tcsh is too old, you need version 6.16.00 or newer.  Enhanced tcsh completion will not work."
  exit
endif
unset __tcsh_version


# Go over each bash completion script and generate a corresponding 'complete'
# command and tcsh script for that 'complete' command.
\mkdir -p ${__script_location}
foreach __command_name (`\ls /usr/share/bash-completion/completions/`)
  set __tcsh_script = ${__script_location}/${__command_name}

  complete ${__command_name} p,\*,\`bash\ ${__tcsh_script}\ '"${COMMAND_LINE}"'\`,


  cat << EOF > ${__tcsh_script}
#!bash
#
# This script is GENERATED and will be overwritten automatically.
# Do not modify it directly.
#
# This script will replace itself with another script which can
# properly perform completion.

# Remove ourselves
\rm \$0

# Generate the new script
# Must use the -i flag for this script to properly setup some environment functions
# needed for completion scripts such as /usr/share/bash-completion/completions/apropos
bash -i \${HOME}/git/tcsh-completion/setup-tcsh-completion.bash \`basename \$0\` > \$0

EOF
end
unset __command_name
unset __tcsh_script
unset __script_location
