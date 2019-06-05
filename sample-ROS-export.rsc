# Sample file, old hAP-AC-default-script
# (with `/foobar` and `nozoo` and test/non-real phrases)
/foobar nozoo comment="zoo" wireless 123

## Some stuff just added for testing syntax highlighting
/interface ethernet
set [ find default-name=ether1 ] advertise=\
    10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full
set [ find default-name=ether2 ] advertise=\
    10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full

:global ssid;
#| RouterMode:
#|  * WAN port is protected by firewall and enabled DHCP client
#|  * Wireless interfaces are part of LAN bridge
#|  * WAN port is protected by firewall and enabled DHCP client
#|  * IP address 192.168.88.1/24 is set on LAN port
#| wlan1 Configuration:
#|     mode:          ap-bridge;
#|     band:          2ghz-b/g/n;
#|     ht-chains:     0,1,2;
#|     ht-extension:  20/40mhz-Ce;
#| wlan2 Configuration:
#|     mode:          ap-bridge;
#|     band:          5ghz-a/n/ac;
#|     ht-chains:     0,1,2;
#|     ht-extension:  20/40mhz-Ce;
#| LAN Configuration:
#|     switch group: ether2 (master), ether3, ether4, ether5
#|     DHCP Server: enabled;
#|     DNS: enabled;
#| WAN (gateway) Configuration:
#|     gateway:  ether1 ;
#|     firewall:  enabled;
#|     NAT:   enabled;

