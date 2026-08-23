package anifire.creator.models
{
	import flash.display.LoaderInfo;
	import flash.events.EventDispatcher;

	public class CcLibrary extends EventDispatcher
	{
		public static const XML_NODE_NAME:String = "library";
		private var _theme_id:String;
		private var _component_id:String;
		private var _type:String;
		private var _imagedata:LoaderInfo;
		private var _money:Number;
		private var _sharingPoint:Number;

		public function CcLibrary()
		{
			super();
		}

		public function get imagedata() : LoaderInfo
		{
			return this._imagedata;
		}
		public function set imagedata(value:LoaderInfo) : void
		{
			this._imagedata = value;
		}

		public function set theme_id(value:String) : void
		{
			this._theme_id = value;
		}
		public function get theme_id() : String
		{
			return this._theme_id;
		}

		public function set component_id(value:String) : void
		{
			this._component_id = value;
		}
		public function get component_id() : String
		{
			return this._component_id;
		}

		public function set type(value:String) : void
		{
			this._type = value;
		}
		public function get type() : String
		{
			return this._type;
		}

		public function get money() : Number
		{
			return this._money;
		}
		public function set money(value:Number) : void
		{
			this._money = value;
		}

		public function get sharingPoint() : Number
		{
			return this._sharingPoint;
		}
		public function set sharingPoint(value:Number) : void
		{
			this._sharingPoint = value;
		}

		public function clone() : CcLibrary
		{
			var cloned:CcLibrary = new CcLibrary();
			cloned.type = this.type;
			cloned.component_id = this.component_id;
			cloned.theme_id = this.theme_id;
			cloned.money = this.money;
			cloned.sharingPoint = this.sharingPoint;
			return cloned;
		}

		public function deserialize(xml:XML) : void
		{
			this._component_id = xml.@component_id;
			this._type = xml.@type;
			this._theme_id = xml.@theme_id;
			this._money = xml.@money;
			this._sharingPoint = xml.@sharing;
		}

		public function serialize() : String
		{
			return "<" + XML_NODE_NAME + " type=\"" + this._type + "\"" + " component_id=\"" + this._component_id + "\"" + " theme_id=\"" + this._theme_id + "\"" + "/>";
		}
	}
}
