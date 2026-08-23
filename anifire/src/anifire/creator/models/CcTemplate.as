package anifire.creator.models
{
	import anifire.util.UtilHashArray;

	public class CcTemplate extends CcCharacter
	{
		public static const XML_NODE_NAME:String = "template";
		private var _id:String;

		public function CcTemplate()
		{
			super();
		}

		public function get id() : String
		{
			return this._id;
		}
		public function set id(value:String) : void
		{
			this._id = value;
		}

		override public function deserialize(xml:XML, ccThemes:UtilHashArray) : void
		{
			var child:XML,
				component:CcComponent,
				color:CcColor,
				library:CcLibrary,
				type:String,
				cptThumb:CcComponentThumb;
			this.id = xml.@id;
			this.removeAllUserChosenComponent();
			this.currentTheme = ccThemes.getValueByIndex(0) as CcTheme;
			for each (child in xml.child(CcComponent.XML_NODE_NAME)) {
				type = CcComponent.getComponentThumbTypeFromXml(child);
				component = new CcComponent();
				component.deserialize(child, ccThemes);
				this.addUserChosenComponent(component);
			}
			this.removeAllUserChosenColors();
			for each (child in xml.child(CcColor.XML_NODE_NAME)) {
				color = new CcColor();
				if (color.deserialize(child, this.currentTheme, this)) {
					this.addUserChosenColor(color);
				}
			}
			this.removeAllUserChosenLibraries();
			for each (child in xml.child(CcLibrary.XML_NODE_NAME)) {
				library = new CcLibrary();
				cptThumb = this.currentTheme
					.getComponentThumbByInternalId(CcComponentThumb.generateInternalId(child.@type, child.@component_id));
				if (cptThumb) {
					child.@money = cptThumb.money;
					child.@sharing = cptThumb.sharingPoint;
				}
				library.deserialize(child);
				this.addUserChosenLibrary(library);
			}
		}
	}
}
