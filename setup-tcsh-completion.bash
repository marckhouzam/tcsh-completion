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

for completionScript in /usr/share/bash-completion/completions/*
do
	# Remove any existing complete commands
	complete -r
	# Source the script to generate the complete command(s)
	source ${completionScript}
	# Reach each complete command generated which is of the -F format
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

		echo complete ${commandName} \'p,\*,\`bash\ ${HOME}/.tcsh-completion.bash\ ${commandFunction}\ ${completionScript}\ \"\$\{COMMAND_LINE\}\"\`,\' >> $1
	done
done
