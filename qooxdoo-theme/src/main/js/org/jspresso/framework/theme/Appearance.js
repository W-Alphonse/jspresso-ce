/* ************************************************************************

 Copyright:

 License:

 Authors:

 ************************************************************************ */

qx.Theme.define("org.jspresso.framework.theme.Appearance",
    {
      extend: qx.theme.simple.Appearance,

      appearances: {
        "widget": {
          base: true,
          style: function (states) {
            return {
              backgroundColor: "app-background"
            };
          }
        },

        "menubar": {
          base: true,
          style: function (states) {
            return {
              backgroundColor: "app-background"
            };
          }
        },

        "toolbar": {
          base: true,
          style: function (states) {
            return {
              backgroundColor: "app-background"
            };
          }
        },

        "toolbar/part": {
          base: true,
          style: function (states) {
            return {
              height: 30
            };
          }
        },

        "toolbar/part/container": {
          base: true,
          style: function (states) {
            return {
              padding: 2
            };
          }
        },

        "application-bar": {
          alias: "toolbar",
          include: "toolbar",
          style: function (states) {
            return {
              paddingBottom: 50,
              backgroundColor: undefined,
              decorator: "header-box"
            };
          }
        },

        "application-split": {
          alias: "splitpane",
          include: "splitpane",
          style: function (states) {
            return {
              backgroundColor: "app-background",
              decorator: "transition-box"
            };
          }
        },

        "application-accordion": {
          style: function (states) {
            return {
              decorator: "transition-box"
            };
          }
        },

        "application-split/splitter": {
          alias: "splitpane/splitter",
          include: "splitpane/splitter",
          style: function (states) {
            return {
              backgroundColor: "app-background"
            };
          }
        },

        "logo": {
          alias: "image",
          include: "image",
          style: function (state) {
            return {
              minWidth: 60,
              decorator: "accordion-box",
              margin: [0, 2, 2, 2],
              padding: 4
            }
          }
        },

        "accordion-section": {
          include: "collapsable-panel",
          alias: "collapsable-panel",
          style: function (state) {
            return {
              padding: 4,
              decorator: "accordion-box"
            }
          }
        },

        "workspace-panel": {
          style: function (state) {
            return {
              margin: [0, 2, 2, 2],
              padding: 2,
              decorator: "accordion-box",
              backgroundColor: "app-background"
            }
          }
        },

        "button-frame": {
          base: true,
          style: function (states) {
            return {
              padding: [2, 4],
              margin: 2
            };
          }
        },

        "button": {
          base: true,
          include: "button-frame",
          style: function (states, superStyles) {
            return {
              decorator: states.hovered ? superStyles.decorator : undefined,
              padding: states.hovered ? [2, 4] : [3, 5]
            };
          }
        },

        "textfield": {
          base: true,
          style: function (states) {
            return {
              padding: [2, 4]
            };
          }
        },

        "checkbox": {
          base: true,
          style: function (states) {
            return {
              padding: 2
            };
          }
        },

        "table": {
          base: true,
          style: function (states) {
            return {
              decorator: "panel-box",
              headerCellHeight: 25,
              rowHeight: 25
            };
          }
        },

        "table-header-cell": {
          base: true,
          style: function (states) {
            var hovered = "";
            if (states.hovered) {
              hovered = "-hovered";
            }
            return {
              decorator: states.first ? "table-header-cell-first" + hovered : "table-header-cell" + hovered
            };
          }
        },

        "groupbox/legend": {
          base: true,
          style: function (states) {
            return {
              padding: 5,
              margin: [0, 5]
            };
          }
        },

        "groupbox/frame": {
          base: true,
          style: function (states) {
            return {
              backgroundColor: "app-background"
            };
          }
        },

        "collapsable-panel": {
          include: "groupbox/frame",
          style: function (states) {
            return {
              showSeparator: true,
              gap: 2,
              decorator: "panel-box",
              margin: 2,
              padding: 0
            };
          }
        },

        "collapsable-panel/bar/icon": {
          include: "groupbox/legend",
          alias: "groupbox/legend"
        },

        "tree": {
          base: true,
          style: function (states) {
            return {
              decorator: undefined,
              padding: 0
            };
          }
        },

        "splitbutton/button": {
          base: true,
          include: "button-frame",
          style: function (states, superStyles) {
            return {
              padding: states.hovered ? [2, 4] : [3, 5],
              margin: [2, 0, 2, 2],
              decorator: states.hovered ? superStyles.decorator : undefined
            };
          }
        },

        "splitbutton/arrow": {
          base: true,
          include: "button-frame",
          style: function (states, superStyles) {
            return {
              padding: states.hovered ? [2, 4] : [3, 5],
              margin: [2, 2, 2, 0],
              decorator: states.hovered ? superStyles.decorator : undefined
            };
          }
        },

        "splitpane": {
          base: true,
          style: function (states) {
            return {
              margin: 0,
              padding: 0
            };
          }
        },

        "datefield/button": {
          base: true,
          style: function (states) {
            return {
              margin: 0,
              padding: 0
            };
          }
        },

        "tabview/bar": {
          alias: "slidebar",
          base: true,

          style: function (states) {
            var margin = 2;
            var marginTop = margin, marginRight = margin, marginBottom = margin, marginLeft = margin;

            if (states.barTop) {
              marginBottom -= (margin + 1);
            } else if (states.barBottom) {
              marginTop -= (margin + 1);
            } else if (states.barRight) {
              marginLeft -= (margin + 1);
            } else {
              marginRight -= (margin + 1);
            }

            return {
              marginBottom: marginBottom,
              marginTop: marginTop,
              marginLeft: marginLeft,
              marginRight: marginRight
            };
          }
        },

        "tabview/pane": {
          base: true,
          style: function (states) {
            var margin = 2;
            var marginTop = margin, marginRight = margin, marginBottom = margin, marginLeft = margin;
            var decoratorSelector;

            if (states.barTop) {
              decoratorSelector = "top";
              marginTop -= margin;
            } else if (states.barBottom) {
              decoratorSelector = "bottom";
              marginBottom -= margin;
            } else if (states.barRight) {
              decoratorSelector = "right";
              marginRight -= margin;
            } else {
              decoratorSelector = "left";
              marginLeft -= margin;
            }

            return {
              padding: 2,
              marginBottom: marginBottom,
              marginTop: marginTop,
              marginLeft: marginLeft,
              marginRight: marginRight,
              decorator: "panel-box-" + decoratorSelector + "-angled",
              backgroundColor: "app-background"
            };
          }
        },

        "tabview-page/button": {
          base: true,
          style: function (states) {
            var padding;
            if (states.barTop || states.barBottom) {
              padding = [4, 8, 4, 6];
            } else {
              padding = [4, 2, 4, 2];
            }

            return {
              textColor: states.disabled ? "text-disabled" : states.checked ? undefined : "gray",
              backgroundColor: states.checked ? "app-background" : undefined,
              padding: padding,
              font: states.disabled ? undefined : states.checked ? "bold" : undefined
            };
          }
        },

        "upload-form": {
          style: function (states) {
            return {
              padding: 8,
              decorator: "main"
            }
          }
        },

        "window": {
          base: true,
          style: function (states) {
            return {
              backgroundColor: "app-background"
            };
          }
        },

        "window/captionbar": {
          base: true,
          style: function (states) {
            return {
              backgroundColor: states.active ? "window-caption-background" : "background-disabled"
            };
          }
        },

        "list" : {
          base: true,
          style: function (states) {
            return {
              backgroundColor: "app-background"
            };
          }
        }
      }
    });