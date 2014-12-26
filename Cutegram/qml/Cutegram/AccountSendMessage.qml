import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0

Rectangle {
    id: smsg
    width: 100
    height: txt.height<minimumHeight? minimumHeight : txt.height
    color: backColor2

    property Dialog currentDialog
    property real minimumHeight: 40*Devices.density

    property bool isChat: currentDialog? currentDialog.peer.chatId != 0 : false

    signal accepted( string text )
    signal emojiRequest(real x, real y)

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onClicked: txt.focus = true
    }

    TextAreaCore {
        id: txt
        anchors.left: attach_btn.right
        anchors.right: emoji_btn.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 4*Devices.density
        selectByMouse: true
        selectionColor: masterPalette.highlight
        selectedTextColor: masterPalette.highlightedText
        pickerEnable: Devices.isTouchDevice
        color: textColor0
        wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
        clip: true

        onTextChanged: if( text.trim().length == 0 ) text = ""
        Keys.onPressed: {
            if( event.key == Qt.Key_Return || event.key == Qt.Key_Enter )
                if( event.modifiers == Qt.NoModifier )
                    smsg.send()
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        cursorShape: Qt.IBeamCursor
        onClicked: {
            if( mouse.button == Qt.RightButton ) {
                var actions = ["Copy","Paste","Delete"]
                var res = Cutegram.showMenu(actions)
                switch(res) {
                case 0:
                    txt.copy()
                    break;

                case 1:txt
                    txt.paste()
                    break;

                case 2:
                    txt.remove(txt.selectionStart, txt.selectionEnd)
                    break;
                }
            } else {
                mouse.accepted = false
            }
        }
    }

    Button {
        id: attach_btn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        normalColor: "#00000000"
        highlightColor: "#1f000000"
        cursorShape: Qt.PointingHandCursor
        width: 40*Devices.density
        iconHeight: 20*Devices.density
        opacity: 0.6
        icon: "files/attach.png"
        onClicked: {
            if( currentDialog == telegramObject.nullDialog )
                return
            var file = Desktop.getOpenFileName(View)
            if( file.length == 0 )
                return

            var dId = isChat? currentDialog.peer.chatId : currentDialog.peer.userId
            telegramObject.sendFile(dId, file)
        }
    }

    Button {
        id: emoji_btn
        anchors.right: send_btn.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        normalColor: "#00000000"
        highlightColor: "#1f000000"
        cursorShape: Qt.PointingHandCursor
        width: 26*Devices.density
        iconHeight: 20*Devices.density
        opacity: 0.6
        icon: "files/emoji.png"
        onClicked: {
            var pnt = main.mapFromItem(emoji_btn,0,0)
            smsg.emojiRequest(pnt.x + width/2, pnt.y + height*0.2)
        }
    }

    Button {
        id: send_btn
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        textColor: masterPalette.highlight
        normalColor: "#00000000"
        highlightColor: "#0f000000"
        width: 70*Devices.density
        cursorShape: Qt.PointingHandCursor
        textFont.pixelSize: 12*Devices.fontDensity
        textMargin: -2*Devices.density
        text: qsTr("Send")
        onClicked: smsg.send()
    }

    function insertText( str ) {
        if( txt.selectedText.length != 0 )
            txt.remove(txt.selectionStart, txt.selectionEnd)

        txt.insert( txt.cursorPosition, str )
    }

    function send() {
        if( currentDialog == telegramObject.nullDialog )
            return
        var msg = txt.text.trim()
        if( msg == "" )
            return

        smsg.accepted(msg)
        txt.text = ""
    }
}
