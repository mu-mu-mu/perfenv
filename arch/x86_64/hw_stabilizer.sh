#!/bin/bash
set -eu

disable_turbo_boost() {
	if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
		echo "Disabling Turbo Boost..."
		echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
	else
		echo "Turbo Boost setting not found."
	fi
}

disable_hyper_threading() {
	if [ -f /sys/devices/system/cpu/smt/control ]; then
		echo "Disabling Hyper-Threading..."
		echo off | sudo tee /sys/devices/system/cpu/smt/control
	else
		echo "Hyper-Threading control not found."
	fi
}

set_performance_governor() {
	echo "Setting CPU governor to performance..."
	for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
		if [ -f "$cpu/online" ]; then
			online=$(cat "$cpu/online")
			if [ "$online" -eq 1 ]; then
				sudo cpufreq-set -c ${cpu##*/cpu} -g performance
			fi
		else
			# cpu0 may not have /online
			sudo cpufreq-set -c ${cpu##*/cpu} -g performance
		fi
	done
}

disable_turbo_boost
disable_hyper_threading
set_performance_governor
