#!/bin/bash
# add 2018-06-29 by Pascal Withopf, released under ASL 2.0
. $srcdir/diag.sh init
setvar_RS_HOSTNAME
. $srcdir/diag.sh generate-conf
. $srcdir/diag.sh add-conf '
module(load="../contrib/pmsnare/.libs/pmsnare")
module(load="../plugins/imudp/.libs/imudp")
input(type="imudp" port="13514" ruleset="ruleset1")

global(parser.escapeControlCharactersCStyle="on")

$EscapeControlCharactersOnReceive on


template(name="outfmt" type="string" string="%PRI%,%syslogfacility-text%,%syslogseverity-text%,%programname%,%syslogtag%,%msg%\n")

ruleset(name="ruleset1" parser=["rsyslog.snare","rsyslog.rfc5424","rsyslog.rfc3164"]) {
	action(type="omfile" file="rsyslog.out.log"
	       template="outfmt")
}
'
. $srcdir/diag.sh startup
. $srcdir/diag.sh tcpflood -m1 -T "udp" -M "\"<14> 05/21/2017:00:00:00 GMT HOSTNAME 1-ABC-2 : default SSLLOG SSL_HANDSHAKE_SUCCESS 39672436 0 :  SPCBId 6377757 - ClientIP 192.168.0.11 - ClientPort 55073 - VserverServiceIP 192.168.0.11 - VserverServicePort 443 - ClientVersion TLSv1.0 - CipherSuite \\\"AES-256-CBC-SHA TLSv1 Non-Export 256-bit\\\" - Session Reuse    The authenti\""
. $srcdir/diag.sh tcpflood -m1 -T "udp" -M "\"<14>123456789: HOSTNAME: May 21 12:00:01.123 gmt: %IOSXE-6-PLATFORM: F0: cpp_cp: QFP:0.0 Thread:105 TS:00000000000000 %NAT-6-LOG_TRANSLATION: Created Translation UDP 192.168.0.11:44593 192.168.0.11:21129 192.168.0.11:53 192.168.0.11:53 0................\""
. $srcdir/diag.sh tcpflood -m1 -T "udp" -M "\"<14>May 21 2017 00:00:00: %ASA-4-102030: Deny udp src vlan_12302:192.168.0.11/514 dst vlan_1233:192.168.0.11/514 by access-group "local_in" [0x0, 0x0]\""
. $srcdir/diag.sh tcpflood -m1 -T "udp" -M "\"<14>2017-05-21T00:00:01.123Z hostname.domain Hostd: verbose hostd[81480B70] [Originator@6876 sub=Hostsvc.StorageSystem] SendStorageInfoEvent: Notify: StorageSystemMsg{HBAs=[vmhba0, vmhba1, vmhba2, vmhba3, vmhba32, vmhba4, ]};\""
. $srcdir/diag.sh tcpflood -m1 -T "udp" -M "\"<14>May 21 12:00:01 hostname CROND[12393]: pam_unix(crond:session): session closed for user root................\""
. $srcdir/diag.sh tcpflood -m1 -T "udp" -M "\"<14>May 21 12:00:01 hostname.domain MSWinEventLog	1	Security	00000000	Sun May 21 12:00:01.123	4624	Microsoft-Windows-Security-Auditing	N/A	N/A	Success Audit	hostname.domain	Logon		An account was successfully logged on.    Subject:   Security ID:  0x000000000   Account Name:  first.last   Account Domain:  domain   Logon ID:  0x000000000    Logon Type:   3    New Logon:   Security ID:  0x000000000   Account Name:  first.last   Account Domain:  domain   Logon ID:  0x000000000   Logon GUID:  0x000000000    Process Information:   Process ID:  0x000000000   Process Name:  first.last    Network Information:   Workstation Name:    Source Network Address: 192.168.0.11   Source Port:  51542    Detailed Authentication Information:   Logon Process:  Kerberos   Authentication Package: Kerberos   Transited Services: -   Package Name (NTLM only): -   Key Length:  0    This event is generated when a logon session is created. It is generated on the computer that was accessed.    The subject fields indicate the account on the local system which requested the logon. This is most commonly a service such as the Server service, or a local process such as Winlogon.exe or Services.exe.    The logon type field indicates the kind of logon that occurred. The most common types are 2 (interactive) and 3 (network).    The New Logon fields indicate the account for whom the new logon was created, i.e. the account that wa................\""
. $srcdir/diag.sh shutdown-when-empty
. $srcdir/diag.sh wait-shutdown

export EXPECTED='14,user,info,,, 05/21/2017:00:00:00 GMT HOSTNAME 1-ABC-2 : default SSLLOG SSL_HANDSHAKE_SUCCESS 39672436 0 :  SPCBId 6377757 - ClientIP 192.168.0.11 - ClientPort 55073 - VserverServiceIP 192.168.0.11 - VserverServicePort 443 - ClientVersion TLSv1.0 - CipherSuite "AES-256-CBC-SHA TLSv1 Non-Export 256-bit" - Session Reuse    The authenti
14,user,info,123456789,123456789:, HOSTNAME: May 21 12:00:01.123 gmt: %IOSXE-6-PLATFORM: F0: cpp_cp: QFP:0.0 Thread:105 TS:00000000000000 %NAT-6-LOG_TRANSLATION: Created Translation UDP 192.168.0.11:44593 192.168.0.11:21129 192.168.0.11:53 192.168.0.11:53 0................
14,user,info,%ASA-4-102030,%ASA-4-102030:, Deny udp src vlan_12302:192.168.0.11/514 dst vlan_1233:192.168.0.11/514 by access-group local_in [0x0, 0x0]
14,user,info,Hostd,Hostd:, verbose hostd[81480B70] [Originator@6876 sub=Hostsvc.StorageSystem] SendStorageInfoEvent: Notify: StorageSystemMsg{HBAs=[vmhba0, vmhba1, vmhba2, vmhba3, vmhba32, vmhba4, ]};
14,user,info,CROND,CROND[12393]:, pam_unix(crond:session): session closed for user root................
14,user,info,MSWinEventLog,MSWinEventLog, 1\tSecurity\t00000000\tSun May 21 12:00:01.123\t4624\tMicrosoft-Windows-Security-Auditing\tN/A\tN/A\tSuccess Audit\thostname.domain\tLogon\t\tAn account was successfully logged on.    Subject:   Security ID:  0x000000000   Account Name:  first.last   Account Domain:  domain   Logon ID:  0x000000000    Logon Type:   3    New Logon:   Security ID:  0x000000000   Account Name:  first.last   Account Domain:  domain   Logon ID:  0x000000000   Logon GUID:  0x000000000    Process Information:   Process ID:  0x000000000   Process Name:  first.last    Network Information:   Workstation Name:    Source Network Address: 192.168.0.11   Source Port:  51542    Detailed Authentication Information:   Logon Process:  Kerberos   Authentication Package: Kerberos   Transited Services: -   Package Name (NTLM only): -   Key Length:  0    This event is generated when a logon session is created. It is generated on the computer that was accessed.    The subject fields indicate the account on the local system which requested the logon. This is most commonly a service such as the Server service, or a local process such as Winlogon.exe or Services.exe.    The logon type field indicates the kind of logon that occurred. The most common types are 2 (interactive) and 3 (network).    The New Logon fields indicate the account for whom the new logon was created, i.e. the account that wa................'
cmp_exact rsyslog.out.log

. $srcdir/diag.sh exit