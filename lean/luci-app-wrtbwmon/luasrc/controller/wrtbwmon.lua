module("luci.controller.wrtbwmon", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/wrtbwmon") then
		return
	end

	entry({"admin", "nlbw", "usage"}, alias("admin", "nlbw", "usage", "details"), _("实时流量统计"), 60)
	entry({"admin", "nlbw", "usage", "details"}, template("wrtbwmon/wrtbwmon"), _("详细信息"), 10).leaf = true
	entry({"admin", "nlbw", "usage", "config"}, cbi("wrtbwmon/config"), _("配置"), 20).leaf = true
	entry({"admin", "nlbw", "usage", "custom"}, form("wrtbwmon/custom"), _("自定义主机信息"), 30).leaf = true
	entry({"admin", "nlbw", "usage", "check_dependency"}, call("check_dependency")).dependent = true
	entry({"admin", "nlbw", "usage", "usage_data"}, call("usage_data")).dependent = true
	entry({"admin", "nlbw", "usage", "usage_reset"}, call("usage_reset")).dependent = true
end

function usage_database_path()
	local cursor = luci.model.uci.cursor()
	if cursor:get("wrtbwmon", "general", "persist") == "1" then
        	return "/etc/config/usage.db"
	else
        	return "/tmp/usage.db"
	end
end

function check_dependency()
	local ret = "0"
	local status, ipkg = pcall(require, "luci.model.ipkg")
	if not status or ipkg.installed('wrtbwmon') then
        	ret = "1"
	end
	luci.http.prepare_content("text/plain")
	luci.http.write(ret)
end

function usage_data()
	local db = usage_database_path()
	local publish_cmd = "wrtbwmon publish " .. db .. " /tmp/usage.htm /etc/config/wrtbwmon.user"
 	local cmd = "wrtbwmon update " .. db .. " && " .. publish_cmd .. " && cat /tmp/usage.htm"
	luci.http.prepare_content("text/html")
	luci.http.write(luci.sys.exec(cmd))
end

function usage_reset()
	local db = usage_database_path()
	local ret = luci.sys.call("wrtbwmon update " .. db .. " && rm " .. db)
	luci.http.status(204)
end
