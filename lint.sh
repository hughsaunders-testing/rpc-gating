#!/bin/bash

rc=0

check_jjb(){
  which jenkins-jobs >/dev/null \
    || { echo "jenkins-jobs unavailble, please install jenkins-job-builder from pip"
         return
       }
  jenkins-jobs test -r rpc-jobs >/dev/null \
    && echo "JJB Syntax ok" \
    || { echo "JJB Syntax fail"; rc=1; }
}

check_groovy(){
  which groovy > /dev/null \
    || { echo "groovy unavailble, please install groovy2 from apt/your package manager"
         return
       }
  grc=0
  while read scriptf
  do groovy -classpath pipeline-steps $scriptf || grc=1
  done < <(find pipeline-steps -name \*.groovy \! -name NonCPS.groovy)

  if [[ $grc == 0 ]]
  then
    echo "Groovy syntax ok"
  else
    echo "Groovy syntax fail"
    rc=1
  fi
}

check_ansible(){
  which ansible-playbook >/dev/null \
    || { echo "ansible-playbook unavailable, please install ansible from pip"
         return
       }
  mkdir -p playbooks/roles
  ansible-galaxy install -r role_requirements.yml -p playbooks/roles
  ansible-playbook --syntax-check playbooks/*.yml \
    && echo "Playbook Syntax OK" \
    || { echo "Playbook syntax fail"; rc=1; }
}

check_bash(){
  while read script
  do
    bash -n $script \
      && echo "Bash syntax ok: $script" \
      || { echo "Bash syntax fail $script"; rc=1; }
  done < <(find . -iname \*.sh)
}

check_python(){
  while read script
  do
    python -m py_compile  $script \
      && echo "Python syntax ok: $script" \
      || { echo "Bash syntax fail $script"; rc=1; }
  done < <(find . -iname \*.py)
}


check_jjb
check_groovy
check_ansible
check_bash
check_python

if [[ $rc == 0 ]]
then
  echo -e "\n**********************\nAll syntax checks passed :)\n**********************\n"
fi

exit $rc
