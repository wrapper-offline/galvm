package anifire.creator.models
{
	public class CcColorThumb
	{

		public static const XML_NODE_NAME:String = "color";

		public static const XML_CHOICE_NODE_NAME:String = "choice";

		private var _colorReference:String;

		private var _originalColor:uint;

		private var _isOriginalColorExist:Boolean;

		private var _componentType:String;

		private var _enable:Boolean;

		private var _defaultColor:uint;

		private var _colorChoices:Array = new Array();

		private var _parentComponentType:String;

		private var _parentComponentColorRef:String;

		public function CcColorThumb()
		{
			super();
		}

		internal static function generateInternalId(ref:String) : String
		{
			return ref;
		}

		public function parentComponentType() : String
		{
			return this._parentComponentType;
		}

		public function parentComponentColorRef() : String
		{
			return this._parentComponentColorRef;
		}

		public function get colorReference() : String
		{
			return this._colorReference;
		}
		public function set colorReference(value:String) : void
		{
			this._colorReference = value;
		}

		public function get originalColor() : uint
		{
			return this._originalColor;
		}
		public function set originalColor(value:uint) : void
		{
			this._originalColor = value;
		}

		public function get componentType() : String
		{
			return this._componentType;
		}
		public function set componentType(value:String) : void
		{
			this._componentType = value;
		}

		public function get enable() : Boolean
		{
			return this._enable;
		}
		public function set enable(value:Boolean) : void
		{
			this._enable = value;
		}

		public function get defaultColor() : uint
		{
			return this._defaultColor;
		}
		public function set defaultColor(value:uint) : void
		{
			this._defaultColor = value;
		}

		public function get isOriginalColorExist() : Boolean
		{
			return this._isOriginalColorExist;
		}

		public function get internalId() : String
		{
			return generateInternalId(this.colorReference);
		}

		public function get colorChoices() : Array
		{
			return this._colorChoices;
		}

		public function deSerialize(xml:XML, cptType:String = null) : void
		{
			this.colorReference = xml.@r;
			if (xml.attribute("oc").length() > 0) {
				this._isOriginalColorExist = true;
				this.originalColor = xml.@oc;
			} else {
				this._isOriginalColorExist = false;
			}
			if (cptType == null) {
				this.componentType = xml.attribute("component_type").length() > 0 ? xml.@component_type : null;
			} else {
				this.componentType = cptType;
			}
			this.enable = xml.@enable == "N" ? false : true;
			// i'm aware this isn't standard and errors out in the ide,
			// BUT it's what goanimate did...
			this.defaultColor = xml.@default;
			if (xml.attribute("parent_component_type").length() > 0 && xml.attribute("parent_color_r").length() > 0) {
				this._parentComponentType = xml.@parent_component_type;
				this._parentComponentColorRef = xml.@parent_color_r;
			} else {
				this._parentComponentType = null;
				this._parentComponentColorRef = null;
			}
			for each (var choiceXml:XML in xml.child(XML_CHOICE_NODE_NAME)) {
				this._colorChoices.push(uint(Number(choiceXml.toString())));
			}
		}
	}
}
