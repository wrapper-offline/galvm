package anifire.creator.models
{
	import anifire.creator.events.CcComponentLoadEvent;
	import anifire.util.UtilHashArray;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class CcAction extends EventDispatcher
	{
		public static const PACK_XML_NODE_NAME:String = "actionpack";
		public static const XML_NODE_NAME:String = "action";
		private var _id:String;
		private var _name:String;
		private var _enable:Boolean;
		private var _category:String;
		private var _group:String;
		private var _selections:UtilHashArray = new UtilHashArray();
		private var _require_components:Array = new Array();
		public var imageData:ByteArray = null;
		private var _isLoadingImageData:Boolean = false;

		public function CcAction()
		{
			super();
		}

		public function get group() : String
		{
			return this._group;
		}
		public function set group(value:String) : void
		{
			this._group = value;
		}

		public function get id() : String
		{
			return this._id;
		}

		public function get name() : String
		{
			return this._name;
		}

		public function get enable() : Boolean
		{
			return this._enable;
		}

		public function get category() : String
		{
			return this._category;
		}

		public function get requireComponents() : Array
		{
			return this._require_components;
		}

		public function get filename() : String
		{
			return this.id + ".swf";
		}

		public function getSelectionByComponentType(type:String) : CcSelection
		{
			return this._selections.getValueByKey(type) as CcSelection;
		}

		public function deserialize(xml:XML) : void
		{
			var sels:XML;
			var reqCpts:XML;
			var reqCpt:CcRequireComponent;
			var sel:CcSelection;
			this._id = xml.@id;
			this._name = xml.@name;
			this._enable = xml.@enable == "N" ? false : true;
			this._category = xml.@category;
			this._group = xml.@group;
			for each (sels in xml.child(CcSelection.XML_NODE_NAME)) {
				sel = new CcSelection();
				sel.deserialize(sels);
				this._selections.push(sel.type, sel);
			}
			for each (reqCpts in xml.child("require_component")) {
				reqCpt = new CcRequireComponent();
				reqCpt.deserialize(reqCpts);
				this._require_components.push(reqCpt);
			}
		}

		public function loadImageData(req:URLRequest) : void
		{
			if(this.imageData != null) {
				this.dispatchLoadCompleteEvent();
			} else if(!this._isLoadingImageData) {
				var loader:URLLoader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.addEventListener(Event.COMPLETE, this.onLoadImageDataComplete);
				loader.load(req);
			}
		}

		private function onLoadImageDataComplete(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.onLoadImageDataComplete);
			var loader:URLLoader = event.target as URLLoader;
			this.imageData = loader.data as ByteArray;
			this.dispatchLoadCompleteEvent();
		}

		private function dispatchLoadCompleteEvent() : void
		{
			this.dispatchEvent(new CcComponentLoadEvent(CcComponentLoadEvent.LOAD_ACTION_IMAGE_DATA_COMPLETE, this, this.id));
		}
	}
}