:log info Starting_defconf_script_;
:global action;
#-------------------------------------------------------------------------------
# Apply configuration.
# these commands are executed after installation or configuration reset
#-------------------------------------------------------------------------------
:if ($action = "apply") do={
# wait for interfaces
:local count 0; 
:while ([/interface ethernet find] = "") do={ 
:if ($count = 30) do={
:log warning "DefConf: Unable to find ethernet interfaces";
/quit;
}
:delay 1s; :set count ($count +1); 
};

  :local count 0;
  :while ([/interface wireless print count-only] < 2) do={ 
    :set count ($count +1);
    :if ($count = 30) do={
      :log warning "DefConf: Unable to find wireless interface(s)"; 
      /ip address add address=192.168.88.1/24 interface=ether1 comment="defconf";
      /quit
    }
    :delay 1s;
  };
  /interface wireless {
    set wlan1 mode=ap-bridge band=2ghz-b/g/n tx-chains=0,1,2 rx-chains=0,1,2 \
      disabled=no wireless-protocol=802.11 distance=indoors
    :local wlanMac  [/interface wireless get wlan1 mac-address];
    :set ssid "MikroTik-$[:pick $wlanMac 9 11]$[:pick $wlanMac 12 14]$[:pick $wlanMac 15 17]"
    set wlan1 ssid=$ssid
    set wlan1 frequency=auto
    set wlan1 channel-width=20/40mhz-Ce ;
  }
  /interface wireless {
    set wlan2 mode=ap-bridge band=5ghz-a/n/ac tx-chains=0,1,2 rx-chains=0,1,2 \
      disabled=no wireless-protocol=802.11 distance=indoors
    :local wlanMac  [/interface wireless get wlan2 mac-address];
    :set ssid "MikroTik-$[:pick $wlanMac 9 11]$[:pick $wlanMac 12 14]$[:pick $wlanMac 15 17]"
    set wlan2 ssid=$ssid
    set wlan2 frequency=auto
    set wlan2 channel-width=20/40mhz-Ce ;
  }
 /interface ethernet {
   set ether2 name=ether2-master;
   set ether3 master-port=ether2-master;
   set ether4 master-port=ether2-master;
   set ether5 master-port=ether2-master;
 }
 /interface bridge
   add name=bridge disabled=no auto-mac=yes protocol-mode=rstp comment=defconf;
 :local bMACIsSet 0;
 :foreach k in=[/interface find where !(slave=yes  || name~"ether1" || name~"bridge")] do={
   :log info "k: $k"
   :local tmpPortName [/interface get $k name];
   :log info "port: $tmpPortName"
   :if ($bMACIsSet = 0) do={
     :if ([/interface get $k type] = "ether") do={
       /interface bridge set "bridge" auto-mac=no admin-mac=[/interface ethernet get $tmpPortName mac-address];
       :set bMACIsSet 1;
     }
   }
   /interface bridge port
     add bridge=bridge interface=$tmpPortName comment=defconf;
 }
  /ip address add address=192.168.88.1/24 interface=bridge comment="defconf";
   /ip pool add name="default-dhcp" ranges=192.168.88.10-192.168.88.254;
   /ip dhcp-server
     add name=defconf address-pool="default-dhcp" interface=bridge lease-time=10m disabled=no;
   /ip dhcp-server network
     add address=192.168.88.0/24 gateway=192.168.88.1 comment="defconf";
 /ip dns {
     set allow-remote-requests=yes
     static add name=router address=192.168.88.1
 }

   /ip dhcp-client add interface=ether1 disabled=no comment="defconf";
 /ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade comment="defconf: masquerade"
 /ip firewall {
   filter add chain=input action=accept protocol=icmp comment="defconf: accept ICMP"
   filter add chain=input action=accept connection-state=established,related comment="defconf: accept establieshed,related"
   filter add chain=input action=drop in-interface=ether1 comment="defconf: drop all from WAN"
   filter add chain=forward action=fasttrack-connection connection-state=established,related comment="defconf: fasttrack"
   filter add chain=forward action=accept connection-state=established,related comment="defconf: accept established,related"
   filter add chain=forward action=drop connection-state=invalid comment="defconf: drop invalid"
   filter add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface=ether1 comment="defconf:  drop all from WAN not DSTNATed"
 }
 /ip neighbor discovery set [find name="ether1"] discover=no
 /tool mac-server disable [find];
 /tool mac-server mac-winbox disable [find];
 :foreach k in=[/interface find where !(slave=yes  || name~"ether1")] do={
   :local tmpName [/interface get $k name];
   /tool mac-server add interface=$tmpName disabled=no;
   /tool mac-server mac-winbox add interface=$tmpName disabled=no;
 }
}
#-------------------------------------------------------------------------------
# Revert configuration.
# these commands are executed if user requests to remove default configuration
#-------------------------------------------------------------------------------
:if ($action = "revert") do={
# remove wan port protection
 /ip firewall filter remove [find comment~"defconf"]
 /ip firewall nat remove [find comment~"defconf"]
 /tool mac-server remove [find interface!=all]
 /tool mac-server set [find] disabled=no
 /tool mac-server mac-winbox remove [find interface!=all]
 /tool mac-server mac-winbox set [find] disabled=no
 /ip neighbor discovery set [find ] discover=yes
   :local o [/ip dhcp-server network find comment="defconf"]
   :if ([:len $o] != 0) do={ /ip dhcp-server network remove $o }
   :local o [/ip dhcp-server find name="defconf" !disabled]
   :if ([:len $o] != 0) do={ /ip dhcp-server remove $o }
   /ip pool {
     :local o [find name="default-dhcp" ranges=192.168.88.10-192.168.88.254]
     :if ([:len $o] != 0) do={ remove $o }
   }
   :local o [/ip dhcp-client find comment="defconf"]
   :if ([:len $o] != 0) do={ /ip dhcp-client remove $o }
 /ip dns {
   set allow-remote-requests=no
   :local o [static find name=router address=192.168.88.1]
   :if ([:len $o] != 0) do={ static remove $o }
 }
 /ip address {
   :local o [find comment="defconf"]
   :if ([:len $o] != 0) do={ remove $o }
 }
 :foreach iface in=[/interface ethernet find] do={
   /interface ethernet set $iface name=[get $iface default-name]
   /interface ethernet set $iface master-port=none
 }
 /interface bridge port remove [find comment="defconf"]
 /interface bridge remove [find comment="defconf"]
 /interface wireless reset-configuration wlan1
 /interface wireless reset-configuration wlan2
}
:log info Defconf_script_finished;
