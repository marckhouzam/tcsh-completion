#!/bin/bash -i
#
# Copyright (C) 2017 Marc Khouzam <marc.khouzam@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


# When executed, this script will generate a file with all the
# necessary tcsh complete commands to delegate completion
# to the existing bash completions scripts.
#
root_path=$(cd `dirname $0` && pwd)
extra_scripts="${root_path}/extra-scripts.txt"
completion_file="${HOME}/.tcsh-completion.tcsh"

# Check that tcsh is modern enough for completion.  We need version 6.16 or higher.
tcsh_version=(`tcsh --version | awk '{print $2}' | \sed 's/\./ /g'`)
if [[ ${tcsh_version[0]} -lt 6 || \
     ( ${tcsh_version[0]} -eq 6 && \
       ${tcsh_version[1]} -lt 16 ) ]]; then
  unset tcsh_version
  echo "ERROR: Your version of tcsh is too old, you need version 6.16.00 or newer.  Enhanced tcsh-completion will not work."
  exit
fi

# Echo the tcsh 'complete' command corresponding
# to the script passed as a parameter.
# Parameters:
# 1: The full path of the bash completion script
#    for which this method will generate a tcsh
#    'complete' command.
_generate_tcsh_complete_command ()
{
  toolCompletionScript=$1

  # It does not look like the main bash completion script is necessary
  # to generate the 'complete' commands we are interested in.
  # So let's avoid to source it to save time
  #
  #bashCompletionScript=/usr/share/bash-completion/bash_completion
  #if [ -e ${bashCompletionScript} ]; then
  #  source ${bashCompletionScript}
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
  complete | \egrep -e '-F' | while read completionCommand
  do
    # Remove everything up to the last space to find the command name
    # e.g. complete -o bashdefault -o default -o nospace -F git_wrapgitk_main gitk
    #  becomes
    #      gitk
    commandName=${completionCommand##* }

    # Remove everything up to and including "-F "
    # e.g. complete -o bashdefault -o default -o nospace -F git_wrapgitk_main gitk
    #  becomes
    #      git_wrapgitk_main gitk
    tmp=${completionCommand##*-F }
    # Remove everyting after the first space
    # e.g. git_wrapgitk_main gitk
    #  becomes
    #  git_wrapgitk_main
    # Note that we cannot simply use the output in $tmp to
    # express both strings we are looking for as there could
    # be other parameters included in $tmp
    commandFunction=${tmp%% *}

    echo complete ${commandName} \'p,\*,\`bash\ ${root_path}/tcsh-completion.bash\ ${commandFunction}\ ${toolCompletionScript}\ \"\$\{COMMAND_LINE\}\"\`,\'
  done
}

\rm -f "${completion_file}"
# Go over each bash completion script and generate a corresponding 'complete' command
for script_path in /usr/share/bash-completion/completions/*; do
  _generate_tcsh_complete_command "${script_path}" >> "${completion_file}"
done

# Don't include those more basic completions until the tcsh handling is more robust
#  _generate_tcsh_complete_command /usr/share/bash-completion/bash_completion >> "${completion_file}"


# Handle any extra scripts specified by the user.
# First create the file if it is not there to help the user.
if [ ! -e "${extra_scripts}" ]; then
    echo "# You can add the full path, one per line, of any" >> "${extra_scripts}"
    echo "# bash completions script that you want tcsh-completion to use." >> "${extra_scripts}"
fi
# Ignore lines starting with # and lines with only spaces in them
for script_path in `cat "${extra_scripts}" | \egrep -ve '^#|^\s*$' `; do
  # Replace a path starting with ~<user>/ or ~/ with the home directory of the user
  # If we don't, then the function won't find the script in question
  script_path="${script_path/#\~*([^\/])/$HOME}"

  _generate_tcsh_complete_command "${script_path}" >> "${completion_file}"
done

echo
echo =\> If not added already, add a line to source ${completion_file} in your .tcshrc or .cshrc file.
echo =\> Also note that you can add other completions scripts in the ${extra_scripts} file.
echo
