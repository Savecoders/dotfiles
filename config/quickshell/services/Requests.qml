pragma Singleton
import qs.core
import Quickshell

Singleton {
    id: root

    function get(url, callback) {
        const xhr = new XMLHttpRequest();
        const cleanup = () => {
            xhr.abort();
            xhr.onreadystatechange = null;
            xhr.onerror = null;
        };
        xhr.open("GET", url, true);
        xhr.onreadystatechange = () => {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 && xhr.responseText !== undefined)
                    callback(xhr.responseText);
                else
                    console.warn(`[REQUESTS] GET request to ${url} failed with status ${xhr.status}`);
                cleanup();
            }
        };
        xhr.onerror = () => {
            console.warn(`[REQUESTS] GET request to ${url} failed`);
            cleanup();
        };
        xhr.send();
    }

}
