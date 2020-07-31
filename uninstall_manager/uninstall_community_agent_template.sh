#!/bin/bash
export LC_ALL=C
. /etc/profile.d/kubernetes_master.sh
shopt -s expand_aliases
SERVICE_LIST=`ls /etc/ | grep -E "^(dashboard|discover|governor|guardian|hdfs|hue|hyperbase|inceptor|kafka|transwarp_license_cluster|notification|oozie|rubik|search|slipstream|sophon|sqoop|tos|transpedia|transporter|txsql|workflow|yarn|zookeeper|kms|shiva|argodb.*)[0-9]*$"`
OSTYPE="RHEL"
PACKAGES_TO_REMOVE=""
REMOVE_DATA="true"
PACKAGES_REMOVED=""


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

log_progress() {
  echo "$1"
}

#show import information to console and report file
log_info() {
  echo "[I]$1"
}

log_warning () {
  echo "[W]Warning: $1"
}

log_error () {
  echo "[E]Error: $1"
}

toExit() {
  exit 1;
}

check_os() {
  log_info "Start to check OS Type of $(hostname)"
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
  elif grep "Kylin " $VersionFile > /dev/null; then
    OSTYPE="KYLIN"
    log_progress "Target OS is KYLIN"
  else
    OSTYPE="unsupported"
    log_error "Unsupported OS type"
    exit 1
  fi
  log_info "Finish check OS Type"
}

check_repo() {
  repo_file=""
  if [[ "$OSTYPE" == "RHEL" ]]
  then
    repo_file="/etc/yum.repos.d/transwarp.repo"
  elif [[ "$OSTYPE" == "SUSE" ]]
  then
    repo_file="/etc/zypp/repos.d/transwarp.repo"
  else
    repo_file="/etc/apt/sources.list.d/transwarp.list"
  fi

  if [ -f "$repo_file" ]
  then
    baseurl=$(cat "$repo_file" | grep baseurl | cut -d= -f2)
    if [[ "$baseurl" =~ http:* ]]
    then
      code=$(curl -I "${baseurl}/repodata/repomd.xml" 2>/dev/null | head -n1 | cut -d' ' -f2)
      if [[ "$code" =~ ^[3|4|5][0-9]{2}$ ]]
      then
        log_error "Transwarp repo information is broken. Please fix it first."
        toExit
      fi
    elif [[ "$baseurl" =~ ftp:* ]]
    then
      curl "${baseurl}/repodata/repomd.xml" 2>/dev/null
      if [[ "$?" != "0" ]]
      then
        log_error "Transwarp repo information is broken. Please fix it first."
        toExit
      fi
    fi
  else
    log_error "File transwarp.repo doesn't exist. Please fix it first."
    toExit
  fi
}

