package anifire.browser.core
{
	import anifire.browser.events.CoreEvent;
	import anifire.browser.interfaces.IBehavior;
	import anifire.browser.interfaces.ICharProduct;
	import anifire.browser.interfaces.ITheme;
	import anifire.browser.interfaces.IThumb;
	import anifire.component.CcActionLoader;
	import anifire.constant.AnimeConstants;
	import anifire.constant.CcLibConstant;
	import anifire.constant.RaceConstants;
	import anifire.constant.ServerConstants;
	import anifire.event.StudioEvent;
	import anifire.managers.CCBodyManager;
	import anifire.managers.CCThemeManager;
	import anifire.models.creator.CCBodyModel;
	import anifire.models.creator.CCCharacterActionModel;
	import anifire.models.creator.CCThemeModel;
	import anifire.util.UtilCrypto;
	import anifire.util.UtilHashArray;
	import anifire.util.UtilHashBytes;
	import anifire.util.UtilNetwork;
	import anifire.util.UtilPlain;
	import anifire.util.UtilString;
	import anifire.util.UtilURLStream;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipFile;
	
	public class CharThumb extends Thumb implements ICharProduct
	{
		
		public static const XML_NODE_NAME:String = "char";
		
		
		private var _facing:String = "unknown";
		private var _actions:Vector.<anifire.browser.core.Action>;
		private var _actionLookup:Object;
		private var _motions:Vector.<anifire.browser.core.Motion>;
		private var _motionLookup:Object;
		private var _facials:Vector.<anifire.browser.core.Facial>;
		private var _facialLookup:Object;
		private var _libraries:UtilHashBytes;
		private var _defaultTalkAction:anifire.browser.core.Action;
		private var _defaultAction:anifire.browser.core.Action;
		private var _defaultMotion:anifire.browser.core.Motion;
		private var _isLoadingActionMotion:Boolean = false;
		private var _isZipLoaded:Boolean = false;
		private var _ccThemeId:String;
		private var _numCcAction:int = 0;
		private var _numTotalCcAction:int = 0;
		private var _copyable:Boolean = true;
		private var _tray:String;
		private var _propXML:Vector.<XML>;
		private var _propThumb:anifire.browser.core.PropThumb;
		private var _mThumbId:String;
		private var _processed:Boolean;
		private var _ccThemeModel:CCThemeModel;
		private var _locked:Boolean;
		private var _ccBodyModel:CCBodyModel;
		private var _thumbnailUrl:String;
		public var thumbBitmapData:BitmapData;
		
		public function CharThumb()
		{
			this._propXML = new Vector.<XML>();
			super();
			this.clearActionData();
			this._facials = new Vector.<anifire.browser.core.Facial>();
			this._facialLookup = {};
			this._libraries = new UtilHashBytes();
		}
		
		public function get ccThemeModel() : CCThemeModel
		{
			if(!this._ccThemeModel)
			{
				this._ccThemeModel = CCThemeManager.instance.getThemeModel(this.ccThemeId);
			}
			return this._ccThemeModel;
		}
		
		public function get ccBodyModel() : CCBodyModel
		{
			if(!this._ccBodyModel)
			{
				this._ccBodyModel = CCBodyManager.instance.getBodyModel(this.id);
			}
			return this._ccBodyModel;
		}
		
		public function get processed() : Boolean
		{
			return this._processed;
		}
		
		public function get mThumbId() : String
		{
			return this._mThumbId;
		}
		
		public function set mThumbId(param1:String) : void
		{
			this._mThumbId = param1;
		}
		
		public function get propXML() : Vector.<XML>
		{
			return this._propXML;
		}
		
		public function set propXML(param1:Vector.<XML>) : void
		{
			this._propXML = param1;
		}
		
		public function get tray() : String
		{
			return this._tray;
		}
		
		public function set tray(param1:String) : void
		{
			this._tray = param1;
		}
		
		public function get locked() : Boolean
		{
			return this._locked;
		}
		
		protected function clearActionData() : void
		{
			this._actions = new Vector.<anifire.browser.core.Action>();
			this._actionLookup = {};
			this._motions = new Vector.<anifire.browser.core.Motion>();
			this._motionLookup = {};
			this._defaultAction = null;
			this._defaultMotion = null;
			this._defaultTalkAction = null;
		}
		
		public function isSWFCharacter() : Boolean
		{
			if(this.defaultAction)
			{
				return UtilString.hasSWFextension(this.defaultAction.id);
			}
			return false;
		}
		
		public function getIsZipLoaded() : Boolean
		{
			return this._isZipLoaded;
		}
		
		private function setIsZipLoaded(param1:Boolean) : void
		{
			this._isZipLoaded = param1;
		}
		
		public function addLibrary(param1:String, param2:Object) : void
		{
			this._libraries.push(param1,param2 as ByteArray);
		}
		
		public function getLibraryNum() : Number
		{
			return this._libraries.length;
		}
		
		public function getLibraryById(param1:String) : Object
		{
			return this._libraries.getValueByKey(param1);
		}
		
		public function getLibraryIdByIndex(param1:Number) : String
		{
			return this._libraries.getKey(param1);
		}
		
		public function getLibraries() : UtilHashBytes
		{
			return this._libraries;
		}
		
		public function addAction(param1:anifire.browser.core.Action) : void
		{
			this._actions.push(param1);
			this._actionLookup[param1.id] = param1;
		}
		
		private function searchActionNodeById(param1:String) : XML
		{
			var result:XML = null;
			var id:String = param1;
			var i:int = 0;
			while(i < 12)
			{
				switch(i)
				{
					case 0:
						result = this.xml.action.(@id == id)[0];
						break;
					case 1:
						result = this.xml.group.action.(@id == id)[0];
						break;
					case 2:
						result = this.xml.category.action.(@id == id)[0];
						break;
					case 3:
						result = this.xml.category.group.action.(@id == id)[0];
						break;
					case 4:
						result = this.xml.motion.(@id == id)[0];
						break;
					case 5:
						result = this.xml.group.motion.(@id == id)[0];
						break;
					case 6:
						result = this.xml.category.motion.(@id == id)[0];
						break;
					case 7:
						result = this.xml.category.group.motion.(@id == id)[0];
						break;
					case 8:
						result = this.xml.category.category.action.(@id == id)[0];
						break;
					case 9:
						result = this.xml.category.category.group.action.(@id == id)[0];
						break;
					case 10:
						result = this.xml.category.category.motion.(@id == id)[0];
						break;
					case 11:
						result = this.xml.category.category.group.motion.(@id == id)[0];
				}
				if(result)
				{
					break;
				}
				i++;
			}
			return result;
		}
		
		private function createActionByXML(param1:XML) : anifire.browser.core.Action
		{
			var _loc2_:anifire.browser.core.Action;
			var _loc3_:anifire.browser.core.Motion;
			var _loc4_:XML;
			var _loc5_:Vector.<XML> = new Vector.<XML>();
			var _loc6_:Boolean = false;
			var _loc7_:int;
			var _loc8_:String = String(this.xml.attribute["default"]);
			var _loc9_:Array;
			var _loc10_:Number;
			if(param1.name().localName == anifire.browser.core.Motion.XML_NODE_NAME)
			{
				_loc6_ = true;
			}
			if(_loc6_)
			{
				_loc3_ = new anifire.browser.core.Motion(this,param1.@id,param1.@name,param1.@totalframe,param1.@enable,param1.@aid);
				_loc3_.defaultActionId = _loc8_;
				this.addMotion(_loc3_);
			}
			if(param1.prop.length() > 0)
			{
				_loc7_ = 0;
				while(_loc7_ < param1.prop.length())
				{
					_loc4_ = param1.prop[_loc7_];
					_loc5_.push(_loc4_);
					_loc7_++;
				}
			}
			if(param1.hasOwnProperty("@seq") && String(param1.@seq) != "" && Number(param1.@seq) > 0)
			{
				_loc9_ = new Array();
				_loc10_ = 0;
				while(_loc10_ < Number(param1.@seq))
				{
					_loc9_.push(_loc10_);
					_loc10_++;
				}
			}
			if(_loc9_)
			{
				_loc2_ = new anifire.browser.core.SequentialAction(this,param1.@id,param1.@name,param1.@totalframe,param1.@enable,param1.@aid,_loc5_);
				SequentialAction(_loc2_).actionSequence.init(_loc9_);
			}
			else
			{
				_loc2_ = new anifire.browser.core.Action(this,param1.@id,param1.@name,param1.@totalframe,param1.@enable,param1.@aid,_loc5_);
			}
			_loc2_.defaultActionId = _loc8_;
			if(param1.@next.length() > 0)
			{
				_loc2_.nextActionId = param1.@next;
			}
			_loc2_.isMotion = _loc6_;
			this.addAction(_loc2_);
			return _loc2_;
		}
		
		private function createAction(param1:String) : Action
		{
			if(!param1)
			{
				return null;
			}
			var _loc2_:Action;
			var _loc3_:Motion;
			var _loc4_:XML;
			var _loc5_:XML;
			var _loc6_:Vector.<XML> = new Vector.<XML>();
			var _loc7_:Boolean = false;
			if(this.ccBodyModel.completed)
			{
				var _loc8_:int;
				var _loc9_:CCCharacterActionModel;
				if(Boolean(_loc9_ = this.ccThemeModel.getCharacterActionModel(this.ccBodyModel,param1)) && Boolean(_loc9_.actionModel))
				{
					if(_loc9_.actionModel.propXML)
					{
						_loc8_ = 0;
						while(_loc8_ < _loc9_.actionModel.propXML.length())
						{
							_loc5_ = _loc9_.actionModel.propXML[_loc8_];
							_loc6_.push(_loc5_);
							_loc8_++;
						}
					}
					_loc2_ = new Action(this,_loc9_.actionModel.id,_loc9_.actionModel.name,_loc9_.actionModel.totalframe,"Y","",_loc6_);
					_loc2_.isMotion = _loc9_.actionModel.isMotion;
					_loc2_.defaultActionId = _loc9_.defaultActionId;
					_loc2_.nextActionId = _loc9_.actionModel.nextActionId;
					this.addAction(_loc2_);
				}
			}
			else if(this.xml)
			{
				_loc4_ = this.searchActionNodeById(param1);
				_loc2_ = this.createActionByXML(_loc4_);
			}
			return _loc2_;
		}
		
		public function getActionById(param1:String) : anifire.browser.core.Action
		{
			var _loc2_:anifire.browser.core.Action = this._actionLookup[param1];
			if(!_loc2_)
			{
				_loc2_ = this.createAction(param1);
			}
			return _loc2_;
		}
		
		public function getActionAt(param1:int) : anifire.browser.core.Action
		{
			return this._actions[param1] as anifire.browser.core.Action;
		}
		
		public function getActionNum() : int
		{
			return this._actions.length;
		}
		
		public function get facials() : Vector.<anifire.browser.core.Facial>
		{
			return this._facials;
		}
		
		public function addFacial(param1:anifire.browser.core.Facial) : void
		{
			this._facials.push(param1);
			this._facialLookup[param1.id] = param1;
		}
		
		public function getFacialById(param1:String) : anifire.browser.core.Facial
		{
			return this._facialLookup[param1];
		}
		
		public function getFacialAt(param1:int) : anifire.browser.core.Facial
		{
			return this._facials[param1];
		}
		
		public function getMotionById(param1:String) : anifire.browser.core.Motion
		{
			var _loc2_:anifire.browser.core.Motion = this._motionLookup[param1];
			if(!_loc2_)
			{
				this.getActionById(param1);
				_loc2_ = this._motionLookup[param1];
			}
			return _loc2_;
		}
		
		public function addMotion(param1:anifire.browser.core.Motion) : void
		{
			this._motions.push(param1);
			this._motionLookup[param1.id] = param1;
		}
		
		public function getMotionAt(param1:int) : anifire.browser.core.Motion
		{
			return this._motions[param1];
		}
		
		public function getMotionNum() : int
		{
			return this._motions.length;
		}
		
		public function get facing() : String
		{
			return this._facing;
		}
		
		public function set facing(param1:String) : void
		{
			this._facing = param1;
		}
		
		public function get motions() : Vector.<anifire.browser.core.Motion>
		{
			return this._motions;
		}
		
		public function get defaultTalkAction() : anifire.browser.core.Action
		{
			var action:XML = null;
			if(!this._defaultTalkAction)
			{
				if(this.xml)
				{
					action = this.xml..action.(@id.toString().search("talk") > -1 && @id.toString().search("phone") == -1)[0];
					if(action)
					{
						this._defaultTalkAction = this.getActionById(action.@id);
					}
				}
			}
			return this._defaultTalkAction;
		}
		
		override public function get defaultAction() : IBehavior
		{
			var _loc1_:String = null;
			if(!this._defaultAction && Boolean(xml))
			{
				this._defaultAction = this.getActionById(xml.@default);
			}
			if(!this._defaultAction && this.ccThemeModel.completed && this.ccBodyModel.completed)
			{
				_loc1_ = this.ccBodyModel.bodyShapeId;
				this._defaultAction = this.getActionById(this.ccThemeModel.getCharacterDefaultActionId(_loc1_));
			}
			return this._defaultAction;
		}
		
		public function get defaultMotion() : anifire.browser.core.Motion
		{
			if(!this._defaultMotion && Boolean(xml))
			{
				this._defaultMotion = this.getMotionById(this.xml.@motion);
			}
			return this._defaultMotion;
		}
		
		public function get ccThemeId() : String
		{
			return this._ccThemeId;
		}
		
		public function set ccThemeId(param1:String) : void
		{
			this._ccThemeId = param1;
		}
		
		public function get copyable() : Boolean
		{
			return this._copyable;
		}
		
		public function get thumbnailUrl() : String
		{
			if(Boolean(this._thumbnailUrl) && this._thumbnailUrl != "")
			{
				return this._thumbnailUrl;
			}
			return null;
		}
		
		override public function deSerialize(themeChar:XML, theme:ITheme, param3:Boolean = false) : void
		{
			this.xml = themeChar;
			this.setFileName("char/" + themeChar.@id + "/" + themeChar.@thumb);
			this.id = themeChar.@id;
			this.aid = themeChar.@aid;
			this.name = themeChar.@name;
			var _loc4_:Theme = theme as Theme;
			if (_loc4_.isCCTheme)
			{
				this.theme = theme;
			}
			else
			{
				this.theme = theme;
			}
			this.enable = themeChar.@enable != "N" ? true : false;
			this.raceCode = themeChar.@cc_theme_id.length() > 0 ? 1 : 0;
			if(themeChar.@raceCode.length() > 0)
			{
				this.raceCode = int(themeChar.@raceCode);
			}
			this.encryptId = themeChar.@encryptId;
			this._locked = themeChar.@locked == "Y";
			this._copyable = themeChar.@copyable == "N" ? false : true;
			this._ccThemeId = themeChar.attribute("cc_theme_id");
			this._thumbnailUrl = themeChar.@thumbnail_url;
			if(themeChar.hasOwnProperty("@path"))
			{
				this.path = String(themeChar.@path);
			}
			_loc10_ = 0;
			while (_loc10_ < themeChar.prop.length())
			{
				this.propXML.push(themeChar.prop[_loc10_]);
				_loc10_++;
			}
			if (themeChar.@facing == AnimeConstants.FACING_LEFT || themeChar.@facing == AnimeConstants.FACING_RIGHT)
			{
				this.facing = themeChar.@facing;
			}
			else
			{
				this.facing = AnimeConstants.FACING_LEFT;
			}
			tags = themeChar.child("tags");
			var _loc5_:XMLList = themeChar.child("tag");
			var _loc6_:XML;
			var _loc7_:XML;
			var _loc8_:anifire.browser.core.Facial;
			_loc10_ = 0;
			while (_loc10_ < _loc5_.length())
			{
				sysTags.push(_loc5_[_loc10_]);
				_loc10_++;
			}
			if (this.theme.id == "ugc")
			{
				this.isPublished = themeChar.@published == "1" ? true : false;
			}
			var _loc9_:int = themeChar.category.length();
			var _loc10_:int;
			_loc10_ = 0;
			this.clearActionData();
			this._facials = new Vector.<anifire.browser.core.Facial>();
			this._facialLookup = {};
			var _loc11_:XML;
			var _loc12_:XML;
			var _loc13_:String;
			var _loc14_:String;
			_loc10_ = 0;
			while (_loc10_ < themeChar.library.length())
			{
				_loc6_ = themeChar.library[_loc10_];
				_loc13_ = this.themeId + "." + _loc6_.@type + "." + _loc6_.@component_id + ".swf";
				this.addLibrary(_loc13_, null);
				_loc10_++;
			}
			_loc10_ = 0;
			while (_loc10_ < themeChar.colorset.length())
			{
				_loc11_ = themeChar.colorset[_loc10_];
				_loc14_ = _loc11_.attribute("aid").length() == 0 ? "0" : _loc11_.@aid;
				colorRef.push(_loc14_, _loc11_);
				_loc10_++;
			}
			_loc10_ = 0;
			while (_loc10_ < themeChar.c_parts.c_area.length())
			{
				_loc12_ = themeChar.c_parts.c_area[_loc10_];
				if (themeChar.c_parts.@enable != "N")
				{
					colorParts.push(_loc12_, _loc12_.attribute("oc").length() == 0 ? uint.MAX_VALUE : _loc12_.@oc);
				}
				_loc10_++;
			}
			if (this.getLibraryNum() > 0)
			{
				raceCode = RaceConstants.SKINNED_SWF;
			}
		}
		
		private function deSerializeAction() : void
		{
			var _loc1_:XML = null;
			if(!this.xml)
			{
				return;
			}
			this.clearActionData();
			var _loc2_:XMLList = this.xml..action as XMLList;
			var _loc3_:XMLList = this.xml..motion as XMLList;
			for each(_loc1_ in _loc2_)
			{
				this.createActionByXML(_loc1_);
			}
			for each(_loc1_ in _loc3_)
			{
				this.createActionByXML(_loc1_);
			}
		}
		
		override public function isThumbReady(param1:String = "") : Boolean
		{
			var _loc2_:int = 0;
			var _loc3_:anifire.browser.core.Action = null;
			var _loc4_:anifire.browser.core.Motion = null;
			if(this.getIsZipLoaded())
			{
				return true;
			}
			if(theme.id == "ugc")
			{
				if(this.isSWFCharacter())
				{
					_loc2_ = 0;
					while(_loc2_ < this._actions.length)
					{
						_loc3_ = this._actions[_loc2_] as anifire.browser.core.Action;
						if(!_loc3_.imageData)
						{
							return false;
						}
						_loc2_++;
					}
					_loc2_ = 0;
					while(_loc2_ < this.motions.length)
					{
						if(!(_loc4_ = this.motions[_loc2_] as anifire.browser.core.Motion).imageData)
						{
							return false;
						}
						_loc2_++;
					}
				}
				else if(!this.ccBodyModel.completed)
				{
					return false;
				}
			}
			if(param1 == "" && Boolean(this.defaultAction))
			{
				param1 = this.defaultAction.id;
			}
			return Boolean(param1) && this.getActionById(param1).imageData != null;
		}
		
		private function onLoadCCBodyFinish(param1:Event) : void
		{
			this.loadAction();
		}
		
		public function loadAction(param1:Behavior = null, param2:Boolean = false) : void
		{
			if(this.ccThemeModel.completed && !this.ccBodyModel.completed)
			{
				this.ccBodyModel.addEventListener(Event.COMPLETE,this.onLoadCCBodyFinish);
				this.ccBodyModel.load();
				return;
			}
			if(param1 == null)
			{
				param1 = this.defaultAction as Behavior;
			}
			param1.addEventListener(CoreEvent.LOAD_STATE_COMPLETE,this.onLoadBehaviorComplete);
			if(param1.imageData == null || param1.withSpeech != param2)
			{
				if(param1 is anifire.browser.core.Action)
				{
					if(this.ccThemeModel.completed)
					{
						param1.loadImageDataByCam(this.ccThemeModel.getCharacterActionModel(this.ccBodyModel,param1.id));
					}
					else
					{
						param1.loadImageData(ServerConstants.PARAM_CHAR_ACTION,param2,this.path);
					}
				}
				else if(param1 is anifire.browser.core.Facial)
				{
					param1.loadImageData(ServerConstants.PARAM_CHAR_FACIAL,param2,this.path);
				}
			}
		}
		
		private function onLoadBehaviorComplete(param1:Event) : void
		{
			IEventDispatcher(param1.target).removeEventListener(param1.type,this.onLoadBehaviorComplete);
			this.dispatchEvent(param1);
		}
		
		public function loadDefaultActionByBodyModel() : void
		{
			if(!this.ccBodyModel.completed)
			{
				this.ccBodyModel.addEventListener(Event.COMPLETE,this.onCCBodyModelComplete);
				this.ccBodyModel.load();
			}
			else
			{
				dispatchEvent(new StudioEvent(StudioEvent.BODY_MODEL_COMPLETE));
			}
		}
		
		private function onCCBodyModelComplete(param1:Event) : void
		{
			this.ccBodyModel.removeEventListener(Event.COMPLETE,this.onCCBodyModelComplete);
			dispatchEvent(new StudioEvent(StudioEvent.BODY_MODEL_COMPLETE));
		}
		
		override public function mergeThumbByXML(param1:XML) : void
		{
			var _loc2_:CharThumb = new CharThumb();
			_loc2_.deSerialize(param1,this.theme);
			this.mergeThumb(_loc2_ as IThumb);
		}
		
		override public function mergeThumb(param1:IThumb) : void
		{
			if(param1.theme.id == this.theme.id && param1.id == this.id)
			{
				var _loc2_:int;
				var _loc3_:int;
				var _loc4_:Behavior;
				var _loc5_:Behavior;
				this.xml = param1.xml;
				_loc3_ = 0;
				while(_loc3_ < CharThumb(param1).getActionNum())
				{
					_loc5_ = CharThumb(param1).getActionAt(_loc3_);
					if(Boolean(_loc4_ = this.getActionById(_loc5_.id)) && !_loc4_.imageData)
					{
						_loc4_.imageData = _loc5_.imageData;
					}
					_loc3_++;
				}
				_loc2_ = 0;
				while(_loc2_ < this.motions.length)
				{
					_loc4_ = this.motions[_loc2_] as Behavior;
					if(_loc4_.imageData == null)
					{
						_loc3_ = 0;
						while(_loc3_ < CharThumb(param1).motions.length)
						{
							_loc5_ = this.motions[_loc3_] as Behavior;
							if(_loc4_.id == _loc5_.id)
							{
								_loc4_.imageData = _loc5_.imageData;
								break;
							}
							_loc3_++;
						}
					}
					_loc2_++;
				}
				_loc3_ = 0;
				while(_loc3_ < CharThumb(param1).motions.length)
				{
					_loc5_ = CharThumb(param1).motions[_loc3_] as Behavior;
					if(!this.getMotionById(_loc5_.id))
					{
						_loc5_.thumb = this;
						this.addMotion(_loc5_ as anifire.browser.core.Motion);
					}
					_loc3_++;
				}
				_loc2_ = 0;
				while(_loc2_ < this._facials.length)
				{
					_loc4_ = this._facials[_loc2_];
					if(_loc4_.imageData == null)
					{
						_loc3_ = 0;
						while(_loc3_ < CharThumb(param1).facials.length)
						{
							_loc5_ = CharThumb(param1).facials[_loc3_] as Behavior;
							if(_loc4_.id == _loc5_.id)
							{
								_loc4_.imageData = _loc5_.imageData;
								break;
							}
							_loc3_++;
						}
					}
					_loc2_++;
				}
				_loc3_ = 0;
				while(_loc3_ < CharThumb(param1).facials.length)
				{
					_loc5_ = CharThumb(param1).facials[_loc3_] as Behavior;
					if(!this.getFacialById(_loc5_.id))
					{
						_loc5_.thumb = this;
						this.addFacial(_loc5_ as anifire.browser.core.Facial);
					}
					_loc3_++;
				}
				this.xml = param1.xml;
			}
		}
		
		public function loadActionsAndMotions() : void
		{
			var _loc1_:URLRequest = null;
			var _loc2_:UtilURLStream = null;
			if(!this._isLoadingActionMotion)
			{
				this._isLoadingActionMotion = true;
				_loc1_ = UtilNetwork.getGetThemeAssetRequest(this.theme.id,this.id,ServerConstants.PARAM_CHAR);
				_loc2_ = new UtilURLStream();
				_loc2_.addEventListener(Event.COMPLETE,this.doLoadActionsAndMotionsCompleted);
				_loc2_.addEventListener(UtilURLStream.TIME_OUT,this.doLoadActionsAndMotionsTimeOut);
				_loc2_.addEventListener(IOErrorEvent.IO_ERROR,this.doLoadActionsAndMotionsIOError);
				_loc2_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.doLoadActionsAndMotionsSecurityError);
				_loc2_.load(_loc1_);
			}
		}
		
		public function initImageData(param1:ZipFile, param2:String) : void
		{
			var _loc3_:int;
			var _loc4_:int;
			var _loc5_:String;
			var _loc6_:ZipEntry;
			var _loc7_:UtilCrypto;
			var _loc8_:ByteArray;
			var _loc9_:ZipFile;
			var _loc10_:ZipEntry;
			var _loc11_:ByteArray;
			var _loc12_:UtilHashArray;
			var _loc13_:Action;
			var _loc14_:Object;
			var _loc15_:Boolean = this.theme.id != "ugc" ? true : false;
			this.deSerializeAction();
			var _loc16_:Number = this.getActionNum();
			var _loc17_:Number = this.getMotionNum();
			this._numCcAction = 0;
			this._numTotalCcAction = 0;
			_loc3_ = 0;
			while(_loc3_ < _loc16_)
			{
				_loc13_ = this.getActionAt(_loc3_);
				_loc5_ = param2 + _loc13_.id;
				if((Boolean(_loc6_ = param1.getEntry(_loc5_))) && isCC)
				{
					++this._numTotalCcAction;
				}
				_loc3_++;
			}
			_loc3_ = 0;
			while(_loc3_ < _loc16_)
			{
				_loc13_ = this.getActionAt(_loc3_);
				_loc5_ = param2 + _loc13_.id;
				_loc6_ = param1.getEntry(_loc5_);
				if(_loc6_)
				{
					if(!isCC)
					{
						this.imageData = this.thumbImageData = _loc13_.imageData = param1.getInput(_loc6_);
						if(_loc15_)
						{
							(_loc7_ = new UtilCrypto()).decrypt(_loc13_.imageData as ByteArray);
						}
					}
					else if(_loc13_.id.indexOf(".zip") >= 0)
					{
						_loc8_ = param1.getInput(_loc6_);
						_loc9_ = new ZipFile(_loc8_);
						_loc13_.imageData = UtilPlain.convertZipAsImagedataObject(_loc9_);
					}
					else
					{
						var _loc20_:XML = XML(param1.getInput(_loc6_));
						++this._numCcAction;
						_loc13_.addEventListener(CoreEvent.LOAD_STATE_COMPLETE,this.onCcActionReady);
						_loc13_.loadImageDataByXml(_loc20_);
					}
				}
				_loc3_++;
			}
			_loc3_ = 0;
			while(_loc3_ < _loc17_)
			{
				var _loc21_:Motion = this.getMotionAt(_loc3_);
				_loc5_ = param2 + _loc21_.id;
				_loc6_ = param1.getEntry(_loc5_);
				if(_loc6_)
				{
					_loc21_.imageData = param1.getInput(_loc6_);
					if(_loc15_)
					{
						(_loc7_ = new UtilCrypto()).decrypt(_loc21_.imageData as ByteArray);
					}
				}
				_loc3_++;
			}
			var _loc18_:ZipEntry = param1.getEntry(param2 + CcLibConstant.NODE_LIBRARY + ".zip");
			if(_loc18_ != null)
			{
				var _loc22_:ByteArray = param1.getInput(_loc18_) as ByteArray;
				var _loc23_:ZipEntry;
				var _loc24_:ZipFile = new ZipFile(_loc22_);
				var _loc25_:int = 0;
				while(_loc25_ < _loc24_.size)
				{
					_loc23_ = _loc24_.entries[_loc25_];
					this.addLibrary(_loc23_.name,_loc24_.getInput(_loc23_));
					_loc25_++;
				}
			}
			var _loc19_:PropThumb = theme.getPropThumbById(id + ".head") as PropThumb;
			if(_loc19_ != null)
			{
				var _loc26_:Number = _loc19_.states.length;
				_loc3_ = 0;
				while(_loc3_ < _loc26_)
				{
					var _loc27_:State = _loc19_.getStateAt(_loc3_);
					_loc5_ = param2 + "head/" + _loc27_.id;
					_loc6_ = param1.getEntry(_loc5_);
					if(!isCC)
					{
						if(_loc6_ != null)
						{
							_loc27_.imageData = param1.getInput(param1.getEntry(_loc5_));
							if(_loc15_)
							{
								(_loc7_ = new UtilCrypto()).decrypt(_loc27_.imageData as ByteArray);
							}
						}
					}
					else if(_loc6_ != null)
					{
						_loc8_ = param1.getInput(_loc6_);
						_loc9_ = new ZipFile(_loc8_);
						_loc27_.imageData = UtilPlain.convertZipAsImagedataObject(_loc9_);
					}
					_loc3_++;
				}
			}
			if(!isCC || this._numCcAction == 0)
			{
				this.dispatchEvent(new CoreEvent(CoreEvent.LOAD_THUMB_COMPLETE,this));
			}
		}
		
		public function onCcActionReady(param1:Event) : void
		{
			if(this._numTotalCcAction == this._numCcAction)
			{
				this.dispatchEvent(new CoreEvent(CoreEvent.LOAD_THUMB_COMPLETE,this));
			}
		}
		
		public function BitmapDataToByteArray(param1:DisplayObject) : ByteArray
		{
			var _loc2_:uint = param1.width;
			var _loc3_:uint = param1.height;
			var _loc4_:BitmapData = new BitmapData(_loc2_,_loc3_);
			_loc4_.draw(param1);
			var _loc5_:ByteArray = _loc4_.getPixels(new Rectangle(0,0,_loc2_,_loc3_));
			_loc5_.writeShort(_loc3_);
			_loc5_.writeShort(_loc2_);
			return _loc5_;
		}
		
		private function doLoadActionsAndMotionsIOError(param1:IOErrorEvent) : void
		{
			(param1.target as IEventDispatcher).removeEventListener(param1.type,this.doLoadActionsAndMotionsIOError);
			this._isLoadingActionMotion = false;
			Alert.show("Error in loading character action",param1.type);
		}
		
		private function doLoadActionsAndMotionsSecurityError(param1:SecurityErrorEvent) : void
		{
			(param1.target as IEventDispatcher).removeEventListener(param1.type,this.doLoadActionsAndMotionsSecurityError);
			this._isLoadingActionMotion = false;
			Alert.show("Error in loading character action",param1.type);
		}
		
		private function doLoadActionsAndMotionsTimeOut(param1:Event) : void
		{
			(param1.target as IEventDispatcher).removeEventListener(param1.type,this.doLoadActionsAndMotionsTimeOut);
			this._isLoadingActionMotion = false;
			Alert.show("Operation Timeout");
		}
		
		public function getFolderPathInCharZip() : String
		{
			if(this.path)
			{
				return "char/" + this.path + "/";
			}
			return "char/" + this.id + "/";
		}
		
		private function doLoadActionCompleted(param1:Event) : void
		{
		}
		
		private function doLoadActionsAndMotionsCompleted(param1:Event) : void
		{
			(param1.target as IEventDispatcher).removeEventListener(param1.type,this.doLoadActionsAndMotionsCompleted);
			var _loc2_:URLStream = URLStream(param1.target);
			var _loc3_:ByteArray = new ByteArray();
			_loc2_.readBytes(_loc3_,0,_loc2_.bytesAvailable);
			var _loc4_:ZipFile = new ZipFile(_loc3_);
			this.initImageData(_loc4_,this.getFolderPathInCharZip());
			this._isLoadingActionMotion = false;
			this.setIsZipLoaded(true);
			this.dispatchEvent(new CoreEvent(CoreEvent.LOAD_THUMB_COMPLETE,this));
		}
		
		override public function loadImageData() : void
		{
			var _loc1_:URLRequest;
			var _loc2_:UtilURLStream = new UtilURLStream();
			if(this.isCC)
			{
				var _loc3_:CCBodyModel = CCBodyManager.instance.getBodyModel(this.id);
				var _loc4_:String = CCThemeManager.instance.getThemeModel(this.ccThemeId).getCharacterDefaultActionId(_loc3_.bodyShapeId);
				var _loc5_:CCCharacterActionModel = CCThemeManager.instance.getThemeModel(this.ccThemeId).getCharacterActionModel(_loc3_,_loc4_);
				if(_loc5_)
				{
					var _loc6_:CcActionLoader = new CcActionLoader();
					_loc6_.addEventListener(Event.COMPLETE,this.onCcActionLoaded);
					_loc6_.addEventListener(IOErrorEvent.IO_ERROR,this.onCcActionFailed);
					_loc6_.loadCcComponentsByCam(_loc5_);
					return;
				}
				_loc1_ = UtilNetwork.getGetCcActionRequest(this.id,this.defaultAction.id);
			}
			else if(this.path)
			{
				_loc1_ = UtilNetwork.getGetThemeAssetRequest(this.theme.id,this.path,ServerConstants.PARAM_CHAR_ACTION,this.defaultAction.id);
			}
			else
			{
				_loc1_ = UtilNetwork.getGetThemeAssetRequest(this.theme.id,this.id,ServerConstants.PARAM_CHAR_ACTION,this.defaultAction.id);
			}
			_loc2_.addEventListener(Event.COMPLETE,this.loadImageDataComplete);
			_loc2_.addEventListener(UtilURLStream.TIME_OUT,this.onLoadImageDataFail);
			_loc2_.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadImageDataFail);
			_loc2_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadImageDataFail);
			_loc2_.load(_loc1_);
		}
		
		private function onLoadImageDataFail(param1:Event) : void
		{
		}
		
		private function onCcActionLoaded(param1:Event) : void
		{
			var _loc2_:CcActionLoader = CcActionLoader(param1.target);
			if(_loc2_.imageData)
			{
				if(!this.imageData)
				{
					this.imageData = new Object();
				}
				if(_loc2_.imageData["xml"])
				{
					this.imageData["xml"] = _loc2_.imageData["xml"];
				}
				if(_loc2_.imageData["cam"])
				{
					this.imageData["cam"] = _loc2_.imageData["cam"];
				}
				this.imageData["imageData"] = _loc2_.imageData["imageData"];
				this.dispatchEvent(new CoreEvent(CoreEvent.LOAD_THUMB_COMPLETE,this));
			}
		}
		
		override public function loadImageDataComplete(param1:Event) : void
		{
			(param1.target as IEventDispatcher).removeEventListener(param1.type,this.loadImageDataComplete);
			var _loc2_:UtilCrypto;
			var _loc3_:URLStream = URLStream(param1.target);
			var _loc4_:ByteArray = new ByteArray();
			_loc3_.readBytes(_loc4_,0,_loc3_.bytesAvailable);
			var _loc5_:CcActionLoader;
			if(this.isCC)
			{
				if(this.id.indexOf("zip") < 0)
				{
					_loc5_ = new CcActionLoader();
					_loc5_.addEventListener(Event.COMPLETE,this.onCcActionLoaded);
					_loc5_.addEventListener(IOErrorEvent.IO_ERROR,this.onCcActionFailed);
					_loc5_.loadCcComponents(XML(_loc4_),0,0,null,this._ccThemeId == "cc2" ? 2 : 1);
					return;
				}
				var _loc6_:ZipFile = new ZipFile(_loc4_);
				this.imageData = UtilPlain.convertZipAsImagedataObject(_loc6_);
			}
			else
			{
				this.imageData = new Object();
				this.imageData["figure"] = _loc4_;
				if(this.theme.id != "ugc" && !this.isCC)
				{
					_loc2_ = new UtilCrypto();
					_loc2_.decrypt(ByteArray(this.imageData["figure"]));
				}
				if(raceCode == RaceConstants.SKINNED_SWF)
				{
					_loc5_ = new CcActionLoader();
					_loc5_.addEventListener(Event.COMPLETE,this.onCcActionLoaded);
					_loc5_.addEventListener(IOErrorEvent.IO_ERROR,this.onCcActionFailed);
					_loc5_.loadCcComponents(this.xml,0,0,null,raceCode + 1,false,"default");
					return;
				}
			}
			if(this.propXML.length > 0 && Boolean(this.theme))
			{
				this._propThumb = this.theme.getPropThumbById(this.propXML[0].@id) as anifire.browser.core.PropThumb;
				if(Boolean(this._propThumb) && !this._propThumb.imageData)
				{
					this._propThumb.addEventListener(CoreEvent.LOAD_THUMB_COMPLETE,this.onPropImageDataLoaded);
					this._propThumb.loadImageData();
					return;
				}
			}
			this.dispatchEvent(new CoreEvent(CoreEvent.LOAD_THUMB_COMPLETE,this));
		}
		
		private function onPropImageDataLoaded(param1:Event) : void
		{
			this.dispatchEvent(new CoreEvent(CoreEvent.LOAD_THUMB_COMPLETE,this));
		}
		
		private function onCcActionFailed(param1:IOErrorEvent) : void
		{
			this.dispatchEvent(new CoreEvent(CoreEvent.LOAD_THUMB_COMPLETE,this));
		}
		
		public function get propImageData() : Object
		{
			if(this._propThumb)
			{
				return this._propThumb.imageData;
			}
			return null;
		}
		
		public function createCCHeadPropThumb() : anifire.browser.core.PropThumb
		{
			var _loc1_:anifire.browser.core.PropThumb = new anifire.browser.core.PropThumb();
			_loc1_.initAsCCHeadProp(this,this.ccThemeModel);
			return _loc1_;
		}
		
		public function getHeadPropThumb() : anifire.browser.core.PropThumb
		{
			var _loc1_:* = this.id + ".head";
			var _loc2_:Theme = theme as Theme;
			var _loc3_:anifire.browser.core.PropThumb = _loc2_.getPropThumbById(_loc1_) as anifire.browser.core.PropThumb;
			if(!_loc3_)
			{
				_loc3_ = (this as CharThumb).createCCHeadPropThumb();
				_loc2_.addThumb(_loc3_);
			}
			return _loc3_;
		}
	}
}
