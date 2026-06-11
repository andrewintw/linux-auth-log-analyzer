#!/bin/sh

LOG_FILES="/var/log/auth.log*"
TOP_COUNT=100

# Privilege Check (Must be run with sudo/root)
if [ "$(id -u)" -ne 0 ]; then
	echo "ERROR: This script must be run with sudo or as root privilege!"
	echo "Please try again using: sudo $0"
	exit 1
fi

print_header() {
	echo "================================================================================"
	echo "  $1"
	echo "================================================================================"
}

# 1. Failed password - Top Accounts
print_header "1. Failed password - Top Accounts (Top $TOP_COUNT)"
zgrep "Failed password" $LOG_FILES | awk -F' ' '{
	for(i=1; i<=NF; i++) {
		if($i=="for" && $(i+1) != "invalid") { print $(i+1); break; }
		if($i=="for" && $(i+1) == "invalid") { print $(i+3); break; }
	}
}' | grep -v '^$' | sort | uniq -c | sort -nr | head -n $TOP_COUNT
echo ""

# 2. Invalid user - Top Accounts
print_header "2. Invalid user - Top Accounts (Top $TOP_COUNT)"
zgrep "Invalid user" $LOG_FILES | awk -F' ' '{
	for(i=1; i<=NF; i++) {
		if($i=="user") { print $(i+1); break; }
	}
}' | grep -v '^$' | sort | uniq -c | sort -nr | head -n $TOP_COUNT
echo ""

# 3. Failed password - Top IPs
print_header "3. Failed password - Top IPs (Top $TOP_COUNT)"
zgrep "Failed password" $LOG_FILES | awk -F' ' '{
	for(i=1; i<=NF; i++) {
		if($i=="from") { print $(i+1); break; }
	}
}' | grep -v '^$' | sort | uniq -c | sort -nr | head -n $TOP_COUNT
echo ""

# 4. Invalid user - Top IPs
print_header "4. Invalid user - Top IPs (Top $TOP_COUNT)"
zgrep "Invalid user" $LOG_FILES | awk -F' ' '{
	for(i=1; i<=NF; i++) {
		if($i=="from") { print $(i+1); break; }
	}
}' | grep -v '^$' | sort | uniq -c | sort -nr | head -n $TOP_COUNT
echo ""

# 5. Hourly Distribution of Attacks
print_header "5. Hourly Distribution of Attacks (00:00 - 23:59)"
zgrep -E "Failed password|Invalid user" $LOG_FILES | awk '{print $3}' | cut -d: -f1 | sort | uniq -c | sort -n
echo ""

# 6. Daily Distribution of Attacks
print_header "6. Daily Distribution of Attacks (Top Timeline)"
zgrep -E "Failed password|Invalid user" $LOG_FILES | awk '{print $1" "$2}' | sort | uniq -c | sort -nr | head -n 30
echo ""

# 7. Successful Logins Audit
print_header "7. Successful Logins Audit (Security Verification)"
#zgrep "Accepted" $LOG_FILES | awk -F' ' '{
#	user="UNKNOWN"; ip="UNKNOWN";
#	for(i=1; i<=NF; i++) {
#		if($i=="for")  { user=$(i+1); }
#		if($i=="from") { ip=$(i+1); }
#	}
#	# Print date, time, user, and source IP
#	print $1" "$2" "$3" - User: "user" | IP: "ip;
#}' | sort -r
#echo ""

zgrep "Accepted" /var/log/auth.log* | awk -F' ' '{
	for(i=1; i<=NF; i++) {
		if($i=="from") { print $(i+1); break; }
	}
}' | sort | uniq -c | sort -nr

# 8. Current Fail2ban Defense Status
print_header "8. Current Fail2ban Defense Status"
if command -v fail2ban-client >/dev/null 2>&1; then
	fail2ban-client status sshd
else
	echo "Fail2ban command not found or not running."
fi
echo ""
