#!/bin/bash -i
#
# Copyright (C) 2017 Marc Khouzam <marc.khouzam@gmail.com>
# Distributed under the MIT License (MIT)
#
# This script takes a bash completion script as its parameter.
# It will print the command name for which the script provides completions
# followed by the corresponding bash function to be called from that script
# to trigger completion.

# For example, 
#   $0 /usr/share/bash-completion/completions/git
# will output
#   gitk __git_wrap__gitk_main
#   git __git_wrap__git_main
#

if [ $# -ne 1 ]; then
	echo "Usage: $0 <completionScript>"
	echo "where <completionScript> is the full path of the bash completion script that will feed the tcsh completion"
	exit
fi

toolCompletionScript=$1

# It does not look like the main bash completion script is necessary
# to generate the 'complete' commands we are interested in.
# So let's avoid to source it to save time
#
#bashCompletionScript=/usr/share/bash-completion/bash_completion
#if [ -e ${bashCompletionScript} ]; then
#	source ${bashCompletionScript}
#fi

# Remove any existing complete commands
complete -r

# Source the script to generate the complete command(s) we will parse
# Note that for some of the scripts we may handle to properly be sourced,
# we need to run the bash shell in interactive mode; this explains why
# we must use the '-i' flag at the top of the file.
# For example, this is necessary for the 'apropos' completion script
source ${toolCompletionScript} &> /dev/null

# Read each complete command generated as long as uses the -F format
complete | egrep -e '-F' | while read completionCommand
do
	# Remove everything up to the last space to find the command name
	# e.g. complete -o bashdefault -o default -o nospace -F __git_wrap__gitk_main gitk
	#  becomes
	#      gitk
	commandName=${completionCommand##* }

	# Remove everything up to and including "-F "
	# e.g. complete -o bashdefault -o default -o nospace -F __git_wrap__gitk_main gitk
	#  becomes
	#      __git_wrap__gitk_main gitk
	tmp=${completionCommand##*-F }
	# Remove everyting after the first space
	# e.g. __git_wrap__gitk_main gitk
	#  becomes
	#  __git_wrap__gitk_main
	# Note that we cannot simply use the output in $tmp to
	# express both strings we are looking for as there could
	# be other parameters included in $tmp
	commandFunction=${tmp%% *}

	echo complete ${commandName} \'p,\*,\`bash\ ${HOME}/.tcsh-completion.bash\ ${commandFunction}\ ${toolCompletionScript}\ \"\$\{COMMAND_LINE\}\"\`,\'
done
