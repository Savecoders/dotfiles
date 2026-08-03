pragma Singleton
import "root:/lib/fuzzysort.js" as Fuzzy
import Quickshell

Singleton {
    id: root

    readonly property var list: DesktopEntries.applications.values.filter((a) => {
        return !a.noDisplay;
    }).sort((a, b) => {
        return a.name.localeCompare(b.name);
    })
    readonly property var preppedApps: list.map((a) => {
        return ({
            "name": Fuzzy.prepare(a.name),
            "comment": Fuzzy.prepare(a.comment),
            "entry": a
        });
    })

    function fuzzyQuery(search) {
        return Fuzzy.go(search, preppedApps, {
            "all": true,
            "keys": ["name", "comment"],
            "scoreFn": (r) => {
                return r[0].score > 0 ? r[0].score * 0.9 + r[1].score * 0.1 : 0;
            }
        }).map((r) => {
            return r.obj.entry;
        });
    }

    function launch(entry) {
        if (entry.execString.startsWith("sh -c"))
            Quickshell.execDetached(["sh", "-c", `app2unit -- ${entry.execString}`]);
        else
            Quickshell.execDetached(["sh", "-c", `app2unit -- '${entry.id}.desktop' || app2unit -- ${entry.execString}`]);
    }

}
