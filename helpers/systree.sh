preparation_workspace() {
    mkdir -pv \
        "$WORKSPACE" \
        "$LOGDIR" \
        "$BACKUP_DIR" \
        "$IMGDIR"
}

preparation_sysfile(){
	sudo ROOTFS="$ROOTFS" chmod 755 "$ROOTFS"
	sudo ROOTFS="$ROOTFS" chown $USER:$USER "$ROOTFS"

	rm -rf "${ROOTFS:?}"/* 
	mkdir -pv "${ROOTFS:?}"/tmp

	touch "$STATE_BUILD"
	touch "$STATE_FILE"
}

make_minimal_systree() {
	mkdir -pv "$ROOTFS"/{etc,var} "$ROOTFS"/usr/{bin,lib,lib64,sbin} "$TOOLCHAIN" "$SOURCES"

	for i in bin lib sbin; do
		ln -sv usr/$i "$ROOTFS"/$i
	done
}

make_full_systree() {
	mkdir -pv /{boot,home,mnt,opt,srv}

	mkdir -pv /etc/{opt,sysconfig}
	mkdir -pv /lib/firmware
	mkdir -pv /media/{floppy,cdrom}
	mkdir -pv /usr/{,local/}{include,src}
	mkdir -pv /usr/lib/locale
	mkdir -pv /usr/local/{bin,lib,sbin}
	mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
	mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
	mkdir -pv /usr/{,local/}share/man/man{1..8}
	mkdir -pv /var/{cache,local,log,mail,opt,spool}
	mkdir -pv /var/lib/{color,misc,locate}

	ln -sfv /run /var/run
	ln -sfv /run/lock /var/lock

	install -dv -m 0750 /root
	install -dv -m 1777 /tmp /var/tmp
	ln -sv /proc/self/mounts /etc/mtab

	touch /var/log/{btmp,lastlog,faillog,wtmp}
	chgrp -v utmp /var/log/lastlog
	chmod -v 664  /var/log/lastlog
	chmod -v 600  /var/log/btmp
}

touch_hosts() {
	cat > /etc/hosts << EOF
127.0.0.1  localhost $(hostname)
::1        localhost
EOF
}

touch_passwd() {
	cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF
}

touch_group() {
	cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF
}