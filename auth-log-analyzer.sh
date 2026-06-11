#!/bin/bash

# =====================================================================
# Script Name : auth-log-analyzer.sh
# Description : Linux Authentication Log Analyzer
# =====================================================================

# Global Variables (Will be dynamically updated in main)
LOG_FILES="/var/log/auth.log"
TOP_COUNT=100
HAS_ZGREP="FALSE"

# =====================================================================
# Utility Functions
# =====================================================================

print_header() {
	# Cyan color wrapper (\033[1;36m) for dynamic and prominent audit borders
	echo -e "\033[1;36m================================================================================"
	echo "  $1"
	echo -e "================================================================================\033[0m"
}

check_privileges() {
	# Privilege Check (Must be run with sudo/root to read auth logs)
	if [ "$(id -u)" -ne 0 ]; then
		echo "ERROR: This script must be run with sudo or as root privilege!"
		echo "Please try again using: sudo $(basename "$0")"
		exit 1
	fi
}

detect_environment() {
	# Environment Detection: Check if zgrep utility is available
	if command -v zgrep >/dev/null 2>&1; then
		HAS_ZGREP="TRUE"
		LOG_FILES="/var/log/auth.log*"
		echo -e '\033[1;32m[+] Advanced environment: zgrep detected. Auditing both live and compressed historical archives (*.gz).\033[0m'
	else
		HAS_ZGREP="FALSE"
		LOG_FILES="/var/log/auth.log"
		echo -e '\033[1;33m[!] Legacy environment: zgrep missing. Auditing live active log files ONLY (Skipping compressed archives).\033[0m'
	fi
	echo ""
}

safe_grep() {
	# Fail-Safe Search Wrapper: Divert traffic dynamically between zgrep and standard grep
	if [ "$HAS_ZGREP" = "TRUE" ]; then
		zgrep "$@"
	else
		grep "$@"
	fi
}

# =====================================================================
# Core Forensic Audit Functions
# =====================================================================

audit_failed_accounts() {
	# Failed password - Top Accounts
	print_header "Failed password - Top Target Accounts (Top $TOP_COUNT)"
	safe_grep "Failed password" $LOG_FILES 2>/dev/null | awk -F' ' '{
		for(i=1; i<=NF; i++) {
			if($i=="for" && $(i+1) != "invalid") { print $(i+1); break; }
			if($i=="for" && $(i+1) == "invalid") { print $(i+3); break; }
		}
	}' | grep -v '^$' | sort | uniq -c | sort -nr | head -n $TOP_COUNT
	echo ""
}

audit_invalid_accounts() {
	# Invalid user - Top Accounts
	print_header "Invalid user - Top Target Accounts (Top $TOP_COUNT)"
	safe_grep "Invalid user" $LOG_FILES 2>/dev/null | awk -F' ' '{
		for(i=1; i<=NF; i++) {
			if($i=="user") { print $(i+1); break; }
		}
	}' | grep -v '^$' | sort | uniq -c | sort -nr | head -n $TOP_COUNT
	echo ""
}

audit_failed_ips() {
	# Failed password - Top IPs
	print_header "Failed password - Top Source IPs (Top $TOP_COUNT)"
	safe_grep "Failed password" $LOG_FILES 2>/dev/null | awk -F' ' '{
		for(i=1; i<=NF; i++) {
			if($i=="from") { print $(i+1); break; }
		}
	}' | grep -v '^$' | sort | uniq -c | sort -nr | head -n $TOP_COUNT
	echo ""
}

audit_top_ip_targets() {
	# Target Accounts Attacked by Top Aggressive IPs
	print_header "Target Accounts Attacked by Top Aggressive IPs"
	
	# POSIX Compliance FIX: Separate variable declaration and assignment for legacy shell compatibility
	local TOP_IPS
	TOP_IPS=$(safe_grep "Failed password" $LOG_FILES 2>/dev/null | awk -F' ' '{
		for(i=1; i<=NF; i++) { if($i=="from") { print $(i+1); break; } }
	}' | grep -v '^$' | sort | uniq -c | sort -nr | head -n 2 | awk '{print $2}')

	# Step 2: Loop through each top IP and profile its targeted accounts
	for target_ip in $TOP_IPS; do
		echo "[+] Investigating Targeted Accounts from IP: [$target_ip]"
		echo "--------------------------------------------------"

		safe_grep "Failed password" $LOG_FILES 2>/dev/null | grep "$target_ip" | awk -F' ' '{
			for(i=1; i<=NF; i++) {
				if($i=="for" && $(i+1) != "invalid") { print "  Account: [" $(i+1) "]"; break; }
				if($i=="for" && $(i+1) == "invalid") { print "  Account: [" $(i+3) "] (Invalid/Non-existent)"; break; }
			}
		}' | sort | uniq -c | sort -nr | head -n 10
		echo ""
	done
}

