#!/bin/bash
# author: chengs
set -e

INVENTORY='/tmp/yun_os/nodes.txt'
HAPROXY_BAK='/etc/haproxy/conf_bak.d/'
HAPROXY_DIR='/etc/haproxy/conf.d/'
ETC_MY_CNF='/etc/my.cnf.d/galera.cnf'
ETC_MY_CNF_BAK='/etc/my.cnf.d/galera.cnf.bak'

echo_warn(){
    echo -e "\033[33m$1\033[0m"
}
Note(){
    echo_warn "Check $1 ...."
}
nodes(){
    local roles="$1"
    local field="$2" #1:management 2:pxe 3:storagepub 4:hostname 5:role
    if [[ $roles == "all" ]];then
        cat ${INVENTORY} | awk "{print \$${field}}" | sort | uniq
    else
        cat ${INVENTORY} | egrep -e "$roles" | awk "{print \$${field}}" | sort | uniq
    fi
}

check(){
    Note "Openstack Services"
    python /tmp/yun_os/services/service_manager.py check

    Note "ls -l $HAPROXY_DIR"
    ls -l $HAPROXY_DIR/

    Note "$ETC_MY_CNF Configs"
    cat $ETC_MY_CNF | egrep 'max_connections|wait_timeout|wsrep_cluster_address'

    Note "Mariadb Cluster Options"
    mysql -e "show global status like '%wsrep_cluster%';"
}

## --- Main ---
check
