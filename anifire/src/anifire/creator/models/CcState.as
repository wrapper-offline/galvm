package anifire.creator.models
{
	import anifire.creator.events.CcComponentLoadEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class CcState extends EventDispatcher
	{
		public static const XML_NODE_NAME:String = "state";
		public var stateId:String;
		public var filename:String;
		public var imageData:ByteArray = null;
		private var _isLoadingImageData:Boolean = false;

		public function CcState()
		{
			super();
		}

		public function deserialize(xml:XML) : void
		{
			this.stateId = xml.@id;
			this.filename = xml.@filename;
		}

		public function loadImageData(req:URLRequest) : void
		{
			if (this.imageData != null) {
				this.dispatchLoadCompleteEvent();
			} else if (!this._isLoadingImageData) {
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
			this.dispatchEvent(new CcComponentLoadEvent(CcComponentLoadEvent.LOAD_STATE_IMAGE_DATA_COMPLETE, this, this.stateId));
		}
	}
}
