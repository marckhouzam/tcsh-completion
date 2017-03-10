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

set __tcsh_completion_version = `\echo ${tcsh} | \sed 's/\./ /g'`
if ( ${__tcsh_completion_version[1]} < 6 || \
     ( ${__tcsh_completion_version[1]} == 6 && \
       ${__tcsh_completion_version[2]} < 16 ) ) then
	unset __tcsh_completion_version
	echo "tcsh-completion.tcsh: Your version of tcsh is too old, you need version 6.16.00 or newer.  Enhanced tcsh completion will not work."
	exit
endif
unset __tcsh_completion_version

set __tcsh_completion_file = /tmp/.tcsh_completion
echo > ${__tcsh_completion_file}
foreach __tcsh_completion_bash_script (/usr/share/bash-completion/completions/*)
	./setup-tcsh-completion.bash ${__tcsh_completion_bash_script} >> ${__tcsh_completion_file}
end
source ${__tcsh_completion_file}
\rm ${__tcsh_completion_file}
unset __tcsh_completion_file
unset __tcsh_completion_bash_script
