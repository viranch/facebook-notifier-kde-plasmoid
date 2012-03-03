import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents

Item {
    id: notifier
    property int minimumWidth: 290
    property int minimumHeight: 340
    property string feedUrl: ""
    property bool showTimeStamps: false
    property int update_interval: 1 //in minutes

    PlasmaCore.DataSource {
        id: fbSource
        engine: "rss"
        interval: update_interval*60000
        property int lastTime
        onNewData: {
            var title = data["title"];
            if (title!="") titleLabel.text = title;
            plasmoid.busy = false;
            var time = data["items"][0]["time"];
            if (time>lastTime) {
                lastTime = time;
                plasmoid.showPopup(7500);
            }
        }
    }

    Component.onCompleted: {
        plasmoid.addEventListener('ConfigChanged', configChanged);
        titleLabel.text = "No feed available";
    }

    function configChanged() {
        var url = plasmoid.readConfig("feed");
        showTimeStamps = plasmoid.readConfig("time_stamps");
        update_interval = plasmoid.readConfig("interval");
        if (url!="" && url!=feedUrl) {
            feedUrl = url;
            plasmoid.busy = true;
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

    PlasmaCore.Theme { id: theme }

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
        clip: true

        delegate: Notification {
            width: view.width
            icon: model["icon"]
            text: model["description"]
            link: model["link"]
        }

        section {
            property: "time"
            delegate: showTimeStamps ? sectionDelegate : empty
        }

        highlight: PlasmaCore.FrameSvgItem {
            imagePath: "widgets/viewitem"
            prefix: "hover"
            opacity: 0
            Behavior on opacity { NumberAnimation { duration: 250 } }
        }
    }

    Component {
        id: sectionDelegate

        PlasmaComponents.Label {
            x: 8
            y: 8
            text: getTimeStamp(section*1000);
            opacity: 0.6
            color: theme.textColor
        }
    }
    Component {
        id: empty
        Item {}
    }


    function getTimeStamp(msecs) {
        var pub = new Date(msecs);
        var now = new Date();
        var secs = Math.floor((now-pub)/1000);
        var days = Math.floor(secs/(86400));
        if (days==1) return "Yesterday";
        else if (days>1) return days+" days ago";

        var hours = Math.floor(secs/3600);
        var mins = Math.floor((secs%3600)/60);

        var l = "";
        if (hours==1) l += "1 hour";
        else if (hours>1) l += hours+" hours";
        if (hours>0 && mins>0) l+= " and ";
        if (mins==1) l += "1 minute";
        if (mins>1) l += mins+" minutes";
        else if (hours+mins==0) return secs+" seconds ago";
        return l+" ago";
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

