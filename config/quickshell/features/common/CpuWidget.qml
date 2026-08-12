import QtQuick
import qs.core
import qs.services

ResourceWidget {
    tooltipText: "CPU Load: " + (Cpu.usage ?? 0) + "%"
    progressValue: (Cpu.usage ?? 0) / 100
    iconName: "developer_board"
    labelText: (Cpu.usage ?? 0) + "%"
    fgColor: Colours.palette.primary
}
