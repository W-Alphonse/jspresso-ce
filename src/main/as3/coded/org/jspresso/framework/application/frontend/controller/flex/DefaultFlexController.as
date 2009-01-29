package org.jspresso.framework.application.frontend.controller.flex {
  import flash.display.DisplayObject;
  
  import mx.binding.utils.BindingUtils;
  import mx.collections.ArrayCollection;
  import mx.collections.IList;
  import mx.collections.ListCollectionView;
  import mx.containers.ApplicationControlBar;
  import mx.controls.Alert;
  import mx.controls.Button;
  import mx.controls.MenuBar;
  import mx.core.Application;
  import mx.core.UIComponent;
  import mx.events.MenuEvent;
  import mx.rpc.events.FaultEvent;
  import mx.rpc.events.ResultEvent;
  import mx.rpc.remoting.mxml.Operation;
  import mx.rpc.remoting.mxml.RemoteObject;
  
  import org.jspresso.framework.action.IActionHandler;
  import org.jspresso.framework.application.frontend.command.remote.RemoteActionCommand;
  import org.jspresso.framework.application.frontend.command.remote.RemoteChildrenCommand;
  import org.jspresso.framework.application.frontend.command.remote.RemoteCommand;
  import org.jspresso.framework.application.frontend.command.remote.RemoteEnablementCommand;
  import org.jspresso.framework.application.frontend.command.remote.RemoteInitCommand;
  import org.jspresso.framework.application.frontend.command.remote.RemoteMessageCommand;
  import org.jspresso.framework.application.frontend.command.remote.RemoteReadabilityCommand;
  import org.jspresso.framework.application.frontend.command.remote.RemoteSelectionCommand;
  import org.jspresso.framework.application.frontend.command.remote.RemoteValueCommand;
  import org.jspresso.framework.application.frontend.command.remote.RemoteWritabilityCommand;
  import org.jspresso.framework.gui.remote.RAction;
  import org.jspresso.framework.gui.remote.RActionList;
  import org.jspresso.framework.gui.remote.RComponent;
  import org.jspresso.framework.state.remote.RemoteCompositeValueState;
  import org.jspresso.framework.state.remote.RemoteValueState;
  import org.jspresso.framework.util.remote.IRemotePeer;
  import org.jspresso.framework.util.remote.registry.BasicRemotePeerRegistry;
  import org.jspresso.framework.util.remote.registry.IRemotePeerRegistry;
  import org.jspresso.framework.view.flex.DefaultFlexViewFactory;
  
  
  public class DefaultFlexController implements IRemotePeerRegistry, IActionHandler {
    
    private static const HANDLE_COMMANDS_METHOD:String = "handleCommands";
    private static const START_METHOD:String = "start";
    private var _remoteController:RemoteObject;
    private var _viewFactory:DefaultFlexViewFactory;
    private var _remotePeerRegistry:IRemotePeerRegistry;
    private var _changeNotificationsEnabled:Boolean;
    private var _commandsQueue:IList;
    private var _commandRegistrationEnabled:Boolean;
    
    public function DefaultFlexController(remoteController:RemoteObject) {
      _remotePeerRegistry = new BasicRemotePeerRegistry();
      _viewFactory = new DefaultFlexViewFactory(this, this);
      _changeNotificationsEnabled = true;
      _remoteController = remoteController;
      _commandsQueue = new ArrayCollection(new Array());
      _commandRegistrationEnabled = true;
      initRemoteController();
    }
    
    public function createComponent(remoteComponent:RComponent):UIComponent {
      return _viewFactory.createComponent(remoteComponent);
    }
    
    public function register(remotePeer:IRemotePeer):void {
      if(!isRegistered(remotePeer.guid)) {
        _remotePeerRegistry.register(remotePeer);
        if(remotePeer is RemoteValueState) {
          bindRemoteValueState(remotePeer as RemoteValueState);
          if(remotePeer is RemoteCompositeValueState) {
            for each(var childState:RemoteValueState in (remotePeer as RemoteCompositeValueState).children) {
              register(childState);
            }
          }
        }
      }
    }
    
    private function bindRemoteValueState(remoteValueState:RemoteValueState):void {
      var wasEnabled:Boolean = _changeNotificationsEnabled;
      try {
        _changeNotificationsEnabled = false;

        var valueListener:Function = function(value:Object):void {
          valueUpdated(remoteValueState);
        }
        BindingUtils.bindSetter(valueListener, remoteValueState, "value", true);

        if(remoteValueState is RemoteCompositeValueState) {
          var selectedIndicesListener:Function = function(selectedIndices:Array):void {
            selectedIndicesUpdated(remoteValueState as RemoteCompositeValueState);
          }
          BindingUtils.bindSetter(selectedIndicesListener, remoteValueState, "selectedIndices", true);
        }

      } finally {
        _changeNotificationsEnabled = wasEnabled;
      }
    }
    
    public function valueUpdated(remoteValueState:RemoteValueState):void {
      if(_changeNotificationsEnabled) {
        //trace(">>> Value update <<< " + remoteValueState.value);
        var command:RemoteValueCommand = new RemoteValueCommand();
        command.targetPeerGuid = remoteValueState.guid;
        command.value = remoteValueState.value;
        registerCommand(command);
      }
    }
    
    public function selectedIndicesUpdated(remoteCompositeValueState:RemoteCompositeValueState):void {
      if(_changeNotificationsEnabled) {
        //trace(">>> Selected indices update <<< " + remoteCompositeValueState.selectedIndices + " on " + remoteCompositeValueState.value);
        var command:RemoteSelectionCommand = new RemoteSelectionCommand();
        command.targetPeerGuid = remoteCompositeValueState.guid;
        command.selectedIndices = remoteCompositeValueState.selectedIndices;
        command.leadingIndex = remoteCompositeValueState.leadingIndex;
        registerCommand(command);
      }
    }

    public function leadingIndexUpdated(remoteCompositeValueState:RemoteCompositeValueState):void {
      if(_changeNotificationsEnabled) {
        //trace(">>> Leading index update <<< " + remoteCompositeValueState.leadingIndex + " on " + remoteCompositeValueState.value);
        var command:RemoteSelectionCommand = new RemoteSelectionCommand();
        command.targetPeerGuid = remoteCompositeValueState.guid;
        command.selectedIndices = remoteCompositeValueState.selectedIndices;
        command.leadingIndex = remoteCompositeValueState.leadingIndex;
        registerCommand(command);
      }
    }

    public function execute(action:RAction, param:String=null):void {
      //trace(">>> Execute <<< " + action.name + " param = " + param);
      var command:RemoteActionCommand = new RemoteActionCommand();
      command.targetPeerGuid = action.guid;
      command.parameter = param;
      registerCommand(command);
    }
    
    protected function registerCommand(command:RemoteCommand):void {
      if(_commandRegistrationEnabled) {
        //trace("Command registered for next round trip : " + command);
        _commandsQueue.addItem(command);
        dispatchCommands();
        _commandsQueue.removeAll();
      }
    }

    protected function handleCommands(commands:ListCollectionView):void {
      //trace("Recieved commands :");
      try {
        _commandRegistrationEnabled = false;
        if (commands != null) {
          for each(var command:RemoteCommand in commands) {
            //trace("  -> " + command);
            handleCommand(command);
          }
        }
      } finally {
        _commandRegistrationEnabled = true;
      }
    }

    protected function handleCommand(command:RemoteCommand):void {
      if(command is RemoteMessageCommand) {
        var messageCommand:RemoteMessageCommand = command as RemoteMessageCommand;
        var alert:Alert = Alert.show(messageCommand.message,
                   messageCommand.title,
                   Alert.OK,
                   null,
                   null,
                   null,
                   Alert.OK);

        if(messageCommand.messageIcon) {
          var alertForm:UIComponent =  alert.getChildAt(0) as UIComponent;
          var messageIcon:Class = _viewFactory.getIconForComponent(alertForm, messageCommand.messageIcon);
          alert.iconClass = messageIcon;
          alert.removeChild(alertForm);
          for(var childIndex:int = alertForm.numChildren - 1; childIndex>=0; childIndex--) {
            var childComp:DisplayObject = alertForm.getChildAt(childIndex);
            if(childComp is Button) {
              alertForm.removeChildAt(childIndex);
            }
          }
          alert.addChild(alertForm);
        }

        if(messageCommand.titleIcon) {
          var titleIcon:Class = _viewFactory.getIconForComponent(alert, messageCommand.titleIcon);
          alert.titleIcon = titleIcon;
        }
      } else if(command is RemoteInitCommand) {
        var initCommand:RemoteInitCommand = command as RemoteInitCommand;
        initApplicationFrame(initCommand.workspaceActions,
                             initCommand.actions,
                             initCommand.helpActions);
      } else {
        var targetPeer:IRemotePeer = getRegistered(command.targetPeerGuid);
        if(targetPeer == null) {
          handleError("Target remote peer could not be retrieved :");
          handleError("  guid    = " + command.targetPeerGuid);
          handleError("  command = " + command);
          if(command is RemoteValueCommand) {
            handleError("  value   = " + (command as RemoteValueCommand).value);
          } else if(command is RemoteChildrenCommand) {
            for each (var childState:RemoteValueState in (command as RemoteChildrenCommand).children) {
              handleError("  child = " + childState);
              handleError("    guid  = " + childState.guid);
              handleError("    value = " + childState.value);
            }
          }
          return;
        }
        if(command is RemoteValueCommand) {
          (targetPeer as RemoteValueState).value =
            (command as RemoteValueCommand).value;
          if(targetPeer is RemoteCompositeValueState) {
           (targetPeer as RemoteCompositeValueState).description =
             (command as RemoteValueCommand).description;
           (targetPeer as RemoteCompositeValueState).iconImageUrl =
             (command as RemoteValueCommand).iconImageUrl;
          }
        } else if(command is RemoteReadabilityCommand) {
          (targetPeer as RemoteValueState).readable =
            (command as RemoteReadabilityCommand).readable;
        } else if(command is RemoteWritabilityCommand) {
          (targetPeer as RemoteValueState).writable =
            (command as RemoteWritabilityCommand).writable;
        } else if(command is RemoteSelectionCommand) {
          (targetPeer as RemoteCompositeValueState).selectedIndices =
            (command as RemoteSelectionCommand).selectedIndices;
          (targetPeer as RemoteCompositeValueState).leadingIndex =
            (command as RemoteSelectionCommand).leadingIndex;
        } else if(command is RemoteEnablementCommand) {
          (targetPeer as RAction).enabled =
            (command as RemoteEnablementCommand).enabled;
        } else if(command is RemoteChildrenCommand) {
          var children:ListCollectionView = (targetPeer as RemoteCompositeValueState).children; 
          //children.disableAutoUpdate();
          children.removeAll();
          if((command as RemoteChildrenCommand).children != null) {
            for each(var child:RemoteValueState in (command as RemoteChildrenCommand).children) {
              if(isRegistered(child.guid)) {
                child = getRegistered(child.guid) as RemoteValueState;
              } else {
                register(child);
              }
              children.addItem(child);
            }
          }
          //children.enableAutoUpdate();
        }
      }
    }

    protected function handleError(message:String):void {
      trace("Recieved error : " + message);
    }

    public function getRegistered(guid:String):IRemotePeer {
      return _remotePeerRegistry.getRegistered(guid);
    }

    public function unregister(guid:String):void {
      _remotePeerRegistry.unregister(guid);
    }

    public function isRegistered(guid:String):Boolean {
      return _remotePeerRegistry.isRegistered(guid);
    }
    
    protected function dispatchCommands():void {
      var operation:Operation = _remoteController.operations[HANDLE_COMMANDS_METHOD] as Operation;
      operation.send(_commandsQueue);
      _commandsQueue.removeAll();
    }
    
    private function initRemoteController():void {
      _remoteController.showBusyCursor = true;
      var commandsHandler:Function = function(resultEvent:ResultEvent):void {
        handleCommands(resultEvent.result as ListCollectionView);
      };
      var errorHandler:Function = function(faultEvent:FaultEvent):void {
        handleError(faultEvent.fault.message);
      };
      var operation:Operation;
      operation = _remoteController.operations[HANDLE_COMMANDS_METHOD];
      operation.addEventListener(ResultEvent.RESULT, commandsHandler);
      operation.addEventListener(FaultEvent.FAULT, errorHandler);
      operation = _remoteController.operations[START_METHOD];
      operation.addEventListener(ResultEvent.RESULT, commandsHandler);
      operation.addEventListener(FaultEvent.FAULT, errorHandler);
    }
    
    private function initApplicationFrame(workspaceActions:Array,
                                          actions:Array,
                                          helpActions:Array):void {
      var controlBar:ApplicationControlBar = new ApplicationControlBar();
      controlBar.dock = true;
      (Application.application as Application).addChild(controlBar);
      controlBar.addChild(createApplicationMenuBar(workspaceActions, actions, helpActions));
    }
    
    private function createApplicationMenuBar(workspaceActions:Array,
                                              actions:Array,
                                              helpActions:Array):MenuBar {
      var menuBarModel:Object = new Object();
      var menus:Array = new Array();
      menus = menus.concat(createMenus(workspaceActions, true));
      menus = menus.concat(createMenus(actions, false));
      menus = menus.concat(createMenus(helpActions, true));
      menuBarModel["children"] = menus;
      
      var menuBar:MenuBar = new MenuBar();
      menuBar.percentWidth = 100.0;
      menuBar.showRoot = false;
      menuBar.dataProvider = menus;
      
      var menuHandler:Function = function(event:MenuEvent):void  {
        if (event.item["data"] is RAction) {
          execute(event.item["data"] as RAction, null);
        }        
      }
      menuBar.addEventListener(MenuEvent.ITEM_CLICK, menuHandler);

      return menuBar;                                            
    }
    
    private function createMenus(actionLists:Array, useSeparator:Boolean):Array {
      var menus:Array = new Array();
      if(actionLists != null) {
        var menu:Object;
        for each (var actionList:RActionList in actionLists) {
          if (!useSeparator || menus.length == 0) {
            menu = createMenu(actionList);
            menus.push(menu);
          } else {
            var separator:Object = new Object();
            separator["type"] = "separator";
            for each (var menuItem:Object in createMenuItems(actionList)) {
              menu["children"].push(menuItem);
            }
          }
        }
      }
      return menus;
    }
    
    private function createMenu(actionList:RActionList):Object {
      var menu:Object = new Object();
      menu["label"] = actionList.name;
      menu["description"] = actionList.description;
      menu["data"] = actionList;
      menu["rIcon"] = actionList.icon;
      
      var menuItems:Array = new Array();
      for each (var menuItem:Object in createMenuItems(actionList)) {
        menuItems.push(menuItem);
      }
      menu["children"] = menuItems;
      return menu;
    }
  
    private function createMenuItems(actionList:RActionList):Array {
      var menuItems:Array = new Array();
      for each(var action:RAction in actionList.actions) {
        menuItems.push(createMenuItem(action));
      }
      return menuItems;
    }
  
    private function createMenuItem(action:RAction):Object {
      var menuItem:Object = new Object();
      menuItem["label"] = action.name;
      menuItem["description"] = action.description;
      menuItem["data"] = action;
      menuItem["rIcon"] = action.icon;
      return menuItem;
    }

    public function start(language:String):void {
      var operation:Operation = _remoteController.operations[START_METHOD] as Operation;
      operation.send(language);
    }
    
  }
}