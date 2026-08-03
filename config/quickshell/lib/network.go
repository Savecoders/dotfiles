package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func getConnectivity() string {
	out, err := exec.Command("nmcli", "networking", "connectivity").Output()
	if err != nil {
		return "off"
	}
	res := strings.TrimSpace(string(out))
	if res == "full" || res == "limited" {
		return "on"
	}
	return "off"
}

func getActiveConnection() string {
	out, err := exec.Command("nmcli", "-t", "-f", "NAME,TYPE,DEVICE", "connection", "show", "--active").Output()
	if err != nil {
		return "Disconnected"
	}
	lines := strings.Split(strings.TrimSpace(string(out)), "\n")
	for _, line := range lines {
		parts := strings.Split(line, ":")
		if len(parts) >= 3 {
			name, _, dev := parts[0], parts[1], parts[2]
			if dev != "lo" && dev != "" {
				return name
			}
		}
	}
	return "Disconnected"
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
	if len(os.Args) > 1 && os.Args[1] == "--info" {
		conn := getConnectivity()
		if conn == "off" {
			fmt.Println("Network Off")
			return
		}
		active := getActiveConnection()
		fmt.Println(active)
		return
	}

	toggleNetwork()
}
