import QtQuick

ListModel {
    function append_p(dict) { return append(dict) }
    function get_p(index) { return get(index) }
    function insert_p(index, dict) { return insert(index, dict) }
    function move_p(from, to, n) { return move(from, to, n) }
    function remove_p(index, count) { return remove(index, count) }
    function set_p(index, dict) { return set(index, dict) }
    function setProperty_p(index, prop, value) { return setProperty(index, prop, value) }
}
