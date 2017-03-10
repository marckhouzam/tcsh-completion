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

mkdir -p ${HOME}/git/tcsh-completion/completions

cat << EOF > ${tcshCompletionScript}
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
bash \${HOME}/git/tcsh-completion/setup-tcsh-completion.bash \`basename \$0\` > \$0

EOF

# Echo the tcsh complete command so that it can be sourced by the caller
echo complete ${commandName} \'p,\*,\`bash\ ${tcshCompletionScript}\ \"\$\{COMMAND_LINE\}\"\`,\'
