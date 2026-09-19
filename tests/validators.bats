#!/usr/bin/env bats
# tests/validators.bats - lib/core.sh input validators. All pure and silent,
# so they are exercised directly with no network or tool invocation.

load 'test_helper'

setup() {
    load_libs
}

# --- fys_is_port ------------------------------------------------------------

@test "is_port: accepts 1, 80 and 65535" {
    fys_is_port 1
    fys_is_port 80
    fys_is_port 65535
}

@test "is_port: rejects 0, 65536, empty and non-numeric" {
    ! fys_is_port 0
    ! fys_is_port 65536
    ! fys_is_port ""
    ! fys_is_port 80a
    ! fys_is_port -1
}

# --- fys_is_port_spec -------------------------------------------------------

@test "is_port_spec: accepts single, range and comma lists" {
    fys_is_port_spec 80
    fys_is_port_spec 1-1000
    fys_is_port_spec 22,80,443
    fys_is_port_spec 1-100,443,8000-8100
}

@test "is_port_spec: rejects empty, trailing comma and letters" {
    ! fys_is_port_spec ""
    ! fys_is_port_spec 80,
    ! fys_is_port_spec 1--2
    ! fys_is_port_spec 80:443
}

# --- fys_is_ipv4 ------------------------------------------------------------

@test "is_ipv4: accepts valid dotted quads" {
    fys_is_ipv4 0.0.0.0
    fys_is_ipv4 192.168.1.1
    fys_is_ipv4 255.255.255.255
}

@test "is_ipv4: rejects out-of-range octets and malformed input" {
    ! fys_is_ipv4 256.0.0.1
    ! fys_is_ipv4 1.2.3
    ! fys_is_ipv4 1.2.3.4.5
    ! fys_is_ipv4 10.0.0.
    ! fys_is_ipv4 ""
}

# --- fys_is_hostname --------------------------------------------------------

@test "is_hostname: accepts fqdns and single labels" {
    fys_is_hostname example.com
    fys_is_hostname sub.example.co.uk
    fys_is_hostname localhost
    fys_is_hostname a-b.example.com
}

@test "is_hostname: rejects leading hyphen, empty label and spaces" {
    ! fys_is_hostname -bad.example.com
    ! fys_is_hostname example..com
    ! fys_is_hostname "bad host"
    ! fys_is_hostname ""
}

# --- fys_is_host / cidr / host_or_cidr --------------------------------------

@test "is_host: accepts either an IPv4 or a hostname" {
    fys_is_host 10.0.0.1
    fys_is_host scanme.example.org
}

@test "is_cidr: accepts valid ranges, rejects bad prefixes and bare IPs" {
    fys_is_cidr 192.168.1.0/24
    fys_is_cidr 10.0.0.0/8
    ! fys_is_cidr 192.168.1.0/33
    ! fys_is_cidr 10.0.0.1
    ! fys_is_cidr 10.0.0.0/
}

@test "is_host_or_cidr: accepts host and cidr, rejects garbage" {
    fys_is_host_or_cidr 192.168.1.1
    fys_is_host_or_cidr 192.168.1.0/24
    fys_is_host_or_cidr example.com
    ! fys_is_host_or_cidr "not a target"
}

# --- detect_package_manager -------------------------------------------------

@test "detect_package_manager: returns a known token" {
    run detect_package_manager
    [[ "$output" =~ ^(apt|dnf|yum|pacman|zypper|apk|brew|unknown)$ ]]
}
