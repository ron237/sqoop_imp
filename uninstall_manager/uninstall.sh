#!/bin/bash
set -e
export LC_ALL=C

NODE_ADDRESS_LIST_FILE="node.list"
LOG_FILE="uninstall.log"
REMOVE_DATA="true"
NODES=""
SERVICES=""
OSTYPE="RHEL"
USER="root"
SILENT="0"
PORT=22
NO_PASSWD="false"
SSH_KEY="/etc/transwarp/transwarp-id_rsa"


if command -v apt-get;then
  REPO_BIN='apt-get'
  REPO_YES_OPT='-y'
  REPO_REMOVE='purge'
  PKG_BIN='dpkg'
  PKG_QRY_OPT='-s'
  PKG_QRY_ALL_OPT='-l'
  PKG_REMOVE_OPT='-r'
elif command -v yum; then
  REPO_BIN='yum'
  REPO_YES_OPT='-y'
  REPO_REMOVE='remove'
  PKG_BIN='rpm'
  PKG_QRY_OPT='-q'
  PKG_QRY_ALL_OPT='-qa'
  PKG_REMOVE_OPT='-e'
elif command -v zypper; then
  REPO_BIN='zypper'
  REPO_YES_OPT='-n'
  REPO_REMOVE='remove'
  PKG_BIN='rpm'
  PKG_QRY_OPT='-q'
  PKG_QRY_ALL_OPT='-qa'
  PKG_REMOVE_OPT='-e'
else
  echo "FATAL: no yum or zypper or apt found" >&2;
  exit 1
fi

#init the environment to run uninstall process
#init the log file
init () {
  if [ -f "$LOG_FILE" ]
  then
    mv "$LOG_FILE" "${LOG_FILE}.1"
  fi
  cat /dev/null > "$LOG_FILE"
}
#log function to record the process information of the uninstall
log_file () {
  echo "$1" >> $LOG_FILE
}

log_progress () {
  echo -n .
  log_file "$1"
}

log_info () {
  echo
  echo -ne "$1"
  log_file "$1"
}

log_warning () {
  echo
  echo -ne "\033[31mWaring:\033[0m $1"
  log_file "Waring: $1"
}

log_error () {
  echo
  echo -ne "\033[31mError: $1\033[0m"
  log_file "Error: $1"
}

toExit() {
  echo
  echo "Please refer uninstall.log for more information and resolve issues first before retry!"
  exit 1;
}

transform() {
  echo "$1" | sed 's/^[^\[].*/./g' | sed -r 's/^\[I\](.*)/\1\\\\n\\\\r/g' | \
  sed -r 's/^\[W\]Warning:(.*)/\\\\033[31mWarning:\\\\033[0m\1\\\\n\\\\r/g' | \
  sed -r 's/^\[E\](.*)/\\\\033[31m\1\\\\033[0m\\\\n\\\\r/g' | \
  sed -r 's/^Finish/\\\\n\\\\rFinish/g'
}

check_os() {
  log_progress "Start to check OS type of manager node"
  local VersionFile="/etc/issue"
  if [ -e /etc/redhat-release ]; then
    VersionFile="/etc/redhat-release"
  fi
  if grep "CentOS release" $VersionFile > /dev/null || grep "Red Hat" $VersionFile > /dev/null; then
    OSTYPE="RHEL"
    log_progress "Target OS is RHEL"
  elif grep "CentOS Linux release" $VersionFile > /dev/null || grep "Red Hat" $VersionFile > /dev/null; then
    OSTYPE="RHEL"
    log_progress "Target OS is RHEL"
  elif grep "SUSE Linux Enterprise Server" $VersionFile > /dev/null || grep "openSUSE" $VersionFile > /dev/null; then
    OSTYPE="SUSE"
    log_progress "Target OS is SUSE"
  else
    OSTYPE="unsupported"
    log_error "Unsupported OS type"
    exit 1
  fi
  log_progress "Check OS type finished"
}

