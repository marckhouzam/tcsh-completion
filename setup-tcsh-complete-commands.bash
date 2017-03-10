#!/bin/bash
#
# Copyright (C) 2017 Marc Khouzam <marc.khouzam@gmail.com>
# Distributed under the MIT License (MIT)
#

if [ $# -ne 1 ]; then
	echo "Usage: $0 <completionScript>"
	echo "where <completionScript> is the full path of the bash completion script that will feed the tcsh completion"
	exit
fi

commandName=`basename $1`
tcshCompletionScript=${HOME}/git/tcsh-completion/completions/${commandName}

\ln -fs ${HOME}/git/tcsh-completion/setupCommon.bash ${tcshCompletionScript}
echo complete ${commandName} \'p,\*,\`bash\ ${tcshCompletionScript}\ \"\$\{COMMAND_LINE\}\"\`,\'
