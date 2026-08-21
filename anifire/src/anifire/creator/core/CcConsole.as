package anifire.creator.core
{
	import anifire.component.CCThumb;
	import anifire.constant.CcLibConstant;
	import anifire.constant.CcServerConstant;
	import anifire.constant.LicenseConstants;
	import anifire.constant.ServerConstants;
	import anifire.creator.components.ConfirmPopUp;
	import anifire.creator.events.CcCoreEvent;
	import anifire.creator.events.CcPointUpdateEvent;
	import anifire.creator.events.CcSaveCharEvent;
	import anifire.creator.interfaces.ICcCharEditorContainer;
	import anifire.creator.interfaces.ICcMainUiContainer;
	import anifire.creator.interfaces.ICcPreviewAndSaveContainer;
	import anifire.creator.interfaces.IConfiguration;
	import anifire.creator.models.CcCharacter;
	import anifire.creator.models.CcTheme;
	import anifire.event.LoadEmbedMovieEvent;
	import anifire.event.StudioEvent;
	import anifire.managers.AmplitudeAnalyticsManager;
	import anifire.managers.AppConfigManager;
	import anifire.managers.ExternalLinkManager;
	import anifire.managers.NativeCursorManager;
	import anifire.managers.ServerConnector;
	import anifire.util.UtilCrypto;
	import anifire.util.UtilDict;
	import anifire.util.UtilErrorLogger;
	import anifire.util.UtilHashArray;
	import anifire.util.UtilNetwork;
	import anifire.util.UtilSite;
	import anifire.util.UtilURLStream;
	import anifire.util.UtilUser;
	import com.adobe.serialization.json.JS0N;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.utils.Base64Encoder;
	import mx.utils.StringUtil;
	import nochump.util.zip.ZipEntry;
	import spark.events.PopUpEvent;

	public class CcConsole implements IEventDispatcher
	{
		private static var _cc_console:CcConsole;
		private static var _cfg:IConfiguration;
		private static var _updatePopUp:IFlexDisplayObject;
		private static var _themeId:String = "";
		private static var _configManager:AppConfigManager = AppConfigManager.instance;
		private var _eventDispatcher:EventDispatcher;
		private var _ccCharEditorController:CcCharEditorController;
		private var _ccPreviewAndSaveController:CcPreviewAndSaveController;
		private var _ccChar:CcCharacter;
		private var _themes:UtilHashArray;
		private var _currentThemeId:String;
		private var _ui_mainUiContainer:ICcMainUiContainer;
		private var _moneyMode:int;
		private var _isUserLogined:Boolean;
		private var _userLevel:int;
		private var _original_assetId:String;
		private var _coupon:int = 0;
		private var _upsellHookId:String;
		private var _expectedUserType:Number = -1;
		private var _serverConnector:ServerConnector;
		private var _modeInEdit:Boolean = true;

		public function CcConsole(
			main_ui_container:ICcMainUiContainer,
			ui_ce_container:ICcCharEditorContainer, 
			ui_ps_container:ICcPreviewAndSaveContainer
		)
		{
			super();
			this._ui_mainUiContainer = main_ui_container;
			this._eventDispatcher = new EventDispatcher();
			this._themes = new UtilHashArray();

			var themeId:String = _configManager.getValue(ServerConstants.PARAM_THEME_ID);
			if (themeId == null || themeId.length <= 0) {
				themeId = "family";
			}
			setThemeId(themeId);

			this.originalAssetId = _configManager.getValue("original_asset_id") as String;
			if (this.originalAssetId == null || this.originalAssetId.length <= 0) {
				this.originalAssetId = null;
			}

			var isUserLoginParam:String = _configManager.getValue(ServerConstants.FLASHVAR_IS_USER_LOGIN_MODE) as String;
			if (isUserLoginParam == "Y") {
				this._isUserLogined = true;
			} else {
				this._isUserLogined = false;
			}

			this.addCallBacks();

			var moneyModeParam:String = _configManager.getValue(ServerConstants.FLASHVAR_MONEY_MODE) as String;
			this.initMoneyMode(moneyModeParam);

			var userLevelParam:String = _configManager.getValue(ServerConstants.FLASHVAR_IS_ADMIN) as String;
			if (userLevelParam == "1") {
				this._userLevel = CcLibConstant.USER_LEVEL_SUPER;
			} else {
				this._userLevel = CcLibConstant.USER_LEVEL_NORMAL;
			}

			this._ccCharEditorController = new CcCharEditorController();
			this.ccCharEditorController.configuration = _cfg;
			this.ccCharEditorController.initUi(ui_ce_container);
			this.ccCharEditorController.addEventListener(CcCoreEvent.USER_WANT_TO_PREVIEW, this.onUserWantToPreview);
			this.ccCharEditorController.addEventListener(CcCoreEvent.USER_WANT_TO_MODIFY, this.onUserWantToModify);
			this.ccCharEditorController.addEventListener(CcCoreEvent.USER_WANT_TO_SAVE, this.onUserWantToSave);

			this._ccPreviewAndSaveController = new CcPreviewAndSaveController();
			this._ccPreviewAndSaveController.configuration = _cfg;
			this.ccPreviewAndSaveController.initUi(ui_ps_container);
			this.ccPreviewAndSaveController.addEventListener(CcCoreEvent.USER_WANT_TO_CANCEL, this.onUserWantToEditAgain);
			this.ccPreviewAndSaveController.addEventListener(CcCoreEvent.USER_WANT_TO_CONFIRM, this.onUserWantToConfirm);
			this.ccPreviewAndSaveController.addEventListener(CcCoreEvent.USER_WANT_TO_MODIFY, this.onUserWantToModify);
			this.ccPreviewAndSaveController.addEventListener(CcCoreEvent.USER_WANT_TO_SAVE, this.onUserWantToSave);

			this._serverConnector = ServerConnector.instance;
			this._serverConnector.addEventListener(StudioEvent.UPGRADE_PENDING, this.onUpgradePending);
			this._serverConnector.addEventListener(StudioEvent.UPGRADE_COMPLETE, this.onUpgradeComplete);
			this._serverConnector.addEventListener(StudioEvent.UPGRADE_ERROR, this.onUpgradeError);
			this.loadCcThemeList();
		}

		public static function setThemeId(value:String) : void
		{
			_themeId = value;
		}

		public static function setConfiguration(value:IConfiguration) : void
		{
			_cfg = value;
		}

		public static function initializeCcConsole(
			main_ui_container:ICcMainUiContainer,
			ui_ce_container:ICcCharEditorContainer,
			ui_ps_container:ICcPreviewAndSaveContainer
		) : CcConsole
		{
			if (_cc_console == null) {
				_cc_console = new CcConsole(main_ui_container, ui_ce_container, ui_ps_container);
			}
			return _cc_console;
		}

		public static function getCcConsole() : CcConsole
		{
			if (_cc_console != null) {
				return _cc_console;
			}
			throw new Error("CcConsole must be intialized first");
		}

		public function get configuration() : IConfiguration
		{
			return _cfg;
		}

		private function get coupon() : int
		{
			return this._coupon;
		}

		private function get originalAssetId() : String
		{
			return this._original_assetId;
		}

		private function set originalAssetId(value:String) : void
		{
			this._original_assetId = value;
		}

		private function get isUserLogined() : Boolean
		{
			return this._isUserLogined;
		}

		private function get moneyMode() : int
		{
			return this._moneyMode;
		}

		private function get userLevel() : int
		{
			return this._userLevel;
		}

		private function get ui_mainUiContainer() : ICcMainUiContainer
		{
			return this._ui_mainUiContainer;
		}

		private function get ccCharEditorController() : CcCharEditorController
		{
			return this._ccCharEditorController;
		}

		private function get ccPreviewAndSaveController() : CcPreviewAndSaveController
		{
			return this._ccPreviewAndSaveController;
		}

		private function get ccChar() : CcCharacter
		{
			return this._ccChar;
		}

		public function resetExpectedUserType() : void
		{
			this._expectedUserType = -1;
			this._upsellHookId = null;
		}

		private function initMoneyMode(mode:String) : void
		{
			if (mode == "free") {
				this._moneyMode = CcLibConstant.MONEY_MODE_NORMAL;
				this._coupon = CcLibConstant.COUPON_VALUE;
			} else if (mode == "noneed") {
				this._moneyMode = CcLibConstant.MONEY_MODE_DONT_NEED_MONEY;
			} else if (mode == "school") {
				this._moneyMode = CcLibConstant.MONEY_MODE_SCHOOL;
			} else {
				this._moneyMode = CcLibConstant.MONEY_MODE_NORMAL;
			}
		}

		private function onUpgradeComplete(event:Event) : void
		{
			this.ccCharEditorController.updateTopButtonOnRole();
			this.ccPreviewAndSaveController.updateTopButtonOnRole();
		}

		private function onUpgradeError(event:Event) : void
		{
			UtilErrorLogger.getInstance().appendCustomError("Failed to refresh user type: " + event);
		}

		private function onUpgradePending(event:Event) : void
		{
			var popUp:ConfirmPopUp = new ConfirmPopUp();
			popUp.message = UtilDict.toDisplay("go", "Once you complete your purchase, please save this character.");
			popUp.title = UtilDict.toDisplay("go", "Refresh to Unlock Features");
			popUp.confirmText = UtilDict.toDisplay("go", "OK");
			popUp.addEventListener(StudioEvent.POPUP_CONFIRM, this.onConfirmAlert);
			popUp.showCancelButton = false;
			popUp.showCloseButton = false;
			popUp.open(FlexGlobals.topLevelApplication as DisplayObjectContainer, true);
		}

		private function onConfirmAlert(event:Event) : void
		{
			ServerConnector.instance.refreshUserType();
		}

		private function addCallBacks() : void
		{
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("ccUpgradePending", this.onUpgradeActived);
			}
		}

		private function addTheme(param1:CcTheme) : void
		{
			this._themes.push(param1.id, param1);
		}

		private function getTheme(param1:String) : CcTheme
		{
			return this._themes.getValueByKey(param1) as CcTheme;
		}

		private function setCurrentThemeId(param1:String) : void
		{
			this._currentThemeId = param1;
		}

		private function getCurrentThemeId() : String
		{
			return this._currentThemeId;
		}

		private function loadCcThemeList() : void
		{
			this.onLoadCcThemeListComplete();
		}

		public function isCopyingChar() : Boolean
		{
			return this.originalAssetId == null ? false : true;
		}

		public function getTemplateCCPreMadeChars() : Array
		{
			var theme:CcTheme = this.getTheme(this.getCurrentThemeId());
			return theme.preMadeChars;
		}

		public function refreshTemplateCCSelector(chars:Array, tag:String = "default") : void
		{
			var _console:CcConsole = this;
			var _numCC:int = int(chars.length);
			var numCCStarted:int = 0;
			if (chars.length == 0) {
				return;
			}
			for each (var char:CcCharacter in chars) {
				(function() : void
				{
					var _ccChar = char;
					var stream = new UtilURLStream();
					var _ccActionHandler = function(event:Event):void
					{
						stream.removeEventListener(Event.COMPLETE, _ccActionHandler);
						parseCCActionZipEventHandler({
							"char": _ccChar, 
							"streamEvent": event, 
							"tag": tag
						});
					};
					var request = UtilNetwork.getGetCcActionRequest(char.assetId, char.thumbnailActionId + ".zip");
					stream.addEventListener(Event.COMPLETE, _ccActionHandler);
					addEventListener(
						CcCoreEvent.LOAD_CHARACTER_THUMB_COMPLETE,
						function (event:CcCoreEvent) : void
						{
							if (--_numCC <= 0) {
								_console.dispatchEvent(new CcCoreEvent(
									CcCoreEvent.LOAD_CHARACTER_THUMB_ALL_COMPLETE,
									_console,
									{
										"tag": tag, 
										"total": chars.length
									}
								));
							}
						}
					);
					stream.load(request);
				})();
			}
		}

		private function onUserWantToStart(event:Event) : void
		{
			this.ccCharEditorController.initTheme(this.getTheme(this.getCurrentThemeId()));
			this.ccCharEditorController.initMode(this.moneyMode, this.isUserLogined, this.userLevel, this.coupon);
			this.ccCharEditorController.start(this.ccChar, !this.isCopyingChar());
			this.ccPreviewAndSaveController.initTheme(this.getTheme(this.getCurrentThemeId()));
			this.ccPreviewAndSaveController.initMode();
			this.ccPreviewAndSaveController.initChar(this.ccChar);
			this._modeInEdit = true;
			if (_configManager.getValue(ServerConstants.FLASHVAR_CC_START_PAGE) == "save") {
				this.onUserWantToPreview(event);
			}
			this.dispatchEvent(new CcCoreEvent(CcCoreEvent.LOAD_EVERYTHING_COMPLETE, this));
		}

		private function onUserWantToModify(event:Event) : void
		{
			this._modeInEdit = true;
			this.ui_mainUiContainer.ui_main_ccCharEditor.visible = true;
			this.ui_mainUiContainer.ui_main_ccCharPreviewAndSaveScreen.visible = false;
			this.ccCharEditorController.proceedToShow();
		}

		private function onUserWantToPreview(event:Event) : void
		{
			this._modeInEdit = false;
			this.ui_mainUiContainer.ui_main_ccCharEditor.visible = false;
			this.ui_mainUiContainer.ui_main_ccCharPreviewAndSaveScreen.visible = true;
			this.ccPreviewAndSaveController.proceedToShow();
		}

		private function onUserWantToGoToStudio(event:Event) : void
		{
			if (UtilSite.siteId == UtilSite.YOUTUBE || UtilSite.siteId == UtilSite.SKOLETUBE) {
				ExternalLinkManager.instance.navigate(ServerConstants.YOUTUBE_CREATE_MOVIE_PATH);
				return;
			}
			var theme:CcTheme = this.getTheme(this.getCurrentThemeId());
			var path:String = ServerConstants.STUDIO_PAGE_PATH;
			if (theme.studioThemeId) {
				LicenseConstants.visitStudioByTheme(theme.studioThemeId);
				return;
			}
			if (event is CcCoreEvent) {
				var evtData:Object = (event as CcCoreEvent).getData();
				if (evtData != null && String(evtData) != "") {
					path = String(evtData);
				}
			}
			ExternalLinkManager.instance.navigateWithSession(path);
		}

		private function doUpdatePreviewStatus(event:CcPointUpdateEvent) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.doUpdatePreviewStatus);
		}

		private function doUpdatePreviewStatusAndConfirm(event:CcPointUpdateEvent) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.doUpdatePreviewStatusAndConfirm);
		}

		private function onUserWantToConfirm(event:Event) : void
		{
			if (CcLibConstant.IS_BUSINESS_THEME && !UtilUser.hasBusinessFeatures)
			{
				this._expectedUserType = UtilUser.PUBLISH_USER;
			}
			else if (UtilUser.userType == UtilUser.BASIC_USER)
			{
				this._expectedUserType = UtilUser.PLUS_USER;
			}
			if (this._expectedUserType > -1)
			{
				this._serverConnector.refreshUserType();
				return;
			}
			this.onUserWantToSave(null);
		}

		private function onUserWantToSave(event:Event) : void
		{
			this.addEventListener(CcSaveCharEvent.SAVE_CHAR_COMPLETE, this.doTellUserSaveStatus);
			this.addEventListener(CcSaveCharEvent.SAVE_CHAR_NOT_ENOUGH_MONEY_POINT, this.doTellUserSaveStatus);
			this.addEventListener(CcSaveCharEvent.SAVE_CHAR_ERROR_OCCUR, this.doTellUserSaveStatus);
			if (this._modeInEdit) {
				this.ccCharEditorController.addEventListener(LoadEmbedMovieEvent.COMPLETE_EVENT, this.doSave);
				this.ccCharEditorController.resetCCAction();
			} else {
				this.ccPreviewAndSaveController.addEventListener(LoadEmbedMovieEvent.COMPLETE_EVENT, this.doSave);
				this.ccPreviewAndSaveController.resetCCAction();
			}
		}

		private function doSave(event:Event) : void
		{
			NativeCursorManager.instance.setBusyCursor();
			FlexGlobals.topLevelApplication.enabled = false;
			setTimeout(this.save, 5000);
		}

		private function doTellUserSaveStatus(event:CcSaveCharEvent) : void
		{
			this.removeEventListener(CcSaveCharEvent.SAVE_CHAR_COMPLETE, this.doTellUserSaveStatus);
			this.removeEventListener(CcSaveCharEvent.SAVE_CHAR_NOT_ENOUGH_MONEY_POINT, this.doTellUserSaveStatus);
			this.removeEventListener(CcSaveCharEvent.SAVE_CHAR_ERROR_OCCUR, this.doTellUserSaveStatus);
			if (event.type == CcSaveCharEvent.SAVE_CHAR_COMPLETE) {
				this.ccPreviewAndSaveController.proceedToSaveComplete(event.gopoint, event.gobuck, event.assetId);
				try {
					var isTemplate:Boolean = false;
					if (this.ccChar.copiedFromTemplate) {
						try {
							isTemplate = !this.ccChar.isTemplateModified();
						} catch (e2:Error) {}
					}
					var js:String = StringUtil.substitute(
						"CCStandaloneBannerAdUI.gaLogTx.logCCPartsNormal({0}, {1}, {2})",
						event.assetId,
						JS0N.encode(event.gaTrackModel.parts.filter(
							function(obj:*, index:int, array:Array):Boolean
							{
								return (["GoUpper", "GoLower", "upper_body", "lower_body", "hair"] as Array).indexOf(obj.ctype) >= 0;
							}
						)),
						isTemplate ? this.ccChar.templateId : "0"
					);
					ExternalInterface.call(js);
				} catch (e:Error) {}
			} else if (event.type == CcSaveCharEvent.SAVE_CHAR_NOT_ENOUGH_MONEY_POINT) {
				this.ccPreviewAndSaveController.proceedToSaveNotEnoughMoney(event.gopoint, event.gobuck);
			} else if (event.type == CcSaveCharEvent.SAVE_CHAR_ERROR_OCCUR) {
				this.ccPreviewAndSaveController.proceedToSaveError();
			}
		}

		/**
		 * In older CC builds, this function would have made the editor visible.
		 */
		private function onUserWantToEditAgain(event:Event) : void {}

		private function onLoadCcThemeListComplete() : void
		{
			this.setCurrentThemeId(_themeId);
			this.addEventListener(CcCoreEvent.LOAD_THEME_COMPLETE, this.doLoadPreMadeChar);
			this.loadCcTheme(this.getCurrentThemeId());
		}

		private function loadLatestPreMadeChars(e:Event) : void
		{
			(e.currentTarget as CcTheme).removeEventListener(CcCoreEvent.LOAD_PRE_MADE_CHARACTER_COMPLETE, this.loadLatestPreMadeChars);
			var preMadeChars:Array = (e.currentTarget as CcTheme).preMadeChars.slice().filter(
				function (char:CcCharacter, index:int, array:Array) : Boolean
				{
					return "professions" == char.category;
				}
			);
			preMadeChars.sortOn("createDateTime", Array.DESCENDING);
			this.refreshTemplateCCSelector(preMadeChars.slice(0, 6), "latest");
		}

		private function loadRandomPreMadeChars(e:Event) : void
		{
			(e.currentTarget as CcTheme).removeEventListener(CcCoreEvent.LOAD_PRE_MADE_CHARACTER_COMPLETE, this.loadRandomPreMadeChars);
			var preMadeChars:Array = (e.currentTarget as CcTheme).preMadeChars.slice().filter(
				function (char:CcCharacter, index:int, array:Array) : Boolean
				{
					return "professions" == char.category;
				}
			);
			var randCharList:Array = [];
			if (preMadeChars.length <= 6) {
				randCharList = preMadeChars.slice(0, 6);
			} else {
				while (randCharList.length < 6) {
					var idx:int = int(Math.random() * preMadeChars.length);
					if (randCharList.indexOf(preMadeChars[idx]) < 0) {
						randCharList.push(preMadeChars[idx]);
					}
				}
			}
			this.refreshTemplateCCSelector(randCharList, "latest");
		}

		private function doLoadPreMadeChar(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.doLoadPreMadeChar);
			var theme:CcTheme = this.getTheme(this.getCurrentThemeId());
			if (this.originalAssetId != null) {
				theme.addEventListener(CcCoreEvent.LOAD_PRE_MADE_CHARACTER_COMPLETE, this.doLoadExistingCcChar);
			} else {
				theme.addEventListener(CcCoreEvent.LOAD_PRE_MADE_CHARACTER_COMPLETE, this.doPrepareCcChar);
			}
			theme.addEventListener(CcCoreEvent.LOAD_PRE_MADE_CHARACTER_COMPLETE, this.doEnableUserToStartUseCC);
			if (_cfg.loadPreMadeCharsEnabled()) {
				theme.addEventListener(CcCoreEvent.LOAD_PRE_MADE_CHARACTER_COMPLETE, this.loadLatestPreMadeChars);
				theme.initCcThemePreMadeChar();
			} else {
				theme.dispatchEvent(new CcCoreEvent(CcCoreEvent.LOAD_PRE_MADE_CHARACTER_COMPLETE, this, null));
			}
		}

		private function doEnableUserToStartUseCC(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.doEnableUserToStartUseCC);
			var self:CcConsole = this;
			var proceedHandler:Function = function (e:CcCoreEvent) : void
			{
				self.removeEventListener(CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE, proceedHandler);
				onUserWantToStart(event);
			};
			if (this.originalAssetId != null) {
				this.addEventListener(CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE, proceedHandler);
			} else {
				this.onUserWantToStart(event);
			}
		}

		private function doPrepareCcChar(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.doPrepareCcChar);
			this._ccChar = new CcCharacter();
			if (_themeId == "cc2" || _themeId == "chibi" || _themeId == "ninja") {
				this._ccChar.ver = 2;
			}
			var theme:CcTheme = this.getTheme(this.getCurrentThemeId());
			var bsTypes:Array = theme.getBodyShapeTypes();
			var bs:String = bsTypes[int(Math.floor(Math.random() * theme.getBodyShapeTypes().length))] as String;
		}

		private function doLoadExistingCcChar(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.doLoadExistingCcChar);
			this.addEventListener(CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE, this.doPrepareExistingCcChar);
			this.loadExistingCharCompositionXml(_configManager.getValue("original_asset_id") as String);
		}

		private function prepareExistingCcChar(param1:String) : void
		{
			this._ccChar = new CcCharacter();
			var arr:UtilHashArray = new UtilHashArray();
			arr.push(this.getCurrentThemeId(), this.getTheme(this.getCurrentThemeId()));
			this._ccChar.deserialize(new XML(param1), arr);
		}

		private function doPrepareExistingCcChar(event:CcCoreEvent) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.doPrepareExistingCcChar);
			this.prepareExistingCcChar(event.getData() as String);
		}

		private function save() : void
		{
			NativeCursorManager.instance.setBusyCursor();
			AmplitudeAnalyticsManager.instance.log(AmplitudeAnalyticsManager.EVENT_NAME_CREATED_CHARACTER);
			var face:ByteArray;
			var faceB64:Base64Encoder;
			var body:ByteArray;
			var bodyB64:Base64Encoder;
			if (this._modeInEdit) {
				face = this._ccCharEditorController.saveSnapShot();
				body = this._ccCharEditorController.saveSnapShot(true);
			} else {
				face = this._ccPreviewAndSaveController.saveSnapShot();
				body = this._ccPreviewAndSaveController.saveSnapShot(true);
			}
			faceB64 = new Base64Encoder();
			faceB64.encodeBytes(face);
			bodyB64 = new Base64Encoder();
			bodyB64.encodeBytes(body);
			var urlLoader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(CcServerConstant.ACTION_SAVE_CC_CHAR);
			var variables:URLVariables = new URLVariables();
			_configManager.appendURLVariables(variables);
			variables["body"] = this.serialize();
			variables["title"] = "Untitled";
			variables["imagedata"] = faceB64.flush();
			variables["thumbdata"] = bodyB64.flush();
			if (this.ccChar.assetId != "") {
				variables["assetId"] = this.ccChar.assetId;
			}
			request.data = variables;
			request.method = URLRequestMethod.POST;
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			urlLoader.addEventListener(Event.COMPLETE, this.saveCharacter_completeHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.saveCharacter_errorHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.saveCharacter_errorHandler);
			urlLoader.load(request);
		}

		private function saveCharacter_completeHandler(param1:Event) : void
		{
			NativeCursorManager.instance.removeBusyCursor();
			var loader:URLLoader = param1.target as URLLoader;
			var response:String = loader.data as String;
			loader.removeEventListener(Event.COMPLETE, this.saveCharacter_completeHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, this.saveCharacter_errorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.saveCharacter_errorHandler);
			var firstChar:String = response.slice(0, 1);
			var xml:String = response.slice(1);
			if (firstChar == "1" && xml == ServerConstants.ERROR_CODE_LOGGED_OUT) {
				this.showLoggedOutPopUp();
			} else if (ExternalInterface.available) {
				ExternalInterface.call("characterSaved");
			}
		}

		private function saveCharacter_errorHandler(param1:Event) : void
		{
			var loader:URLLoader = param1.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, this.saveCharacter_completeHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, this.saveCharacter_errorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.saveCharacter_errorHandler);
			this.dispatchEvent(new CcSaveCharEvent(CcSaveCharEvent.SAVE_CHAR_ERROR_OCCUR, this));
		}

		private function showLoggedOutPopUp() : void
		{
			var _loc1_:ConfirmPopUp = new ConfirmPopUp();
			_loc1_.title = UtilDict.translate("Logged out");
			_loc1_.message = UtilDict.translate("Login again to continue.\nUnsaved changes may have been lost.");
			_loc1_.confirmText = UtilDict.translate("Login");
			_loc1_.iconType = ConfirmPopUp.CONFIRM_POPUP_NO_ICON;
			_loc1_.showCancelButton = false;
			_loc1_.showCloseButton = false;
			_loc1_.addEventListener(PopUpEvent.CLOSE, this.loggedOutPopUp_closeHandler);
			_loc1_.open(FlexGlobals.topLevelApplication as DisplayObjectContainer, true);
		}

		private function loggedOutPopUp_closeHandler(param1:PopUpEvent) : void
		{
			ExternalLinkManager.instance.navigate(ServerConstants.LOGIN_PAGE_PATH);
		}

		private function serialize() : String
		{
			return "<?xml version=\"1.0\" encoding=\"utf-8\"?>" + this.ccChar.serialize();
		}

		private function loadCcTheme(param1:String) : void
		{
			var _loc2_:CcTheme = new CcTheme();
			_loc2_.id = param1;
			this.addTheme(_loc2_);
			_loc2_.addEventListener(CcCoreEvent.LOAD_THEME_COMPLETE, this.onLoadCcThemeComplete);
			_loc2_.initCcThemeByLoadThemeFile(param1);
		}

		private function onLoadCcThemeComplete(param1:Event) : void
		{
			(param1.target as IEventDispatcher).removeEventListener(param1.type, this.onLoadCcThemeComplete);
			this.dispatchEvent(new CcCoreEvent(CcCoreEvent.LOAD_THEME_COMPLETE, this));
		}

		private function loadExistingCharCompositionXml(param1:String) : void
		{
			var _loc2_:URLRequest = null;
			var _loc3_:URLLoader = null;
			_loc2_ = new URLRequest(ServerConstants.ACTION_GET_CC_CHAR_COMPOSITION_XML);
			_loc2_.method = URLRequestMethod.POST;
			var _loc4_:URLVariables = new URLVariables();
			_configManager.appendURLVariables(_loc4_);
			_loc4_["assetId"] = param1;
			_loc2_.data = _loc4_;
			_loc3_ = new URLLoader();
			_loc3_.dataFormat = URLLoaderDataFormat.TEXT;
			_loc3_.addEventListener(Event.COMPLETE, this.onLoadExistingCharCompositionXmlComplete);
			_loc3_.load(_loc2_);
		}

		private function onLoadExistingCharCompositionXmlComplete(param1:Event) : void
		{
			(param1.target as IEventDispatcher).removeEventListener(param1.type, this.onLoadExistingCharCompositionXmlComplete);
			var _loc2_:URLLoader = param1.target as URLLoader;
			var _loc3_:String = _loc2_.data as String;
			if (_loc3_.charAt(0) == "0") {
				var _loc4_:String = _loc3_.substr(1);
				var _loc5_:CcCoreEvent = new CcCoreEvent(CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE, this, _loc4_);
				this.dispatchEvent(_loc5_);
			}
		}

		public function parseCCActionZipEventHandler(data:Object) : void
		{
			var decryptEngine:UtilCrypto;
			var j:int = 0;
			var ccZipEntry:ZipEntry;
			var ccChar:CcCharacter = data.char as CcCharacter;
			var event:Event = data.streamEvent as Event;
			var stream:URLStream = URLStream(event.target);
			var swfBytes:ByteArray = new ByteArray();
			stream.readBytes(swfBytes, 0, stream.bytesAvailable);
			try {
				var args:Object = new Object();
				var thumb:CCThumb = new CCThumb();
				var ccConsole:CcConsole = this;
				thumb.cellWidth = thumb.cellHeight = CcLibConstant.TEMPLATE_CCTHUMB_WIDTH;
				thumb.initByXml(XML(swfBytes));
			} catch (e:Error) {
				thumb.initByXml(XML(swfBytes));
			}
			thumb.addEventListener(LoadEmbedMovieEvent.COMPLETE_EVENT, function (event:Event) : void
			{
				ccConsole.dispatchEvent(
					new CcCoreEvent(CcCoreEvent.LOAD_CHARACTER_THUMB_COMPLETE, this, {
						"char": ccChar, 
						"thumbnail": thumb, 
						"tag": data.tag
					})
				);
			});
		}

		public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
		{
			this._eventDispatcher.addEventListener(param1, param2, param3, param4, param5);
		}

		public function dispatchEvent(event:Event) : Boolean
		{
			return this._eventDispatcher.dispatchEvent(event);
		}

		public function hasEventListener(param1:String) : Boolean
		{
			return this._eventDispatcher.hasEventListener(param1);
		}

		public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
		{
			return this._eventDispatcher.removeEventListener(param1, param2, param3);
		}

		public function willTrigger(param1:String) : Boolean
		{
			return this._eventDispatcher.willTrigger(param1);
		}

		private function onUpgradeActived(param1:Event = null) : void
		{
		}
	}
}