remove_one_package() {
  if "${PKG_BIN}" "${PKG_QRY_OPT}" $1 >> "$LOG_FILE"
  then
    log_progress "Start to remove package $1"
    if "${REPO_BIN}" "${REPO_YES_OPT}" "${REPO_REMOVE}" $1 >> "$LOG_FILE" 2>&1
    then
      log_progress "Remove package $1 finished"
    else
      log_error "failed to remove pakcage $1"
      toExit
    fi
  fi
}

yes_no() {
 echo
 read -p "$1 (y/n) " ANSWER
 case "$ANSWER" in
  y|Y) ;;
  *) log_info "Uninstall cancelled!"; echo; exit 2;;
 esac
}

#read configuration form database
get_config_from_database () {
  local sql=$1
  local sqlparam=$2
  local target_file=$3
  cat /dev/null > "$target_file"
  local tokens=$($mysqlexecutor "$sql" $sqlparam)
  if [ -n "$tokens" ]
  then
    log_progress "SQL execution result is: $tokens"
    for token in "${tokens[@]}"; do
      value=$(echo "$token")
      echo "$value" >> "$target_file"
    done
    log_progress "The result has been written into file: $target_file"
  else
    log_progress  "SQL execution result is empty!"
  fi
}


start() {
  localhostname=$(hostname)
  hostname=localhost

  log_info "Start Uninstall process"
  #get node information
  SKIP_AGENT=0
  if [ -n "${NODES}" ]
  then
    log_progress "Use default node address from --nodes option"
  else
    if [ -s "${NODE_ADDRESS_LIST_FILE}" ]
    then
      log_progress "${NODE_ADDRESS_LIST_FILE} exists"
    else
      log_info "Read node address from database"
      if grep -E "ha.enabled.*=.*true" /etc/transwarp-manager/master/application.conf > /dev/null
      then
        password=$(cat /etc/transwarp-manager/master/db.properties | grep io.transwarp.manager.db.password | awk -F = '{print $2}') && \
        hostname=$(cat /etc/transwarp-manager/master/db.properties | grep io.transwarp.manager.db.url | cut -d, -f2 | cut -d: -f1) && \
        port=$(cat /etc/transwarp-manager/master/db.properties | grep io.transwarp.manager.db.url | cut -d, -f2 | cut -d: -f2) && \
        database=transwarp_manager && \
        mysqlexecutor="mysql -h ${hostname} -u transwarp -p${password} -P ${port}  -D ${database} -e "
      else
        password=$(cat /etc/transwarp-manager/master/db.properties | grep io.transwarp.manager.db.password | awk -F = '{print $2}') && \
        socket=$(cat /etc/transwarp-manager/master/my.cnf | grep socket  | awk -F = '{print $2}') && \
        port=$(cat /etc/transwarp-manager/master/my.cnf | grep port  | awk -F = '{print $2}') && \
        manager_mysql_data_dir=$(cat /etc/transwarp-manager/master/my.cnf | grep datadir  | awk -F = '{print $2}') && \
        database=transwarp_manager && \
        mysqlexecutor="mysql -h ${hostname} -u transwarp -p${password} -S ${socket} -D ${database} -e "
      fi
      if [ $? -eq 0 ]
      then
        get_config_from_database "select hostname from node;" "--skip-column-name" "$NODE_ADDRESS_LIST_FILE"
        log_info "Finish Read node address from database"
      else
        log_error "Database file db.properties or my.cnf not available! Can't read node address from database."
        log_info "Make sure you are operating on the master node."
        log_info "You can manually specify the nodes by --nodes options or fill the file node.list to operate uninstall."
        toExit
      fi
    fi

    if [ -e "${NODE_ADDRESS_LIST_FILE}" ]
    then
      node_array=($(cat "$NODE_ADDRESS_LIST_FILE"))
      if [[ ${#node_array[@]} -eq 0 ]]
      then
        log_info "Get Zero node information from node.list, which means no agent node is currently installed."
        log_info "You can specify the nodes by --nodes options or fill the file node.list"
        log_info "Uninstall will only remove manager on current node: $localhostname"
        if [[ "$SILENT" == "1" ]]
        then
          log_progress "Confirm to uninstall? (y|n) y "
        else
          yes_no "Confirm to uninstall?"
        fi
        SKIP_AGENT=1
        DELETE_MANAGER=1
      else
        NODES=$(echo "${node_array[@]}")
      fi
    fi
  fi

  if [[ "$SKIP_AGENT" == "0" ]]
  then
    if [ -z "$NODES" ]
    then
      log_error "No node will be uninstalled. Uninstall abort!"
      toExit
    fi

    log_info "Uninstall will operate on nodes: $NODES"
    if [[ "$SILENT" == "1" ]]
    then
      log_progress "Confirm to uninstall? (y|n) y "
    else
      yes_no "Confirm to uninstall?"
    fi

    if [ -f "uninstall_community_agent_template.sh" ]
    then
      log_progress "Render uninstall_community_agent_template.sh to uninstall_community_agent_instance.sh"
      cp "uninstall_community_agent_template.sh" "uninstall_community_agent_instance.sh"
      sed -i "s/REMOVE_DATA=.*/REMOVE_DATA=\"${REMOVE_DATA}\"/" "uninstall_community_agent_instance.sh"
    else
      log_error "Missing uninstall_community_agent_template. Uninstall abort!"
      toExit
    fi

    if [ "$NO_PASSWD" == "true" ] && [ -n "$SSH_KEY" ]
    then
      export SSH_COMMAND="ssh -i $SSH_KEY  -p $PORT -o StrictHostKeyChecking=no"
    else
      export SSH_COMMAND="ssh -p $PORT -o StrictHostKeyChecking=no"
    fi

    target_nodes=($NODES)
    DELETE_MANAGER=0
    for node in "${target_nodes[@]}"; do
      log_info "========================Uninstall on $node========================"
      echo
      if [[ "$USER" == "root" ]]
      then
  #      ssh root@"$node" 'bash -s' < uninstall_community_agent_instance.sh | tee -a "$LOG_FILE" | \
  #      sed 's/^[^\[].*/./g' | sed -r 's/^\[I\](.*)/\1\\\\n/g' | sed -r 's/^\[W\]Warning:(.*)/\\\\033[31mWarning:\\\\033[0m\1\\\\n/g' | \
  #      sed -r 's/^\[E\](.*)/\\\\033[31m\1\\\\033[0m\\\\n/g' | while read line; do echo -ne $line; done
        $SSH_COMMAND root@"$node" 'bash -s' < uninstall_community_agent_instance.sh | tee -a "$LOG_FILE" | \
        while read line; do echo "$(transform "$line")" | xargs echo -ne ; done
      else
        $SSH_COMMAND "$USER"@"$node" 'sudo bash -s' < uninstall_community_agent_instance.sh | tee -a "$LOG_FILE" | \
        while read line; do echo "$(transform "$line")" | xargs echo -ne ; done
      fi
      RESULT=${PIPESTATUS[0]}
      log_info "========================Uninstall finish on $node========================"
      if [[ "$RESULT" == "0" ]]
      then
        log_info "Uninstall is Successful on $node !"
        nodehostname=$($SSH_COMMAND "$USER"@"$node" 'hostname')
        if [[ "$nodehostname" == "$localhostname" ]]
        then
          DELETE_MANAGER=1
        fi
      else
        log_error "Uninstall Failed on $node !"
        toExit
      fi
    done
  fi
  log_info "Finish Uninstall process"
}

package_removed_check() {
  if "${PKG_BIN}" "${PKG_QRY_OPT}" $1 > /dev/null
  then
    log_warning "Package $1 supposed to be removed, but still exists!"
    log_info "Please re-execute the unistall script or manually execute: \033[31m\"${PKG_BIN} ${PKG_REMOVE_OPT} $1\"\033[0m"
    echo
  fi
}

dir_removed_check() {
  if [ -e $1 ]; then
    log_warning "Directory $1 supposed to be removed, but still exists!"
    log_info "Please re-execute the unistall script or manually execute: \033[31m\"rm -rf $1\"\033[0m"
    echo
  fi
}

check_uninstall_result() {
  log_info "Start to check uninstall result"

  log_progress "check if package is still installed"
  package_removed_check transwarp-manager
  package_removed_check transwarp-manager-common
  log_progress "Finish package check"

  log_progress "check if dirs exists"
  dir_removed_check /var/log/transwarp*
  dir_removed_check /var/lib/transwarp*
  dir_removed_check /usr/lib/transwarp*
  #dir_removed_check /etc/transwarp*
  dir_removed_check /transwarp/mounts/*
  dir_removed_check /var/transwarp*
  dir_removed_check /var/lib/transwarp-manager/master/pub/transwarp
  dir_removed_check /var/ftp/pub/transwarp_update
  log_progress "finsh check dirs"

  log_progress "check if port is inuse"
  ports=(3308)
  for port in "${ports[@]}"
  do
    if ss -anp | grep '${port}' | grep LISTEN
    then
      log_warning "Port ${port} is not supposed to be LISTENING!"
      log_info "Please re-execute the unistall script or manually execute:"
      log_info "\033[31m\"ss -anp | grep -w ${port} | grep LISTEN | awk \'{print \$7}\' | awk -F \"=\" \'{print \$2}\' | awk -F \",\" \'{print \$1}\' | xargs kill -9\"\033[0m"
      echo
    fi
  done
  log_progress "finsh check port"

  log_info "Finish check uninstall result"
  echo
}

#get parameter
for opt in "$@"; do
  case $opt in
    --keepdata) REMOVE_DATA="false"; log_file "Get argument for REMOVE_DATA: $REMOVE_DATA"; shift;;
    --nopasswd) NO_PASSWD="true"; log_file "Get argument for NO_PASSWD: $NO_PASSWD"; shift;;
    --sshkey=*) SSH_KEY=${opt#*=}; log_file "Get argument for SSH_KEY: $SSH_KEY"; shift;;
    --nodes=*) NODES=${opt#*=}; log_file "Get argument for NODES: $NODES"; shift;;
    --user=*) USER=${opt#*=}; log_file "Get argument for USER: $USER"; shift;;
    --port=*) PORT=${opt#*=}; log_file "Get argument for PORT: $PORT"; shift;;
    -y) SILENT="1"; shift;;
    *) log_error "Unsupport argument: '$opt'. Exit Now!"
      echo
      echo "Usage: uninstall.sh  [ --user=* ] [ --nodes='*' ] [ --keepdata ] [ --nopasswd ] [ --sshkey=* ] [ --port=* ] [ -y ]"
      echo "option:"
      echo "  --user=*   : Specify user to execute uninstall script; default user is 'root'."
      echo "  --nodes=*  : Specify nodes to be uninstalled; e.g. --node='tw-node1 tw-node2 tw-node3'."
      echo "  --keepdata : Keep service data; data files will not be removed during uninstallation."
      echo "  --nopasswd : Use SSH Key to login agent nodes; default to use password login without '--nopasswd' option."
      echo "  --sshkey=* : Specify the connection port of ssh. The default port is 22."
      echo "  --port=*   : Specify the private key for public key authentication. The default is '/etc/transwarp/transwarp-id_rsa'"
      echo "  -y         : Assume yes; assume that the answer to any question which would be asked is yes."
      exit 1
      ;;
  esac
done


init
start
check_uninstall_result

exit 0