get_installed_packages() {
  if [[ "$OSTYPE" == "RHEL" ]]
  then
    PACKAGES_TO_REMOVE=$(yum list installed | awk 'p; /Installed Packages/ {p=1}' | tr '\n\r' ' ' | awk '{for (i=1;i<=NF;i++){ if ((i % 3 ==0)&&($i~/transwarp$/)) {vl=i-2; print $vl}} }')
  elif [[ "$OSTYPE" == "SUSE" ]]
  then
    PACKAGES_TO_REMOVE=$(zypper search -i -r transwarp | awk '{FS="|"; if($1~/^[[:blank:]]*i[[:blank:]]*$/) {print $2}}')
  else
    PACKAGES_TO_REMOVE=$(grep Package /var/lib/apt/lists/*:8180_pub_transwarp-*_Packages | cut -d' ' -f2)
  fi
  log_progress "Packages installed from transwarp repo are:"
  log_progress "$PACKAGES_TO_REMOVE"
}

remove_one_package() {
  log_progress "Start to remove package $1"
  if "${REPO_BIN}" "${REPO_YES_OPT}" "${REPO_REMOVE}" $1 > /dev/null 2>&1
  then
    log_progress "Remove package $1 finished"
    PACKAGES_REMOVED="$PACKAGES_REMOVED $1"
  else
    log_error "Failed to remove pakcage $1"
    toExit
  fi
}

remove_packages() {
  log_info "Start to remove transwarp repo packages"
  get_installed_packages
  package_array=$(echo "$PACKAGES_TO_REMOVE"  | tr '\n\r' ' ')
  IFS=' '
  for package in ${package_array[@]};
  do
    if [[ "$package" =~ krb5-libs* ]] || [[ "$package" =~ openldap* ]] || [[ "$package" =~ libseccomp2* ]] || \
    [[ "$package" =~ libselinux* ]]  || [[ "$package" =~ libsemanage* ]] || [[ "$package" =~ libsepol* ]] || \
    [[ "$package" =~ transwarp-manager* ]] || [[ "$package" =~ libgssapi* ]] || [[ "$package" =~ libk5crypto* ]] || \
    [[ "$package" =~ libkrb* ]] || [[ "$package" == vsftpd ]] || [[ "$package" == tar ]]
    then
      log_progress "Ignore the package $package"
    else
      if "${PKG_BIN}" "${PKG_QRY_OPT}" $package > /dev/null 2>&1
      then
        [ -n "$package" ] && remove_one_package "$package"
      fi
    fi
  done
  IFS="$old_IFS"
  if "${PKG_BIN}" "${PKG_QRY_OPT}" transwarp-manager-agent > /dev/null 2>&1
  then
    remove_one_package "transwarp-manager-agent"
  fi
  if ! "${PKG_BIN}" "${PKG_QRY_OPT}" transwarp-manager > /dev/null 2>&1 && "${PKG_BIN}" "${PKG_QRY_OPT}" transwarp-manager-common > /dev/null 2>&1
  then
    remove_one_package "transwarp-manager-common"
  fi
  log_info "Finish remove transwarp repo packages"
}

DATA_DIR=()
ORIGIN_DATA_DIR=()
MOUNT_DATA_DIR=()

parse_data_dir_from_xml() {
  local config_file=$1
  local key=$2
  local service_sid=$3
  DATA_DIR=()
  MOUNT_DATA_DIR=()
  name_line_num=0
  value_line_num=0
  if [ -f "$config_file" ]
  then
    name_line_num=$(grep -n "<name>$key</name>" "$config_file" | cut -d: -f1)
    log_progress "line number of $key is $name_line_num"
    if [[ "$name_line_num"=~'^[0-9]+$' ]] && [[ $name_line_num -gt 0 ]]
    then
      value_line_num=$((name_line_num+1))
      origin_data_dir=$(sed -n "${value_line_num}p" "$config_file" | sed "s/<[^>]*>//g" | tr -d "[:blank:]")

      parse_mount_data_dir "$origin_data_dir" "$service_sid"

      log_progress "Get data dir ${DATA_DIR[@]} from $config_file"
      log_progress "Get mount data dir ${MOUNT_DATA_DIR[@]} from $config_file"
    fi
  else
    log_progress "File $config_file does not exist!"
  fi
}

parse_data_dir_from_variable() {
  local data_dir=$1
  local service_sid=$2
  DATA_DIR=()
  MOUNT_DATA_DIR=()
  parse_mount_data_dir "$data_dir" "$service_sid"
  log_progress "Get data dir ${DATA_DIR[@]} from origin data dir $data_dir"
  log_progress "Get mount data dir ${MOUNT_DATA_DIR[@]} from origin data dir $data_dir"
}

parse_mount_data_dir () {
  local origin_data_dir=$1
  local service_sid=$2
  IFS=','
  for datadir in ${origin_data_dir[@]}; do
    if [[ `echo "$datadir" | grep ^/vdir` ]];
    then
      dir=${datadir#*vdir}
      DATA_DIR=("${DATA_DIR[@]}" "$dir")
      MOUNT_DATA_DIR=("${MOUNT_DATA_DIR[@]}" "/transwarp/mounts/$service_sid$dir")
    else
      DATA_DIR=("${DATA_DIR[@]}" "$datadir")
      log_progress "Do not parse $datadir"
    fi
  done
  IFS="$old_IFS"
}

remove_data_folder() {
  local service_id="$1"
  local data_dir=()
  local mount_data_dir=()
  case $service_id in
    hdfs*)
      if [ -f "/etc/$service_id/conf/hdfs-site.xml" ]
      then
        parse_data_dir_from_xml "/etc/$service_id/conf/hdfs-site.xml" "dfs.namenode.name.dir" "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")

        parse_data_dir_from_xml "/etc/$service_id/conf/hdfs-site.xml" "dfs.datanode.data.dir" "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")

        parse_data_dir_from_xml "/etc/$service_id/conf/hdfs-site.xml" "dfs.namenode.checkpoint.dir" "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")

        parse_data_dir_from_xml "/etc/$service_id/conf/hdfs-site.xml" "dfs.journalnode.edits.dir" "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
      else
        log_info "File /etc/$service_id/conf/hdfs-site.xml does not exist!"
        log_warning "Data dir of $service_id may not be completely removed!"
      fi

      if [ -d "/var/namenode_format" ]
      then
        data_dir=("${data_dir[@]}" "/var/namenode_format")
      else
        log_progress "Directory /var/namenode_format does not exist!"
      fi
      ;;
    yarn*)
      if [ -f "/etc/$service_id/conf/yarn-site.xml" ]
      then
        parse_data_dir_from_xml "/etc/$service_id/conf/yarn-site.xml" "yarn.nodemanager.remote-app-log-dir" "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")

        parse_data_dir_from_xml "/etc/$service_id/conf/yarn-site.xml" "yarn.nodemanager.local-dirs" "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")

        parse_data_dir_from_xml "/etc/$service_id/conf/yarn-site.xml" "yarn.nodemanager.log-dirs" "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
      else
        log_info "File /etc/$service_id/conf/yarn-site.xml does not exist!"
        log_warning "Data dir of $service_id may not be completely removed!"
      fi

      if [ -d "/hadoop/yarn" ]
      then
        data_dir=("${data_dir[@]}" "/hadoop/yarn")
      else
        log_progress "Directory /hadoop/yarn does not exist!"
      fi

      ;;
    inceptor* | slipstream*)
      ngmr_file="/etc/$service_id/conf/ngmr-env.sh"
      if [ -f $ngmr_file ]
      then
        ngmr_localdir=($(grep 'export SPARK_LOCAL_DIR=*' $ngmr_file | sed 's/export[[:blank:]]SPARK_LOCAL_DIR=//' | sed 's/\"//g'))
        parse_data_dir_from_variable "$ngmr_localdir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")

        fast_disk_dir=($(grep 'export SPARK_FASTDISK_DIR=*' $ngmr_file | sed 's/export[[:blank:]]SPARK_FASTDISK_DIR=//' | sed 's/\"//g'))
        parse_data_dir_from_variable "$fast_disk_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")

        mysql_data_dir=($(grep 'export MYSQL_DATADIR=*' $ngmr_file | sed 's/export[[:blank:]]MYSQL_DATADIR=//' | sed 's/\"//g'))
        parse_data_dir_from_variable "$mysql_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
      else
        log_info "File /etc/$service_id/conf/ngmr-env.sh does not exist!"
        log_warning "Data dir of $service_id may not be completely removed!"
      fi

      if [ -d "/hadoop/mysql" ]
      then
        data_dir=("${data_dir[@]}" "/hadoop/mysql")
      else
        log_progress "Directory /hadoop/mysql does not exist!"
      fi

      if [ -d "/hadoop/ngmr" ]
      then
        data_dir=("${data_dir[@]}" "/hadoop/ngmr")
      else
        log_progress "Directory /hadoop/ngmr does not exist!"
      fi

      ramdisk_ngmr="true"
      ;;
    search*)
      if [ -f "/etc/$service_id/conf/elasticsearch.yml" ]
      then
        path_data_dir=($(grep 'path.data=*' /etc/$service_id/conf/elasticsearch.yml | sed 's/path.data:[[:blank:]]//'))
        parse_data_dir_from_variable "$path_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
      else
        log_info "File /etc/$service_id/conf/elasticsearch.yml does not exist!"
        log_warning "Data dir of $service_id may not be completely removed!"
      fi
      ;;
    kafka*)
      if [ -f "/etc/$service_id/conf/kafka-env.sh" ]
      then
        kafka_data_dir=($(grep 'export KAFKA_DATA_DIRS=*' /etc/$service_id/conf/kafka-env.sh | sed 's/export[[:blank:]]KAFKA_DATA_DIRS=//' | sed 's/\"//g'))
        parse_data_dir_from_variable "$kafka_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
      else
        log_info "File /etc/$service_id/conf/kafka-env.sh does not exist!"
        log_warning "Data dir of $service_id may not be completely removed!"
      fi
      ;;
    tos*)
      tos_data_dirs=("/var/etcd" "/srv/kubernetes" "/run/kubernetes" "/var/run/kubernetes" "/var/lib/registry_data")
      for dir_item in "${tos_data_dirs[@]}"; do
        if [ -d "$dir_item" ]
        then
          data_dir=("${data_dir[@]}" "$dir_item")
        else
          log_progress "Directory $dir_item does not exist!"
        fi
      done
      ;;
    guardian*)
      if [ -f "/etc/$service_id/conf/guardian-ds.properties" ]
      then
        guardian_data_dir=($(grep 'guardian.ds.database.dir=*' /etc/$service_id/conf/guardian-ds.properties | sed 's/guardian.ds.database.dir=//'))
        parse_data_dir_from_variable "$guardian_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
      else
        log_progress "File /etc/$service_id/conf/guardian-ds.properties does not exist!"
      fi

      if [ -f "/etc/$service_id/conf/install_conf.sh" ]
      then
        guardian_data_dir=($(grep 'DATA_DIR=*' /etc/$service_id/conf/install_conf.sh | sed 's/DATA_DIR=//'))
        parse_data_dir_from_variable "$guardian_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
      else
        log_progress "File /etc/$service_id/conf/install_conf.sh does not exist!"
      fi

      if [ -d "/srv/guardian" ]
      then
        data_dir=("${data_dir[@]}" "/srv/guardian")
      else
        log_progress "Directory /srv/guardian does not exist!"
      fi

      if [ -d "/guardian" ]
      then
        data_dir=("${data_dir[@]}" "/guardian")
      else
        log_progress "Directory /guardian does not exist!"
      fi
      ;;
    transwarp_license_cluster* | zookeeper*)
      if [ -f "/etc/$service_id/conf/zookeeper-env.sh" ]
      then
        zk_data_dir=($(grep 'export ZOOKEEPER_DATA_DIR=*' /etc/$service_id/conf/zookeeper-env.sh | sed 's/export[[:blank:]]ZOOKEEPER_DATA_DIR=//'))
        parse_data_dir_from_variable "$zk_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
      else
        log_info "File /etc/$service_id/conf/zookeeper-env.sh does not exist!"
        log_warning "Data dir of $service_id may not be completely removed!"
      fi
      ;;
    txsql*)
      if [ -f "/etc/$service_id/conf/install_conf.sh" ]
      then
        txsql_data_dir=($(grep 'DATA_DIR=*' /etc/$service_id/conf/install_conf.sh | sed 's/DATA_DIR=//'))
        parse_data_dir_from_variable "$txsql_data_dir" "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")

        txsql_data_dir=($(grep 'LOG_DIR=*' /etc/$service_id/conf/install_conf.sh | sed 's/LOG_DIR=//'))
        parse_data_dir_from_variable "$txsql_data_dir" "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
      else
        log_info "File /etc/$service_id/conf/install_conf.sh does not exist!"
        log_warning "Data dir of $service_id may not be completely removed!"
      fi
      ;;
    sqoop*)
      if [ -d "/var/transwarp/$service_id" ]
      then
        data_dir=("${data_dir[@]}" "/var/transwarp/$service_id")
      else
        log_progress "Directory /var/transwarp/$service_id does not exist!"
      fi
      ;;
    shiva*)
      #master.log.log_dir, tabletserver.log.log_dir(default to be deleted)
      #master.master.data_path
      if [ -f "/etc/${service_id}/conf/master.conf" ]
      then
        shiva_data_dir=($(grep 'data_path=*' /etc/${service_id}/conf/master.conf | sed 's/data_path=//'))
        parse_data_dir_from_variable "$shiva_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
      else
        log_info "File /etc/$service_id/conf/master.conf does not exist!"
        log_warning "Data dir of $service_id may not be completely removed!"
      fi

      #tabletserver.store.datadirs
      if [ -f "/etc/${service_id}/conf/store.conf" ]
      then
        store_data_dirs=($(grep 'data_dir=*' /etc/${service_id}/conf/store.conf | sed 's/data_dir=//'))
        for store_data_dir in ${store_data_dirs[@]}
        do
          parse_data_dir_from_variable "$store_data_dir"  "$service_id"
          data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
          mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
        done
      else
        log_info "File /etc/$service_id/conf/store.conf does not exist!"
        log_warning "Data dir of $service_id may not be completely removed!"
      fi
      ;;
    argodbcomputing*)
      #ngmr.fastdisk.dir, ngmr.localdir
      if [ -f "/etc/${service_id}/conf/ngmr-env.sh" ]
      then
        ngmr_data_dir=($(grep 'export SPARK_FASTDISK_DIR=*' /etc/${service_id}/conf/ngmr-env.sh | sed 's/export[[:blank:]]SPARK_FASTDISK_DIR=//'))
        parse_data_dir_from_variable "$ngmr_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")

        ngmr_data_dir=($(grep 'export SPARK_LOCAL_DIR=*' /etc/${service_id}/conf/ngmr-env.sh | sed 's/export[[:blank:]]SPARK_LOCAL_DIR=//'))
        parse_data_dir_from_variable "$ngmr_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
      else
        log_info "File /etc/$service_id/conf/ngmr-env.sh does not exist!"
      fi
      ;;
    argodbstorage*)
      #shiva.master.log.log_dir, shiva.tabletserver.log.log_dir(default to be deleted)
      #shiva.master.master.data_path
      if [ -f "/etc/${service_id}/conf/shiva/master.conf" ]
      then
        shiva_data_dir=($(grep 'data_path=*' /etc/${service_id}/conf/shiva/master.conf | sed 's/data_path=//'))
        parse_data_dir_from_variable "$shiva_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
      else
        log_info "File /etc/$service_id/conf/shiva/master.conf does not exist!"
        log_warning "Data dir of $service_id may not be completely removed!"
      fi

      #shiva.tabletserver.store.datadirs
      if [ -f "/etc/${service_id}/conf/shiva/store.conf" ]
      then
        store_data_dirs=($(grep 'data_dir=*' /etc/${service_id}/conf/shiva/store.conf | sed 's/data_dir=//'))
        for store_data_dir in ${store_data_dirs[@]}
        do
          parse_data_dir_from_variable "$store_data_dir"  "$service_id"
          data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
          mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
        done
      else
        log_info "File /etc/$service_id/conf/shiva/store.conf does not exist!"
        log_warning "Data dir of $service_id may not be completely removed!"
      fi

      #ngmr.fastdisk.dir, ngmr.localdir
      if [ -f "/etc/${service_id}/conf/ngmr-env.sh" ]
      then
        ngmr_data_dir=($(grep 'export SPARK_FASTDISK_DIR=*' /etc/${service_id}/conf/ngmr-env.sh | sed 's/export[[:blank:]]SPARK_FASTDISK_DIR=//'))
        parse_data_dir_from_variable "$ngmr_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")

        ngmr_data_dir=($(grep 'export SPARK_LOCAL_DIR=*' /etc/${service_id}/conf/ngmr-env.sh | sed 's/export[[:blank:]]SPARK_LOCAL_DIR=//'))
        parse_data_dir_from_variable "$ngmr_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
      else
        log_info "File /etc/$service_id/conf/ngmr-env.sh does not exist!"
      fi

      #ladder.master.journal.data_path, ladder.master.localfs.data_path, ladder.worker.mem.data_path, ladder.worker.hdd.data_path
      if [ -f "/etc/${service_id}/conf/ladder/ladder-site.properties" ]
      then
        ladder_data_dir=($(grep 'ladder.master.journal.folder=*' /etc/${service_id}/conf/ladder/ladder-site.properties | sed 's/ladder.master.journal.folder=//'))
        parse_data_dir_from_variable "$ladder_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")

        ladder_data_dir=($(grep 'ladder.underfs.address=*' /etc/${service_id}/conf/ladder/ladder-site.properties | sed 's/ladder.underfs.address=//'))
        parse_data_dir_from_variable "$ladder_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")

        ladder_data_dir=($(grep 'ladder.worker.tieredstore.level0.dirs.path=*' /etc/${service_id}/conf/ladder/ladder-site.properties | sed 's/ladder.worker.tieredstore.level0.dirs.path=//'))
        parse_data_dir_from_variable "$ladder_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")

        ladder_data_dir=($(grep 'ladder.worker.tieredstore.level1.dirs.path=*' /etc/${service_id}/conf/ladder/ladder-site.properties | sed 's/ladder.worker.tieredstore.level1.dirs.path=//'))
        parse_data_dir_from_variable "$ladder_data_dir"  "$service_id"
        data_dir=("${data_dir[@]}" "${DATA_DIR[@]}")
        mount_data_dir=("${mount_data_dir[@]}" "${MOUNT_DATA_DIR[@]}")
      else
        log_info "File /etc/$service_id/conf/ngmr-env.sh does not exist!"
      fi

      if [ -d "/var/transwarp/data/ladder" ]
      then
        data_dir=("${data_dir[@]}" "/var/transwarp/data/ladder")
      else
        log_progress "Directory /var/transwarp/data/ladder does not exist!"
      fi
      ;;
    dashboard* | discover* | governor* | hue* | hyperbase* | notification* | oozie* | rubik* | sophon* | \
    transpedia* | transporter* | workflow* | kms* )
      log_progress "Service $service_id has no data dir to remove"
      ;;
    *)
      log_warning "Unhandled service $service_id"
      ;;
  esac
  log_progress "Catch mounted data dirs: ${mount_data_dir[@]}"
  log_progress "Start to umount caught data dirs"
  for dir_item in "${mount_data_dir[@]}"; do
    if grep "$dir_item" /etc/fstab | grep bind && \
       sed -i -r 's#^.*'$dir_item'.*bind.*$##g' /etc/fstab && \
       sed -i '/^$/d' /etc/fstab
    then
      log_progress "remove mount bind entry of $dir_item from /etc/fstab"
    fi
    if [ -d "$dir_item" ]
    then
      if mount | grep "$dir_item"
      then
        log_progress "umount data directory $dir_item"
        umount -f "$dir_item"
      else
        log_progress "remove data directory $dir_item"
        rm -rf "$dir_item"
      fi
    else
      log_progress "Invalid dir $dir_item. Do nothing."
    fi
  done
  sleep 3s
  for dir_item in "${mount_data_dir[@]}"; do
    if [ -d "$dir_item" ]
    then
      if mount | grep "$dir_item"
      then
        log_error "Cannot umount directory $dir_item"
        toExit
      else
        log_progress "remove mount directory $dir_item"
        rm -rf "$dir_item"
      fi
    fi
  done
  log_progress "Finish umount caught data dirs"

  log_progress "Catch data dir: ${data_dir[@]}"
  log_progress "Start to remove caught data dirs"
  for dir_item in "${data_dir[@]}"; do
    if [ -n "$dir_item" ] && [ "$dir_item" != "/mnt/ramdisk/ngmr" ]
    then
      log_progress "Remove data folder $dir_item"
      if [ -d "$dir_item" ]
      then
        log_progress "Start to remove content under directory $dir_item"
        rm -rf "$dir_item"
        log_progress "Remove content under directory Done"
      fi
    else
      log_progress "Do nothing with data folder:$dir_item"
    fi
  done
  log_progress "Remove directory /transwarp/mounts/$service_id"
  [ -d "/transwarp/mounts/$service_id" ] && rm -rf "/transwarp/mounts/$service_id"
  log_progress "Finish remove caught data dirs"
}

remove_agent_files() {
  log_info "Start to remove transwarp-manager-agent related directories"
  #these directories could have data in runtime, delete them manually
  other_dirs=("transwarp-manager-agent:/etc/transwarp-manager/agent" "transwarp-manager-agent:/usr/lib/transwarp-manager/agent" \
  "transwarp-manager-agent:/var/lib/transwarp-manager/agent" "transwarp-manager-agent:/var/log/transwarp-manager/agent")
  for other_dir in "${other_dirs[@]}"; do
    related_package=${other_dir%:*}
    real_dir=${other_dir#*:}
    #only when the package has been removed, then to delete the dir

    if "${PKG_BIN}" "${PKG_QRY_OPT}" ${related_package} > /dev/null 2>&1
    then
      log_warning "Pakcage $related_package should have been removed, yet still exists!"
      log_warning "Ignore directory: $real_dir!"
    else
      if [ -d "$real_dir" ]
      then
        log_progress "Pakcage $related_package has been removed. Remove directory: $real_dir"
        rm -rf "$real_dir"
        log_progress "Remove directory: $real_dir Done"
      fi
    fi
  done
  log_info "Finish remove transwarp-manager-agent related directories"
}

remove_manager_files() {
  if "${PKG_BIN}" "${PKG_QRY_OPT}" transwarp-manager > /dev/null 2>&1
  then
    log_info "Start to uninstall transwarp-manager"

    log_progress "Delete transwarp-manager related data"
    if systemctl status transwarp-manager-db > /dev/null 2>&1
    then
      systemctl stop transwarp-manager-db
    fi
    if systemctl status transwarp-manager > /dev/null 2>&1
    then
      systemctl stop transwarp-manager
    fi
    remove_one_package "transwarp-manager"
    remove_one_package "transwarp-manager-common"
    dir_array=("/var/lib/" "/usr/lib/" "/etc/" "/var/log/")
    for dir_item in "${dir_array[@]}"; do
      if [ -d "${dir_item}transwarp-manager" ]
      then
        log_progress "Delete directory ${dir_item}transwarp-manager"
        rm -rf "${dir_item}transwarp-manager"
      fi
    done
    [ -d /usr/lib/transwarp ] && rm -rf /usr/lib/transwarp
#    [ -n "$(ls /etc/transwarp/ 2>/dev/null)" ] && find /etc/transwarp/* -depth ! -name "transwarp-id_rsa*" -exec rm -rf {} \;
    if [ -d /var/transwarp ] && [ -z "$(ls /var/transwarp/ 2>/dev/null)" ]
    then
      rm -rf /var/transwarp/
    fi
    if [ -d /transwarp/mounts ] && [ -z "$(ls /transwarp/mounts/ 2>/dev/null)" ]
    then
      rm -rf /transwarp/mounts/
    fi
    log_progress "Delete transwarp repo packages directory"
    if [[ "$OSTYPE" == "RHEL" ]]
    then
      [ -d /var/lib/transwarp-manager/master/pub/transwarp ] && rm -rf /var/lib/transwarp-manager/master/pub/transwarp
      [ -d /var/ftp/pub/transwarp_update ] && rm -rf /var/ftp/pub/transwarp_update
    else
      [ -d /srv/ftp/pub/transwarp ] && rm -rf /srv/ftp/pub/transwarp
      [ -d /srv/ftp/pub/transwarp_update ] && rm -rf /srv/ftp/pub/transwarp_update
    fi
    log_info "Finish uninstall transwarp-manager"
  fi
}

remove_file_and_folder() {
  local services=($SERVICE_LIST)
  local fix_dirs=("/etc/" "/var/log/")
  ramdisk_ngmr="false"
  log_info "Remove data of service $service"
  for service_item in "${services[@]}"; do
    log_info "Start to remove service $service_item"
    if [[ "$REMOVE_DATA" == "true" ]]
    then
      log_progress "Remove data folders of $service_item"
      remove_data_folder "$service_item"
      log_progress "Finish remove data folders of $service_item"
    fi
    log_progress "Remove config and log folders of $service_item"
    for dir_item in "${fix_dirs[@]}"; do
      if [ -d "$dir_item$service_item" ]
      then
        log_progress "Remove directory: $dir_item$service_item"
        rm -rf "$dir_item$service_item"
        log_progress "Remove directory done"
      else
        log_progress "Directory $dir_item$service_item does not exist. Do nothing."
      fi
    done
    log_progress "Finish remove config and log folders of $service_item"
    log_info "Finish remove service $service_item"
  done

  if [[ "$REMOVE_DATA" == "true" ]] && [[ "$ramdisk_ngmr" == "true" ]]
  then
    if [ -d /mnt/ramdisk/ngmr ]
    then
      log_progress "Start to remove content under directory $dir_item"
      grep "/mnt/ramdisk/ngmr" /etc/fstab && \
      sed -i -r 's#^.*/mnt/ramdisk/ngmr.*$##g' /etc/fstab && \
      sed -i '/^$/d' /etc/fstab
      mountpoint -q /mnt/ramdisk/ngmr && umount -f /mnt/ramdisk/ngmr
      rm -rf /mnt/ramdisk/ngmr
      log_progress "Finish remove content under directory $dir_item"
    fi
  fi
}

stop_docker(){
  log_info "Start to Stop docker and Delete docker data dirs"
  if systemctl status docker >/dev/null
  then
    local docker_containers=($(docker ps -qa))
    if [[ ${#docker_containers[@]} -gt 0 ]]
    then
      for container in "${docker_containers[@]}";
      do
        if docker ps -q | grep "$container" && docker kill $container
        then
          log_progress "Stopped docker container $container"
        fi

        if docker ps -qa | grep "$container" && docker rm -fv $container
        then
          log_progress "Removed docker container $container"
        else
          if docker ps -qa | grep "$container"
          then
            log_error "Remove docker container $container failed!"
            toExit
          fi
        fi
      done
    fi

    docker_containers=($(docker ps -qa))
    if [[ ${#docker_containers[@]} -gt 0 ]]
    then
      log_error "Remove docker containers failed!"
      toExit
    fi

    local docker_images=($(docker images -qa))
    if [[ ${#docker_images[@]} -gt 0 ]]
    then
      for image in "${docker_images[@]}";
      do
        if docker images -qa | grep "$image" && docker rmi -f $image
        then
          log_progress "Removed docker image $image"
        else
          if docker images -qa | grep "$image"
          then
            log_error "Remove docker image $image failed!"
            toExit
          fi
        fi
      done
    fi

    local docker_images=($(docker images -qa))
    if [[ ${#docker_images[@]} -gt 0 ]]
    then
      log_error "Remove docker images failed!"
      toExit
    fi

    if systemctl stop docker
    then
      log_progress "Docker stopped"
    else
      log_error "Cannot stop docker service"
      toExit
    fi
  fi

  if systemctl status docker-monitor >/dev/null
  then
    systemctl stop docker-monitor
  fi

  local docker_thread=(`ps -aux | grep "docker" | awk '{print $2}' `)
  for td in "${docker_thread[@]}";
  do
    kill -9 "$td" 2> /dev/null
  done

  rm -f /usr/sbin/docker-monitor

  rm -rf /var/lib/docker/* /etc/sysconfig/docker /etc/sysconfig/docker-storage
  if "${PKG_BIN}" "${PKG_QRY_ALL_OPT}" | grep ^docker
  then
    remove_one_package docker*
  fi

  log_info "Finish Stop docker and Delete docker data dirs"
}

downgrade_libsemanage(){
  ##删除5.1.1及其以下版本中docker分区
  local block_docker=(` vgs | grep "docker" `)
  if [[ ${#block_docker[@]} -gt 0 ]]
  then
     log_progress "begin remove vg docker !"
     pvremove -f docker
     vgremove -f docker
     log_progress "success!! remove vg docker and docker path"
     ###删除/降级libsemanage
     yum -y remove libsemanage-python*
     yum -y downgrade libsemanage*
  fi
}

stop_kubernetes(){
  log_info "Start to stop kubernetes and delete kubernetes files"
  if systemctl status kubelet > /dev/null 2>&1
  then
    if ! systemctl stop kubelet
    then
      log_error "Cannot stop kubelete!"
      toExit
    else
      log_progress "Kubelet stopped"
    fi
  fi

  if systemctl status haproxy > /dev/null
  then
    if ! systemctl stop haproxy
    then
      log_error "Cannot stop haproxy!"
      toExit
    else
      log_progress "haproxy stopped"
    fi
  fi

  local kubelet_mounts=($(mount | grep /var/lib/kubelet | awk '{print $3}'))
  if [[ ${#kubelet_mounts[@]} -gt 0 ]]
  then
    for mount_item in "${kubelet_mounts[@]}";
    do
      if umount -f "$mount_item"
      then
        log_progress "Directory $mount_item umounted"
      else
        log_warning "Umount $mount_item failed!"
      fi
    done
  fi

  for pkg in "hyperkube-tos haproxy"
  do
    if "${PKG_BIN}" "${PKG_QRY_OPT}" $pkg > /dev/null 2>&1
    then
      log_progress "Start to unistall $pkg"
      "${REPO_BIN}" "${REPO_YES_OPT}" "${REPO_REMOVE}" $pkg > /dev/null 2>&1
      log_progress "Finish uninstall $pkg"
    fi
  done
  if "${PKG_BIN}" "${PKG_QRY_OPT}" hyperkube-tos > /dev/null 2>&1
  then
    "${REPO_BIN}" "${REPO_YES_OPT}" "${REPO_REMOVE}" hyperkube-tos > /dev/null 2>&1
  fi
  rm -rf /opt/kubernetes/ /usr/sbin/haproxy-systemd-wrapper /usr/sbin/haproxy
  rm -rf /usr/lib/systemd/system/kubelet.service /usr/lib/systemd/system/haproxy.service
  rm -rf /var/log/kubernetes /var/lib/kubelet
  log_info "Finished stop kubernetes and delete kubernetes files"
}

delete_tos_pod(){
  log_info "Start to delete all tos pods"
  if systemctl status haproxy >/dev/null 2>&1 || systemctl status kubelet >/dev/null 2>&1
  then
    log_progress "Remove dir /opt/kubernetes/manifests-multi"
    rm -rf /opt/kubernetes/manifests-multi

    local default_deployments=($(kubectl get deployments --no-headers 2>/dev/null | awk '{print $1}'))
    if [[ ${#default_deployments[@]} -gt 0 ]]
    then
      for deployment in "${default_deployments[@]}";
      do
        log_progress "Remove deployment $deployment"
        kubectl delete deployments $deployment --grace-period=0 2>/dev/null
      done
    fi

    log_progress "Remove deployment and pods of kube-system"
    kubectl delete deployments --namespace=kube-system --grace-period=0 --all 2>/dev/null
    kubectl delete po --namespace=kube-system --all 2>/dev/null

    if [ $(kubectl get po --no-headers 2>/dev/null | wc -l) -gt 0 ] || \
       [ $(kubectl get po --namespace=kube-system --no-headers 2>/dev/null | grep $(hostname) | wc -l) -gt 0 ]
    then
      log_warning "Delete tos deployments not successful: pod number supposed to be 0, yet not!"
    fi
  fi
  log_info "Finish delete all tos pods"
}

stop_manager() {
  log_info "Start to Stop transwarp-manager"
  if "${PKG_BIN}" "${PKG_QRY_OPT}" transwarp-manger > /dev/null 2>&1 && service transwarp-manager status
  then
    if ! service transwarp-manager stop
    then
      log_error "Cannot stop transwarp-manager!"
      toExit
    fi
  fi
  log_info "Finish Stop transwarp-manager"
}

stop_agent() {
  log_info "Start to Stop transwarp-manager-agent"
  if service transwarp-manager-agent status
  then
    if ! service transwarp-manager-agent stop
    then
      log_error "Cannot stop transwarp-manager-agent!"
      toExit
    fi
  fi
  log_info "Finish Stop transwarp-manager-agent"
}

package_removed_check() {
  if "${PKG_BIN}" "${PKG_QRY_OPT}" $1 > /dev/null 2>&1
  then
    log_warning "Package $1 supposed to be removed, but still exists!"
    log_info "Please re-execute the unistall script or manually execute: \"${PKG_BIN} ${PKG_REMOVE_OPT} $1\""
  fi
}

path_umount_check() {
  if mount | grep $1 > /dev/null
  then
    log_warning "Path $1 supposed to be umounted, but still exists!"
    log_info "Please re-execute the unistall script or manually execute: \"mount | grep $1 | awk '{print \$3}'| xargs umount\""
  fi
}

dir_removed_check() {
  if [ -e $1 ]
  then
    log_warning "Directory $1 supposed to be removed, but still exists!"
    log_info "Please re-execute the unistall script or manually execute: \"rm -rf $1\""
  fi
}

process_stop_check() {
  if ps -aux | grep $1 | grep -v grep
  then
    log_warning "Process $1 supposed to be stopped, but still running!"
    log_info "Please re-execute the unistall script or manually execute: \"ps -aux | grep $1 | awk '{print \$2}' | xargs kill -9\""
  fi
}

check_uninstall_result() {
  log_info "Start to check agent uninstall result"

  log_progress "check if package is still installed"
  docker_comps=(docker docker-common docker-compose docker-selinux)
  for comp in "${docker_comps[@]}"
  do
    package_removed_check ${comp}
  done
  package_removed_check transwarp-manager-agent
  log_progress "Finish package check"

  log_progress "check if mount path exists"
  path_umount_check 'transwarp/mounts'
  path_umount_check 'kubelet'
  log_progress "Finish path umount check"

  log_progress "check if dirs exists"
  dir_removed_check /hadoop/*
  dir_removed_check /mnt/disk*/hadoop
  dir_removed_check /srv/kubernetes
  dir_removed_check /run/kubernetes
  dir_removed_check /etc/kubernetes*
  dir_removed_check /var/log/kubernetes*
  dir_removed_check /var/lib/kubelet*
  dir_removed_check /var/etcd
  dir_removed_check /var/lib/registry*
  dir_removed_check /guardian*
  dir_removed_check /mnt/disk*/search
  dir_removed_check /var/log/transwarp-manager/agent*
  dir_removed_check /var/lib/transwarp-manager/agent*
  dir_removed_check /usr/lib/transwarp-manager/agent*
  dir_removed_check /etc/transwarp-manager/agent*
  dir_removed_check /transwarp/mounts/*
  dir_removed_check /var/transwarp/*
  dir_removed_check /var/namenode_format
  log_progress "finsh check dirs"

  log_progress "check if port is inuse"
  ports=(3316 17000 13306 6000 3306 8001)
  for port in "${ports[@]}"
  do
    if ss -anp | grep ${port} | grep LISTEN
    then
      log_info "Port ${port} is not supposed to be LISTENING!"
      log_info "Please re-execute the unistall script or manually execute:"
      log_info "\"ss -anp | grep -w ${port} | grep LISTEN | awk '{print \$7}' | awk -F \"=\" '{print \$2}' | awk -F \",\" '{print \$1}' | xargs kill -9\""
    fi
  done
  log_progress "finsh check port"

  log_progress "check if process is running"
  process_stop_check docker
  process_stop_check search
  log_progress "finish check process"

  log_info "Finish check agent uninstall result"
}

main() {
  check_os
  stop_manager
  stop_agent
  delete_tos_pod
  stop_kubernetes
  stop_docker
  remove_file_and_folder
  remove_packages
  remove_agent_files
  remove_manager_files
  downgrade_libsemanage
  check_uninstall_result
}
main