import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents

Item {
    id: notifier
    property int minimumWidth: 290
    property int minimumHeight: 340
    property string feed
    property int update_interval: 1 //in minutes

    PlasmaCore.DataSource {
        id: fbSource
        engine: "rss"
        connectedSources: [feed]
        interval: update_interval*60000
        onNewData: plasmoid.showPopup(7500);
    }

    property string title: fbSource.data[feed]["title"]
    onTitleChanged: {
        if (title!="") titleLabel.text = title;
    }

    PlasmaCore.DataSource {
        id: opener
        engine: "executable"
        function openUrl(link) { connectSource("kde-open \""+link+"\""); }
    }

    PlasmaComponents.Label {
        id: titleLabel
        anchors {
            top: parent.top
            topMargin: 0
            left: parent.left
            right: parent.right
        }
        horizontalAlignment: Text.AlignHCenter
        clip: true
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
            topMargin: 0
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
            bottom: parent.bottom
        }
        model: fbSource.data[feed]["items"]
        spacing: 5
        clip: true

        delegate: Row {
            spacing: 5

            Image {
                id: icon
                source: modelData["icon"]
                anchors.verticalCenter: parent.verticalCenter
            }

            PlasmaComponents.Label {
                id: label
                text: modelData["description"]
                width: view.width-icon.width-spacing
                wrapMode: Text.WordWrap
                onLinkActivated: opener.openUrl(link);
            }
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

