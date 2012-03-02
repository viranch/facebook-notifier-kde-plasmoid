import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents

Item {
    id: notifier
    property int minimumWidth: 290
    property int minimumHeight: 340
    property string feedUrl: ""
    property int update_interval: 1 //in minutes

    PlasmaCore.DataSource {
        id: fbSource
        engine: "rss"
        interval: update_interval*60000
        onSourceAdded: plasmoid.busy = true;
        property string lastItem
        onNewData: {
            var title = data["title"];
            if (title!="") titleLabel.text = title;
            plasmoid.busy = false;
            var newItem = data["items"][0]["title"];
            if (newItem!=lastItem) {
                lastItem = newItem;
                plasmoid.showPopup(7500);
            }
        }
    }

    Component.onCompleted: {
        plasmoid.addEventListener('ConfigChanged', configChanged);
        titleLabel.text = "No feed available";
    }

    function configChanged() {
        feedUrl = plasmoid.readConfig("feed");
        if (feedUrl!="") {
            titleLabel.text = "Fetching notifications...";
            fbSource.connectedSources = [feedUrl];
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: 0
        hoverEnabled: true
        onEntered: view.highlightItem.opacity = 0;
        onExited: view.highlightItem.opacity = 0;
    }

    PlasmaComponents.Label {
        id: titleLabel
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        clip: true

        MouseArea {
            anchors.fill: parent
            onClicked: plasmoid.openUrl("http://www.facebook.com/")
        }
    }

    PlasmaCore.Svg {
        id: lineSvg
        imagePath: "widgets/line"
    }
    PlasmaCore.SvgItem {
        id: sep
        svg: lineSvg
        elementId: "horizontal-line"
        anchors {
            top: titleLabel.bottom
            left: parent.left
            right: parent.right
        }
        height: lineSvg.elementSize("horizontal-line").height
    }

    ListView {
        id: view
        anchors {
            top: sep.bottom
            topMargin: 5
            left: parent.left
            right: scrollBar.visible ? scrollBar.left : parent.right
            rightMargin: 5
            bottom: parent.bottom
            bottomMargin: 5
        }
        model: PlasmaCore.DataModel {
            dataSource: fbSource
            keyRoleFilter: "items"
        }
        spacing: -8
        clip: true

        delegate: Notification {
            width: view.width
            icon: model["icon"]
            text: model["description"]
            link: model["link"]
        }

        highlight: PlasmaCore.FrameSvgItem {
            imagePath: "widgets/viewitem"
            prefix: "hover"
            opacity: 0
            Behavior on opacity { NumberAnimation { duration: 250 } }
        }
    }

    PlasmaComponents.ScrollBar {
        id: scrollBar
        flickableItem: view
        anchors {
            right: parent.right
            top: flickableItem.top
            bottom: flickableItem.bottom
        }
    }
}

