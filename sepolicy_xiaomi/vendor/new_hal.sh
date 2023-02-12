#!/bin/bash

set -x

touch hal_"$1".te
touch hal_"$1"_default.te

cat > hal_"$1".te <<-EOF
binder_call(hal_$1_client, hal_$1_server)

add_hwservice(hal_$1_server, hal_$1_hwservice)
allow hal_$1_client hal_$1_hwservice:hwservice_manager find;
EOF

cat > hal_"$1"_default.te <<-EOF
type hal_$1_default, domain;
hal_server_domain(hal_$1_default, hal_$1);

type hal_$1_default_exec, exec_type, vendor_file_type, file_type;
init_daemon_domain(hal_$1_default);
EOF

cat >> attributes <<-EOF
attribute hal_$1;
attribute hal_$1_server;
attribute hal_$1_client;
EOF

if ! grep -q "hal_$1_hwservice" hwservice.te ; then
	echo "Writing to hwservice"
	echo "type hal_$1_hwservice, hwservice_manager_type;" >> hwservice.te
fi

if ! grep -q "hal_$1_hwservice" hwservice_contexts ; then
	echo "Enter hwservice_contexts: "
	read -r hwcontext
	echo "$hwcontext" >> hwservice_contexts
fi

