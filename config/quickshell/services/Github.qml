import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
pragma Singleton

Singleton {
    id: root

    property int contributionNumber: 0
    property string author: Config.settings.misc.githubUsername || ""
    property bool loaded: false
    property var contributions: []

    onAuthorChanged: {
        debounceTimer.restart();
    }
    Component.onCompleted: {
        if (root.author && root.author.length > 0)
            getContributions.running = true;

    }

    Timer {
        id: debounceTimer

        interval: 1000
        repeat: false
        onTriggered: {
            if (root.author && root.author.length > 0) {
                root.loaded = false;
                root.contributions = [];
                root.contributionNumber = 0;
                getContributions.running = true;
            }
        }
    }

    Timer {
        interval: 600000
        running: !!(root.author && root.author.length > 0)
        repeat: true
        onTriggered: {
            if (root.author && root.author.length > 0) {
                root.loaded = false;
                root.contributions = [];
                root.contributionNumber = 0;
                getContributions.running = true;
            }
        }
    }

    Process {
        id: getContributions

        running: false
        command: ["curl", `https://github-contributions-api.jogruber.de/v4/${root.author}`]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const json = JSON.parse(this.text);
                    const oneYearAgo = new Date();
                    oneYearAgo.setDate(oneYearAgo.getDate() - 365);
                    root.contributionNumber = json.contributions.filter((c) => {
                        return new Date(c.date) >= oneYearAgo;
                    }).reduce((sum, c) => {
                        return sum + c.count;
                    }, 0);
                    const allContribs = json.contributions;
                    const today = new Date();
                    const cutoff = new Date(today);
                    cutoff.setDate(cutoff.getDate() - 280);
                    const recentContribs = allContribs.filter((c) => {
                        return new Date(c.date) >= cutoff;
                    }).sort((a, b) => {
                        return new Date(a.date) - new Date(b.date);
                    });
                    root.contributions = recentContribs;
                    root.loaded = true;
                } catch (e) {
                    console.error("Failed to parse GitHub contributions:", e);
                    root.loaded = false;
                }
            }
        }

    }

}