audit_hourly_distribution() {
	# Hourly Distribution of Attacks
	print_header "Hourly Distribution of Attacks (00:00 - 23:59)"
	safe_grep -E "Failed password|Invalid user" $LOG_FILES 2>/dev/null | awk '{
		if ($1 ~ /^[0-9]{4}-/) { split($1, a, "T"); split(a[2], b, ":"); print b[1] }
		else { split($3, a, ":"); print a[1] }
	}' | sort | uniq -c | sort -n
	echo ""
}

audit_daily_distribution() {
	# Daily Distribution of Attacks
	print_header "Daily Distribution of Attacks (Top Timeline)"
	safe_grep -E "Failed password|Invalid user" $LOG_FILES 2>/dev/null | awk '{
		if ($1 ~ /^[0-9]{4}-/) { split($1, a, "T"); print a[1] }
		else { print $1" "$2 }
	}' | sort | uniq -c | sort -nr | head -n 30
	echo ""
}

audit_successful_logins() {
	# Successful Logins Audit
	print_header "Successful Logins Audit (Accepted Connections Timeline)"

	# MINIMAL FIX: Filter specifically for 'sshd' to exclude local auth noise (polkit/su)
	safe_grep "sshd" $LOG_FILES 2>/dev/null | grep "Accepted" | awk -F' ' '{
		user="UNKNOWN"; ip="UNKNOWN";
		for(i=1; i<=NF; i++) {
			# Handle standard users vs invalid users dynamically
			if($i=="for") { 
				if($(i+1) == "invalid" && $(i+2) == "user") {
					user=$(i+3);
				} else {
					user=$(i+1); 
				}
			}
			if($i=="from") { ip=$(i+1); }
		}
		if ($1 ~ /^[0-9]{4}-/) { split($1, a, "T"); dt=a[1]" "substr(a[2],1,8) }
		else { dt=$1" "$2" "$3 }

		# Only print if we captured a valid user, or print unparsed lines for visibility
		print dt " - User: [" user "] | From IP: [" ip "]"
	}' | sort -r | head -n $TOP_COUNT
	echo ""
}

audit_sudo_escalation() {
	# Sudo Privilege Escalation Audit
	print_header "Sudo Privilege Escalation Audit (Activity Log)"
	safe_grep "sudo:" $LOG_FILES 2>/dev/null | grep -E "COMMAND=|session opened" | awk '{
		if ($1 ~ /^[0-9]{4}-/) { split($1, a, "T"); dt=a[1]" "substr(a[2],1,8) }
		else { dt=$1" "$2" "$3 }

		idx=1;
		for(i=1; i<=NF; i++) {
			if($i ~ /sudo:/ || $i ~ /sudo\[/) { idx=i+1; break; }
		}

		out=""; for(i=idx; i<=NF; i++) out=out$i" ";
		print dt " - " out
	}' | sort -r | head -n $TOP_COUNT
	echo ""
}

audit_fail2ban_status() {
	# Current Fail2ban Defense Status
	print_header "Current Fail2ban Defense Status"
	if command -v fail2ban-client >/dev/null 2>&1; then
		fail2ban-client status sshd 2>/dev/null || echo "Fail2ban daemon is installed but not running."
	else
		echo "Fail2ban command not found or not running."
	fi
	echo ""
}

# =====================================================================
# Main Pipeline Orchestrator
# =====================================================================

main() {
	# Enforce root privileges
	check_privileges

	# Inspect runtime capabilities (zgrep check and dynamic file registration)
	detect_environment

	# Execute independent forensic audit modules sequentially
	audit_failed_accounts
	audit_invalid_accounts
	audit_failed_ips
	audit_top_ip_targets
	audit_hourly_distribution
	audit_daily_distribution
	audit_successful_logins
	audit_sudo_escalation
	audit_fail2ban_status
}

# Execute main pipeline
main "$@"
