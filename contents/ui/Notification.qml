import QtQuick 1.1
import org.kde.plasma.components 0.1 as PlasmaComponents

Item {
    property alias icon: iconImg.source
    property alias text: description.text
    property string link
    height: container.height+10

    Row {
        id: container
        spacing: 5
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 5
            right: parent.right
            rightMargin: 5
        }

        Image {
            id: iconImg
            anchors.verticalCenter: parent.verticalCenter
        }

        PlasmaComponents.Label {
            id: description
            width: parent.width-iconImg.width-parent.spacing
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
        onClicked: plasmoid.openUrl(link);
    }
}
