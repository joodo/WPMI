import WPMI.impl

HttpRequestImpl {
    id: root

    function get(url) {
        return _sendWrapper(url, "GET");
    }

    function _sendWrapper(url, method) {
        if (url) {
            let urlObject
            try {
                urlObject = new URL(url)
            } catch (err) {
                const oldUrlObject = new URL(root.url)
                urlObject = new URL(url, oldUrlObject.origin)
            }

            root.url = urlObject
        }

        send(method);

        return new Promise((resolve, reject) => {
                               root.finished.connect(data => resolve(data));
                               root.errored.connect(err => reject(err));
                           });
    }
}
