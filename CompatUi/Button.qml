// SPDX-License-Identifier: MIT
// Copyright (c) David Heinemeier Hansson
// Adapted from Omarchy 4.0.4; see OMARCHY-LICENSE.
// Explicit theme imports avoid Qt 6.12 Color name collisions.
import qs.Ui as ShellUi
import "." as LocalUi
import QtQuick
import QtQuick.Controls
import qs.Commons as Commons

// The button. One component for every clickable thing in the kit.
// States compose independently and are applied in priority order:
//
//   pressed (mouse down)         pressed fill
//   activeFocus (Tab focus)      focus fill + focus border token
//   hasCursor || hover           hover-cursor fill (+ border if `bordered`)
//   selected                     selected fill + optional selected border
//   active                       selected fill
//   idle                         transparent or normal border if `bordered`
//
// All fills/borders come from `qs.Commons.Style` tokens, so themes
// control the look via [controls] in shell.toml.
//
// Emits `hovered(bool)` so panels with their own keyboard cursor model
// can update state on mouse enter/leave.
ShellUi.BorderSurface {
  id: root

  property string text: ""
  property string iconText: ""
  property string tooltipText: ""

  // State flags (see comment above for paint priority).
  property bool selected: false
  property bool active: false
  property bool hasCursor: false
  property bool focusable: false
  property bool bordered: false

  // Colors. Defaults track the theme; per-instance overrides are honored.
  property color foreground: Commons.Color.foreground
  property color background: "transparent"
  property color accent: Commons.Color.accent

  // Sizing.
  property string fontFamily: Commons.Style.font.family
  property real fontSize: Commons.Style.font.body
  property real iconSize: Commons.Style.font.icon
  property real iconRotation: 0
  property bool iconSpinning: false
  property real horizontalPadding: Commons.Style.spacing.controlPaddingX
  property real verticalPadding: Commons.Style.spacing.controlPaddingY
  property bool leftAlign: false

  leftPadding: horizontalPadding
  rightPadding: horizontalPadding
  topPadding: verticalPadding
  bottomPadding: verticalPadding

  // Tooltip palette. Auto-rendered if tooltipText is set. Defaults pull
  // from [tooltip] in shell.toml; override per-instance only when a button
  // intentionally wants a tooltip that diverges from the theme.
  property color tooltipBackground: Commons.Color.tooltip.background
  property color tooltipForeground: Commons.Color.tooltip.text
  property color tooltipBorder: Commons.Color.tooltip.border

  signal clicked()
  signal rightClicked()
  signal hovered(bool isHovered)

  activeFocusOnTab: focusable
  Keys.onReturnPressed: if (focusable) root.clicked()
  Keys.onEnterPressed: if (focusable) root.clicked()
  Keys.onSpacePressed: if (focusable) root.clicked()

  // Reserve the largest border any visual state can paint. Otherwise a
  // borderless idle button grows by a pixel per side on hover/focus and
  // relayouts neighboring controls.
  implicitWidth: row.implicitWidth + horizontalPadding * 2 + _reservedBorderLeft + _reservedBorderRight
  implicitHeight: row.implicitHeight + verticalPadding * 2 + _reservedBorderTop + _reservedBorderBottom
  radius: Commons.Style.cornerRadius

  readonly property bool hot: mouseArea.containsMouse || hasCursor
  readonly property bool _showFocusRing: focusable && activeFocus
  readonly property color _selectedColor: Commons.Style.selectedStateColor(root.foreground, root.accent)
  readonly property var _tooltipBorderSpec: LocalUi.ThemeBorder.localOrSurfaceSpec("tooltip", "border", root.tooltipBorder, Commons.Color.tooltip.border, Math.max(1, Commons.Style.normalBorderWidth))
  readonly property var _focusBorderSpec: LocalUi.ThemeBorder.controlSpec("focus", root.foreground, root.accent)
  readonly property var _hoverBorderSpec: LocalUi.ThemeBorder.controlSpec("hover-cursor", root.foreground, root.accent)
  readonly property var _selectedBorderSpec: LocalUi.ThemeBorder.controlSpec("selected", root.foreground, root.accent)
  readonly property var _normalBorderSpec: LocalUi.ThemeBorder.controlSpec("normal", root.foreground, root.accent)
  readonly property real _reservedBorderTop: Math.max(
    focusable ? LocalUi.ThemeBorder.top(_focusBorderSpec) : 0,
    LocalUi.ThemeBorder.top(_hoverBorderSpec),
    LocalUi.ThemeBorder.top(_selectedBorderSpec),
    bordered ? LocalUi.ThemeBorder.top(_normalBorderSpec) : 0)
  readonly property real _reservedBorderRight: Math.max(
    focusable ? LocalUi.ThemeBorder.right(_focusBorderSpec) : 0,
    LocalUi.ThemeBorder.right(_hoverBorderSpec),
    LocalUi.ThemeBorder.right(_selectedBorderSpec),
    bordered ? LocalUi.ThemeBorder.right(_normalBorderSpec) : 0)
  readonly property real _reservedBorderBottom: Math.max(
    focusable ? LocalUi.ThemeBorder.bottom(_focusBorderSpec) : 0,
    LocalUi.ThemeBorder.bottom(_hoverBorderSpec),
    LocalUi.ThemeBorder.bottom(_selectedBorderSpec),
    bordered ? LocalUi.ThemeBorder.bottom(_normalBorderSpec) : 0)
  readonly property real _reservedBorderLeft: Math.max(
    focusable ? LocalUi.ThemeBorder.left(_focusBorderSpec) : 0,
    LocalUi.ThemeBorder.left(_hoverBorderSpec),
    LocalUi.ThemeBorder.left(_selectedBorderSpec),
    bordered ? LocalUi.ThemeBorder.left(_normalBorderSpec) : 0)
  readonly property real _reservedContentLeftInset: _reservedBorderLeft + leftPadding
  readonly property var _borderSpec: _showFocusRing ? _focusBorderSpec
    : hot                      ? _hoverBorderSpec
    : selected                 ? (LocalUi.ThemeBorder.controlHasWidth("selected") ? _selectedBorderSpec : (bordered ? _normalBorderSpec : LocalUi.ThemeBorder.none()))
    : bordered                 ? _normalBorderSpec
    : LocalUi.ThemeBorder.none()

  color: mouseArea.pressed ? Commons.Style.pressedFillFor(root.foreground, root.accent)
    : _showFocusRing       ? Commons.Style.focusFillFor(root.foreground, root.accent)
    : hot                  ? Commons.Style.hoverFillFor(root.foreground, root.accent)
    : selected             ? Commons.Style.selectedFillFor(root.foreground, root.accent)
    : active               ? Commons.Style.selectedFillFor(root.foreground, root.accent)
    : background

  // Border follows the same state precedence as fill. Buttons stay
  // borderless at rest unless `bordered` is set, but hover-cursor/focus
  // always use the shared cursor border so the keyboard target is visible
  // and consistent with the rest of the kit. Selected borders are off by
  // default for plain buttons; explicitly bordered buttons keep their
  // normal border when selected unless selected-border-width opts in to a
  // dedicated selected border.
  borderSpec: _borderSpec

  Behavior on color { ColorAnimation { duration: 120 } }

  ToolTip {
    visible: root.tooltipText !== "" && mouseArea.containsMouse
    text: root.tooltipText
    delay: 400
    padding: 0
    background: ShellUi.BorderSurface {
      color: root.tooltipBackground
      borderSpec: root._tooltipBorderSpec
      radius: 0
    }
    contentItem: Text {
      textFormat: Text.PlainText
      text: root.tooltipText
      color: root.tooltipForeground
      font.family: root.fontFamily
      font.pixelSize: Commons.Style.font.bodySmall
      leftPadding: LocalUi.ThemeBorder.left(root._tooltipBorderSpec) + Commons.Style.spacing.controlPaddingX
      rightPadding: LocalUi.ThemeBorder.right(root._tooltipBorderSpec) + Commons.Style.spacing.controlPaddingX
      topPadding: LocalUi.ThemeBorder.top(root._tooltipBorderSpec) + Commons.Style.spacing.controlPaddingY
      bottomPadding: LocalUi.ThemeBorder.bottom(root._tooltipBorderSpec) + Commons.Style.spacing.controlPaddingY
    }
  }

  Row {
    id: row
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: root.leftAlign ? parent.left : undefined
    anchors.leftMargin: root.leftAlign ? root._reservedContentLeftInset : 0
    anchors.horizontalCenter: root.leftAlign ? undefined : parent.horizontalCenter
    spacing: Commons.Style.spacing.controlGap

    Text {
      textFormat: Text.PlainText
      visible: root.iconText !== ""
      text: root.iconText
      color: root.selected ? root._selectedColor : root.foreground
      font.family: root.fontFamily
      font.pixelSize: root.iconSize
      rotation: root.iconSpinning ? 0 : root.iconRotation
      transformOrigin: Item.Center
      anchors.verticalCenter: parent.verticalCenter

      RotationAnimation on rotation {
        from: 0
        to: 360
        duration: 900
        loops: Animation.Infinite
        running: root.iconSpinning
      }
    }

    Text {
      textFormat: Text.PlainText
      visible: root.text !== ""
      text: root.text
      color: root.selected ? root._selectedColor : root.foreground
      font.family: root.fontFamily
      font.pixelSize: root.fontSize
      font.bold: root.selected
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (root.focusable) root.forceActiveFocus()
      if (mouse.button === Qt.RightButton) root.rightClicked()
      else root.clicked()
    }
  }

  HoverHandler {
    onHoveredChanged: root.hovered(hovered)
  }
}
