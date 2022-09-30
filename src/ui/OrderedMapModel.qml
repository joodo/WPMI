import QtQuick

ListModelWrapper {
    enum OffsetType {
        Relative,
        Absolute
    }

    property var _keyIndex: new Map()

    // Set key to value. If ket exists, it'll be moved to the tail of list
    function append(key, value) {
        if (!value) return;
        value.modelKey = key;

        if (_keyIndex.has(key)) {
            move(key, -1, OrderedMapModel.Absolute);
            set(key, value);
            _keyIndex.set(key, count);
        } else {
            append(value);
            _keyIndex.set(key, count);
        }
    }

    function get(key) {
        if (!_keyIndex.has(key)) return undefined;
        return get_p(_keyIndex.get(key));
    }

    // insert key, value at position
    function insert(position, key, value) {
        if (!value) return;
        value.modelKey = key;

        if (_keyIndex.has(key)) {
            move(key, -1, OrderedMapModel.Absolute);
            set(key, value);
        } else {
            _keyIndex.set(key, count);
            append(value);
        }
    }
}
