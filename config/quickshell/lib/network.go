package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"
)

type NetworkInfo struct {
	State    string `json:"state"`
	Type     string `json:"type"`
	Name     string `json:"name"`
	Strength int    `json:"strength"`
	Icon     string `json:"icon"`
}

func getConnectivity() string {
	out, err := exec.Command("nmcli", "networking").Output()
	if err != nil {
		return "off"
	}
	res := strings.TrimSpace(string(out))
	if res == "enabled" {
		return "on"
	}
	return "off"
}

func getWifiSignal() int {
	out, err := exec.Command("nmcli", "-t", "-f", "IN-USE,SIGNAL", "device", "wifi", "list", "--rescan", "no").Output()
	if err != nil {
		return 80
	}
	lines := strings.Split(strings.TrimSpace(string(out)), "\n")
	for _, line := range lines {
		if strings.HasPrefix(line, "*:") {
			parts := strings.Split(line, ":")
			if len(parts) >= 2 {
				s, err := strconv.Atoi(strings.TrimSpace(parts[1]))
				if err == nil {
					return s
				}
			}
		}
	}
	return 80
}

func getNetworkInfo() NetworkInfo {
	conn := getConnectivity()
	if conn == "off" {
		return NetworkInfo{
			State:    "off",
			Type:     "none",
			Name:     "Network Off",
			Strength: 0,
			Icon:     "signal_wifi_bad",
		}
	}

	out, err := exec.Command("nmcli", "-t", "-f", "NAME,TYPE,DEVICE,STATE", "connection", "show", "--active").Output()
	if err != nil {
		return NetworkInfo{
			State:    "disconnected",
			Type:     "none",
			Name:     "Disconnected",
			Strength: 0,
			Icon:     "signal_wifi_statusbar_not_connected",
		}
	}

	lines := strings.Split(strings.TrimSpace(string(out)), "\n")
	var vpnInfo NetworkInfo
	hasVpn := false

	for _, line := range lines {
		parts := strings.Split(line, ":")
		if len(parts) >= 3 {
			name, connType, dev := parts[0], parts[1], parts[2]
			if dev == "lo" || dev == "" || name == "" {
				continue
			}

			if connType == "802-3-ethernet" {
				return NetworkInfo{
					State:    "connected",
					Type:     "ethernet",
					Name:     name,
					Strength: 100,
					Icon:     "lan",
				}
			} else if connType == "802-11-wireless" {
				strength := getWifiSignal()
				icon := "network_wifi"
				if strength <= 25 {
					icon = "network_wifi_1_bar"
				} else if strength <= 50 {
					icon = "network_wifi_2_bar"
				} else if strength <= 75 {
					icon = "network_wifi_3_bar"
				}
				return NetworkInfo{
					State:    "connected",
					Type:     "wifi",
					Name:     name,
					Strength: strength,
					Icon:     icon,
				}
			} else if connType == "tun" || connType == "wireguard" || strings.Contains(connType, "vpn") {
				vpnInfo = NetworkInfo{
					State:    "connected",
					Type:     "vpn",
					Name:     name,
					Strength: 100,
					Icon:     "vpn_lock",
				}
				hasVpn = true
			}
		}
	}

	if hasVpn {
		return vpnInfo
	}

	return NetworkInfo{
		State:    "disconnected",
		Type:     "none",
		Name:     "Disconnected",
		Strength: 0,
		Icon:     "signal_wifi_statusbar_not_connected",
	}
}

func toggleNetwork() {
	conn := getConnectivity()
	if conn == "on" {
		exec.Command("nmcli", "networking", "off").Run()
	} else {
		exec.Command("nmcli", "networking", "on").Run()
	}
}

func main() {
	if len(os.Args) > 1 {
		switch os.Args[1] {
		case "--info":
			info := getNetworkInfo()
			b, _ := json.Marshal(info)
			fmt.Println(string(b))
			return
		case "--watch":
			for {
				info := getNetworkInfo()
				b, _ := json.Marshal(info)
				fmt.Println(string(b))
				time.Sleep(12 * time.Second)
			}
		}
	}

	toggleNetwork()
}
