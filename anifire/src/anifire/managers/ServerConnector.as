package anifire.managers
{
	import anifire.constant.ServerConstants;
	import anifire.event.StudioEvent;
	import anifire.models.ApiEventModel;
	import anifire.util.UtilErrorLogger;
	import anifire.util.UtilUser;
	import com.adobe.serialization.json.JSON;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Timer;

	public class ServerConnector extends EventDispatcher
	{
		private static var _instance:ServerConnector;
		public static const TYPE_FONT:String = "font";
		private static var _configManager:AppConfigManager = AppConfigManager.instance;
		public static const HEARTBEAT_URI:String = "goapi/heartbeat/v1/";
		public static const HEARTBEAT_INTERVAL:int = 2 * 60 * 1000;

		private var _logger:UtilErrorLogger;
		/** Decodes a String containing JSON data. */
		private var _decodeFunc:Function;
		private var _events:Vector.<ApiEventModel>;
		private var _heartbeatStarted:Boolean;
		private var _heartbeatTimer:Timer;
		private var _heartbeatLoader:URLLoader;
		private var _heartbeatRequest:URLRequest;

		public function ServerConnector()
		{
			super();
			this.init();
		}

		public static function get instance() : ServerConnector
		{
			if (!_instance) {
				_instance = new ServerConnector();
			}
			return _instance;
		}

		protected function init() : void
		{
			this._events = new Vector.<ApiEventModel>();
			this._logger = UtilErrorLogger.getInstance();
			this._decodeFunc = com.adobe.serialization.json.JSON.decode;
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("onUpsellUpgrade", this.onUpsellUpgradePending);
				ExternalInterface.addCallback("selectSceneByGuid", this.selectSceneByGuid);
				ExternalInterface.addCallback("setWorkNoteMenuItemSelected", this.setWorkNoteMenuItemSelected);
				ExternalInterface.addCallback("bind", this.bind);
				ExternalInterface.addCallback("unbind", this.unbind);
				ExternalInterface.addCallback("openYourLibrary", this.openYourLibrary);
				var onInit:String = _configManager.getValue("initcb");
				if (onInit) {
					ExternalInterface.call(onInit);
				}
			}
		}

		public function bind(eventName:String, callback:String) : void
		{
			this._events.push(new ApiEventModel(eventName, callback));
		}

		public function unbind(eventName:String, callback:String) : void
		{
			var length:int = int(this._events.length);
			for (var i = length; i >= 0; i--) {
				var event:ApiEventModel = this._events[i];
				if (event.eventName == eventName && event.callback == callback) {
					this._events.splice(i, 1);
				}
			}
		}

		public function notifyEvent(eventName:String, extraData:Object = null) : void
		{
			if (!ExternalInterface.available) {
				return;
			}
			if (!extraData) {
				extraData = {};
			}
			var length:int = int(this._events.length);
			for (var i:int = 0; i < length; i++) {
				var event:ApiEventModel = this._events[i];
				if (event.eventName == eventName) {
					ExternalInterface.call(event.callback, eventName, extraData);
				}
			}
		}

		public function notifyAssetReady(type:String, file:String) : void
		{
			var extraData:Object = {};
			extraData["type"] = type;
			extraData["file"] = file;
			this.notifyEvent("userAssetReady", extraData);
		}

		public function notifyAssetDelete(type:String, file:String) : void
		{
			var extraData:Object = {};
			extraData["type"] = type;
			extraData["file"] = file;
			this.notifyEvent("userAssetDelete", extraData);
		}

		public function startHeartbeat(movieId:String = null) : void
		{
			if (this._heartbeatStarted) {
				return;
			}
			this._heartbeatStarted = true;
			this._heartbeatTimer = new Timer(HEARTBEAT_INTERVAL);
			this._heartbeatTimer.addEventListener(TimerEvent.TIMER, this.onHeartbeatTimer);
			var variables:URLVariables = new URLVariables();
			_configManager.appendURLVariables(variables);
			if (!variables["movieId"] && Boolean(movieId)) {
				variables["movieId"] = movieId;
			}
			variables["actions"] = "lock";
			this._heartbeatRequest = new URLRequest(ServerConstants.HOST_PATH + HEARTBEAT_URI);
			this._heartbeatRequest.data = variables;
			this._heartbeatRequest.method = URLRequestMethod.POST;
			this._logger.info("[HB] Started with movie ID: " + variables["movieId"]);
			this.sendHeartbeat();
		}

		private function sendHeartbeat() : void
		{
			this._heartbeatLoader = new URLLoader();
			this._heartbeatLoader.addEventListener(Event.COMPLETE, this.onHeartbeatComplete);
			this._heartbeatLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onHeartbeatError);
			this._heartbeatLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onHeartbeatError);
			this._heartbeatLoader.load(this._heartbeatRequest);
		}

		private function onHeartbeatTimer(event:TimerEvent) : void
		{
			this.sendHeartbeat();
		}

		private function onHeartbeatComplete(event:Event) : void
		{
			try {
				var result:Object = this._decodeFunc(this._heartbeatLoader.data);
				if (result["health"] == "1") {
					this._logger.info("[HB OK] " + result["ts"]);
					if (result["locked"] == "1") {
						var studioEvent:StudioEvent = new StudioEvent(StudioEvent.HEARTBEAT_TAKEOVER);
						studioEvent.data = result["locker"];
						this._logger.info("[LOCK] Taken over by:" + result["locker"]);
						dispatchEvent(studioEvent);
					}
				} else {
					this._logger.info("[HB NG] " + result["errmsg"] + " " + result["ts"]);
				}
			} catch (e:Error) {
				_logger.info("[HB ERR]\n" + _heartbeatLoader.data + "\n---\n");
				return;
			}
			this.clearHeartbeatLoader();
			this._heartbeatTimer.reset();
			this._heartbeatTimer.start();
		}

		private function onHeartbeatError(event:Event) : void
		{
			this._logger.info("[HB FAIL] " + event);
			this.clearHeartbeatLoader();
			this._heartbeatTimer.reset();
			this._heartbeatTimer.start();
		}

		private function clearHeartbeatLoader() : void
		{
			if (this._heartbeatLoader) {
				this._heartbeatLoader.addEventListener(Event.COMPLETE, this.onHeartbeatComplete);
				this._heartbeatLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onHeartbeatError);
				this._heartbeatLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onHeartbeatError);
				this._heartbeatLoader = null;
			}
		}

		public function notifySceneChange(guid:String) : void
		{
			if (guid) {
				var extraData:Object = {};
				extraData["guid"] = guid;
				this.notifyEvent("scene", extraData);
			}
		}

		public function setWorkNoteSideBarVisible(visibility:Boolean) : void
		{
			var extraData:Object = {};
			extraData["visible"] = visibility;
			this.notifyEvent("showSideBar", extraData);
		}

		public function setWorkNoteMenuItemSelected(sidebarVisible:Boolean) : void
		{
			var event:StudioEvent = new StudioEvent(StudioEvent.WORK_NOTE_VISIBILITY_CHANGE);
			event.data = sidebarVisible;
			dispatchEvent(event);
		}

		public function openYourLibrary() : void
		{
			var event:StudioEvent = new StudioEvent(StudioEvent.OPEN_YOUR_LIBRARY);
			dispatchEvent(event);
		}

		public function selectSceneByGuid(guid:String) : void
		{
			if (guid) {
				var event:StudioEvent = new StudioEvent(StudioEvent.SELECT_SCENE_FROM_NOTE);
				event.data = guid;
				dispatchEvent(event);
			}
		}

		/**
		 * Whether the tutorial should be skipped.
		 */
		public function get neverDisplayTutorial() : Boolean
		{
			if (ExternalInterface.available) {
				return ExternalInterface.call("interactiveTutorial.neverDisplay");
			}
			return false;
		}

		public function set neverDisplayTutorial(value:Boolean) : void
		{
			if (ExternalInterface.available) {
				ExternalInterface.call("interactiveTutorial.neverDisplay", value);
			}
		}

		/**
		 * Triggers an upsell to be displayed.
		 */
		public function displayUpsellHook(hookId:String) : void
		{
			if (ExternalInterface.available) {
				ExternalInterface.call("triggerUpsell", hookId);
			}
		}

		public function onUpsellUpgradePending() : void
		{
			dispatchEvent(new StudioEvent(StudioEvent.UPGRADE_PENDING));
		}

		public function refreshUserType() : void
		{
			var variables:URLVariables = AppConfigManager.instance.createURLVariables();
			var request:URLRequest = new URLRequest(ServerConstants.ACTION_GET_INIT_PARAMS);
			request.data = variables;
			request.method = URLRequestMethod.POST;
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, this.onRefreshUserTypeComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onRefreshUserTypeError);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onRefreshUserTypeError);
			urlLoader.load(request);
		}

		private function onRefreshUserTypeComplete(event:Event) : void
		{
			var urlLoader:URLLoader = event.target as URLLoader;
			urlLoader.removeEventListener(Event.COMPLETE, this.onRefreshUserTypeComplete);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, this.onRefreshUserTypeError);
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onRefreshUserTypeError);
			try {
				var result:Object = this._decodeFunc(urlLoader.data);
				if (result["result"] != true) {
					this.dispatchRefreshUserTypeError(result["message"]);
					return;
				}
				var newUserType:Number = Number(result["ut"]);
				UtilUser.updateUserType(newUserType);
				this._logger.info("User type upgraded to: " + newUserType);
			} catch (e:Error) {
				dispatchRefreshUserTypeError(e.message, e);
				return;
			}
			dispatchEvent(new StudioEvent(StudioEvent.UPGRADE_COMPLETE));
		}

		private function onRefreshUserTypeError(event:Event) : void
		{
			var urlLoader:URLLoader = event.target as URLLoader;
			urlLoader.removeEventListener(Event.COMPLETE, this.onRefreshUserTypeComplete);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, this.onRefreshUserTypeError);
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onRefreshUserTypeError);
			this.dispatchRefreshUserTypeError(event.toString());
		}

		private function dispatchRefreshUserTypeError(msg:String = "", e:Error = null) : void
		{
			this._logger.appendCustomError("Upgrade error: " + msg, e);
			dispatchEvent(new StudioEvent(StudioEvent.UPGRADE_ERROR));
		}
	}
}
