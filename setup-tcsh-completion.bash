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

# Allow for debug printouts when running the script by hand
if [ "$1" == "-d" ] || [ "$1" == "--debug" ]; then
    debug=true
    shift
fi

root_path=$(cd `dirname $0` && pwd)
setup_script=${root_path}/`basename $0`
alias=completion-refresh

completion_scripts_path="/usr/share/bash-completion/completions"
bash_completion_script="/usr/share/bash-completion/bash_completion"
if [[ $(uname) == "Darwin" ]]; then
  completion_scripts_path="/usr/local/etc/bash_completion.d"
  bash_completion_script="/usr/local/etc/bash_completion"
fi

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

# Some scripts use this method which is included in ${bash_completion_script}.
# However, that method gets unset at the end of the ${bash_completion_script}.
# So we define it ourselves here.  Note that _have() is also defined in
# ${bash_completion_script} but does not get unset.
if [[ $(uname) == "Darwin" ]]; then
  # This function checks whether we have a given program on the system.
  # No need for bulky functions in memory if we don't.
  have()
  {
      unset -v have
      # Completions for system administrator commands are installed as well in
      # case completion is attempted via `sudo command ...'.
      PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin type $1 &>/dev/null &&
      have="yes"
  }
else
  have()
  {
      unset -v have
      _have $1 && have=yes
  }
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
  #if [ -e ${bash_completion_script} ]; then
  #  source ${bash_completion_script}
  #fi

  # Remove any existing complete commands
  complete -r

  # Source the script to generate the complete command(s) we will parse
  # Note that for some of the scripts we may handle to properly be sourced,
  # we need to run the bash shell in interactive mode; this explains why
  # we must use the '-i' flag at the top of the file.
  # For example, this is necessary for the 'apropos' completion script
  if [ "${debug}" == "true" ]; then
    source ${toolCompletionScript}
  else
    source ${toolCompletionScript} &> /dev/null
  fi

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
for script_path in ${completion_scripts_path}/*; do
  _generate_tcsh_complete_command "${script_path}" >> "${completion_file}"
done

# Don't include those more basic completions until the tcsh handling is more robust
#  _generate_tcsh_complete_command ${bash_completion_script} >> "${completion_file}"


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

# Add an alias to allow the user to easily refresh the completion script.
# This alias will be used when the user installs a new tool and wants to
# setup its completion
echo "alias ${alias} '${setup_script} && source ${completion_file}'" >> "${completion_file}"

echo
echo =\> If not added already, add a line to source ${completion_file}
echo =\> in your .tcshrc or .cshrc file. Also note that you can add other completions scripts in
echo =\> the ${extra_scripts} file.
echo =\>
echo =\> After installing a new tool, you can refresh the completions using the alias ${alias}
echo
