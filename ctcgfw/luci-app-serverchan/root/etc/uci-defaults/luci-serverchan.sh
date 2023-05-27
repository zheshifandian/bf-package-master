#!/bin/sh

function get_config(){
	while [[ "$*" != "" ]]; do
		eval ${1}='`uci get serverchan.serverchan.$1`' 2>/dev/null
		shift
	done
}

function del_config(){
	while [[ "$*" != "" ]]; do
		eval ${1}='`uci del serverchan.serverchan.$1`' 2>/dev/null
		shift
	done
}

get_config "serverchan_up" "serverchan_down" 
[ -n "$serverchan_up" ] && [ "$serverchan_up" -eq "1" ] && uci add_list serverchan.serverchan.device_notification='online'
[ -n "$serverchan_down" ] && [ "$serverchan_down" -eq "1" ] && uci add_list serverchan.serverchan.device_notification='offline'
del_config "serverchan_up" "serverchan_down"

get_config "cpuload_enable" "temperature_enable"
[ -n "$cpuload_enable" ] && [ "$cpuload_enable" -eq "1" ] && uci add_list serverchan.serverchan.cpu_notification='load'
[ -n "$temperature_enable" ] && [ "$temperature_enable" -eq "1" ] && uci add_list serverchan.serverchan.cpu_notification='temp'
del_config "cpuload_enable" "temperature_enable"

get_config "web_logged" "ssh_logged" "web_login_failed" "ssh_login_failed"
[ -n "$web_logged" ] && [ "$web_logged" -eq "1" ] && uci add_list serverchan.serverchan.login_notification='web_logged'
[ -n "$ssh_logged" ] && [ "$ssh_logged" -eq "1" ] && uci add_list serverchan.serverchan.login_notification='ssh_logged'
[ -n "$web_login_failed" ] && [ "$web_login_failed" -eq "1" ] && uci add_list serverchan.serverchan.login_notification='web_login_failed'
[ -n "$ssh_login_failed" ] && [ "$ssh_login_failed" -eq "1" ] && uci add_list serverchan.serverchan.login_notification='ssh_login_failed'
del_config "web_logged" "ssh_logged" "web_login_failed" "ssh_login_failed"

get_config "regular_time" "regular_time2" "regular_time3"
[ -n "$regular_time" ] && [ "$regular_time" -eq "1" ] && uci add_list serverchan.serverchan.regular_time="$regular_time"
[ -n "$regular_time2" ] && [ "$regular_time2" -eq "1" ] && uci add_list serverchan.serverchan.regular_time="$regular_time2"
[ -n "$regular_time3" ] && [ "$regular_time3" -eq "1" ] && uci add_list serverchan.serverchan.regular_time="$regular_time3"
del_config "regular_time" "regular_time2" "regular_time3"

get_config "router_status" "router_temp" "router_wan" "client_list"
[ -n "$router_status" ] && [ "$router_status" -eq "1" ] && uci add_list serverchan.serverchan.send_notification='router_status'
[ -n "$router_temp" ] && [ "$router_temp" -eq "1" ] && uci add_list serverchan.serverchan.send_notification='router_temp'
[ -n "$router_wan" ] && [ "$router_wan" -eq "1" ] && uci add_list serverchan.serverchan.send_notification='wan_info'
[ -n "$client_list" ] && [ "$client_list" -eq "1" ] && uci add_list serverchan.serverchan.send_notification='client_list'
del_config "router_status" "router_temp" "router_wan" "client_list"

uci commit serverchan
