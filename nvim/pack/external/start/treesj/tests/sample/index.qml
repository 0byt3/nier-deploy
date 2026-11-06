import QtQuick

Item {
    id: root

    // RESULT OF JOIN (node "ui_object_initializer")
    Item { id: container; width: 200; height: 200 }

    // RESULT OF SPLIT (node "ui_object_initializer")
    Item {
        id: container
        width: 200
        height: 200
    }

    // RESULT OF JOIN (node "array")
    property var colors: [ "red", "green", "blue" ]

    // RESULT OF SPLIT (node "array")
    property var colors: [
    "red",
    "green",
    "blue",
    ]

    // RESULT OF JOIN (node "function_declaration")
    function calc( x: int, y: int ): int { return x + y; }

    // RESULT OF SPLIT (node "function_declaration")
    function calc( x: int, y: int ): int {
        return x + y
    }

    // RESULT OF JOIN (node "statement_block")
    function checkStatus (x:string) { if (x == "ok") { return true; } else { return false; }; }

    // RESULT OF SPLIT (node "statement_block")
    function checkStatus (x:string) {
        if (x == "ok") {
            return true
        } else {
            return false
        }
    }

    // RESULT OF JOIN (node "statement_block") more complicated
    MouseArea { id: mouseArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { rect.isExpanded = !rect.isExpanded; if (rect.isExpanded) { rect.x = root.width - rect.width; } else { rect.x = 0; rect.y = 0; }; rect.y = root.height - rect.height; } }

    // RESULT OF SPLIT (node "statement_block") more complicated
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            rect.isExpanded = !rect.isExpanded
            if (rect.isExpanded) {
                rect.x = root.width - rect.width
            } else {
                rect.x = 0
                rect.y = 0
            }
            rect.y = root.height - rect.height
        }
    }
}
