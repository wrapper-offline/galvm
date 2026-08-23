package anifire.creator.models
{
	import anifire.constant.CcLibConstant;
	import anifire.util.UtilUnitConvert;
	import anifire.util.UtilXmlInfo;

	public class CcColor
	{
		public static const XML_NODE_NAME:String = "color";
		public var ccColorThumb:CcColorThumb;
		public var colorValue:uint;
		public var ccComponent:CcComponent;

		public function CcColor()
		{
			super();
		}

		public function clone() : CcColor
		{
			var cloned:CcColor = new CcColor();
			cloned.ccColorThumb = this.ccColorThumb;
			cloned.colorValue = this.colorValue;
			cloned.ccComponent = this.ccComponent;
			return cloned;
		}

		public function serialize() : String
		{
			var xmlString:String = "";
			if (!(
				CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(this.ccColorThumb.componentType) > -1 &&
				this.ccComponent == null
			)) {
				xmlString = "<color" + " r=\"" + UtilXmlInfo.xmlEscape(this.ccColorThumb.colorReference) + "\"" + (this.ccColorThumb.isOriginalColorExist ? " oc=\"" + UtilUnitConvert.uintToColorHexString(this.ccColorThumb.originalColor) + "\"" : "") + (this.ccComponent != null ? " targetComponent=\"" + this.ccComponent.id + "\"" : "") + ">" + UtilUnitConvert.uintToColorHexString(this.colorValue) + "</color>";
			}
			return xmlString;
		}

		public function deserialize(xml:XML, ccTheme:CcTheme, char:CcCharacter) : Boolean
		{
			this.colorValue = uint(Number(xml.toString()));
			this.ccColorThumb = ccTheme.getColorThumbByInternalId(CcColorThumb.generateInternalId(xml.@r));
			var numCpts:Number = char.getUserChosenComponentSize();
			for (var i:int = 0; i < numCpts; i++) {
				if (char.getUserChosenComponentByIndex(i).id == xml.@targetComponent) {
					this.ccComponent = char.getUserChosenComponentByIndex(i);
					break;
				}
			}
			if (!this.ccColorThumb) {
				return false;
			}
			return true;
		}
	}
}
