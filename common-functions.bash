#!bash
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

bash_completion_script="/usr/share/bash-completion/bash_completion"
if [[ $(uname) == "Darwin" ]]; then
  bash_completion_script="/usr/local/etc/bash_completion"
fi

if [ -e ${bash_completion_script} ]; then
	source ${bash_completion_script}
fi

# Some scripts use the below method which is included in ${bash_completion_script}.
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

