package anifire.browser.core
{
	import anifire.browser.events.CoreEvent;
	import anifire.browser.interfaces.ITheme;
	import anifire.browser.interfaces.IThumb;
	import anifire.browser.managers.ImageDataManager;
	import anifire.constant.AnimeConstants;
	import anifire.constant.ServerConstants;
	import anifire.models.creator.CCFaceModel;
	import anifire.models.creator.CCThemeModel;
	import anifire.util.UtilCrypto;
	import anifire.util.UtilDict;
	import anifire.util.UtilHashArray;
	import anifire.util.UtilNetwork;
	import anifire.util.UtilPlain;
	import anifire.util.UtilURLStream;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipFile;
	
	public class PropThumb extends Thumb
	{
		
		public static const XML_NODE_NAME:String = "prop";
		
		
		private var _holdable:Boolean = false;
		
		private var _placeable:Boolean = false;
		
		private var _headable:Boolean = false;
		
		private var _wearable:Boolean = false;
		
		private var _subType:String = "";
		
		private var _handStyle:String = "";
		
		private var _facing:String;
		
		private var _states:Array;
		
		private var _isLoadingState:Boolean = false;
		
		private var _isZipLoaded:Boolean = false;
		
		private var _defaultState:anifire.browser.core.State;
		
		private var _defaultTalkState:anifire.browser.core.State;
		
		private var _assetUrl:String;
		
		private var _processed:Boolean;
		
		private var _ccThemeId:String;
		
		public function PropThumb()
		{
			super();
			this._states = [];
		}
		
		public function get ccThemeId() : String
		{
			return this._ccThemeId;
		}
		
		public function set ccThemeId(param1:String) : void
		{
			this._ccThemeId = param1;
		}
		
		public function get processed() : Boolean
		{
			return this._processed;
		}
		
		override public function set handStyle(param1:String) : void
		{
			this._handStyle = param1;
		}
		
		override public function get handStyle() : String
		{
			return this._handStyle;
		}
		
		public function get subType() : String
		{
			return this._subType;
		}
		
		public function set subType(param1:String) : void
		{
			this._subType = param1;
		}
		
		public function getIsZipLoaded() : Boolean
		{
			return this._isZipLoaded;
		}
		
		private function setIsZipLoaded(param1:Boolean) : void
		{
			this._isZipLoaded = param1;
		}
		
		public function addState(param1:anifire.browser.core.State) : void
		{
			this._states.push(param1);
		}
		
		public function get states() : Array
		{
			return this._states;
		}
		
		public function set states(param1:Array) : void
		{
			this._states = param1;
		}
		
		public function getStateById(param1:String) : anifire.browser.core.State
		{
			var _loc2_:anifire.browser.core.State = null;
			var _loc3_:int = 0;
			while(_loc3_ < this._states.length)
			{
				if(State(this._states[_loc3_]).id == param1)
				{
					_loc2_ = State(this._states[_loc3_]);
					break;
				}
				_loc3_++;
			}
			return _loc2_;
		}
		
		public function getStateAt(param1:int) : anifire.browser.core.State
		{
			return this.states[param1] as anifire.browser.core.State;
		}
		
		public function getStateNum() : int
		{
			return this.states.length;
		}
		
		public function get holdable() : Boolean
		{
			return this._holdable;
		}
		
		public function set holdable(param1:Boolean) : void
		{
			this._holdable = param1;
		}
		
		public function get placeable() : Boolean
		{
			return this._placeable;
		}
		
		public function set placeable(param1:Boolean) : void
		{
			this._placeable = param1;
		}
		
		public function get headable() : Boolean
		{
			return this._headable;
		}
		
		public function set headable(param1:Boolean) : void
		{
			this._headable = param1;
		}
		
		public function get wearable() : Boolean
		{
			return this._wearable;
		}
		
		public function set wearable(param1:Boolean) : void
		{
			this._wearable = param1;
		}
		
		public function get facing() : String
		{
			return this._facing;
		}
		
		public function set facing(param1:String) : void
		{
			this._facing = param1;
		}
		
		public function get defaultState() : anifire.browser.core.State
		{
			if(this._defaultState == null)
			{
				if(this.states[0] != null)
				{
					this._defaultState = this.states[0] as anifire.browser.core.State;
				}
			}
			return this._defaultState;
		}
		
		public function get defaultStateId() : String
		{
			if(this.defaultState)
			{
				return this.defaultState.id;
			}
			return "";
		}
		
		public function set defaultState(param1:anifire.browser.core.State) : void
		{
			this._defaultState = param1;
		}
		
		public function get defaultTalkState() : anifire.browser.core.State
		{
			var _loc1_:int = 0;
			if(this._defaultTalkState == null)
			{
				_loc1_ = 0;
				while(_loc1_ < this.states.length)
				{
					if(State(this.states[_loc1_]).isTalkRelated())
					{
						this._defaultTalkState = this.states[_loc1_] as anifire.browser.core.State;
						break;
					}
					_loc1_++;
				}
			}
			return this._defaultTalkState;
		}
		
		public function set defaultTalkState(param1:anifire.browser.core.State) : void
		{
			this._defaultTalkState = param1;
		}
		
		override public function deSerialize(param1:XML, param2:ITheme, param3:Boolean = false) : void
		{
			if(param1.state.length() <= 0)
			{
				this.setFileName("prop/" + param1.@id);
			}
			else
			{
				this.setFileName("prop/" + param1.@id + "/" + param1.@thumb);
				this.thumbId = param1.@thumb;
			}
			this.id = param1.@id;
			this.aid = param1.@aid;
			this.name = UtilDict.toDisplay("store",param1.@name);
			this.placeable = param1.@placeable == "1" ? true : false;
			this.holdable = param1.@holdable == "1" ? true : false;
			this.headable = param1.@headable == "1" ? true : false;
			this.wearable = param1.@wearable == "1" ? true : false;
			this.enable = param1.@enable == "N" ? false : true;
			this.theme = param2;
			if(param1.@facing == AnimeConstants.FACING_LEFT || param1.@facing == AnimeConstants.FACING_RIGHT)
			{
				this.facing = param1.@facing;
			}
			else
			{
				this.facing = AnimeConstants.FACING_UNKNOW;
			}
			if(this.theme.id == "ugc")
			{
				this.tags = param1.tags;
				this.isPublished = param1.@published == "1" ? true : false;
			}
			var _loc4_:XML;
			var _loc5_:int;
			var _loc6_:XML;
			_loc5_ = 0;
			while(_loc5_ < param1.colorset.length())
			{
				_loc4_ = param1.colorset[_loc5_];
				this.addColorSet(_loc4_);
				_loc5_++;
			}
			_loc5_ = 0;
			while(_loc5_ < param1.c_parts.c_area.length())
			{
				_loc6_ = param1.c_parts.c_area[_loc5_];
				if(param1.c_parts.@enable != "N")
				{
					colorParts.push(_loc6_,_loc6_.attribute("oc").length() == 0 ? uint.MAX_VALUE : _loc6_.@oc);
				}
				_loc5_++;
			}
			var _loc7_:String;
			var _loc8_:XML;
			var _loc9_:State;
			var _loc10_:Number = param1.state.length();
			this._states = new Array();
			_loc5_ = 0;
			while(_loc5_ < _loc10_)
			{
				_loc8_ = param1.state[_loc5_];
				_loc9_ = new anifire.browser.core.State(this,_loc8_.@id,_loc8_.@name,1,_loc8_.@enable,_loc8_.@aid);
				_loc7_ = "prop/" + this.id + "/" + param1.@id;
				this.addState(_loc9_);
				if(_loc8_.@default == "Y")
				{
					this.defaultState = _loc9_;
				}
				_loc5_++;
			}
			var _loc11_:String;
			var _loc12_:XMLList = param1.tag;
			_loc5_ = 0;
			while(_loc5_ < _loc12_.length())
			{
				_loc11_ = _loc12_[_loc5_];
				sysTags.push(_loc11_);
				_loc5_++;
			}
			sysTags.push(this.name);
			sysTags.push(this.fileName);
			this.subType = param1.@subtype != null ? param1.@subtype : "";
			this.handStyle = param1.@handstyle != null ? param1.@handstyle : "";
			this._assetUrl = param1.@asset_url;
		}
		
		override public function mergeThumbWithFacialByXML(param1:XML) : void
		{
			var _loc2_:PropThumb = new PropThumb();
			_loc2_.deSerializeFacial(param1,this.theme);
			this.mergeThumb(_loc2_ as IThumb);
		}
		
		override public function deSerializeFacial(param1:XML, param2:ITheme, param3:int = -1, param4:int = 1) : void
		{
			if(param1.@cc_theme_id.length() > 0)
			{
				this.ccThemeId = param1.@cc_theme_id;
			}
			var _loc5_:XML = param1.facial[0];
			if(_loc5_)
			{
				thumbId = _loc5_.@id;
				setFileName("char/" + param1.@id + "/head/" + thumbId);
			}
			id = param1.@id + ".head";
			aid = param1.@aid;
			name = param1.@name + "\'s head";
			this.placeable = false;
			this.holdable = false;
			this.headable = true;
			this.wearable = false;
			switch(param4)
			{
				case 1:
					enable = _loc5_.@enable == "N" ? false : true;
					break;
				case 2:
					enable = true;
					break;
				default:
					enable = false;
			}
			xml = param1;
			if(param1.@isCC == "Y")
			{
				raceCode = 1;
				enable = false;
			}
			else
			{
				raceCode = 0;
			}
			if(param3 > -1)
			{
				raceCode = param3;
			}
			if(param1.@path.length() > 0)
			{
				this.path = String(param1.@path) + ".head";
			}
			theme = param2;
			this.facing = AnimeConstants.FACING_UNKNOW;
			var _loc6_:String;
			var _loc7_:XML;
			var _loc8_:State;
			var _loc9_:XMLList = param1..facial as XMLList;
			this.states = [];
			var _loc10_:Number = -1;
			var _loc11_:int = 0;
			while(_loc11_ < _loc9_.length())
			{
				var _loc12_:Number = 0;
				_loc5_ = _loc9_[_loc11_];
				_loc8_ = new anifire.browser.core.State(this,_loc5_.@id,_loc5_.@name,1,_loc5_.@enable,_loc5_.@aid);
				this.addState(_loc8_);
				if(_loc8_.id.indexOf("neutral") > -1)
				{
					_loc12_++;
				}
				if(_loc8_.id.indexOf("front") > -1)
				{
					_loc12_++;
				}
				if(_loc8_.id.indexOf("happy") > -1)
				{
					_loc12_++;
				}
				if(_loc12_ > _loc10_)
				{
					_loc10_ = _loc12_;
					this.defaultState = _loc8_;
					if(this.defaultState)
					{
						setFileName("char/" + _loc5_.@id + "/head/" + _loc5_.@id);
						thumbId = _loc5_.@id;
					}
				}
				if(this.defaultTalkState == null && _loc8_.id.indexOf("talk") > -1 && _loc8_.id.indexOf("phone") == -1)
				{
					this.defaultTalkState = _loc8_;
				}
				_loc11_++;
			}
		}
		
		public function initAsCCHeadProp(param1:CharThumb, param2:CCThemeModel) : void
		{
			var _loc3_:CCFaceModel = null;
			var _loc4_:String = null;
			var _loc5_:anifire.browser.core.State = null;
			id = param1.id + ".head";
			this.ccThemeId = param1.ccThemeId;
			this.placeable = false;
			this.holdable = false;
			this.headable = true;
			this.wearable = false;
			raceCode = param1.raceCode;
			path = param1.path + ".head";
			theme = param1.theme;
			this.facing = AnimeConstants.FACING_UNKNOW;
			this.states = [];
			for(_loc4_ in param2.faces)
			{
				_loc3_ = param2.faces[_loc4_];
				_loc5_ = new anifire.browser.core.State(this,_loc3_.fullId,_loc3_.name,1,"Y","");
				this.addState(_loc5_);
			}
			if(_loc3_)
			{
				setFileName("char/" + param1.id + "/head/" + _loc3_.fullId);
			}
		}
		
		public function addColorSet(param1:XML) : Number
		{
			colorRef.push(param1.@aid,param1);
			return colorRef.length - 1;
		}
		
		override public function isThumbReady(param1:String = "") : Boolean
		{
			var _loc2_:XML = null;
			if(this.getIsZipLoaded() || !this.states.length > 0 && this.imageData != null)
			{
				return true;
			}
			if(this.theme)
			{
				_loc2_ = Theme(this.theme).getThumbNodeFromThemeXML(this.theme.getThemeXML(),this);
			}
			if(_loc2_ == null && this.id && this.id.indexOf(".head") == -1)
			{
				return false;
			}
			if(this.states.length > 0)
			{
				if(this.defaultState.imageData == null)
				{
					return false;
				}
				if(_loc2_ != null)
				{
					if(_loc2_.state.length() != this.states.length)
					{
						return false;
					}
				}
			}
			else if(this.imageData == null)
			{
				return false;
			}
			return true;
		}
		
		override public function mergeThumb(param1:IThumb) : void
		{
			var _loc2_:anifire.browser.core.State = null;
			var _loc3_:anifire.browser.core.State = null;
			var _loc4_:int = 0;
			var _loc5_:int = 0;
			var _loc6_:int = 0;
			if(param1.theme.id == this.theme.id && param1.id == this.id)
			{
				if(this.imageData == null)
				{
					this.imageData = param1.imageData;
				}
				_loc4_ = 0;
				while(_loc4_ < this.states.length)
				{
					_loc2_ = this.states[_loc4_] as anifire.browser.core.State;
					if(_loc2_.imageData == null)
					{
						_loc6_ = 0;
						while(_loc6_ < PropThumb(param1).states.length)
						{
							_loc3_ = PropThumb(param1).states[_loc6_] as anifire.browser.core.State;
							if(_loc2_.id == _loc3_.id)
							{
								_loc2_.imageData = _loc3_.imageData;
								break;
							}
							_loc6_++;
						}
					}
					_loc4_++;
				}
				_loc5_ = 0;
				while(_loc5_ < PropThumb(param1).states.length)
				{
					_loc3_ = PropThumb(param1).states[_loc5_] as anifire.browser.core.State;
					if(!this.getStateById(_loc3_.id))
					{
						_loc3_.thumb = this;
						this.addState(_loc3_ as anifire.browser.core.State);
					}
					_loc5_++;
				}
			}
		}
		
		public function isStateReady(param1:Behavior) : Boolean
		{
			return param1.imageData != null;
		}
		
		public function loadState(param1:Behavior = null) : void
		{
			if(param1 == null)
			{
				param1 = this.defaultState;
			}
			param1.addEventListener(CoreEvent.LOAD_STATE_COMPLETE,this.onLoadStateComplete);
			if(param1.imageData == null)
			{
				if(this.getFileName().indexOf("char/") == -1)
				{
					param1.loadImageData(ServerConstants.PARAM_PROP_STATE);
				}
				else
				{
					param1.loadImageData(ServerConstants.PARAM_CHAR_FACIAL,false,this.path);
				}
			}
		}
		
		private function onLoadStateComplete(param1:Event) : void
		{
			IEventDispatcher(param1.target).removeEventListener(param1.type,this.onLoadStateComplete);
			this.dispatchEvent(param1);
		}
		
		public function loadStates() : void
		{
			var _loc1_:URLRequest = null;
			var _loc2_:UtilURLStream = null;
			if(!this._isLoadingState)
			{
				this._isLoadingState = true;
				_loc1_ = UtilNetwork.getGetThemeAssetRequest(this.theme.id,this.id,ServerConstants.PARAM_PROP_EX);
				_loc2_ = new UtilURLStream();
				_loc2_.addEventListener(Event.COMPLETE,this.doLoadStatesCompleted);
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
			var _loc13_:Object;
			var _loc14_:Boolean = this.theme.id != "ugc" ? true : false;
			_loc3_ = 0;
			while(_loc3_ < this.getStateNum())
			{
				var _loc15_:State = this.getStateAt(_loc3_);
				_loc5_ = param2 + _loc15_.id;
				_loc6_ = param1.getEntry(_loc5_);
				if(_loc6_ != null)
				{
					if(!isCC)
					{
						_loc15_.imageData = param1.getInput(param1.getEntry(_loc5_));
						if(_loc14_)
						{
							(_loc7_ = new UtilCrypto()).decrypt(_loc15_.imageData as ByteArray);
						}
					}
					else if(_loc15_.id.indexOf("zip") >= 0)
					{
						_loc8_ = param1.getInput(_loc6_);
						_loc9_ = new ZipFile(_loc8_);
						_loc15_.imageData = UtilPlain.convertZipAsImagedataObject(_loc9_);
					}
					else
					{
						var _loc16_:XML = XML(param1.getInput(_loc6_));
						_loc15_.loadImageDataByXml(_loc16_,1,true);
					}
				}
				_loc3_++;
			}
		}
		
		public function getFolderPathInPropZip() : String
		{
			return "prop/" + this.id + "/";
		}
		
		private function doLoadStatesCompleted(param1:Event) : void
		{
			(param1.target as IEventDispatcher).removeEventListener(param1.type,this.doLoadStatesCompleted);
			var _loc2_:URLStream = URLStream(param1.target);
			var _loc3_:ByteArray = new ByteArray();
			_loc2_.readBytes(_loc3_,0,_loc2_.bytesAvailable);
			var _loc4_:ZipFile = new ZipFile(_loc3_);
			this.initImageData(_loc4_,this.getFolderPathInPropZip());
			this._isLoadingState = false;
			this.setIsZipLoaded(true);
			this.dispatchEvent(new CoreEvent(CoreEvent.LOAD_THUMB_COMPLETE,this));
		}
		
		override public function loadImageData() : void
		{
			var _loc1_:Object = ImageDataManager.instance.getImageData("prop",themeId,id);
			if(_loc1_)
			{
				imageData = _loc1_;
				dispatchEvent(new CoreEvent(CoreEvent.LOAD_THUMB_COMPLETE,this));
			}
			else
			{
				var _loc2_:URLRequest;
				if(Boolean(this._assetUrl) && this._assetUrl != "")
				{
					_loc2_ = new URLRequest(this._assetUrl);
				}
				else if(this.thumbId)
				{
					if(this.getFileName().indexOf("char/") == -1)
					{
						_loc2_ = UtilNetwork.getGetThemeAssetRequest(this.theme.id,this.id,ServerConstants.PARAM_PROP_STATE,this.thumbId,-1,path);
					}
					else
					{
						_loc2_ = UtilNetwork.getGetThemeAssetRequest(this.theme.id,this.id,ServerConstants.PARAM_CHAR_FACIAL,this.thumbId,-1,path);
					}
				}
				else
				{
					_loc2_ = UtilNetwork.getGetThemeAssetRequest(this.themeId,this.id,ServerConstants.PARAM_PROP);
				}
				var _loc3_:UtilURLStream = new UtilURLStream();
				_loc3_.addEventListener(Event.COMPLETE,this.loadImageDataComplete);
				_loc3_.addEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
				_loc3_.load(_loc2_);
			}
		}
		
		private function ioErrorHandler(param1:IOErrorEvent) : void
		{
			param1.stopImmediatePropagation();
			this.removeLoadImageListeners(param1.target as IEventDispatcher);
		}
		
		override public function loadImageDataComplete(param1:Event) : void
		{
			this.removeLoadImageListeners(param1.target as IEventDispatcher);
			var _loc2_:URLStream = URLStream(param1.target);
			var _loc3_:ByteArray = new ByteArray();
			_loc2_.readBytes(_loc3_,0,_loc2_.bytesAvailable);
			var _loc4_:ByteArray = _loc3_;
			if (this.themeId != "ugc")
			{
				var _loc5_:UtilCrypto = new UtilCrypto();
				_loc5_.decrypt(_loc4_);
			}
			this.imageData = _loc4_;
			ImageDataManager.instance.setImageData("prop",themeId,id,_loc4_);
			this.dispatchEvent(new CoreEvent(CoreEvent.LOAD_THUMB_COMPLETE,this));
		}
		
		private function removeLoadImageListeners(param1:IEventDispatcher) : void
		{
			if(param1)
			{
				param1.removeEventListener(Event.COMPLETE,this.loadImageDataComplete);
				param1.removeEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
			}
		}
	}
}
