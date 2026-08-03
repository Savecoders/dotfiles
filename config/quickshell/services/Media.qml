pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.core

Singleton {
    id: root

    readonly property var availablePlayers: {
        const players = Mpris.players.values;
        return players.filter((p) => {
            return isRealPlayer(p);
        });
    }
    property MprisPlayer activePlayer: pickBestPlayer(availablePlayers)
    // Stable metadata properties to prevent UI flickering during fast track changes
    property string stableTitle: ""
    property string stableArtist: ""
    property string stableArtUrl: ""
    readonly property bool isPlaying: activePlayer ? activePlayer.isPlaying : false

    function isRealPlayer(p) {
        if (!p || !p.dbusName)
            return false;

        return (!p.dbusName.startsWith('org.mpris.MediaPlayer2.playerctld') && !(p.dbusName.endsWith('.mpd') && !p.dbusName.endsWith('MediaPlayer2.mpd')));
    }

    function pickBestPlayer(players) {
        if (!players || players.length === 0)
            return null;

        let playing = players.find((p) => {
            return p.isPlaying && p.trackTitle && p.trackTitle !== "";
        });
        if (playing)
            return playing;

        let active = players.find((p) => {
            return p.trackTitle && p.trackTitle !== "";
        });
        if (active)
            return active;

        return players[0];
    }

    function getArtUrl(url) {
        if (!url)
            return "";

        let str = url.toString();
        if (str.startsWith("file://") || str.startsWith("http://") || str.startsWith("https://"))
            return str;

        if (str.startsWith("/"))
            return "file://" + str;

        return str;
    }

    function cleanTitle(title) {
        if (!title)
            return "";

        let str = title.toString();
        str = str.replace(/^ *\([^)]*\) */g, " ");
        str = str.replace(/^ *\[[^\]]*\] */g, " ");
        str = str.replace(/^ *\{[^\}]*\} */g, " ");
        str = str.replace(/^ *【[^】]*】/, "");
        str = str.replace(/^ *《[^》]*》/, "");
        str = str.replace(/^ *「[^」]*」/, "");
        str = str.replace(/^ *『[^』]*』/, "");
        return str.trim();
    }

    function syncMetadata() {
        const p = activePlayer;
        if (!p) {
            idleTimer.restart();
            return ;
        }
        idleTimer.stop();
        if (p.trackTitle && p.trackTitle !== "")
            stableTitle = cleanTitle(p.trackTitle);

        if (p.trackArtist && p.trackArtist !== "")
            stableArtist = cleanTitle(p.trackArtist);

        let art = p.trackArtUrl ? getArtUrl(p.trackArtUrl) : "";
        if (art && art !== "")
            stableArtUrl = art;

    }

    onAvailablePlayersChanged: {
        let best = pickBestPlayer(availablePlayers);
        if (best !== activePlayer)
            activePlayer = best;

    }
    onActivePlayerChanged: {
        syncMetadata();
    }
    Component.onCompleted: {
        syncMetadata();
    }

    Connections {
        function onTrackTitleChanged() {
            root.syncMetadata();
        }

        function onTrackArtistChanged() {
            root.syncMetadata();
        }

        function onTrackArtUrlChanged() {
            root.syncMetadata();
        }

        function onPlaybackStateChanged() {
            let best = root.pickBestPlayer(root.availablePlayers);
            if (best && best !== root.activePlayer)
                root.activePlayer = best;

            root.syncMetadata();
        }

        target: root.activePlayer
    }

    // Grace timer before clearing metadata when media actually stops
    Timer {
        id: idleTimer

        interval: 1200
        repeat: false
        onTriggered: {
            if (!root.activePlayer) {
                root.stableTitle = "";
                root.stableArtist = "";
                root.stableArtUrl = "";
            }
        }
    }

}
