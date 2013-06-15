/**
 * Copyright (c) 2005-2013 Vincent Vandenschrick. All rights reserved.
 * <p>
 * This file is part of the Jspresso framework. Jspresso is free software: you
 * can redistribute it and/or modify it under the terms of the GNU Lesser
 * General Public License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version. Jspresso is
 * distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details. You should have received a copy of the GNU Lesser General Public
 * License along with Jspresso. If not, see <http://www.gnu.org/licenses/>.
 */

package org.jspresso.framework.view.flex {

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TextEvent;

import flex.utils.ui.resize.ResizablePanel;

import flexlib.containers.ButtonScrollingCanvas;

import mx.binding.utils.BindingUtils;
import mx.collections.ListCollectionView;
import mx.containers.ApplicationControlBar;
import mx.containers.Box;
import mx.containers.BoxDirection;
import mx.containers.Canvas;
import mx.containers.DividedBox;
import mx.containers.Grid;
import mx.containers.GridItem;
import mx.containers.GridRow;
import mx.containers.HBox;
import mx.containers.Panel;
import mx.containers.TabNavigator;
import mx.containers.VBox;
import mx.containers.ViewStack;
import mx.controls.Button;
import mx.controls.CheckBox;
import mx.controls.ColorPicker;
import mx.controls.ComboBox;
import mx.controls.DataGrid;
import mx.controls.DateField;
import mx.controls.Image;
import mx.controls.Label;
import mx.controls.List;
import mx.controls.Menu;
import mx.controls.PopUpButton;
import mx.controls.RadioButton;
import mx.controls.RadioButtonGroup;
import mx.controls.Text;
import mx.controls.TextArea;
import mx.controls.TextInput;
import mx.controls.VRule;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.core.ClassFactory;
import mx.core.Container;
import mx.core.IFlexDisplayObject;
import mx.core.ScrollPolicy;
import mx.core.UIComponent;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.ColorPickerEvent;
import mx.events.DataGridEvent;
import mx.events.DataGridEventReason;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;
import mx.events.ItemClickEvent;
import mx.events.ListEvent;
import mx.events.MenuEvent;
import mx.formatters.Formatter;
import mx.formatters.NumberBase;
import mx.formatters.NumberBaseRoundType;
import mx.formatters.NumberFormatter;
import mx.graphics.SolidColor;
import mx.managers.PopUpManager;
import mx.managers.ToolTipManager;
import mx.utils.ObjectUtil;
import mx.utils.StringUtil;

import org.jspresso.framework.action.IActionHandler;
import org.jspresso.framework.application.frontend.command.remote.IRemoteCommandHandler;
import org.jspresso.framework.application.frontend.command.remote.RemoteSelectionCommand;
import org.jspresso.framework.application.frontend.command.remote.RemoteSortCommand;
import org.jspresso.framework.application.frontend.command.remote.RemoteTableChangedCommand;
import org.jspresso.framework.gui.remote.RAction;
import org.jspresso.framework.gui.remote.RActionComponent;
import org.jspresso.framework.gui.remote.RActionEvent;
import org.jspresso.framework.gui.remote.RActionField;
import org.jspresso.framework.gui.remote.RActionList;
import org.jspresso.framework.gui.remote.RBorderContainer;
import org.jspresso.framework.gui.remote.RCardContainer;
import org.jspresso.framework.gui.remote.RCheckBox;
import org.jspresso.framework.gui.remote.RColorField;
import org.jspresso.framework.gui.remote.RComboBox;
import org.jspresso.framework.gui.remote.RComponent;
import org.jspresso.framework.gui.remote.RConstrainedGridContainer;
import org.jspresso.framework.gui.remote.RContainer;
import org.jspresso.framework.gui.remote.RDateField;
import org.jspresso.framework.gui.remote.RDecimalComponent;
import org.jspresso.framework.gui.remote.RDecimalField;
import org.jspresso.framework.gui.remote.RDurationField;
import org.jspresso.framework.gui.remote.REvenGridContainer;
import org.jspresso.framework.gui.remote.RForm;
import org.jspresso.framework.gui.remote.RHtmlArea;
import org.jspresso.framework.gui.remote.RIcon;
import org.jspresso.framework.gui.remote.RImageComponent;
import org.jspresso.framework.gui.remote.RIntegerField;
import org.jspresso.framework.gui.remote.RLabel;
import org.jspresso.framework.gui.remote.RLink;
import org.jspresso.framework.gui.remote.RList;
import org.jspresso.framework.gui.remote.RNumericComponent;
import org.jspresso.framework.gui.remote.RPasswordField;
import org.jspresso.framework.gui.remote.RPercentField;
import org.jspresso.framework.gui.remote.RRadioBox;
import org.jspresso.framework.gui.remote.RSecurityComponent;
import org.jspresso.framework.gui.remote.RSplitContainer;
import org.jspresso.framework.gui.remote.RTabContainer;
import org.jspresso.framework.gui.remote.RTable;
import org.jspresso.framework.gui.remote.RTextArea;
import org.jspresso.framework.gui.remote.RTextComponent;
import org.jspresso.framework.gui.remote.RTextField;
import org.jspresso.framework.gui.remote.RTimeField;
import org.jspresso.framework.gui.remote.RTree;
import org.jspresso.framework.state.remote.RemoteCompositeValueState;
import org.jspresso.framework.state.remote.RemoteFormattedValueState;
import org.jspresso.framework.state.remote.RemoteValueState;
import org.jspresso.framework.util.array.ArrayUtil;
import org.jspresso.framework.util.format.DateFormatter;
import org.jspresso.framework.util.format.DateUtils;
import org.jspresso.framework.util.format.NumberParser;
import org.jspresso.framework.util.format.Parser;
import org.jspresso.framework.util.format.PasswordFormatter;
import org.jspresso.framework.util.format.PercentFormatter;
import org.jspresso.framework.util.format.PercentParser;
import org.jspresso.framework.util.format.TimeParser;
import org.jspresso.framework.util.gui.CellConstraints;
import org.jspresso.framework.util.gui.Dimension;
import org.jspresso.framework.util.gui.Font;
import org.jspresso.framework.util.html.HtmlUtil;
import org.jspresso.framework.util.lang.DateDto;
import org.jspresso.framework.util.remote.registry.IRemotePeerRegistry;
import org.sepy.ui.CheckBoxExtended;

public class DefaultFlexViewFactory {

  [Embed(source="../../../../../../resources/assets/images/reset-16x16.png")]
  private var _iconTemplate:Class;

  [Embed(source="../../../../../../resources/assets/images/reset-16x16.png")]
  private var _resetIcon:Class;

  private static const TEMPLATE_CHAR:String = "O";
  private static const FIELD_MAX_CHAR_COUNT:int = 32;
  private static const NUMERIC_FIELD_MAX_CHAR_COUNT:int = 16;
  private static const COLUMN_MAX_CHAR_COUNT:int = 20;
  private static const DATE_TEMPLATE:String = "00/00/0000";
  private static const LONG_TIME_TEMPLATE:String = "00:00:00";
  private static const SHORT_TIME_TEMPLATE:String = "00:00";
  private static const ICON_WIDTH:int = 16;

  private var _remotePeerRegistry:IRemotePeerRegistry;
  private var _actionHandler:IActionHandler;
  private var _commandHandler:IRemoteCommandHandler;
  private var _remoteValueSorter:RemoteValueSorter;
  private var _timeFormatter:DateFormatter;
  private var _shortTimeFormatter:DateFormatter;
  private var _passwordFormatter:PasswordFormatter;
  private var _datePattern:String;
  private var _firstDayOfWeek:int;

  private var _lastActionTimestamp:Date = new Date();

  public function DefaultFlexViewFactory(remotePeerRegistry:IRemotePeerRegistry, actionHandler:IActionHandler,
                                         commandHandler:IRemoteCommandHandler) {
    _remotePeerRegistry = remotePeerRegistry;
    _actionHandler = actionHandler;
    _commandHandler = commandHandler;
    _remoteValueSorter = new RemoteValueSorter();
    _passwordFormatter = new PasswordFormatter();
    _timeFormatter = new DateFormatter();
    _timeFormatter.formatString = "JJ:NN:SS";
    _shortTimeFormatter = new DateFormatter();
    _shortTimeFormatter.formatString = "JJ:NN";
    ToolTipManager.toolTipClass = HtmlToolTip;
  }

  public function createComponent(remoteComponent:RComponent, registerPeers:Boolean = true):UIComponent {
    var component:UIComponent = createCustomComponent(remoteComponent);
    if (component == null) {
      if (remoteComponent is RActionField) {
        component = createActionField(remoteComponent as RActionField);
      } else if (remoteComponent is RActionComponent) {
        component = createActionComponent(remoteComponent as RActionComponent);
      } else if (remoteComponent is RCheckBox) {
        component = createCheckBox(remoteComponent as RCheckBox);
      } else if (remoteComponent is RComboBox) {
        component = createComboBox(remoteComponent as RComboBox);
      } else if (remoteComponent is RRadioBox) {
        component = createRadioBox(remoteComponent as RRadioBox);
      } else if (remoteComponent is RColorField) {
        component = createColorField(remoteComponent as RColorField);
      } else if (remoteComponent is RContainer) {
        component = createContainer(remoteComponent as RContainer);
      } else if (remoteComponent is RDateField) {
        component = createDateComponent(remoteComponent as RDateField);
      } else if (remoteComponent is RDurationField) {
        component = createDurationField(remoteComponent as RDurationField);
      } else if (remoteComponent is RImageComponent) {
        component = createImageComponent(remoteComponent as RImageComponent);
      } else if (remoteComponent is RList) {
        component = createList(remoteComponent as RList);
      } else if (remoteComponent is RNumericComponent) {
        component = createNumericComponent(remoteComponent as RNumericComponent);
      } else if (remoteComponent is RSecurityComponent) {
        component = createSecurityComponent(remoteComponent as RSecurityComponent);
      } else if (remoteComponent is RTable) {
        component = createTable(remoteComponent as RTable);
      } else if (remoteComponent is RForm) {
        component = createForm(remoteComponent as RForm);
      } else if (remoteComponent is RTextComponent) {
        component = createTextComponent(remoteComponent as RTextComponent);
      } else if (remoteComponent is RTimeField) {
        component = createTimeField(remoteComponent as RTimeField);
      } else if (remoteComponent is RTree) {
        component = createTree(remoteComponent as RTree);
      }
    }
    if (component == null) {
      component = new Canvas();
    }
    remoteComponent.assignPeer(component);
    if (isNaN(component.minWidth)) {
      component.minWidth = 0;
    }
    component.id = remoteComponent.guid;
    if (remoteComponent.toolTip != null) {
      component.toolTip = remoteComponent.toolTip;
    }
    component = decorateWithActions(remoteComponent, component);
    if (remoteComponent.borderType == "TITLED") {
      var decorator:Panel = createPanelComponent();
      decorator.percentWidth = component.percentWidth;
      decorator.percentHeight = component.percentHeight;
      component.percentWidth = 100.0;
      component.percentHeight = 100.0;
      decorator.addChild(component);
      decorator.title = remoteComponent.label;
      decorator.titleIcon = getIconForComponent(decorator, remoteComponent.icon);
      decorator.horizontalScrollPolicy = ScrollPolicy.OFF;
      decorator.verticalScrollPolicy = ScrollPolicy.OFF;
      component = decorator;
    } else if (remoteComponent.borderType == "SIMPLE") {
      component.setStyle("borderStyle", "solid");
    }
    applyComponentStyle(component, remoteComponent);
    applyComponentPreferredSize(component, remoteComponent.preferredSize);
    if (registerPeers) {
      getRemotePeerRegistry().register(remoteComponent);
    }
    return component;
  }

  public function createPanelComponent():Panel {
    return new CollapsiblePanel();
  }

  public function createResizableDialog(dialogParent:DisplayObject):Panel {
    var dialog:ResizablePanel = PopUpManager.createPopUp(dialogParent, ResizablePanel, true) as ResizablePanel;
    dialog.resizable = true;
    return dialog;
  }

  protected function applyComponentPreferredSize(component:UIComponent, preferredSize:Dimension):void {
    if (preferredSize) {
      component.addEventListener(FlexEvent.CREATION_COMPLETE, function (e:FlexEvent):void {
        if (preferredSize.width > 0) {
          component.width = preferredSize.width;
        }
        if (preferredSize.height > 0) {
          component.height = preferredSize.height;
        }
      });
    }
  }

  public function applyComponentStyle(component:*, remoteComponent:RComponent):void {
    if (remoteComponent.foreground) {
      component.setStyle("color", remoteComponent.foreground);
      if (component is IFlexDisplayObject) {
        (component as IFlexDisplayObject).alpha = getAlphaFromArgb(remoteComponent.foreground);
      }
    }
    if (remoteComponent.background) {
      component.setStyle("backgroundColor", remoteComponent.background);
      component.setStyle("backgroundAlpha", getAlphaFromArgb(remoteComponent.background));
    }
    if (remoteComponent.font) {
      if (remoteComponent.font.name) {
        component.setStyle("fontFamily", remoteComponent.font.name);
      }
      if (remoteComponent.font.size > 0) {
        component.setStyle("fontSize", remoteComponent.font.size);
      }
      if (remoteComponent.font.italic) {
        component.setStyle("fontStyle", "italic");
      }
      if (remoteComponent.font.bold) {
        component.setStyle("fontWeight", "bold");
      }
    }
    if (remoteComponent.styleName) {
      component.styleName = remoteComponent.styleName;
    }
  }

  protected function getColorFromArgb(argb:String):SolidColor {
    var color:uint = parseInt(argb.substr(argb.length - 6, 6), 16);
    return new SolidColor(color, getAlphaFromArgb(argb));
  }

  public static function getAlphaFromArgb(argb:String):Number {
    if (argb && argb.length == 10) {
      var alpha:Number = parseInt(argb.substr(2, 2), 16);
      return alpha / 255;
    }
    return 1.0;
  }

  protected function decorateWithActions(remoteComponent:RComponent, component:UIComponent):UIComponent {
    var toolBar:UIComponent;
    var secondaryToolBar:UIComponent;
    if (!(remoteComponent is RActionField) && remoteComponent.actionLists != null) {
      toolBar = createToolBar(remoteComponent, component);
    } else {
      toolBar = createDefaultToolBar(remoteComponent, component);
    }
    if (remoteComponent.secondaryActionLists != null && remoteComponent.secondaryActionLists.length > 0) {
      secondaryToolBar = createSecondaryToolBar(remoteComponent, component);
    }
    if (toolBar || secondaryToolBar) {
      var surroundingBox:VBox = new VBox();
      component.percentWidth = 100.0;
      component.percentHeight = 100.0;

      if (toolBar) {
        toolBar = decorateWithSlideBar(toolBar);
        toolBar.percentWidth = 100.0;
        surroundingBox.addChild(toolBar);
      }
      surroundingBox.addChild(component);
      if (secondaryToolBar) {
        secondaryToolBar = decorateWithSlideBar(secondaryToolBar);
        secondaryToolBar.percentWidth = 100.0;
        surroundingBox.addChild(secondaryToolBar);
      }
      surroundingBox.horizontalScrollPolicy = ScrollPolicy.OFF;
      surroundingBox.verticalScrollPolicy = ScrollPolicy.OFF;
      return surroundingBox;
    }
    return component;
  }

  public function decorateWithSlideBar(component:UIComponent):UIComponent {
    var slideBar:ButtonScrollingCanvas = new ButtonScrollingCanvas();
    slideBar.addChild(component);
    slideBar.percentWidth = 100.0;
    slideBar.buttonWidth = 10;
    slideBar.startScrollingEvent = MouseEvent.MOUSE_OVER;
    slideBar.stopScrollingEvent = MouseEvent.MOUSE_OUT;
    component.addEventListener(FlexEvent.CREATION_COMPLETE, function (event:FlexEvent):void {
      if (component.height > 0) {
        slideBar.height = component.height;
      } else {
        slideBar.height = component.measuredHeight;
      }
      slideBar.minHeight = slideBar.height;
      slideBar.maxHeight = slideBar.height;
    });
    return slideBar;
  }

  protected function createToolBarComponent():ApplicationControlBar {
    var toolBar:ApplicationControlBar = new ApplicationControlBar();
    toolBar.styleName = "applicationControlBar";
    return toolBar;
  }

  protected function createDefaultToolBar(remoteComponent:RComponent, component:UIComponent):ApplicationControlBar {
    return null;
  }

  protected function createToolBar(remoteComponent:RComponent, component:UIComponent):ApplicationControlBar {
    return createToolBarFromActionLists(remoteComponent.actionLists, component);
  }

  protected function createSecondaryToolBar(remoteComponent:RComponent, component:UIComponent):ApplicationControlBar {
    return createToolBarFromActionLists(remoteComponent.secondaryActionLists, component);
  }

  public function createToolBarFromActionLists(actionLists:Array, component:UIComponent):ApplicationControlBar {
    var toolBar:ApplicationControlBar = createToolBarComponent();
    toolBar.percentWidth = 100.0;
    installActionLists(toolBar, actionLists, component);
    return toolBar;
  }

  public function installActionLists(toolBar:ApplicationControlBar, actionLists:Array, component:UIComponent):void {
    if (actionLists != null) {
      for (var i:int = 0; i < actionLists.length; i++) {
        var actionList:RActionList = actionLists[i] as RActionList;
        if (actionList.collapsable) {
          var popupButton:Button = createPopupButton(actionList, component);
          if (popupButton != null) {
            toolBar.addChild(popupButton);
          }
        } else {
          if (actionList.actions != null) {
            for (var j:int = 0; j < actionList.actions.length; j++) {
              toolBar.addChild(createAction(actionList.actions[j], component));
            }
          }
        }
        if (i < actionLists.length - 1) {
          addSeparator(toolBar);
        }
      }
    }
  }

  public function addSeparator(toolBar:ApplicationControlBar, size:int = 20):void {
    var separator:VRule = new VRule();
    separator.height = size;
    separator.maxHeight = size;
    toolBar.addChild(separator);
  }

  protected function getRemotePeerRegistry():IRemotePeerRegistry {
    return _remotePeerRegistry;
  }

  protected function getActionHandler():IActionHandler {
    return _actionHandler;
  }

  protected function createCustomComponent(remoteComponent:RComponent):UIComponent {
    return null;
  }

  protected function createContainer(remoteContainer:RContainer):UIComponent {
    var container:Container;
    if (remoteContainer is RBorderContainer) {
      container = createBorderContainer(remoteContainer as RBorderContainer);
    } else if (remoteContainer is RCardContainer) {
      container = createCardContainer(remoteContainer as RCardContainer);
    } else if (remoteContainer is RConstrainedGridContainer) {
      container = createConstrainedGridContainer(remoteContainer as RConstrainedGridContainer);
    } else if (remoteContainer is REvenGridContainer) {
      container = createEvenGridContainer(remoteContainer as REvenGridContainer);
    } else if (remoteContainer is RSplitContainer) {
      container = createSplitContainer(remoteContainer as RSplitContainer);
    } else if (remoteContainer is RTabContainer) {
      container = createTabContainer(remoteContainer as RTabContainer);
    }
    container.horizontalScrollPolicy = ScrollPolicy.OFF;
    container.verticalScrollPolicy = ScrollPolicy.OFF;
    return container;
  }

  protected function createNumericComponent(remoteNumericComponent:RNumericComponent):UIComponent {
    var numericComponent:UIComponent;
    if (remoteNumericComponent is RDecimalComponent) {
      numericComponent = createDecimalComponent(remoteNumericComponent as RDecimalComponent);
    } else if (remoteNumericComponent is RIntegerField) {
      numericComponent = createIntegerField(remoteNumericComponent as RIntegerField);
    }

    var maxChars:int = -1;
    if (!isNaN(remoteNumericComponent.minValue) && !isNaN(remoteNumericComponent.maxValue)) {
      var formatter:Formatter = createFormatter(remoteNumericComponent);
      maxChars = Math.max(formatter.format(remoteNumericComponent.minValue).length,
                          formatter.format(remoteNumericComponent.maxValue).length);
      if (numericComponent is TextInput) {
        (numericComponent as TextInput).maxChars = maxChars;
      }
    }
    if (maxChars >= 0) {
      sizeMaxComponentWidth(numericComponent, remoteNumericComponent, maxChars + 2, NUMERIC_FIELD_MAX_CHAR_COUNT);
    } else {
      sizeMaxComponentWidth(numericComponent, remoteNumericComponent, NUMERIC_FIELD_MAX_CHAR_COUNT,
                            NUMERIC_FIELD_MAX_CHAR_COUNT);
    }
    configureHorizontalAlignment(numericComponent, remoteNumericComponent.horizontalAlignment);
    return numericComponent;
  }

  protected function createDecimalComponent(remoteDecimalComponent:RDecimalComponent):UIComponent {
    var decimalComponent:UIComponent;
    if (remoteDecimalComponent is RDecimalField) {
      decimalComponent = createDecimalField(remoteDecimalComponent as RDecimalField);
    } else if (remoteDecimalComponent is RPercentField) {
      decimalComponent = createPercentField(remoteDecimalComponent as RPercentField);
    }
    return decimalComponent;
  }

  protected function createTextComponent(remoteTextComponent:RTextComponent):UIComponent {
    var textComponent:UIComponent;
    if (remoteTextComponent is RTextArea) {
      textComponent = createTextArea(remoteTextComponent as RTextArea);
    } else if (remoteTextComponent is RHtmlArea) {
      textComponent = createHtmlArea(remoteTextComponent as RHtmlArea);
    } else if (remoteTextComponent is RPasswordField) {
      textComponent = createPasswordField(remoteTextComponent as RPasswordField);
    } else if (remoteTextComponent is RTextField) {
      textComponent = createTextField(remoteTextComponent as RTextField);
    } else if (remoteTextComponent is RLabel) {
      textComponent = createLabel(remoteTextComponent as RLabel);
    }
    return textComponent;
  }

  protected function createTree(remoteTree:RTree):UIComponent {
    var tree:SelectionTrackingTree = createTreeComponent();
    tree.labelField = "value";
    tree.dataTipField = "description";
    tree.dataDescriptor = new RCVSDataDescriptor();
    tree.itemRenderer = createTreeItemRenderer();
    tree.dataProvider = remoteTree.state;
    tree.minWidth = 200;
    tree.horizontalScrollPolicy = ScrollPolicy.AUTO;
    tree.verticalScrollPolicy = ScrollPolicy.AUTO;
    bindTree(tree, remoteTree.state as RemoteCompositeValueState);
    if (remoteTree.expanded) {
      tree.addEventListener(FlexEvent.CREATION_COMPLETE, function (event:FlexEvent):void {
        expandItem(tree, remoteTree.state as RemoteCompositeValueState, true);
      });
      //        tree.addEventListener(FlexEvent.UPDATE_COMPLETE, function(event:FlexEvent):void {
      //            expandItem(tree, remoteTree.state as RemoteCompositeValueState, true);
      //          });
    } else {
      tree.addEventListener(FlexEvent.CREATION_COMPLETE, function (event:FlexEvent):void {
        expandItem(tree, remoteTree.state as RemoteCompositeValueState, false);
      });
    }
    if (remoteTree.rowAction) {
      getRemotePeerRegistry().register(remoteTree.rowAction);
      tree.doubleClickEnabled = true;
      tree.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, function (event:ListEvent):void {
        _actionHandler.execute(remoteTree.rowAction);
      });
    }
    return tree;
  }

  public function createTreeComponent():SelectionTrackingTree {
    return new SelectionTrackingTree();
  }

  public function createTreeItemRenderer():ClassFactory {
    return new ClassFactory(RemoteValueTreeItemRenderer);
  }

  protected function expandItem(tree:SelectionTrackingTree, remoteState:RemoteCompositeValueState,
                                recurse:Boolean):void {
    tree.expandItem(remoteState, true, true, true);
    if (recurse) {
      if (remoteState.children != null) {
        tree.fixListeners(remoteState.children);
        for (var i:int = 0; i < remoteState.children.length; i++) {
          if (remoteState.children[i] is RemoteCompositeValueState) {
            expandItem(tree, remoteState.children[i], recurse);
          }
        }
      }
    }
  }

  protected function bindTree(tree:SelectionTrackingTree, rootState:RemoteCompositeValueState):void {
    var updateModel:Function = function (selectedItems:Array):void {
      var parentsOfSelectedNodes:Array = [];
      var i:int;
      var node:Object;
      var parentNode:RemoteCompositeValueState;
      for (i = 0; i < selectedItems.length; i++) {
        node = selectedItems[i];
        parentNode = tree.getParentItem(node);
        if (parentNode == null && !tree.showRoot) {
          parentNode = rootState;
        }
        if (parentNode != null && parentsOfSelectedNodes.indexOf(parentNode) == -1) {
          parentsOfSelectedNodes.push(parentNode);
        }
      }
      var oldSelectionTrackingEnabled:Boolean = tree.selectionTrackingEnabled;
      try {
        tree.selectionTrackingEnabled = false;
        clearStateSelection(rootState, parentsOfSelectedNodes);
        for (i = 0; i < selectedItems.length; i++) {
          node = selectedItems[i];
          parentNode = tree.getParentItem(node);
          if (parentNode == null && !tree.showRoot) {
            parentNode = rootState;
          }
          if (parentNode != null) {
            var selectedIndices:Array = [];
            if (parentNode.selectedIndices != null) {
              selectedIndices.concat(parentNode.selectedIndices);
            }
            var childIndex:int = parentNode.children.getItemIndex(node);
            if (childIndex >= 0) {
              selectedIndices.push(childIndex);
              parentNode.leadingIndex = childIndex;
              parentNode.selectedIndices = selectedIndices;
            }
          }
        }
      } finally {
        tree.selectionTrackingEnabled = oldSelectionTrackingEnabled;
      }
    };
    BindingUtils.bindSetter(updateModel, tree, "selectedItems", true);
  }

  protected function clearStateSelection(remoteState:RemoteCompositeValueState, excludedNodes:Array):void {
    if (excludedNodes.indexOf(remoteState) == -1) {
      remoteState.leadingIndex = -1;
      remoteState.selectedIndices = null;
    }
    if (remoteState.children != null) {
      for (var i:int = 0; i < remoteState.children.length; i++) {
        if (remoteState.children[i] is RemoteCompositeValueState) {
          clearStateSelection(remoteState.children[i] as RemoteCompositeValueState, excludedNodes);
        }
      }
    }
  }

  protected function createImageComponent(remoteImageComponent:RImageComponent):UIComponent {
    var imageComponent:Image = new CachedImage();
    imageComponent.scaleContent = false;
    bindImage(imageComponent, remoteImageComponent.state);
    if (remoteImageComponent.scrollable) {
      imageComponent.styleName = "scrollableImage";
      var scrollPane:Canvas = new Canvas();
      scrollPane.addChild(imageComponent);
      return scrollPane;
    } else {
      imageComponent.styleName = "unscrollableImage";
    }
    if (remoteImageComponent.action) {
      getRemotePeerRegistry().register(remoteImageComponent.action);
      imageComponent.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
        // To ensure that the row is selected before the action gets executed.
        imageComponent.callLater(_actionHandler.execute, [remoteImageComponent.action]);
      });
    }
    return imageComponent;
  }

  protected function bindImage(imageComponent:Image, remoteState:RemoteValueState):void {
    var updateView:Function = function (value:Object):void {
      imageComponent.source = value;
    };
    BindingUtils.bindSetter(updateView, remoteState, "value", true);
  }

  protected function createActionComponent(remoteActionComponent:RActionComponent):UIComponent {
    var actionComponent:Button = createAction(remoteActionComponent.action, null);
    return actionComponent;
  }

  protected function createActionField(remoteActionField:RActionField):UIComponent {
    var actionField:HBox = new HBox();
    actionField.styleName = "actionField";
    actionField.regenerateStyleCache(false);
    actionField.horizontalScrollPolicy = ScrollPolicy.OFF;
    actionField.verticalScrollPolicy = ScrollPolicy.OFF;
    var textField:TextInput;
    if (remoteActionField.showTextField) {
      textField = createTextInputComponent();
      actionField.percentWidth = 100.0;
      textField.percentWidth = 100.0;
      textField.name = "tf";
      actionField.addChild(textField);
      sizeMaxComponentWidth(textField, remoteActionField);
    }
    var actionComponents:Array = [];
    for (var i:int = 0; i < remoteActionField.actionLists.length; i++) {
      var actionList:RActionList = remoteActionField.actionLists[i] as RActionList;
      for (var j:int = 0; j < actionList.actions.length; j++) {
        var actionComponent:Button = createAction(actionList.actions[j], actionField);
        actionComponent.addEventListener(FlexEvent.CREATION_COMPLETE, function (event:FlexEvent):void {
          var b:Button = event.currentTarget as Button;
          //noinspection JSSuspiciousNameCombination
          b.width = b.height;
        });
        //actionComponent.focusEnabled = false;
        actionField.addChild(actionComponent);
        actionComponents.push(actionComponent);
      }
    }
    bindActionField(actionField, textField, remoteActionField.state,
                    (remoteActionField.actionLists[0] as RActionList).actions[0], actionComponents);
    return actionField;
  }

  protected function bindActionField(actionField:UIComponent, textInput:TextInput, remoteState:RemoteValueState,
                                     action:RAction, actionComponents:Array):void {

    var updateView:Function = function (value:Object):void {
      if (textInput) {
        if (value == null) {
          textInput.text = null;
        } else {
          textInput.text = value.toString();
        }
      } else {
        if (value == null) {
          actionField.styleName = "emptyActionField";
        } else {
          actionField.styleName = "filledActionField";
        }
      }
    };
    BindingUtils.bindSetter(updateView, remoteState, "value", true);

    if (textInput) {
      var updateEditability:Function = function (value:Object):void {
        if (value) {
          textInput.setStyle("backgroundColor", null);
        } else {
          textInput.setStyle("backgroundColor", textInput.getStyle("backgroundDisabledColor"));
        }
        textInput.editable = value as Boolean;
      };
      BindingUtils.bindSetter(updateEditability, remoteState, "writable");

      var triggerAction:Function = function (event:Event):void {
        var tf:TextInput = (event.currentTarget as TextInput);
        var inputText:String = tf.text;
        if (inputText == null || inputText.length == 0) {
          if (remoteState.value != null && remoteState.value.toString().length > 0) {
            remoteState.value = null;
          }
        } else if (inputText != remoteState.value) {
          if (remoteState.value == null) {
            tf.text = null;
          } else {
            tf.text = remoteState.value.toString();
          }
          if (event is FocusEvent && (event as FocusEvent).relatedObject
            // Not a key focus event
              && ((event as FocusEvent).relatedObject.parent == actionField && (event as FocusEvent).keyCode == 0)) {
            return;
          }
          var actionEvent:RActionEvent = new RActionEvent();
          actionEvent.actionCommand = inputText;
          _actionHandler.execute(action, actionEvent, null, false);
        }
      };
      textInput.addEventListener(FlexEvent.ENTER, triggerAction);
      textInput.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, triggerAction);
      textInput.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, triggerAction);
    }
    for each (var actionComponent:UIComponent in actionComponents) {
      BindingUtils.bindProperty(actionComponent, "enabled", remoteState, "writable");
    }
  }

  protected function createColorField(remoteColorField:RColorField):UIComponent {
    var colorField:HBox = new HBox();
    var colorPicker:ColorPicker = new ColorPicker();
    colorPicker.name = "cc";
    bindColorPicker(colorPicker, remoteColorField.state);
    colorField.addChild(colorPicker);
    var resetButton:Button = createButtonComponent();
    resetButton.setStyle("icon", _resetIcon);
    if (!remoteColorField.resetEnabled) {
      resetButton.enabled = false;
    }
    colorField.addChild(resetButton);
    resetButton.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
      remoteColorField.state.value = remoteColorField.defaultColor;
    });
    var focusIn:Function = function (event:FocusEvent):void {
      var cc:UIComponent = (event.currentTarget as Container).getChildByName("cc") as UIComponent;
      cc.setFocus();
    };
    colorField.addEventListener(FocusEvent.FOCUS_IN, focusIn);
    colorPicker.editable = true;
    return colorField;
  }

  protected function createCheckBox(remoteCheckBox:RCheckBox):UIComponent {
    var checkBox:UIComponent;
    if (remoteCheckBox.triState) {
      checkBox = new CheckBoxExtended();
      (checkBox as CheckBoxExtended).allow3StateForUser = true;
      bindCheckBoxExtended(checkBox as CheckBoxExtended, remoteCheckBox.state);
    } else {
      checkBox = new CheckBox();
      bindCheckBox(checkBox as CheckBox, remoteCheckBox.state);
    }
    sizeMaxComponentWidth(checkBox, remoteCheckBox, 1);
    return checkBox;
  }

  protected function bindCheckBox(checkBox:CheckBox, remoteState:RemoteValueState):void {
    BindingUtils.bindProperty(checkBox, "selected", remoteState, "value", true);
    BindingUtils.bindProperty(remoteState, "value", checkBox, "selected", true);
    BindingUtils.bindProperty(checkBox, "enabled", remoteState, "writable");
  }

  protected function bindCheckBoxExtended(checkBox:CheckBoxExtended, remoteState:RemoteValueState):void {
    var updateView:Function = function (value:Object):void {
      if (value == null) {
        checkBox.middle = true;
        checkBox.selected = false;
      } else {
        checkBox.middle = false;
        checkBox.selected = value as Boolean;
      }
    };
    BindingUtils.bindSetter(updateView, remoteState, "value", true);

    var updateModel:Function = function (event:Event):void {
      if (checkBox.middle) {
        remoteState.value = null;
      } else {
        remoteState.value = checkBox.selected;
      }
    };
    checkBox.addEventListener(MouseEvent.CLICK, updateModel);

    BindingUtils.bindProperty(checkBox, "enabled", remoteState, "writable");
  }

  protected function createComboBox(remoteComboBox:RComboBox):UIComponent {
    var hasIcon:Boolean = false;
    for each(var icon:RIcon in remoteComboBox.icons) {
      if (icon) {
        hasIcon = true;
        break;
      }
    }
    if (remoteComboBox.readOnly) {
      var label:RIconLabel = new RIconLabel();
      var labels:Object = {};
      var icons:Object = {};

      for (var i:int = 0; i < remoteComboBox.values.length; i++) {
        labels[remoteComboBox.values[i] as String] = remoteComboBox.translations[i];
        icons[remoteComboBox.values[i] as String] = remoteComboBox.icons[i];
      }
      label.labels = labels;
      label.icons = icons;
      label.showIcon = hasIcon;

      BindingUtils.bindProperty(label, "value", remoteComboBox.state, "value", true);
      return label;
    } else {
      var comboBox:RIconComboBox = createComboBoxComponent();
      comboBox.dataProvider = remoteComboBox.values;
      comboBox.labels = remoteComboBox.translations;
      comboBox.icons = remoteComboBox.icons;
      comboBox.showIcon = hasIcon;
      bindComboBox(comboBox, remoteComboBox);

      var itemRenderer:ClassFactory = new ClassFactory(RIconListItemRenderer);
      itemRenderer.properties = {labels: remoteComboBox.translations, icons: remoteComboBox.icons, iconTemplate: _iconTemplate, showIcon: hasIcon};
      comboBox.itemRenderer = itemRenderer;

      var maxTr:String = "";
      for each(var tr:String in remoteComboBox.translations) {
        if (tr.length > maxTr.length) {
          maxTr = tr;
        }
      }
      sizeMaxComponentWidthFromText(comboBox, remoteComboBox, maxTr);
      // For Arrow
      comboBox.maxWidth += 30;
      if (hasIcon) {
        comboBox.maxWidth += ICON_WIDTH;
      }
      comboBox.minWidth = comboBox.maxWidth / 2;
      return comboBox;
    }
  }

  public function createComboBoxComponent():RIconComboBox {
    return new RIconComboBox();
  }

  protected function bindComboBox(comboBox:RIconComboBox, remoteComboBox:RComboBox):void {
    BindingUtils.bindProperty(comboBox, "selectedItem", remoteComboBox.state, "value", true);
    BindingUtils.bindProperty(remoteComboBox.state, "value", comboBox, "selectedItem", true);
    BindingUtils.bindProperty(comboBox, "enabled", remoteComboBox.state, "writable");
  }

  protected function createRadioBox(remoteRadioBox:RRadioBox):UIComponent {
    var radioBox:Box = new Box();
    if (remoteRadioBox.orientation == "HORIZONTAL") {
      radioBox.direction = BoxDirection.HORIZONTAL;
    } else {
      radioBox.direction = BoxDirection.VERTICAL;
    }
    var radioGroup:RadioButtonGroup = new RadioButtonGroup();
    for (var i:int = 0; i < remoteRadioBox.values.length; i++) {
      var rb:RadioButton = createRadioButtonComponent();
      rb.value = remoteRadioBox.values[i];
      rb.label = remoteRadioBox.translations[i];
      rb.group = radioGroup;
      sizeMaxComponentWidth(rb, remoteRadioBox, rb.label.length + 5);
      radioBox.addChild(rb);
      // enabled state is not correctly reflected initially without this line.
      rb.enabled = remoteRadioBox.state.writable;
    }
    bindRadioGroup(radioGroup, remoteRadioBox);
    return radioBox;
  }

  public function createRadioButtonComponent():RadioButton {
    return new RadioButton();
  }

  protected function bindRadioGroup(radioGroup:RadioButtonGroup, remoteRadioBox:RRadioBox):void {
    var remoteState:RemoteValueState = remoteRadioBox.state;
    radioGroup.addEventListener(ItemClickEvent.ITEM_CLICK, function (event:ItemClickEvent):void {
      remoteState.value = (event.relatedObject as RadioButton).value;
    });
    BindingUtils.bindProperty(radioGroup, "selectedValue", remoteState, "value");
    BindingUtils.bindProperty(radioGroup, "enabled", remoteState, "writable");
  }

  protected function createBorderContainer(remoteBorderContainer:RBorderContainer):Container {
    var borderContainer:Grid = new Grid();
    borderContainer.styleName = "borderContainer";

    var row:GridRow;
    var cell:GridItem;
    var cellComponent:UIComponent;

    var nbCols:int = 1;
    if (remoteBorderContainer.west != null) {
      nbCols++;
    }
    if (remoteBorderContainer.east != null) {
      nbCols++;
    }

    // NORTH
    if (remoteBorderContainer.north != null) {
      row = new GridRow();
      row.percentWidth = 100.0;
//        row.setStyle("borderStyle","solid");
//        row.setStyle("borderColor","0x00FF00");
      borderContainer.addChild(row);

      cell = new GridItem();
      cell.styleName = "northCell";
      cell.horizontalScrollPolicy = ScrollPolicy.OFF;
      cell.verticalScrollPolicy = ScrollPolicy.OFF;
      cell.colSpan = nbCols;
      cell.percentWidth = 100.0;
      if (remoteBorderContainer.north != null) {
        cellComponent = createComponent(remoteBorderContainer.north);
        if (cellComponent.height > 0) {
          cell.height = cellComponent.height;
          cell.height += 4;
        }
        cellComponent.percentWidth = 100.0;
        cellComponent.percentHeight = 100.0;
        cell.addChild(cellComponent);
      }
      row.addChild(cell);
    }

    // WEST, CENTER, EAST
    row = new GridRow();
    row.percentWidth = 100.0;
    row.percentHeight = 100.0;
//      row.setStyle("borderStyle","solid");
//      row.setStyle("borderColor","0xFF0000");
    borderContainer.addChild(row);

    if (remoteBorderContainer.west != null) {
      cellComponent = createComponent(remoteBorderContainer.west);
      cell = new GridItem();
      cell.styleName = "westCell";
      cell.horizontalScrollPolicy = ScrollPolicy.OFF;
      cell.verticalScrollPolicy = ScrollPolicy.OFF;
      cell.percentHeight = 100.0;
      cell.minWidth = cellComponent.minWidth;
      if (cellComponent.width > 0) {
        cell.width = cellComponent.width;
        cell.width += 2;
      }
      if (cellComponent.maxWidth > 0) {
        cell.maxWidth = cellComponent.maxWidth;
        cell.maxWidth += 2;
      }
      cellComponent.percentWidth = 100.0;
      cellComponent.percentHeight = 100.0;
      cell.addChild(cellComponent);
      row.addChild(cell);
    }

    cell = new GridItem();
    cell.styleName = "centerCell";
    cell.horizontalScrollPolicy = ScrollPolicy.OFF;
    cell.verticalScrollPolicy = ScrollPolicy.OFF;
    cell.percentHeight = 100.0;
    cell.percentWidth = 100.0;
    if (remoteBorderContainer.center != null) {
      cellComponent = createComponent(remoteBorderContainer.center);
      cellComponent.percentWidth = 100.0;
      cellComponent.percentHeight = 100.0;
//        cellComponent.setStyle("borderStyle","solid");
//        cellComponent.setStyle("borderColor","0xFF0000");
      cell.addChild(cellComponent);
    }
//      cell.setStyle("borderStyle","solid");
//      cell.setStyle("borderColor","0x00FF00");
    row.addChild(cell);

    if (remoteBorderContainer.east != null) {
      cellComponent = createComponent(remoteBorderContainer.east);
      cell = new GridItem();
      cell.styleName = "eastCell";
      cell.horizontalScrollPolicy = ScrollPolicy.OFF;
      cell.verticalScrollPolicy = ScrollPolicy.OFF;
      cell.percentHeight = 100.0;
      cell.minWidth = cellComponent.minWidth;
      if (cellComponent.width > 0) {
        cell.width = cellComponent.width;
        cell.width += 2;
      }
      if (cellComponent.maxWidth > 0) {
        cell.maxWidth = cellComponent.maxWidth;
        cell.maxWidth += 2;
      }
      cellComponent.percentWidth = 100.0;
      cellComponent.percentHeight = 100.0;
      cell.addChild(cellComponent);
      row.addChild(cell);
    }

    if (remoteBorderContainer.south != null) {
      // SOUTH
      row = new GridRow();
      row.percentWidth = 100.0;
//        row.setStyle("borderStyle","solid");
//        row.setStyle("borderColor","0x0000FF");
      borderContainer.addChild(row);
      cell = new GridItem();
      cell.styleName = "southCell";
      cell.horizontalScrollPolicy = ScrollPolicy.OFF;
      cell.verticalScrollPolicy = ScrollPolicy.OFF;
      cell.colSpan = nbCols;
      cell.percentWidth = 100.0;
      if (remoteBorderContainer.south != null) {
        cellComponent = createComponent(remoteBorderContainer.south);
        if (cellComponent.height > 0) {
          cell.height = cellComponent.height;
          cell.height += 4;
        }
        cellComponent.percentWidth = 100.0;
        cellComponent.percentHeight = 100.0;
        cell.addChild(cellComponent);
      }
      row.addChild(cell);
    }

//      borderContainer.setStyle("borderStyle","solid");
//      borderContainer.setStyle("borderColor","0xFF0000");
    return borderContainer;
  }

  protected function createCardContainer(remoteCardContainer:RCardContainer):Container {
    var cardContainer:ViewStack = new ViewStack();
    for (var i:int = 0; i < remoteCardContainer.cardNames.length; i++) {
      var rCardComponent:RComponent = remoteCardContainer.cards[i] as RComponent;
      var cardName:String = remoteCardContainer.cardNames[i] as String;

      addCard(cardContainer, rCardComponent, cardName);
    }
    bindCardContainer(cardContainer, remoteCardContainer.state);

    return cardContainer;
  }

  public function addCard(cardContainer:ViewStack, rCardComponent:RComponent, cardName:String):void {
    var existingCard:Container = cardContainer.getChildByName(cardName) as Container;
    if (existingCard == null) {
      var cardCanvas:Canvas = new Canvas();
      cardCanvas.percentWidth = 100.0;
      cardCanvas.percentHeight = 100.0;
      cardCanvas.horizontalScrollPolicy = ScrollPolicy.OFF;
      cardCanvas.verticalScrollPolicy = ScrollPolicy.OFF;
      cardCanvas.name = cardName;
      cardContainer.addChild(cardCanvas);

      var cardComponent:UIComponent = createComponent(rCardComponent);
      cardComponent.percentWidth = 100.0;
      cardComponent.percentHeight = 100.0;
      cardCanvas.addChild(cardComponent);
    }
  }

  protected function bindCardContainer(cardContainer:ViewStack, remoteState:RemoteValueState):void {
    var selectCard:Function = function (value:Object):void {
      if (value == null) {
        //TODO check why null
        //cardContainer.selectedChild = null;
      } else {
        var selectedCard:Container = cardContainer.getChildByName(value as String) as Container;
        if (selectedCard) {
          cardContainer.selectedChild = selectedCard;
        }
      }
    };
    BindingUtils.bindSetter(selectCard, remoteState, "value", true);
  }

  protected function createConstrainedGridContainer(remoteConstrainedGridContainer:RConstrainedGridContainer):Container {
    var constrainedGridContainer:Grid = new Grid();
    constrainedGridContainer.styleName = "constrainedGridContainer";

    var i:int;
    var j:int;
    var nbCols:int = 0;
    var row:GridRow;
    var cell:GridItem;
    var cellConstraints:CellConstraints;

    // Compute and add rows and columns.
    for (i = 0; i < remoteConstrainedGridContainer.cellConstraints.length; i++) {
      cellConstraints = remoteConstrainedGridContainer.cellConstraints[i] as CellConstraints;
      if (cellConstraints.row + cellConstraints.height > constrainedGridContainer.getChildren().length) {
        for (j = cellConstraints.row + cellConstraints.height - constrainedGridContainer.getChildren().length - 1;
             j >= 0; j--) {
          row = new GridRow();
          row.percentWidth = 100.0;
          constrainedGridContainer.addChild(row);
        }
      }
      if (cellConstraints.column + cellConstraints.width > nbCols) {
        nbCols = cellConstraints.column + cellConstraints.width;
      }
    }
    // Add cells
    for (i = 0; i < constrainedGridContainer.getChildren().length; i++) {
      row = constrainedGridContainer.getChildAt(i) as GridRow;
      for (j = 0; j < nbCols; j++) {
        cell = new GridItem();
        cell.horizontalScrollPolicy = ScrollPolicy.OFF;
        cell.verticalScrollPolicy = ScrollPolicy.OFF;
        row.addChild(cell);
      }
    }

    // Add cell components
    for (i = 0; i < remoteConstrainedGridContainer.cellConstraints.length; i++) {
      cellConstraints = remoteConstrainedGridContainer.cellConstraints[i] as CellConstraints;
      row = constrainedGridContainer.getChildAt(cellConstraints.row) as GridRow;
      cell = row.getChildAt(cellConstraints.column) as GridItem;
      cell.colSpan = cellConstraints.width;
      if (cellConstraints.widthResizable) {
        cell.percentWidth = 100.0;
      }
      cell.rowSpan = cellConstraints.height;
      if (cellConstraints.heightResizable) {
        cell.percentHeight = 100.0;
        // Make last spanning row resizable
        (constrainedGridContainer.getChildAt(cellConstraints.row + cellConstraints.height - 1)
            as GridRow).percentHeight = 100.0;
      }

      var cellComponent:UIComponent = createComponent(remoteConstrainedGridContainer.cells[i] as RComponent);
      cellComponent.percentWidth = 100.0;
      cellComponent.percentHeight = 100.0;
      cell.addChild(cellComponent);
    }

    // Cleanup unused cells
    for (i = 0; i < constrainedGridContainer.getChildren().length; i++) {
      row = constrainedGridContainer.getChildAt(i) as GridRow;
      for (j = row.getChildren().length - 1; j >= 0; j--) {
        cell = row.getChildAt(j) as GridItem;
        if (cell.getChildren().length == 0) {
          // Cell is empty
          row.removeChildAt(j);
        }
      }
    }

    return constrainedGridContainer;
  }

  protected function createEvenGridContainer(remoteEvenGridContainer:REvenGridContainer):Container {
    var evenGridContainer:Grid = new Grid();
    evenGridContainer.styleName = "evenGridContainer";

    var nbRows:int;
    var nbCols:int;
    var i:int;

    var row:int = 0;
    var col:int = 0;
    var gridRow:GridRow;
    var cell:GridItem;
    var cellComponent:UIComponent;

    if (remoteEvenGridContainer.drivingDimension == "ROW") {
      nbRows = remoteEvenGridContainer.cells.length / remoteEvenGridContainer.drivingDimensionCellCount;
      if (remoteEvenGridContainer.cells.length % remoteEvenGridContainer.drivingDimensionCellCount > 0) {
        nbRows += 1;
      }
      nbCols = remoteEvenGridContainer.drivingDimensionCellCount;
    } else {
      nbRows = remoteEvenGridContainer.drivingDimensionCellCount;
      nbCols = remoteEvenGridContainer.cells.length / remoteEvenGridContainer.drivingDimensionCellCount;
      if (remoteEvenGridContainer.cells.length % remoteEvenGridContainer.drivingDimensionCellCount > 0) {
        nbCols += 1;
      }
    }
    for (i = 0; i < nbRows; i++) {
      var gr:GridRow = new GridRow();
      gr.percentHeight = 100.0;
      gr.percentWidth = 100.0;
      evenGridContainer.addChild(gr);
    }
    for (i = 0; i < remoteEvenGridContainer.cells.length; i++) {

      gridRow = evenGridContainer.getChildAt(row) as GridRow;

      cell = new GridItem();
      cell.horizontalScrollPolicy = ScrollPolicy.OFF;
      cell.verticalScrollPolicy = ScrollPolicy.OFF;
      cell.percentHeight = 100.0;
      cell.percentWidth = 100.0;
      gridRow.addChild(cell);

      cellComponent = createComponent(remoteEvenGridContainer.cells[i] as RComponent);
      cellComponent.percentWidth = 100.0;
      cellComponent.percentHeight = 100.0;
      cell.addChild(cellComponent);

      if (remoteEvenGridContainer.drivingDimension == "ROW") {
        col++;
        if (col == nbCols) {
          col = 0;
          row++;
        }
      } else if (remoteEvenGridContainer.drivingDimension == "COLUMN") {
        row++;
        if (row == nbRows) {
          row = 0;
          col++;
        }
      }
    }
    return evenGridContainer;
  }

  protected function createForm(remoteForm:RForm):Container {
    var form:Grid = new Grid();
    var col:int = 0;
    var labelsRow:GridRow;
    var componentsRow:GridRow;

    form.styleName = "form";

    componentsRow = new GridRow();
    componentsRow.percentWidth = 100.0;
    if (remoteForm.labelsPosition == "ABOVE") {
      labelsRow = new GridRow();
      labelsRow.percentWidth = 100.0;
      form.addChild(labelsRow);
    } else if (remoteForm.labelsPosition == "ASIDE") {
      labelsRow = componentsRow;
    } else if (remoteForm.labelsPosition == "NONE") {
      labelsRow = componentsRow;
    }
    form.addChild(componentsRow);
    for (var i:int = 0; i < remoteForm.elements.length; i++) {
      var elementWidth:int = remoteForm.elementWidths[i] as int;
      var rComponent:RComponent = remoteForm.elements[i] as RComponent;
      var rComponentLabel:RComponent = remoteForm.elementLabels[i] as RComponent;
      var component:UIComponent = createComponent(rComponent);
      var componentLabel:UIComponent;
      var labelCell:GridItem;

      if (rComponent is RSecurityComponent) {
        sizeMaxComponentWidth(component, rComponent);
      } else {
        bindDynamicAspects(component, rComponent);
      }

      if (remoteForm.labelsPosition != "NONE") {
        componentLabel = createComponent(rComponentLabel, false);
        if (componentLabel.maxWidth > 0) {
          componentLabel.maxWidth = NaN;
        }
        labelCell = new GridItem();
        labelCell.horizontalScrollPolicy = ScrollPolicy.OFF;
        labelCell.verticalScrollPolicy = ScrollPolicy.OFF;
      }

      var componentCell:GridItem = new GridItem();
      if (rComponent is RLabel || rComponent is RCheckBox) {
        componentCell.styleName = "labelComponentCell";
        component.setStyle("paddingRight", 4);
      } else {
        componentCell.styleName = "componentCell";
      }
      componentCell.horizontalScrollPolicy = ScrollPolicy.OFF;
      componentCell.verticalScrollPolicy = ScrollPolicy.OFF;

      if (elementWidth > remoteForm.columnCount) {
        elementWidth = remoteForm.columnCount;
      }
      if (col + elementWidth > remoteForm.columnCount) {
        componentsRow = new GridRow();
        componentsRow.percentWidth = 100.0;
        if (remoteForm.labelsPosition == "ABOVE") {
          labelsRow = new GridRow();
          labelsRow.percentWidth = 100.0;
          form.addChild(labelsRow);
        } else if (remoteForm.labelsPosition == "ASIDE") {
          labelsRow = componentsRow;
        } else if (remoteForm.labelsPosition == "NONE") {
          labelsRow = componentsRow;
        }
        form.addChild(componentsRow);
        col = 0;
      }

      if (remoteForm.labelsPosition == "ABOVE") {
        labelCell.styleName = "aboveLabelCell";
        labelCell.colSpan = elementWidth;
        componentCell.colSpan = elementWidth;
      } else if (remoteForm.labelsPosition == "ASIDE") {
        labelCell.styleName = "asideLabelCell";
        componentCell.colSpan = (elementWidth * 2) - 1;
      } else if (remoteForm.labelsPosition == "NONE") {
        componentCell.colSpan = elementWidth;
      }

      if (remoteForm.labelsPosition != "NONE") {
        //labelCell.setStyle("borderStyle","solid");
        //labelCell.setStyle("borderColor","0x00FF00");
        labelsRow.addChild(labelCell);
        if (rComponentLabel.label || rComponentLabel.icon) {
          labelCell.addChild(componentLabel);
          // makes alignment wrong
          //if(remoteForm.labelsPosition == "ASIDE") {
          //  labelCell.maxWidth = componentLabel.maxWidth;
          //}
        } else {
          if (remoteForm.labelsPosition == "ASIDE") {
            labelCell.maxWidth = 0;
          }
        }
      }

      componentCell.percentWidth = 100.0;
      componentCell.percentHeight = 100.0;
      componentCell.minWidth = 0;
      //        componentCell.setStyle("borderStyle","solid");
      //        componentCell.setStyle("borderColor","0xFF0000");
      //        component.setStyle("borderStyle","solid");
      //        component.setStyle("borderColor","0x0000FF");
      if (rComponent is RTable || rComponent is RTextArea || rComponent is RList || rComponent is RHtmlArea) {
        component.percentWidth = 100.0;
        component.percentHeight = 100.0;
        componentsRow.percentHeight = 100.0;
        if (componentCell.colSpan > 1 || componentCell.colSpan == remoteForm.columnCount) {
          componentCell.maxWidth = NaN;
          component.maxWidth = NaN;
        }
      } else if (component.maxWidth >= 0 && component.maxWidth < (UIComponent.DEFAULT_MAX_WIDTH / 2)) {
        component.percentWidth = 100.0;
        if (elementWidth == 1 && (col + elementWidth < remoteForm.columnCount)) {
          componentCell.maxWidth = component.maxWidth;
          componentCell.width = component.maxWidth;
        } else {
          //Allow last cell and span > 1 cells to grow
          componentCell.percentWidth = 100.0;
        }
      }
      if (component.minWidth > 0) {
        componentCell.minWidth = component.minWidth;
      } else {
        componentCell.minWidth = 0;
      }
      componentsRow.addChild(componentCell);
      componentCell.addChild(component);

      col += elementWidth;
    }

    // to deal with resizing problems
    var resizerRow:GridRow = new GridRow();
    resizerRow.percentWidth = 100.0;
    for (i = 0; i < remoteForm.columnCount; i++) {
      var gi:GridItem = new GridItem();
      resizerRow.addChild(gi);
      if (remoteForm.labelsPosition == "ASIDE") {
        gi = new GridItem();
        gi.percentWidth = 100.0;
        resizerRow.addChild(gi);
      } else {
        gi.percentWidth = 100.0;
      }
    }
    form.addChild(resizerRow);
    // Special toolTip handling
    var remoteState:RemoteValueState = remoteForm.state;
    var updateToolTip:Function = function (value:Object):void {
      form.toolTip = value as String;
    };
    BindingUtils.bindSetter(updateToolTip, remoteState, "value", true);
    form.horizontalScrollPolicy = ScrollPolicy.OFF;
    form.verticalScrollPolicy = ScrollPolicy.OFF;
    var decoratedForm:Container = form;
    if (remoteForm.verticallyScrollable) {
      var scroller:Canvas = new Canvas();
      form.percentWidth = 100.0;
      form.percentHeight = 100.0;
      scroller.addChild(form);
      scroller.horizontalScrollPolicy = ScrollPolicy.OFF;
      scroller.verticalScrollPolicy = ScrollPolicy.AUTO;
      scroller.addEventListener(FlexEvent.CREATION_COMPLETE, function (e:FlexEvent):void {
        scroller.width = form.getExplicitOrMeasuredWidth();
        scroller.height = form.getExplicitOrMeasuredHeight();
      });
      decoratedForm = scroller;
    }
    return decoratedForm;
  }

  private function bindDynamicAspects(component:UIComponent, rComponent:RComponent):void {
    if (component is Container) {
      for each(var child:UIComponent in (component as Container).getChildren()) {
        bindDynamicAspects(child, rComponent);
      }
    } else {
      bindDynamicToolTip(component, rComponent);
      bindDynamicBackground(component, rComponent);
      bindDynamicForeground(component, rComponent);
      bindDynamicFont(component, rComponent);
    }
  }

  protected function bindDynamicToolTip(component:UIComponent, rComponent:RComponent):void {
    if (rComponent.toolTipState) {
      getRemotePeerRegistry().register(rComponent.toolTipState);
      var updateToolTip:Function = function (value:Object):void {
        component.toolTip = value as String;
      };
      BindingUtils.bindSetter(updateToolTip, rComponent.toolTipState, "value", true);
    }
  }

  protected function bindDynamicBackground(component:UIComponent, rComponent:RComponent):void {
    if (rComponent.backgroundState) {
      getRemotePeerRegistry().register(rComponent.backgroundState);
      var updateBackground:Function = function (value:Object):void {
        if (value) {
          component.setStyle("backgroundColor", value);
          component.setStyle("backgroundAlpha", getAlphaFromArgb(value as String));
        } else {
          component.setStyle("backgroundColor", null);
          component.setStyle("backgroundAlpha", null);
        }
      };
      BindingUtils.bindSetter(updateBackground, rComponent.backgroundState, "value", true);
    }
  }

  protected function bindDynamicForeground(component:UIComponent, rComponent:RComponent):void {
    if (rComponent.foregroundState) {
      getRemotePeerRegistry().register(rComponent.foregroundState);
      var updateForeground:Function = function (value:Object):void {
        if (value) {
          component.setStyle("color", value);
          component.setStyle("alpha", getAlphaFromArgb(value as String));
        } else {
          component.setStyle("color", null);
          component.setStyle("alpha", null);
        }
      };
      BindingUtils.bindSetter(updateForeground, rComponent.foregroundState, "value", true);
    }
  }

  protected function bindDynamicFont(component:UIComponent, rComponent:RComponent):void {
    if (rComponent.fontState) {
      getRemotePeerRegistry().register(rComponent.fontState);
      var updateFont:Function = function (value:Object):void {
        if (value is Font) {
          if ((value as Font).name) {
            component.setStyle("fontFamily", (value as Font).name);
          }
          if ((value as Font).size > 0) {
            component.setStyle("fontSize", (value as Font).size);
          }
          if ((value as Font).italic) {
            component.setStyle("fontStyle", "italic");
          }
          if ((value as Font).bold) {
            component.setStyle("fontWeight", "bold");
          }
        } else {
          component.setStyle("fontFamily", null);
          component.setStyle("fontSize", null);
          component.setStyle("fontStyle", null);
          component.setStyle("fontWeight", null);
        }
      };
      BindingUtils.bindSetter(updateFont, rComponent.fontState, "value", true);
    }
  }

  protected function createSplitContainer(remoteSplitContainer:RSplitContainer):Container {
    var splitContainer:DividedBox = new DividedBox();
    splitContainer.resizeToContent = !(remoteSplitContainer.preferredSize != null
        && (remoteSplitContainer.preferredSize.height > 0 || remoteSplitContainer.preferredSize.width > 0));
    splitContainer.liveDragging = true;

    var component:UIComponent;
    if (remoteSplitContainer.orientation == "VERTICAL") {
      splitContainer.direction = BoxDirection.VERTICAL;
    } else {
      splitContainer.direction = BoxDirection.HORIZONTAL;
    }
    if (remoteSplitContainer.leftTop != null) {
      component = createComponent(remoteSplitContainer.leftTop);
      if (remoteSplitContainer.orientation == "VERTICAL") {
        component.percentWidth = 100.0;
      } else {
        component.percentHeight = 100.0;
      }
      splitContainer.addChild(component);
    }
    if (remoteSplitContainer.rightBottom != null) {
      component = createComponent(remoteSplitContainer.rightBottom);
      if (remoteSplitContainer.orientation == "VERTICAL") {
        component.percentWidth = 100.0;
      } else {
        component.percentHeight = 100.0;
      }

      splitContainer.addChild(component);
    }
    splitContainer.addEventListener(FlexEvent.CREATION_COMPLETE, function (event:FlexEvent):void {
      var splitC:DividedBox = event.currentTarget as DividedBox;
      var leftTop:UIComponent = (splitC.getChildAt(0) as UIComponent);
      var rightBottom:UIComponent = (splitC.getChildAt(1) as UIComponent);
      if (leftTop && rightBottom) {
        if (remoteSplitContainer.orientation == "VERTICAL") {
          var topHeight:Number;
          var bottomHeight:Number;
          if (leftTop.height > 0) {
            topHeight = leftTop.height;
          } else {
            topHeight = leftTop.measuredHeight;
          }
          if (rightBottom.height > 0) {
            bottomHeight = rightBottom.height;
          } else {
            bottomHeight = rightBottom.measuredHeight;
          }
          leftTop.percentHeight = (topHeight * 100.0) / (topHeight + bottomHeight);
          rightBottom.percentHeight = (bottomHeight * 100.0) / (topHeight + bottomHeight);
        } else {
          var leftWidth:Number;
          var rightWidth:Number;
          if (leftTop.width > 0) {
            leftWidth = leftTop.width;
          } else {
            leftWidth = leftTop.measuredWidth;
          }
          if (rightBottom.width > 0) {
            rightWidth = rightBottom.width;
          } else {
            rightWidth = rightBottom.measuredWidth;
          }
          leftTop.percentWidth = (leftWidth * 100.0) / (leftWidth + rightWidth);
          rightBottom.percentWidth = (rightWidth * 100.0) / (leftWidth + rightWidth);
        }
      }
    });
    return splitContainer;
  }

  protected function createTabContainer(remoteTabContainer:RTabContainer):Container {
    var tabContainer:TabNavigator = createTabNavigatorComponent();
    tabContainer.historyManagementEnabled = false;
    tabContainer.resizeToContent = !(remoteTabContainer.preferredSize != null
        && (remoteTabContainer.preferredSize.height > 0 || remoteTabContainer.preferredSize.width > 0));

    for (var i:int = 0; i < remoteTabContainer.tabs.length; i++) {
      var rTab:RComponent = remoteTabContainer.tabs[i] as RComponent;
      var tabContent:UIComponent = createComponent(rTab);
      tabContent.percentWidth = 100.0;
      tabContent.percentHeight = 100.0;

      var tabCanvas:Canvas = new Canvas();
      tabCanvas.percentWidth = 100.0;
      tabCanvas.percentHeight = 100.0;
      tabCanvas.label = rTab.label;
      tabCanvas.horizontalScrollPolicy = ScrollPolicy.OFF;
      tabCanvas.verticalScrollPolicy = ScrollPolicy.OFF;
      tabContainer.addChild(tabCanvas);
      if (rTab.toolTip != null) {
        tabCanvas.toolTip = rTab.toolTip;
      }
      var fixTabSize:Function = function (event:FlexEvent):void {
        if (event.target is Canvas) {
          var tabC:Canvas = event.target as Canvas;
          tabC.measuredWidth = (tabC.getChildAt(0) as UIComponent).measuredWidth;
          tabC.measuredHeight = (tabC.getChildAt(0) as UIComponent).measuredHeight;
          //noinspection JSReferencingMutableVariableFromClosure
          tabC.removeEventListener(FlexEvent.CREATION_COMPLETE, fixTabSize);
        }
      };
      tabCanvas.addEventListener(FlexEvent.CREATION_COMPLETE, fixTabSize);
      tabCanvas.addChild(tabContent);
    }

    var assignTabsIcons:Function = function (event:FlexEvent):void {
      if (event.target is TabNavigator) {
        var tabContainer:TabNavigator = event.target as TabNavigator;
        for (var tabIndex:int = 0; tabIndex < tabContainer.getChildren().length; tabIndex++) {
          var tabButton:Button = tabContainer.getTabAt(tabIndex);
          tabButton.setStyle("icon",
                             getIconForComponent(tabButton, (remoteTabContainer.tabs[tabIndex] as RComponent).icon));
          var tab:UIComponent = tabContainer.getChildAt(tabIndex) as UIComponent;
          if (tab.getExplicitOrMeasuredWidth() > tabContainer.getExplicitOrMeasuredWidth()) {
            tabContainer.measuredWidth = tab.getExplicitOrMeasuredWidth();
          }
          if (tab.getExplicitOrMeasuredHeight() > tabContainer.getExplicitOrMeasuredHeight()) {
            tabContainer.measuredHeight = tab.getExplicitOrMeasuredHeight();
          }
        }
        tabContainer.removeEventListener(FlexEvent.CREATION_COMPLETE, assignTabsIcons);
      }
    };
    tabContainer.addEventListener(FlexEvent.CREATION_COMPLETE, assignTabsIcons);

    BindingUtils.bindProperty(tabContainer, "selectedIndex", remoteTabContainer, "selectedIndex", true);
    BindingUtils.bindSetter(function (index:int):void {
      remoteTabContainer.selectedIndex = index;
      var command:RemoteSelectionCommand = new RemoteSelectionCommand();
      command.targetPeerGuid = remoteTabContainer.guid;
      command.permId = remoteTabContainer.permId;
      command.leadingIndex = index;
      _commandHandler.registerCommand(command);
    }, tabContainer, "selectedIndex", true);
    return tabContainer;
  }

  public function createTabNavigatorComponent():TabNavigator {
    return new EnhancedTabNavigator();
  }

  protected function createDateComponent(remoteDateField:RDateField):UIComponent {
    var dateComponent:UIComponent;
    if (remoteDateField.type == "DATE_TIME") {
      dateComponent = createDateTimeField(remoteDateField);
    } else {
      dateComponent = createDateField(remoteDateField);
    }
    return dateComponent;
  }

  protected function createDateField(remoteDateField:RDateField):UIComponent {
    var dateField:DateField = new EnhancedDateField();
    dateField.firstDayOfWeek = firstDayOfWeek;
    dateField.formatString = datePattern;
    dateField.parseFunction = DateUtils.parseDate;
    dateField.editable = true;
    sizeMaxComponentWidthFromText(dateField, remoteDateField, DATE_TEMPLATE);
    dateField.maxWidth += ICON_WIDTH;
    dateField.minWidth = dateField.maxWidth;
    bindDateField(dateField, remoteDateField);
    return dateField;
  }

  protected function bindDateField(dateField:DateField, remoteDateField:RDateField):void {
    var remoteState:RemoteValueState = remoteDateField.state;
    var updateView:Function = function (value:Object):void {
      if (value == null) {
        dateField.selectedDate = null;
        if (dateField.dropdown) {
          dateField.dropdown.selectedDate = new Date();
        }
      } else {
        if (value is DateDto) {
          dateField.selectedDate = DateUtils.fromDateDto(value as DateDto);
        } else {
          dateField.selectedDate = value as Date;
        }
      }
    };
    BindingUtils.bindSetter(updateView, remoteState, "value", true);
    BindingUtils.bindProperty(dateField, "enabled", remoteState, "writable");
    var updateModel:Function = function (event:Event):void {
      if (dateField.text == "") {
        dateField.selectedDate = null;
        remoteState.value = null;
      } else {
        var processEvent:Boolean = true;
        if (event is FocusEvent) {
          var currentTarget:UIComponent = (event as FocusEvent).currentTarget as UIComponent;
          var relatedObject:DisplayObject = (event as FocusEvent).relatedObject as DisplayObject;

          if (currentTarget != dateField || (relatedObject != null && (    dateField.contains(relatedObject)
              || dateField.dropdown.contains(relatedObject)
              )
              )) {
            // do not listen to inner focus events.
            processEvent = false;
          }
        }
        if (processEvent) {
          var parsedDate:Date = DateUtils.parseDate(dateField.text, dateField.formatString);
          var selectedDate:Date = dateField.selectedDate;
          if (ObjectUtil.compare(parsedDate, selectedDate) == 0) {
            if (remoteState.value) {
              var currentAsDate:Date;
              if (remoteState.value is DateDto) {
                currentAsDate = DateUtils.fromDateDto(remoteState.value as DateDto);
              } else {
                currentAsDate = remoteState.value as Date;
              }
              // copy the existing time portion
              selectedDate.setHours(currentAsDate.getHours(), currentAsDate.getMinutes(), currentAsDate.getSeconds(),
                                    currentAsDate.getMilliseconds());
            }
            if (remoteDateField.timezoneAware) {
              remoteState.value = selectedDate;
            } else {
              remoteState.value = DateUtils.fromDate(selectedDate);
            }
          } else {
            // rollback text update
            var ti:TextInput = (dateField.getChildAt(2) as TextInput);
            if (ti) {
              var valueAsDate:Date;
              if (remoteState.value is DateDto) {
                valueAsDate = DateUtils.fromDateDto(remoteState.value as DateDto);
              } else {
                valueAsDate = remoteState.value as Date;
              }
              ti.text = DateField.dateToString(valueAsDate, dateField.formatString);
            }
          }
        }
      }
    };
    dateField.addEventListener(FlexEvent.ENTER, updateModel);
    dateField.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, updateModel);
    dateField.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, updateModel);
  }

  protected function createDateTimeField(remoteDateField:RDateField):UIComponent {
    var dateTimeField:HBox = new HBox();
    dateTimeField.styleName = "dateTimeField";
    dateTimeField.horizontalScrollPolicy = ScrollPolicy.OFF;
    dateTimeField.verticalScrollPolicy = ScrollPolicy.OFF;

    var dateField:UIComponent = createDateField(remoteDateField);

    var remoteTimeField:RTimeField = new RTimeField();
    remoteTimeField.background = remoteDateField.background;
    remoteTimeField.borderType = remoteDateField.borderType;
    remoteTimeField.font = remoteDateField.font;
    remoteTimeField.foreground = remoteDateField.foreground;
    remoteTimeField.guid = remoteDateField.guid;
    remoteTimeField.state = remoteDateField.state;
    remoteTimeField.toolTip = remoteDateField.toolTip;
    remoteTimeField.secondsAware = remoteDateField.secondsAware;
    remoteTimeField.useDateDto(!remoteDateField.timezoneAware);

    var timeField:TextInput = createComponent(remoteTimeField, false) as TextInput;

    dateTimeField.addChild(dateField);
    dateTimeField.addChild(timeField);

    dateTimeField.maxWidth = dateField.maxWidth + timeField.maxWidth + 5;
    dateTimeField.minWidth = dateTimeField.maxWidth;

    return dateTimeField;
  }

  protected function createTimeField(remoteTimeField:RTimeField):UIComponent {
    var timeField:TextInput = createTextInputComponent();
    if (remoteTimeField.secondsAware) {
      sizeMaxComponentWidthFromText(timeField, remoteTimeField, LONG_TIME_TEMPLATE);
    } else {
      sizeMaxComponentWidthFromText(timeField, remoteTimeField, SHORT_TIME_TEMPLATE);
    }
    timeField.minWidth = timeField.maxWidth;
    bindTextInput(timeField, remoteTimeField.state, createFormatter(remoteTimeField), createParser(remoteTimeField));
    return timeField;
  }

  protected function createDecimalField(remoteDecimalField:RDecimalField):UIComponent {
    var decimalField:TextInput = createTextInputComponent();
    var decimalFormatter:NumberFormatter = createFormatter(remoteDecimalField) as NumberFormatter;
    bindTextInput(decimalField, remoteDecimalField.state, decimalFormatter, createParser(remoteDecimalField));
    decimalField.restrict = "0-9" + decimalFormatter.decimalSeparatorTo + decimalFormatter.decimalSeparatorFrom;
    if (remoteDecimalField.minValue <= 0) {
      decimalField.restrict += "\\-";
    }
    return decimalField;
  }

  protected function createIntegerField(remoteIntegerField:RIntegerField):UIComponent {
    var integerField:TextInput = createTextInputComponent();
    var integerFormatter:NumberFormatter = createFormatter(remoteIntegerField) as NumberFormatter;
    bindTextInput(integerField, remoteIntegerField.state, integerFormatter, createParser(remoteIntegerField));
    integerField.restrict = "0-9";
    if (remoteIntegerField.minValue <= 0) {
      integerField.restrict += "\\-";
    }
    return integerField;
  }

  protected function createPercentField(remotePercentField:RPercentField):UIComponent {
    var percentField:TextInput = createTextInputComponent();
    var percentFormatter:NumberFormatter = createFormatter(remotePercentField) as NumberFormatter;
    bindTextInput(percentField, remotePercentField.state, percentFormatter, createParser(remotePercentField));
    percentField.restrict = "0-9" + percentFormatter.decimalSeparatorTo + percentFormatter.decimalSeparatorFrom
        + PercentFormatter.PERCENT_SUFFIX;
    if (remotePercentField.minValue <= 0) {
      percentField.restrict += "\\-";
    }
    return percentField;
  }

  protected function createDurationField(remoteDurationField:RDurationField):UIComponent {
    var durationField:TextInput = createTextInputComponent();
    bindTextInput(durationField, remoteDurationField.state, createFormatter(remoteDurationField),
                  createParser(remoteDurationField));
    return durationField;
  }

  protected function createList(remoteList:RList):List {
    var list:EnhancedList = new EnhancedList();
    list.horizontalScrollPolicy = ScrollPolicy.AUTO;
    list.verticalScrollPolicy = ScrollPolicy.AUTO;
    list.variableRowHeight = true;
    list.allowMultipleSelection = !(remoteList.selectionMode == "SINGLE_SELECTION" || remoteList.selectionMode
        == "SINGLE_CUMULATIVE_SELECTION");
    if (remoteList.selectionMode == "SINGLE_INTERVAL_CUMULATIVE_SELECTION" || remoteList.selectionMode
        == "MULTIPLE_INTERVAL_CUMULATIVE_SELECTION" || remoteList.selectionMode == "SINGLE_CUMULATIVE_SELECTION") {
      list.cumulativeSelection = true;
    }

    var itemRenderer:ClassFactory = new ClassFactory(RemoteValueListItemRenderer);
    itemRenderer.properties = {iconTemplate: _iconTemplate};
    //new ClassFactory(RemoteValueDgItemRenderer);
    list.itemRenderer = itemRenderer;

    list.dataProvider = (remoteList.state as RemoteCompositeValueState).children;
    bindList(list, remoteList.state as RemoteCompositeValueState);
    if (remoteList.rowAction) {
      getRemotePeerRegistry().register(remoteList.rowAction);
      list.doubleClickEnabled = true;
      list.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, function (event:ListEvent):void {
        _actionHandler.execute(remoteList.rowAction);
      });
    }
    return list;
  }

  protected function bindList(list:List, state:RemoteCompositeValueState):void {
    BindingUtils.bindSetter(function (selectedItems:Array):void {
      if (selectedItems != null && selectedItems.length > 0) {
        // work on items to translate indices independently of list sorting state.
        var translatedSelectedIndices:Array = new Array(selectedItems.length);
        for (var i:int = 0; i < selectedItems.length; i++) {
          translatedSelectedIndices[i] = state.children.getItemIndex(selectedItems[i]);
        }
        if (translatedSelectedIndices.length > 0) {
          state.leadingIndex = translatedSelectedIndices[0];
        } else {
          state.leadingIndex = -1;
        }
        if (!ArrayUtil.areUnorderedArraysEqual(translatedSelectedIndices, state.selectedIndices)) {
          translatedSelectedIndices.sort(Array.NUMERIC);
          state.selectedIndices = translatedSelectedIndices;
        }
      } else {
        state.leadingIndex = -1;
        state.selectedIndices = null;
      }
    }, list, "selectedItems", false);
    BindingUtils.bindSetter(function (selectedIndices:Array):void {
      if (selectedIndices != null && selectedIndices.length > 0) {
        // work on items to translate indices independently of list sorting state.
        var selectedItems:Array = new Array(selectedIndices.length);
        for (var i:int = 0; i < selectedIndices.length; i++) {
          if (selectedIndices[i] > -1) {
            if (state.children.length > selectedIndices[i]) {
              selectedItems[i] = state.children.getItemAt(selectedIndices[i]);
            } else {
              // there is a de-sync that will be fixed by another selection command.
              return;
            }
          }
        }
        if (!ArrayUtil.areUnorderedArraysEqual(list.selectedItems, selectedItems)) {
          list.selectedItems = selectedItems;
          if (selectedItems.length == 1) {
            var selIdx:int = (list.dataProvider as ListCollectionView).getItemIndex(selectedItems[0]);
            if (selIdx < 0) {
              selIdx = 0;
            }
            list.scrollToIndex(selIdx);
          }
        }
      } else {
        list.selectedItem = null;
      }
    }, state, "selectedIndices", true);
  }

  protected function createPasswordField(remotePasswordField:RPasswordField):UIComponent {
    var passwordField:TextInput = createTextInputComponent();
    if (passwordField is EnhancedTextInput) {
      (passwordField as EnhancedTextInput).preventDefaultButton = false;
    }
    bindTextInput(passwordField, remotePasswordField.state);
    passwordField.displayAsPassword = true;
    if (remotePasswordField.maxLength >= 0) {
      passwordField.maxChars = remotePasswordField.maxLength;
      sizeMaxComponentWidth(passwordField, remotePasswordField, remotePasswordField.maxLength + 2);
    } else {
      sizeMaxComponentWidth(passwordField, remotePasswordField);
    }
    return passwordField;
  }

  protected function createSecurityComponent(remoteSecurityComponent:RSecurityComponent):UIComponent {
    var securityComponent:Canvas = new Canvas();
    return securityComponent;
  }

  protected function createTable(remoteTable:RTable):UIComponent {
    var table:EnhancedDataGrid = new EnhancedDataGrid();
    table.showDataTips = true;

    var columns:Array = [];

    table.variableRowHeight = true;
    table.regenerateStyleCache(false);

    table.allowMultipleSelection = !(remoteTable.selectionMode == "SINGLE_SELECTION" || remoteTable.selectionMode
        == "SINGLE_CUMULATIVE_SELECTION");
    if (remoteTable.selectionMode == "SINGLE_INTERVAL_CUMULATIVE_SELECTION" || remoteTable.selectionMode
        == "MULTIPLE_INTERVAL_CUMULATIVE_SELECTION" || remoteTable.selectionMode == "SINGLE_CUMULATIVE_SELECTION") {
      table.cbMultiSelection = true;
    }
    if (table.cbMultiSelection) {
      var selectionColumn:DataGridColumn = new DataGridColumn();
      selectionColumn.itemRenderer = new ClassFactory(SelectionCheckBoxRenderer);
      selectionColumn.width = 20;
      selectionColumn.sortable = false;
      selectionColumn.draggable = false;
      selectionColumn.dataField = "guid";
      selectionColumn.headerText = " ";
      selectionColumn.headerRenderer = new ClassFactory(SelectionHeaderRenderer);
      columns.push(selectionColumn);
    }

    for (var i:int = 0; i < remoteTable.columns.length; i++) {
      var rColumn:RComponent = remoteTable.columns[i] as RComponent;
      var rColumnHeader:RComponent = remoteTable.columnHeaders[i] as RComponent;
      if (rColumn.state == null) {
        rColumn.state = new RemoteValueState();
      }
      var editorComponent:UIComponent = createComponent(rColumn, false);

      var column:DataGridColumn = new DataGridColumn();
      column.headerText = rColumnHeader.label;
      applyComponentStyle(column, rColumn);
      var itemRenderer:ClassFactory;
      var ttIndex:int = -1;
      var bgIndex:int = -1;
      var fgIndex:int = -1;
      var foIndex:int = -1;
      if (rColumn.toolTipState != null) {
        ttIndex = ArrayUtil.arrayIndexOf(remoteTable.rowPrototype.children.toArray(), rColumn.toolTipState);
      }
      if (rColumn.backgroundState != null) {
        bgIndex = ArrayUtil.arrayIndexOf(remoteTable.rowPrototype.children.toArray(), rColumn.backgroundState);
      } else if (remoteTable.backgroundState != null) {
        bgIndex = ArrayUtil.arrayIndexOf(remoteTable.rowPrototype.children.toArray(), remoteTable.backgroundState);
      }
      if (rColumn.foregroundState != null) {
        fgIndex = ArrayUtil.arrayIndexOf(remoteTable.rowPrototype.children.toArray(), rColumn.foregroundState);
      } else if (remoteTable.foregroundState != null) {
        fgIndex = ArrayUtil.arrayIndexOf(remoteTable.rowPrototype.children.toArray(), remoteTable.foregroundState);
      }
      if (rColumn.fontState != null) {
        foIndex = ArrayUtil.arrayIndexOf(remoteTable.rowPrototype.children.toArray(), rColumn.fontState);
      } else if (remoteTable.fontState != null) {
        foIndex = ArrayUtil.arrayIndexOf(remoteTable.rowPrototype.children.toArray(), remoteTable.fontState);
      }
      if (rColumn is RComboBox) {
        var hasIcon:Boolean = false;
        for each(var icon:RIcon in (rColumn as RComboBox).icons) {
          if (icon) {
            hasIcon = true;
            break;
          }
        }
        itemRenderer = new ClassFactory(EnumerationDgItemRenderer);
        itemRenderer.properties = {values: (rColumn as RComboBox).values,
          labels: (rColumn as RComboBox).translations,
          icons: (rColumn as RComboBox).icons,
          iconTemplate: _iconTemplate,
          showIcon: hasIcon,
          index: i + 1,
          toolTipIndex: ttIndex,
          backgroundIndex: bgIndex,
          foregroundIndex: fgIndex,
          fontIndex: foIndex};
      } else if (rColumn is RCheckBox || (rColumn is RActionField && !(rColumn as RActionField).showTextField)
          || rColumn is RImageComponent) {
        itemRenderer = new ClassFactory(UIComponentDgItemRenderer);
        itemRenderer.properties = {viewFactory: this,
          remoteComponent: rColumn,
          index: i + 1,
          toolTipIndex: ttIndex,
          backgroundIndex: bgIndex,
          foregroundIndex: fgIndex,
          fontIndex: foIndex};
        column.rendererIsEditor = true;
      } else {
        //Breaks boolean writability gates by making all columns always read only.
        //var readOnly:Boolean = !remoteTable.state.writable;
        var readOnly:Boolean = false;
        var columnAction:RAction = null;
        if (rColumn is RLink) {
          readOnly = true;
          columnAction = (rColumn as RLink).action;
          getRemotePeerRegistry().register(columnAction);
        }
        var alignment:String = "left";
        if (rColumn is RLabel) {
          readOnly = true;
          alignment = (rColumn as RLabel).horizontalAlignment;
        } else if (rColumn is RTextField) {
          alignment = (rColumn as RTextField).horizontalAlignment;
        } else if (rColumn is RNumericComponent) {
          alignment = (rColumn as RNumericComponent).horizontalAlignment;
        }
        if (alignment == "LEFT") {
          alignment = "left";
        } else if (alignment == "CENTER") {
          alignment = "center";
        } else if (alignment == "RIGHT") {
          alignment = "right";
        }
        column.setStyle("textAlign", alignment);
        itemRenderer = new ClassFactory(RemoteValueDgItemRenderer);
        itemRenderer.properties = {formatter: createFormatter(rColumn),
          action: columnAction,
          actionHandler: getActionHandler(),
          selectable: readOnly,
          index: i + 1,
          toolTipIndex: ttIndex,
          backgroundIndex: bgIndex,
          foregroundIndex: fgIndex,
          fontIndex: foIndex};
        column.editable = !readOnly;
      }
      column.itemRenderer = itemRenderer;

      if (!column.rendererIsEditor) {
        var itemEditor:ClassFactory = new ClassFactory(RemoteValueDgItemEditor);
        rColumn.state.writable = true;
        itemEditor.properties = {editor: editorComponent,
          state: rColumn.state,
          index: i + 1};
        column.itemEditor = itemEditor;
      }

      var headerRenderer:ClassFactory = new ClassFactory(DgHeaderItemRenderer);
      headerRenderer.properties = { index: i + 1,
        toolTip: editorComponent.toolTip,
        viewFactory: this,
        rTemplate: rColumnHeader};
      column.headerRenderer = headerRenderer;

      if (rColumn.preferredSize != null && rColumn.preferredSize.width > 0) {
        column.width = rColumn.preferredSize.width;
      } else {
        if (rColumn is RCheckBox) {
          column.width = table.measureText(column.headerText).width + 16;
        } else {
          column.width = Math.max(Math.min(table.measureText(TEMPLATE_CHAR).width * COLUMN_MAX_CHAR_COUNT,
                                           editorComponent.maxWidth), table.measureText(column.headerText).width + 16);
        }
      }
      editorComponent.maxWidth = UIComponent.DEFAULT_MAX_WIDTH;
      column.editorDataField = "state";

      if (remoteTable.sortable && !remoteTable.sortingAction) {
        var property:String = remoteTable.columnIds[i];
        if (!property || property.length == 0 || property.charAt(0) == "#") {
          column.sortable = false;
        } else {
          if (rColumn is RCheckBox) {
            column.sortCompareFunction = _remoteValueSorter.compareBooleans;
          } else if (rColumn is RNumericComponent) {
            column.sortCompareFunction = _remoteValueSorter.compareNumbers;
          } else if (rColumn is RDateField) {
            column.sortCompareFunction = _remoteValueSorter.compareDates;
          } else if (rColumn.state is RemoteFormattedValueState) {
            column.sortCompareFunction = _remoteValueSorter.compareFormatted;
          } else {
            column.sortCompareFunction = _remoteValueSorter.compareStrings;
          }
        }
      }
      columns.push(column);
    }
    if (remoteTable.sortable) {
      if (remoteTable.sortingAction) {
        table.customSort = true;
      }
    } else {
      table.sortableColumns = false;
    }

    table.columns = columns;
    if (remoteTable.horizontallyScrollable) {
      table.horizontalScrollPolicy = ScrollPolicy.AUTO;
    } else {
      table.horizontalScrollPolicy = ScrollPolicy.OFF;
    }
    table.verticalScrollPolicy = ScrollPolicy.AUTO;

    var tableModel:ListCollectionView;
    if (table.customSort) {
      tableModel = (remoteTable.state as RemoteCompositeValueState).children;
    } else {
      // Clone array collection to avoid re-ordering items in original collection when sorting.
      // Not necessary since we've built a ListCollectionView around children array collection
      tableModel = new ListCollectionView((remoteTable.state as RemoteCompositeValueState).children);
      (remoteTable.state as RemoteCompositeValueState).children.addEventListener(CollectionEvent.COLLECTION_CHANGE,
                                                                                 function (event:CollectionEvent):void {
                                                                                   if (event.kind
                                                                                       == CollectionEventKind.REMOVE) {
                                                                                     if (tableModel.sort) {
                                                                                       tableModel.refresh();
                                                                                     }
                                                                                   }
                                                                                 });
    }

    table.dataProvider = tableModel;

    bindTable(table, remoteTable);
    if (remoteTable.rowAction) {
      getRemotePeerRegistry().register(remoteTable.rowAction);
      table.doubleClickEnabled = true;
      table.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, function (event:ListEvent):void {
        _actionHandler.execute(remoteTable.rowAction);
      });
    }
    if (remoteTable.permId) {
      var notifyTableChanged:Function = function (e:Event):void {
        var notificationCommand:RemoteTableChangedCommand = new RemoteTableChangedCommand();
        notificationCommand.tableId = remoteTable.permId;
        var columnIds:Array = [];
        var columnWidths:Array = [];
        for each (var dgColumn:DataGridColumn in table.columns) {
          var columnRenderer:ClassFactory = dgColumn.itemRenderer as ClassFactory;
          // watch out checkbox selection column...
          if (columnRenderer.properties && !isNaN(columnRenderer.properties["index"])) {
            columnIds.push(remoteTable.columnIds[(columnRenderer.properties["index"] as int) - 1]);
            columnWidths.push(dgColumn.width);
          }
        }
        notificationCommand.columnIds = columnIds;
        notificationCommand.columnWidths = columnWidths;
        _commandHandler.registerCommand(notificationCommand);
      };

      table.addEventListener(DataGridEvent.COLUMN_STRETCH, notifyTableChanged);
      table.addEventListener(IndexChangedEvent.HEADER_SHIFT, notifyTableChanged);
    }
    table.minWidth = 0;
    table.minHeight = table.headerHeight * 2;
    return table;
  }

  protected function bindTable(table:EnhancedDataGrid, remoteTable:RTable):void {
    var state:RemoteCompositeValueState = remoteTable.state as RemoteCompositeValueState;
    BindingUtils.bindProperty(table, "editable", state, "writable");
    if (remoteTable.sortable) {
      if (remoteTable.sortingAction) {
        table.addEventListener(DataGridEvent.HEADER_RELEASE, function (event:DataGridEvent):void {
          event.preventDefault();
          var column:DataGridColumn = table.columns[event.columnIndex];
          var property:String;
          var columnRenderer:ClassFactory = column.itemRenderer as ClassFactory;
          // watch out checkbox selection column...
          if (columnRenderer.properties && !isNaN(columnRenderer.properties["index"])) {
            property = remoteTable.columnIds[(columnRenderer.properties["index"] as int) - 1];
          }
          if (!property || property.length == 0 || property.charAt(0) == "#") {
            // do not sort
            return;
          }
          column.sortDescending = !column.sortDescending;
          table.displaySort(event.columnIndex, column.sortDescending);
          if (state.children.length > 1) {
            var orderingProperties:Object = {};
            orderingProperties[property] = column.sortDescending ? "DESCENDING" : "ASCENDING";
            var sortCommand:RemoteSortCommand = new RemoteSortCommand();
            sortCommand.orderingProperties = orderingProperties;
            sortCommand.viewStateGuid = remoteTable.state.guid;
            sortCommand.viewStatePermId = remoteTable.state.permId;
            sortCommand.targetPeerGuid = remoteTable.sortingAction.guid;
            sortCommand.permId = remoteTable.sortingAction.permId;
            _commandHandler.registerCommand(sortCommand);
          }
        });
      } else {
        table.addEventListener(DataGridEvent.HEADER_RELEASE, function (event:DataGridEvent):void {
          var headerIndex:int = (event.itemRenderer as DgHeaderItemRenderer).index;
          var property:String = remoteTable.columnIds[headerIndex - 1];
          if (!property || property.length == 0 || property.charAt(0) == "#") {
            // do not sort
            return;
          }
          _remoteValueSorter.sortColumnIndex = headerIndex;
        });
      }
    }
    BindingUtils.bindSetter(function (selectedItems:Array):void {
      if (selectedItems != null && selectedItems.length > 0) {
        // work on items to translate indices independently of table sorting state.
        var translatedSelectedIndices:Array = new Array(selectedItems.length);
        for (var i:int = 0; i < selectedItems.length; i++) {
          translatedSelectedIndices[i] = state.children.getItemIndex(selectedItems[i]);
        }
        if (translatedSelectedIndices.length > 0) {
          state.leadingIndex = translatedSelectedIndices[0];
        } else {
          state.leadingIndex = -1;
        }
        if (!ArrayUtil.areUnorderedArraysEqual(translatedSelectedIndices, state.selectedIndices)) {
          translatedSelectedIndices.sort(Array.NUMERIC);
          state.selectedIndices = translatedSelectedIndices;
        }
      } else {
        state.leadingIndex = -1;
        state.selectedIndices = null;
      }
    }, table, "selectedItems", true);
    BindingUtils.bindSetter(function (selectedIndices:Array):void {
      if (selectedIndices != null && selectedIndices.length > 0) {
        // work on items to translate indices independently of table sorting state.
        var selectedItems:Array = new Array(selectedIndices.length);
        for (var i:int = 0; i < selectedIndices.length; i++) {
          if (selectedIndices[i] > -1) {
            if (state.children.length > selectedIndices[i]) {
              selectedItems[i] = state.children.getItemAt(selectedIndices[i]);
            } else {
              // there is a de-sync that will be fixed by another selection command.
              return;
            }
          }
        }
        if (!ArrayUtil.areUnorderedArraysEqual(table.selectedItems, selectedItems)) {
          table.selectedItems = selectedItems;
          if (selectedItems.length == 1) {
            var selIdx:int = (table.dataProvider as ListCollectionView).getItemIndex(selectedItems[0]);
            if (selIdx < 0) {
              selIdx = 0;
            }
            table.scrollToIndex(selIdx);
          }
        }
      } else {
        table.selectedItem = null;
      }
    }, state, "selectedIndices", true);

    table.addEventListener(DataGridEvent.ITEM_EDIT_END, function (event:DataGridEvent):void {
      var table:DataGrid = event.currentTarget as DataGrid;
      _actionHandler.setCurrentViewStateGuid(table, null, null);
      if (event.reason != DataGridEventReason.CANCELLED) {
        if (table.itemEditorInstance is RemoteValueDgItemEditor) {
          var currentEditor:RemoteValueDgItemEditor = table.itemEditorInstance as RemoteValueDgItemEditor;
          var state:RemoteValueState = currentEditor.state;
          var row:RemoteCompositeValueState = (table.dataProvider as ListCollectionView).getItemAt(event.rowIndex)
              as RemoteCompositeValueState;
          var cell:RemoteValueState = row.children[currentEditor.index] as RemoteValueState;

          cell.value = state.value;
        }
      }
    });
    table.addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING, function (event:DataGridEvent):void {
      if (event.itemRenderer is SelectionCheckBoxRenderer) {
        event.preventDefault();
        return;
      }
      var dg:DataGrid = event.currentTarget as DataGrid;
      if (dg.editedItemPosition != null && event.rowIndex == dg.editedItemPosition["rowIndex"] && event.columnIndex
          == dg.editedItemPosition["columnIndex"]) {
        event.preventDefault();
        return;
      }
      if (!isDgCellEditable(dg, event.rowIndex, event.columnIndex)) {
        event.preventDefault();
      }
    });
    table.addEventListener(DataGridEvent.ITEM_EDIT_BEGIN, function (event:DataGridEvent):void {
      var dg:DataGrid = event.currentTarget as DataGrid;
      var column:DataGridColumn = dg.columns[event.columnIndex];
      var rowCollection:ListCollectionView = dg.dataProvider as ListCollectionView;
      var cellValueState:RemoteValueState;
      var columnRenderer:ClassFactory = column.itemRenderer as ClassFactory;
      // watch out checkbox selection column...
      if (columnRenderer.properties && !isNaN(columnRenderer.properties["index"])) {
        cellValueState = (rowCollection.getItemAt(event.rowIndex)
            as RemoteCompositeValueState).children[columnRenderer.properties["index"] as int] as RemoteValueState;
        _actionHandler.setCurrentViewStateGuid(dg, cellValueState.guid, cellValueState.permId);
      }
    });
    table.addEventListener(DataGridEvent.ITEM_FOCUS_IN, function (event:DataGridEvent):void {
      ((event.currentTarget as DataGrid).itemEditorInstance as UIComponent).setFocus();
    });
  }

  protected function isDgCellEditable(dg:DataGrid, row:int, col:int):Boolean {
    var column:DataGridColumn = dg.columns[col];
    var rowCollection:ListCollectionView = dg.dataProvider as ListCollectionView;
    var rowValueState:RemoteCompositeValueState = rowCollection.getItemAt(row) as RemoteCompositeValueState;
    if (!rowValueState.writable) {
      return false;
    } else {
      var cellValueState:RemoteValueState;
      var columnRenderer:ClassFactory = column.itemRenderer as ClassFactory;
      // watch out checkbox selection column...
      if (columnRenderer.properties && !isNaN(columnRenderer.properties["index"])) {
        cellValueState = rowValueState.children[columnRenderer.properties["index"] as int] as RemoteValueState;
        if (!cellValueState.writable) {
          return false;
        }
      }
    }
    return true;
  }

  /**
   *
   * @param remoteTextArea
   * @return
   *
   */
  protected function createTextArea(remoteTextArea:RTextArea):UIComponent {
    var textArea:TextArea = createTextAreaComponent();
    if (remoteTextArea.maxLength >= 0) {
      textArea.maxChars = remoteTextArea.maxLength;
    }
    bindTextArea(textArea, remoteTextArea.state);
    sizeMaxComponentWidth(textArea, remoteTextArea);
    return textArea;
  }

  public function createTextAreaComponent():TextArea {
    var ta:EnhancedTextArea = new EnhancedTextArea();
    return ta;
  }

  protected function bindTextArea(textArea:TextArea, remoteState:RemoteValueState):void {
    BindingUtils.bindProperty(textArea, "text", remoteState, "value", true);

    var updateEditability:Function = function (value:Object):void {
      if (value) {
        textArea.setStyle("backgroundColor", null);
      } else {
        textArea.setStyle("backgroundColor", textArea.getStyle("backgroundDisabledColor"));
      }
      textArea.editable = value as Boolean;
    };
    BindingUtils.bindSetter(updateEditability, remoteState, "writable");
    var updateModel:Function = function (event:Event):void {
      var text:String = (event.currentTarget as TextArea).text;
      if (text != null && text.length == 0) {
        text = null;
      }
      if (text) {
        // TextArea silently replaces line breaks with platform one.
        // We have to restore them to the default \n server one
        // See bug #991
        text = text.replace(new RegExp("(\r\n)", "g"), "\n");
        text = text.replace(new RegExp("(\r)", "g"), "\n");
      }
      remoteState.value = text;
    };
    textArea.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, updateModel);
    textArea.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, updateModel);
  }

  protected function createHtmlArea(remoteHtmlArea:RHtmlArea):UIComponent {
    var htmlComponent:UIComponent;
    if (remoteHtmlArea.readOnly) {
      htmlComponent = createHtmlText(remoteHtmlArea);
    } else {
      htmlComponent = createHtmlEditor(remoteHtmlArea);
    }
    return htmlComponent;
  }

  protected function createHtmlEditor(remoteHtmlArea:RHtmlArea):UIComponent {
    var htmlEditor:EnhancedRichTextEditor = createRichTextEditorComponent();
    htmlEditor.styleName = "htmlEditor";
    if (remoteHtmlArea.verticallyScrollable) {
      htmlEditor.verticalScrollPolicy = ScrollPolicy.AUTO;
    } else {
      htmlEditor.verticalScrollPolicy = ScrollPolicy.OFF;
    }
    if (remoteHtmlArea.horizontallyScrollable) {
      htmlEditor.addEventListener(FlexEvent.CREATION_COMPLETE, function (e:FlexEvent):void {
        htmlEditor.textArea.wordWrap = false;
      });
      htmlEditor.horizontalScrollPolicy = ScrollPolicy.AUTO;
    } else {
      htmlEditor.addEventListener(FlexEvent.CREATION_COMPLETE, function (e:FlexEvent):void {
        htmlEditor.textArea.wordWrap = true;
      });
      htmlEditor.horizontalScrollPolicy = ScrollPolicy.OFF;
    }
    bindHtmlEditor(htmlEditor, remoteHtmlArea.state);
    return htmlEditor;
  }

  public function createRichTextEditorComponent():EnhancedRichTextEditor {
    return new EnhancedRichTextEditor();
  }

  protected function bindHtmlEditor(htmlEditor:EnhancedRichTextEditor, remoteState:RemoteValueState):void {
    BindingUtils.bindProperty(htmlEditor, "xhtmlText", remoteState, "value", true);
    BindingUtils.bindProperty(htmlEditor, "editable", remoteState, "writable");
    var updateModel:Function = function (event:Event):void {
      if (htmlEditor.editable) {
        var xhtmlText:String = htmlEditor.xhtmlText;
        if (xhtmlText != null && xhtmlText.length == 0) {
          xhtmlText = null;
        }
        remoteState.value = xhtmlText;
      }
    };
    htmlEditor.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, updateModel);
    htmlEditor.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, updateModel);
    //htmlEditor.addEventListener(Event.CHANGE,updateModel);
  }

  protected function createHtmlText(remoteHtmlArea:RHtmlArea):UIComponent {
    var htmlText:TextArea = createTextAreaComponent();
    htmlText.styleName = "htmlText";
    htmlText.editable = false;
    if (remoteHtmlArea.verticallyScrollable) {
      htmlText.verticalScrollPolicy = ScrollPolicy.AUTO;
    } else {
      htmlText.verticalScrollPolicy = ScrollPolicy.OFF;
    }
    if (remoteHtmlArea.horizontallyScrollable) {
      htmlText.wordWrap = false;
      htmlText.horizontalScrollPolicy = ScrollPolicy.AUTO;
    } else {
      htmlText.wordWrap = true;
      htmlText.horizontalScrollPolicy = ScrollPolicy.OFF;
    }
    bindHtmlText(htmlText, remoteHtmlArea.state);
    return htmlText;
  }

  protected function bindHtmlText(htmlText:TextArea, remoteState:RemoteValueState):void {
    var updateText:Function = function (value:Object):void {
      if (value == null) {
        htmlText.htmlText = null;
      } else {
        htmlText.htmlText = HtmlUtil.convertFromXHtml(value.toString());
      }
    };
    BindingUtils.bindSetter(updateText, remoteState, "value", true);
  }

  protected function createLabel(remoteLabel:RLabel):UIComponent {
    var label:Text = new Text();
    if (remoteLabel.state) {
      label.selectable = true;
    }
    if (!remoteLabel.state) {
      if (remoteLabel.label != null) {
        if (HtmlUtil.isHtml(remoteLabel.label)) {
          label.text = null;
          label.htmlText = HtmlUtil.convertHtmlEntities(remoteLabel.label);
        } else {
          label.htmlText = null;
          label.text = remoteLabel.label;
        }
      }
      if (label.text != null && label.text.length > 0) {
        sizeMaxComponentWidth(label, remoteLabel, label.text.length + 5);
      } else {
        sizeMaxComponentWidth(label, remoteLabel, 0);
      }
    }
    configureHorizontalAlignment(label, remoteLabel.horizontalAlignment);
    if (remoteLabel.state) {
      if (remoteLabel.maxLength >= 0) {
        sizeMaxComponentWidth(label, remoteLabel, remoteLabel.maxLength);
      } else {
        sizeMaxComponentWidth(label, remoteLabel);
      }
      bindLabel(label, remoteLabel);
    }
    if (remoteLabel.icon) {
      var compoundLabel:HBox = new HBox();
      var labelIcon:Image = new CachedImage();
      labelIcon.source = remoteLabel.icon.imageUrlSpec;
      compoundLabel.addChild(labelIcon);
      compoundLabel.addChild(label);
      return compoundLabel;
    }
    return label;
  }

  protected function bindLabel(label:Label, remoteLabel:RLabel):void {
    var remoteState:RemoteValueState = remoteLabel.state;
    var updateLabel:Function;
    if (remoteLabel is RLink && (remoteLabel as RLink).action != null) {
      getRemotePeerRegistry().register((remoteLabel as RLink).action);
      updateLabel = function (value:Object):void {
        if (remoteState.value == null) {
          label.htmlText = null;
        } else {
          var labelText:String = remoteState.value.toString();
          if (HtmlUtil.isHtml(labelText)) {
            labelText = HtmlUtil.convertHtmlEntities(labelText);
          }
          if (((remoteLabel as RLink).action).enabled) {
            label.htmlText = "<u><a href='event:action'>" + labelText + "</a></u>";
          } else {
            label.htmlText = labelText;
          }
        }
      };
      label.selectable = true;
      label.addEventListener(TextEvent.LINK, function (evt:TextEvent):void {
        getActionHandler().execute((remoteLabel as RLink).action);
      });
      BindingUtils.bindSetter(updateLabel, (remoteLabel as RLink).action, "enabled", true);
    } else {
      updateLabel = function (value:Object):void {
        if (value == null) {
          label.text = null;
          label.htmlText = null;
        } else {
          if (HtmlUtil.isHtml(value.toString())) {
            label.text = null;
            label.htmlText = HtmlUtil.convertHtmlEntities(value.toString());
          } else {
            label.htmlText = null;
            label.text = value.toString();
          }
        }
      };
    }
    BindingUtils.bindSetter(updateLabel, remoteState, "value", true);
  }

  protected function createTextField(remoteTextField:RTextField):UIComponent {
    var textField:TextInput = createTextInputComponent();
    if (remoteTextField.maxLength >= 0) {
      textField.maxChars = remoteTextField.maxLength;
      sizeMaxComponentWidth(textField, remoteTextField, remoteTextField.maxLength + 2);
    } else {
      sizeMaxComponentWidth(textField, remoteTextField);
    }
    configureHorizontalAlignment(textField, remoteTextField.horizontalAlignment);
    bindTextInput(textField, remoteTextField.state);
    return textField;
  }

  public function createAction(remoteAction:RAction, component:UIComponent,
                               topApplicationAction:Boolean = false):Button {
    var button:Button = createButton(remoteAction.name, createActionTooltip(remoteAction), remoteAction.icon,
                                     topApplicationAction);
    configureActionButton(button, remoteAction);
    installKeyboardShortcut(remoteAction, component);
    return button;
  }

  public function installKeyboardShortcut(action:RAction, component:UIComponent):void {
    if (action.acceleratorAsString && component) {
      var splittedAccelerator:Array = action.acceleratorAsString.toLowerCase().split(" ");
      var accAlt:Boolean = splittedAccelerator.indexOf("alt") >= 0;
      var accCtrl:Boolean = splittedAccelerator.indexOf("ctrl") >= 0;
      var accShift:Boolean = splittedAccelerator.indexOf("shift") >= 0;
      component.addEventListener(KeyboardEvent.KEY_UP, function (keyEvent:KeyboardEvent):void {
        if (keyEvent.altKey || keyEvent.ctrlKey) {
          if ((keyEvent.altKey && accAlt) || (!keyEvent.altKey && !accAlt)) {
            if ((keyEvent.ctrlKey && accCtrl) || (!keyEvent.ctrlKey && !accCtrl)) {
              if ((keyEvent.shiftKey && accShift) || (!keyEvent.shiftKey && !accShift)) {
                var character:String = String.fromCharCode(keyEvent.charCode);
                if (splittedAccelerator.indexOf(character.toLowerCase()) >= 0) {
                  keyEvent.stopPropagation();
                  getActionHandler().execute(action);
                }
              }
            }
          }
        }
      });
    }
  }

  public function createDialogAction(remoteAction:RAction):Button {
    var button:Button = createDialogButton(remoteAction.name, remoteAction.description, remoteAction.icon);
    configureActionButton(button, remoteAction);
    return button;
  }

  protected function configureActionButton(button:Button, remoteAction:RAction):void {
    //BindingUtils.bindProperty(button, "enabled", remoteAction, "enabled", true);
    var updateButtonState:Function = function (enabled:Boolean):void {
      button.enabled = enabled;
    };
    BindingUtils.bindSetter(updateButtonState, remoteAction, "enabled", true);
    getRemotePeerRegistry().register(remoteAction);
    var listener:Function = function (event:MouseEvent):void {
      _actionHandler.execute(remoteAction);
    };
    addButtonEventListenerWithTimeout(button, listener);
    if (remoteAction.styleName) {
      button.styleName = remoteAction.styleName;
    }
  }

  public function addButtonEventListenerWithTimeout(button:Button, listener:Function, timeout:int = 400):void {
    button.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
      if ((new Date()).time - _lastActionTimestamp.time < timeout) {
        return;
      }
      _lastActionTimestamp = new Date();
      listener(event);
    });
  }

  public function createButton(label:String, toolTip:String, icon:RIcon, topApplicationButton:Boolean = false):Button {
    var button:Button = createButtonComponent(topApplicationButton);
    configureButton(button, label, toolTip, icon);
    return button;
  }

  public function createDialogButton(label:String, toolTip:String, icon:RIcon):Button {
    return createButton(label, toolTip, icon);
  }

  public function createButtonComponent(topApplicationButton:Boolean = false):Button {
    return new EnhancedButton();
  }

  protected function configureButton(button:Button, label:String, toolTip:String, icon:RIcon):void {
    button.setStyle("icon", null);
    if (icon) {
      button.setStyle("icon", getIconForComponent(button, icon));
    }
    if (label) {
      button.label = label;
    }
    if (toolTip) {
      button.toolTip = toolTip;
    }
  }

  public function createTextInputComponent():TextInput {
    var tf:EnhancedTextInput = new EnhancedTextInput();
    tf.preventDefaultButton = true;
    return tf;
  }

  protected function bindTextInput(textInput:TextInput, remoteState:RemoteValueState, formatter:Formatter = null,
                                   parser:Parser = null):void {

    var updateEditability:Function = function (value:Object):void {
      if (value) {
        textInput.setStyle("backgroundColor", null);
      } else {
        textInput.setStyle("backgroundColor", textInput.getStyle("backgroundDisabledColor"));
      }
      textInput.editable = value as Boolean;
    };
    BindingUtils.bindSetter(updateEditability, remoteState, "writable");

    var updateView:Function = function (value:Object):void {
      if (value == null) {
        textInput.text = null;
      } else {
        if (formatter != null) {
          textInput.text = formatter.format(value);
        } else {
          textInput.text = value.toString();
        }
      }
    };
    BindingUtils.bindSetter(updateView, remoteState, "value", true);

    var blockNewLine:Function = function (event:TextEvent):void {
      if (event.text == '\n' || event.text == '\r\n' || event.text == '\r') {
        event.preventDefault();
      }
    };
    textInput.addEventListener(TextEvent.TEXT_INPUT, blockNewLine);

    var trimLastLine:Function = function (evt:Event):void {
      if (textInput.text) {
        textInput.text = StringUtil.trim(textInput.text);
      }
    };
    textInput.addEventListener(Event.CHANGE, trimLastLine);

    var updateModel:Function = function (event:Event):void {
      if (textInput.text) {
        textInput.text = StringUtil.trim(textInput.text);
      }
      var inputText:String = textInput.text;
      if (inputText == null || inputText.length == 0) {
        remoteState.value = null;
      } else {
        if (parser != null) {
          remoteState.value = parser.parse(inputText, remoteState.value);
          textInput.text = formatter.format(remoteState.value);
        } else {
          remoteState.value = inputText;
        }
      }
    };

    textInput.addEventListener(FlexEvent.ENTER, updateModel);
    textInput.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, updateModel);
    textInput.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, updateModel);
  }

  protected function bindColorPicker(colorPicker:ColorPicker, remoteState:RemoteValueState):void {
    BindingUtils.bindProperty(colorPicker, "selectedColor", remoteState, "value", true);
    BindingUtils.bindProperty(colorPicker, "enabled", remoteState, "writable");
    var updateModel:Function = function (event:Event):void {
      var currentAlpha:String;
      if (remoteState.value != null) {
        currentAlpha = (remoteState.value as String).substr(2, 2);
      } else {
        currentAlpha = "FF";
      }
      remoteState.value = "0x" + currentAlpha + (event.currentTarget as ColorPicker).selectedColor.toString(16);
    };
    colorPicker.addEventListener(ColorPickerEvent.CHANGE, updateModel);
  }

  public function getIconForComponent(component:UIComponent, rIcon:RIcon):Class {
    if (rIcon != null) {
      return IconFactory.getClass(component, rIcon.imageUrlSpec, rIcon.dimension.width, rIcon.dimension.height);
    }
    return null;
  }

  protected function createFormatter(remoteComponent:RComponent):Formatter {
    if (remoteComponent is RDateField) {
      var dateFormatter:DateFormatter = new DateFormatter();
      dateFormatter.formatString = datePattern;
      if ((remoteComponent as RDateField).type == "DATE_TIME") {
        dateFormatter.formatString = dateFormatter.formatString + " " + _timeFormatter.formatString;
      }
      return dateFormatter;
    } else if (remoteComponent is RTimeField) {
      if ((remoteComponent as RTimeField).secondsAware) {
        return _timeFormatter;
      } else {
        return _shortTimeFormatter;
      }
    } else if (remoteComponent is RPasswordField) {
      return _passwordFormatter;
    } else if (remoteComponent is RNumericComponent) {
      var numberFormatter:NumberFormatter;
      if (remoteComponent is RPercentField) {
        numberFormatter = new PercentFormatter();
      } else {
        numberFormatter = new NumberFormatter();
      }
      numberFormatter.decimalSeparatorFrom = ".";
      numberFormatter.thousandsSeparatorFrom = "";
      numberFormatter.rounding = NumberBaseRoundType.NEAREST;
      if (remoteComponent is RDecimalComponent) {
        numberFormatter.precision = (remoteComponent as RDecimalComponent).maxFractionDigit;
      } else if (remoteComponent is RIntegerField) {
        numberFormatter.precision = 0;
      }
      return numberFormatter;
    }
    return null;
  }

  protected function createParser(remoteComponent:RComponent):Parser {
    if (remoteComponent is RNumericComponent) {
      var numberParser:NumberParser;
      if (remoteComponent is RPercentField) {
        numberParser = new PercentParser();
      } else {
        numberParser = new NumberParser();
      }
      var formatter:NumberFormatter = createFormatter(remoteComponent) as NumberFormatter;
      numberParser.numberBase = new NumberBase(formatter.decimalSeparatorFrom, formatter.thousandsSeparatorFrom,
                                               formatter.decimalSeparatorTo, formatter.thousandsSeparatorTo);
      numberParser.precision = formatter.precision as uint;
      return numberParser;
    } else if (remoteComponent is RTimeField) {
      var timeParser:TimeParser = new TimeParser();
      timeParser.parseDateDto = (remoteComponent as RTimeField).isUseDateDto();
      return timeParser;
    }
    return null;
  }

  protected function sizeMaxComponentWidth(component:UIComponent, remoteComponent:RComponent,
                                           expectedCharCount:int = FIELD_MAX_CHAR_COUNT,
                                           maxCharCount:int = FIELD_MAX_CHAR_COUNT):void {
    var charCount:int = maxCharCount;
    if (expectedCharCount < charCount) {
      charCount = expectedCharCount;
    }
    var templateText:String = "";
    for (var i:int = 0; i < charCount; i++) {
      templateText += TEMPLATE_CHAR;
    }
    sizeMaxComponentWidthFromText(component, remoteComponent, templateText);
  }

  protected function sizeMaxComponentWidthFromText(component:UIComponent, remoteComponent:RComponent,
                                                   text:String):void {
    var w:int;
    applyComponentStyle(component, remoteComponent);
    component.regenerateStyleCache(false);
    w = component.measureText(text).width + 10;
    if (remoteComponent.preferredSize && remoteComponent.preferredSize.width > w) {
      w = remoteComponent.preferredSize.width;
    }
    component.maxWidth = w;
  }

  public function get iconTemplate():Class {
    return _iconTemplate;
  }

  public function createMenus(actionLists:Array, useSeparator:Boolean, component:UIComponent):Array {
    var menus:Array = [];
    if (actionLists != null) {
      var menu:Object = {};
      for each (var actionList:RActionList in actionLists) {
        if (!useSeparator || menus.length == 0) {
          menu = createMenu(actionList, component);
          menus.push(menu);
        } else {
          var separator:Object = {};
          separator["type"] = "separator";
          menu["children"].push(separator);
          for each (var menuItem:Object in createMenuItems(actionList, component)) {
            menu["children"].push(menuItem);
          }
        }
      }
    }
    return menus;
  }

  public function createPopupButton(actionList:RActionList, component:UIComponent,
                                    topApplicationButton:Boolean = false):Button {
    if (actionList.actions == null || actionList.actions.length == 0) {
      return null;
    }
    if (actionList.actions.length == 1) {
      return createAction(actionList.actions[0], component, topApplicationButton);
    }
    var dp:Object = createMenuItems(actionList, component);
    var menu:Menu = new Menu();
    menu.showDataTips = true;
    menu.dataProvider = dp;
    menu.itemRenderer = new ClassFactory(RIconMenuItemRenderer);
    var popupButton:PopUpButton = createPopUpButtonComponent(topApplicationButton);
    popupButton.popUp = menu;
    var menuHandler:Function = function (event:MenuEvent):void {
      if (event.item["data"] is RAction) {
        var action:RAction = event.item["data"] as RAction;
        getActionHandler().execute(action, null);
      }
    };
    var defaultAction:RAction = actionList.actions[0];
    configureButton(popupButton, defaultAction.name, defaultAction.description, defaultAction.icon);
    popupButton.data = defaultAction;
    popupButton.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
      getActionHandler().execute((event.currentTarget as PopUpButton).data as RAction);
    });
    menu.addEventListener(MenuEvent.ITEM_CLICK, menuHandler);
    return popupButton;
  }

  public function createPopUpButtonComponent(topApplicationButton:Boolean = false):PopUpButton {
    var popupButton:PopUpButton = new PopUpButton();
    popupButton.styleName = "popupButton";
    return popupButton;
  }

  public function createMenu(actionList:RActionList, component:UIComponent):Object {
    var menu:Object = {};
    menu["label"] = actionList.name;
    menu["description"] = actionList.description;
    menu["data"] = actionList;
    if (actionList.icon) {
      menu["icon"] = iconTemplate;
      menu["rIcon"] = actionList.icon;
    }

    var menuItems:Array = [];
    for each (var menuItem:Object in createMenuItems(actionList, component)) {
      menuItems.push(menuItem);
    }
    menu["children"] = menuItems;
    return menu;
  }

  protected function createMenuItems(actionList:RActionList, component:UIComponent):Array {
    var menuItems:Array = [];
    for each(var action:RAction in actionList.actions) {
      menuItems.push(createMenuItem(action, component));
    }
    return menuItems;
  }

  protected function createMenuItem(action:RAction, component:UIComponent):Object {
    var menuItem:Object = {};
    menuItem["label"] = action.name;
    menuItem["description"] = createActionTooltip(action);
    menuItem["data"] = action;
    if (action.icon) {
      menuItem["icon"] = iconTemplate;
      menuItem["rIcon"] = action.icon;
    }
    var updateMenuItemState:Function = function (enabled:Boolean):void {
      menuItem["enabled"] = enabled;
    };
    BindingUtils.bindSetter(updateMenuItemState, action, "enabled", true);
    _remotePeerRegistry.register(action);
    installKeyboardShortcut(action, component);
    return menuItem;
  }

  protected function createActionTooltip(action:RAction):String {
    var toolTip:String = action.description;
    if (action.acceleratorAsString) {
      toolTip = "<html>" + toolTip + " <i>[" + action.acceleratorAsString.split(" ").join("+") + "]</i>" + "</html>";
      toolTip = HtmlUtil.convertHtmlEntities(toolTip);
    }
    return toolTip;
  }

  protected function configureHorizontalAlignment(component:UIComponent, alignment:String):void {
    if (alignment == "LEFT") {
      component.setStyle("textAlign", "left");
    } else if (alignment == "CENTER") {
      component.setStyle("textAlign", "center");
    } else if (alignment == "RIGHT") {
      component.setStyle("textAlign", "right");
    }
  }

  public function get datePattern():String {
    return _datePattern;
  }

  public function set datePattern(value:String):void {
    _datePattern = value;
  }

  public function get firstDayOfWeek():int {
    return _firstDayOfWeek;
  }

  public function set firstDayOfWeek(value:int):void {
    _firstDayOfWeek = value;
  }

  protected function findFirstFocusableComponent(root:UIComponent):UIComponent {
    if (root is TextInput || root is CheckBox || root is CheckBoxExtended || root is ComboBox || root is TextArea
        || root is DateField || root is DataGrid) {
      if (root.enabled) {
        return root;
      }
    }
    if (root is Container) {
      for (var i:int = 0; i < (root as Container).getChildren().length; i++) {
        var child:DisplayObject = root.getChildAt(i);
        if (child is UIComponent) {
          var focusableChild:UIComponent = findFirstFocusableComponent(child as UIComponent);
          if (focusableChild != null) {
            return focusableChild;
          }
        }
      }
    }
    return null;
  }

  protected function findFirstEditableComponent(root:UIComponent):UIComponent {
    if (root is DataGrid) {
      if (root.enabled) {
        return root;
      }
    }
    if (root is Container) {
      for (var i:int = 0; i < (root as Container).getChildren().length; i++) {
        var child:DisplayObject = root.getChildAt(i);
        if (child is UIComponent) {
          var editableChild:UIComponent = findFirstEditableComponent(child as UIComponent);
          if (editableChild != null) {
            return editableChild;
          }
        }
      }
    }
    return null;
  }

  public function edit(component:UIComponent):void {
    var editableChild:UIComponent = findFirstEditableComponent(component);
    if (editableChild is DataGrid) {
      var table:DataGrid = editableChild as DataGrid;
      var selIdx:int = table.selectedIndex;
      if (selIdx >= 0) {
        var col:int = 0;
        var columnRenderer:ClassFactory = table.columns[0].itemRenderer as ClassFactory;
        // watch out checkbox selection column...
        if (!columnRenderer.properties || isNaN(columnRenderer.properties["index"])) {
          col++;
        }
        if (isDgCellEditable(table, selIdx, col)) {
          table.editedItemPosition = {rowIndex: selIdx, columnIndex: col};
        } else {
          table.editedItemPosition = null;
        }
      }
    }
  }

  public function focus(component:UIComponent):void {
    var focusableChild:UIComponent = findFirstFocusableComponent(component);
    if (focusableChild) {
      focusableChild.callLater(function ():void {
        focusableChild.setFocus();
      });
    }
  }

  public function reset():void {
    // Callback called when the controller is restarted.
  }

}
}
