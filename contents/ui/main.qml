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
        onDataChanged: plasmoid.showPopup(7500);
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

    MouseArea {
        anchors.fill: parent
        anchors.margins: 0
        hoverEnabled: true
        onEntered: view.highlightItem.opacity = 0;
        onExited: view.highlightItem.opacity = 0;
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
        model: fbSource.data[feed]["items"]
        spacing: -8
        clip: true

        delegate: Item {
            width: view.width
            height: container.height+20

            Row {
                id: container
                spacing: 5
                anchors {
                    top: parent.top
                    topMargin: 8
                    left: parent.left
                    leftMargin: 5
                    right: parent.right
                    rightMargin: 5
                }

                Image {
                    id: icon
                    source: modelData["icon"]
                    anchors.verticalCenter: parent.verticalCenter
                }

                PlasmaComponents.Label {
                    id: label
                    text: modelData["description"]
                    width: parent.width-icon.paintedWidth-parent.spacing
                    wrapMode: Text.WordWrap
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    view.currentIndex = index;
                    view.highlightItem.opacity = 1;
                }
                onClicked: opener.openUrl(modelData["link"]);
            }
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

