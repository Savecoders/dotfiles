pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

Singleton {
    id: root

    property int contributionNumber: 0
    property string author: (Config.settings && Config.settings.misc) ? (Config.settings.misc.githubUsername || "") : ""
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
        command: ["curl", "-s", "-L", `https://github-contributions.vercel.app/api/v1/${root.author}`]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    if (!this.text || this.text.trim() === "") {
                        root.loaded = false;
                        return ;
                    }
                    const json = JSON.parse(this.text);
                    if (!json || !Array.isArray(json.contributions)) {
                        console.warn("[Github] Primary API invalid response, trying fallback:", this.text);
                        fallbackProc.running = true;
                        return ;
                    }
                    const oneYearAgo = new Date();
                    oneYearAgo.setDate(oneYearAgo.getDate() - 365);
                    root.contributionNumber = json.contributions.filter((c) => {
                        return c && c.date && new Date(c.date) >= oneYearAgo;
                    }).reduce((sum, c) => {
                        let count = typeof c.count === "number" ? c.count : (parseInt(c.count) || 0);
                        return sum + count;
                    }, 0);
                    const allContribs = json.contributions.map((c) => {
                        let cnt = typeof c.count === "number" ? c.count : (parseInt(c.count) || 0);
                        let lvl = 0;
                        if (c.intensity !== undefined)
                            lvl = parseInt(c.intensity) || 0;
                        else if (cnt > 10)
                            lvl = 3;
                        else if (cnt > 5)
                            lvl = 2;
                        else if (cnt > 0)
                            lvl = 1;
                        return {
                            "date": c.date,
                            "count": cnt,
                            "level": lvl
                        };
                    });
                    const today = new Date();
                    const cutoff = new Date(today);
                    cutoff.setDate(cutoff.getDate() - 280);
                    const recentContribs = allContribs.filter((c) => {
                        return c && c.date && new Date(c.date) >= cutoff;
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

    Process {
        id: fallbackProc

        running: false
        command: ["curl", "-s", "-L", `https://github-contributions-api.jogruber.de/v4/${root.author}`]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const json = JSON.parse(this.text);
                    if (!json || !Array.isArray(json.contributions)) {
                        root.loaded = false;
                        return ;
                    }
                    const oneYearAgo = new Date();
                    oneYearAgo.setDate(oneYearAgo.getDate() - 365);
                    root.contributionNumber = json.contributions.filter((c) => {
                        return c && c.date && new Date(c.date) >= oneYearAgo;
                    }).reduce((sum, c) => {
                        return sum + (c.count || 0);
                    }, 0);
                    const allContribs = json.contributions;
                    const today = new Date();
                    const cutoff = new Date(today);
                    cutoff.setDate(cutoff.getDate() - 280);
                    const recentContribs = allContribs.filter((c) => {
                        return c && c.date && new Date(c.date) >= cutoff;
                    }).sort((a, b) => {
                        return new Date(a.date) - new Date(b.date);
                    });
                    root.contributions = recentContribs;
                    root.loaded = true;
                } catch (e) {
                    root.loaded = false;
                }
            }
        }

    }

}
