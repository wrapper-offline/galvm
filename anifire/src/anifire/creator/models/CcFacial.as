package anifire.creator.models
{
	import anifire.util.UtilHashArray;

	public class CcFacial
	{
		public static const XML_NODE_NAME:String = "facial";
		private var _facialId:String;
		private var _name:String;
		private var _enable:Boolean;
		private var _selections:UtilHashArray = new UtilHashArray();
		private var _require_components:Array = new Array();

		public function CcFacial()
		{
			super();
		}

		public function get facialId() : String
		{
			return this._facialId;
		}

		public function get name() : String
		{
			return this._name;
		}

		public function get enable() : Boolean
		{
			return this._enable;
		}

		public function get internalId() : String
		{
			return this._facialId;
		}

		public function get selections() : UtilHashArray
		{
			return this._selections;
		}

		public function get requireComponents() : Array
		{
			return this._require_components;
		}

		public function deserialize(xml:XML) : void
		{
			var sels:XML;
			var reqCpts:XML;
			var reqCpt:CcRequireComponent;
			var sel:CcSelection;
			this._facialId = xml.@id;
			this._name = xml.@name;
			this._enable = xml.@enable == "N" ? false : true;
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
	}
}
