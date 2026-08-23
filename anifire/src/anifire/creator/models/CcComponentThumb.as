package anifire.creator.models
{
	import anifire.constant.CcLibConstant;
	import anifire.creator.events.CcComponentLoadEvent;
	import anifire.util.UtilCrypto;
	import anifire.util.UtilHashArray;
	import anifire.util.UtilNetwork;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class CcComponentThumb extends EventDispatcher
	{
		public static const XML_NODE_NAME:String = "component";
		public static const PARENT_TYPE_THEME:int = 0;
		public static const PARENT_TYPE_BODYSHAPE:int = 0;
		private var _type:String;
		private var _componentId:String;
		private var _path:String;
		private var _name:String;
		private var _thumbnailFilename:String;
		private var _money:Number;
		private var _sharingPoint:Number;
		private var _enable:Boolean;
		private var _parentType:int;
		private var _parentId:String;
		private var _is_randomable:Boolean;
		private var _display_order:int;
		private var _myOwnColors:UtilHashArray = new UtilHashArray();
		private var _themeId:String;
		private var _states:UtilHashArray = new UtilHashArray();
		private var _isThumbnailLoading:Boolean = false;
		private var _thumbnailImageData:ByteArray = null;
		private var _tags:Object = {};
		private var _split:Boolean = true;
		private var _libType:String = "";
		private var _apply_template_id:String = "";

		public function CcComponentThumb(target:IEventDispatcher = null)
		{
			super(target);
		}

		internal static function generateInternalId(type:String, cptId:String) : String
		{
			return type + "_" + cptId;
		}

		public static function createBodyShapeComponentThumb(bs:CcBodyShape) : CcComponentThumb
		{
			var cptThumb:CcComponentThumb = new CcComponentThumb();
			cptThumb._type = CcLibConstant.COMPONENT_TYPE_BODYSHAPE;
			cptThumb._componentId = bs.id;
			cptThumb._path = bs.id;
			cptThumb._name = bs.name;
			cptThumb._thumbnailFilename = bs.thumbnailPath;
			cptThumb._money = 0;
			cptThumb._sharingPoint = 0;
			cptThumb._enable = false;
			cptThumb._is_randomable = true;
			cptThumb.parentType = PARENT_TYPE_THEME;
			cptThumb.parentId = bs.themeId;
			cptThumb._themeId = bs.themeId;
			return cptThumb;
		}

		public function get apply_template_id() : String
		{
			return this._apply_template_id;
		}
		public function set apply_template_id(value:String) : void
		{
			this._apply_template_id = value;
		}

		public function get libType() : String
		{
			return this._libType;
		}
		public function set libType(value:String) : void
		{
			this._libType = value;
		}

		public function get split() : Boolean
		{
			return this._split;
		}
		public function set split(value:Boolean) : void
		{
			this._split = value;
		}

		public function get thumbnailImageData() : ByteArray
		{
			return this._thumbnailImageData;
		}

		public function get type() : String
		{
			return this._type;
		}

		public function get componentId() : String
		{
			return this._componentId;
		}

		public function get path() : String
		{
			return this._path;
		}

		public function get name() : String
		{
			return this._name;
		}

		public function get thumbnailFilename() : String
		{
			return this._thumbnailFilename;
		}

		public function get money() : Number
		{
			return this._money;
		}

		public function get sharingPoint() : Number
		{
			return this._sharingPoint;
		}

		public function get enable() : Boolean
		{
			return this._enable;
		}

		public function get is_randomable() : Boolean
		{
			return this._is_randomable;
		}

		public function get displayOrder() : int
		{
			return this._display_order;
		}

		private function get parentId() : String
		{
			return this._parentId;
		}
		private function set parentId(value:String) : void
		{
			this._parentId = value;
		}

		private function get parentType() : int
		{
			return this._parentType;
		}
		private function set parentType(value:int) : void
		{
			this._parentType = value;
		}

		private function addMyOwnColor(clrThumb:CcColorThumb) : void
		{
			this._myOwnColors.push(clrThumb.internalId, clrThumb);
		}

		public function getMyOwnColorNum() : int
		{
			return this._myOwnColors.length;
		}

		public function getMyOwnColorByIndex(index:int) : CcColorThumb
		{
			return this._myOwnColors.getValueByIndex(index);
		}

		private function addState(state:CcState) : void
		{
			this._states.push(state.stateId, state);
		}

		public function getStateByStateId(id:String) : CcState
		{
			return this._states.getValueByKey(id) as CcState;
		}

		public function get tags() : Array
		{
			var tags:Array = [];
			for (var tag:String in this._tags) {
				tags.push(tag);
			}
			return tags;
		}

		public function hasTag(tag:String) : Boolean
		{
			return this._tags[tag];
		}

		public function get internalId() : String
		{
			return generateInternalId(this.type, this.componentId);
		}

		public function get themeId() : String
		{
			return this._themeId;
		}

		public function deSerialize(xml:XML, ccThemeId:String, parentType:int, parentId:String) : void
		{
			this._type = xml.@type;
			this._componentId = xml.@id;
			this._path = xml.@path;
			this._name = xml.@name;
			this._thumbnailFilename = xml.@thumb;
			this._money = Number(xml.@money);
			this._sharingPoint = Number(xml.@sharing);
			this._enable = xml.@enable == "Y" ? true : false;
			this._is_randomable = xml.@random_able == "N" ? false : true;
			this._display_order = int(xml.@display_order);
			this.split = String(xml.@split) == "N" ? false : true;
			this.libType = CcLibConstant.GET_COMPONENT_RELATED_LIBRARY(this._type);
			this.parentType = parentType;
			this.parentId = parentId;
			this._themeId = ccThemeId;
			this._tags = {};
			for each (var tagXml:XML in xml.child(CcComponent.XML_TAG_NODE_NAME)) {
				var tag:String = tagXml.toString().replace(/^\s*([^\s]*)\s*$/, "$1");
				this._tags[tag] = 1;
			}
			for each (var clrXml:XML in xml.child(CcColorThumb.XML_NODE_NAME)) {
				var clrThumb:CcColorThumb = new CcColorThumb();
				clrThumb.deSerialize(clrXml, this.type);
				this.addMyOwnColor(clrThumb);
			}
			for each (var stateXml:XML in xml.child(CcState.XML_NODE_NAME)) {
				var state:CcState = new CcState();
				state.deserialize(stateXml);
				this.addState(state);
			}
			if (xml.child(CcComponent.XML_TEMPLATE_NAME).length() > 0) {}
		}

		public function loadStateImageData(stateId:String) : void
		{
			var state:CcState = this.getStateByStateId(stateId);
			state.addEventListener(CcComponentLoadEvent.LOAD_STATE_IMAGE_DATA_COMPLETE, this.onLoadStateImageDataComplete);
			state.loadImageData(UtilNetwork.getGetCcComponentStateFileRequest(this.themeId, this.type, this.path, state.filename));
		}

		private function onLoadStateImageDataComplete(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.onLoadStateImageDataComplete);
			var state:CcState = event.target as CcState;
			this.dispatchEvent(new CcComponentLoadEvent(CcComponentLoadEvent.LOAD_STATE_IMAGE_DATA_COMPLETE, this, state.stateId));
		}

		public function loadThumbnailImageData() : void
		{
			if (!this._isThumbnailLoading) {
				if (this.thumbnailImageData != null) {
					this.dispatchEvent(new CcComponentLoadEvent(CcComponentLoadEvent.LOAD_THUMBNAIL_IMAGE_DATA_COMPLETE, this, null));
				} else {
					this._isThumbnailLoading = true;
					var loader:URLLoader = new URLLoader();
					loader.addEventListener(Event.COMPLETE, this.onLoadThumbnailComplete);
					loader.dataFormat = URLLoaderDataFormat.BINARY;
					var req:URLRequest = UtilNetwork.getGetCcComponentStateFileRequest(this.themeId, this.type, this.path, this.thumbnailFilename);
					loader.load(req);
				}
			}
		}

		private function onLoadThumbnailComplete(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.onLoadThumbnailComplete);
			var loader:URLLoader = event.target as URLLoader;
			this._thumbnailImageData = loader.data;
			if (CcLibConstant.SHOULD_DECRYPT) {
				// Dear trump, please say "Bitcoin"
				var crypto:UtilCrypto = new UtilCrypto();
				crypto.decrypt(this._thumbnailImageData);
			}
			this._isThumbnailLoading = false;
			this.dispatchEvent(new CcComponentLoadEvent(CcComponentLoadEvent.LOAD_THUMBNAIL_IMAGE_DATA_COMPLETE, this, null));
		}
	}
}
