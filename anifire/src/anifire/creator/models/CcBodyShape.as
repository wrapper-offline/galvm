package anifire.creator.models
{
	import anifire.constant.CcLibConstant;
	import anifire.managers.AppConfigManager;
	import anifire.util.UtilHashArray;

	public class CcBodyShape
	{
		public static const XML_NODE_NAME:String = "bodyshape";
		private var _id:String;
		private var _name:String;
		private var _thumbnailActionId:String;
		private var _thumbnailFacialId:String;
		private var _thumbnailPath:String;
		private var _enable:Boolean;
		private var _shapeType:String;
		private var _components:UtilHashArray = new UtilHashArray();
		private var _componentsByType:UtilHashArray = new UtilHashArray();
		private var _actions:UtilHashArray = new UtilHashArray();
		private var _themeId:String;
		private var _bodyType:String;
		private var _defaultCharXml:XMLList;
		private var _libraries:UtilHashArray = new UtilHashArray();

		public function CcBodyShape()
		{
			super();
		}

		public function get thumbnailPath() : String
		{
			return this._thumbnailPath;
		}

		public function get id() : String
		{
			return this._id;
		}

		public function get name() : String
		{
			return this._name;
		}

		public function get thumbnailActionId() : String
		{
			return this._thumbnailActionId;
		}

		public function get thumbnailFacialId() : String
		{
			return this._thumbnailFacialId;
		}

		public function get themeId() : String
		{
			return this._themeId;
		}

		public function get bodyType() : String
		{
			return this._bodyType;
		}

		public function getDefaultCharXml() : XML
		{
			var config:AppConfigManager = AppConfigManager.instance;
			var filter:String = config.getValue("ft");
			var filtered:Vector.<XML> = new Vector.<XML>();
			for (var i:int = 0; i < this._defaultCharXml.length(); i++) {
				if (Boolean(filter) && filter == this._defaultCharXml[i].child("tag")) {
					filtered.push(this._defaultCharXml[i]);
				}
			}
			if (filtered.length > 0) {
				return filtered[0];
			}
			return this._defaultCharXml[0];
		}

		public function getActionNum() : Number
		{
			return this._actions.length;
		}

		public function getLibraryNum() : Number
		{
			return this._libraries.length;
		}

		public function getActionByIndex(index:int) : CcAction
		{
			return this._actions.getValueByIndex(index) as CcAction;
		}

		public function getActionById(id:String) : CcAction
		{
			return this._actions.getValueByKey(id) as CcAction;
		}

		private function addAction(action:CcAction) : void
		{
			this._actions.push(action.id, action);
		}

		public function getLibraryByIndex(index:int) : CcLibrary
		{
			return this._libraries.getValueByIndex(index) as CcLibrary;
		}

		public function getLibraryById(id:String) : CcLibrary
		{
			return this._libraries.getValueByKey(id) as CcLibrary;
		}

		private function addLibrary(library:CcLibrary) : void
		{
			this._libraries.push(library.type, library);
		}

		private function addComponentThumb(cptThumb:CcComponentThumb) : void
		{
			this._components.push(cptThumb.internalId, cptThumb);
			var cptThumbs:UtilHashArray = this._componentsByType.getValueByKey(cptThumb.type);
			if (cptThumbs == null) {
				cptThumbs = new UtilHashArray();
				this._componentsByType.push(cptThumb.type, cptThumbs);
				if (CcLibConstant.ALL_LIBRARY_TYPES.indexOf(cptThumb.type) > -1) {
					var library:CcLibrary = new CcLibrary();
					library.type = cptThumb.type;
					this.addLibrary(library);
				}
			}
			cptThumbs.push(cptThumb.internalId, cptThumb);
		}

		public function getComponentThumbByType(type:String) : UtilHashArray
		{
			return this._componentsByType.getValueByKey(type);
		}

		public function deserialize(xml:XML, ccThemeId:String, ccTheme:CcTheme = null) : void
		{
			this._themeId = ccThemeId;
			this._id = xml.@id;
			this._name = xml.@name;
			this._thumbnailActionId = xml.@action_thumb;
			this._thumbnailFacialId = xml.@facial_thumb;
			this._thumbnailPath = xml.@thumb_path;
			this._bodyType = xml.@tag;
			this._enable = xml.@enable == "N" ? false : true;
			this._defaultCharXml = xml.child("default_char");
			var actionPack:XML;
			var child:XML;
			var cptThumb:CcComponentThumb;
			var action:CcAction;
			for each (child in xml.child(CcComponentThumb.XML_NODE_NAME)) {
				cptThumb = new CcComponentThumb();
				cptThumb.deSerialize(child, this.themeId, CcComponentThumb.PARENT_TYPE_BODYSHAPE, this.id);
				this.addComponentThumb(cptThumb);
			}
			for each (child in xml.child(CcAction.XML_NODE_NAME)) {
				if (child.@enable != "N") {
					action = new CcAction();
					action.deserialize(child);
					this.addAction(action);
				}
			}
			for each (actionPack in xml.child(CcAction.PACK_XML_NODE_NAME)) {
				if (actionPack.@is_premium != "Y" && actionPack.@enable == "Y") {
					for each (child in actionPack.child(CcAction.XML_NODE_NAME)) {
						if (!(child.hasOwnProperty("@group") && child.@name != "1")) {
							action = new CcAction();
							action.deserialize(child);
							this.addAction(action);
						}
					}
				}
			}
			for each (child in xml.child(CcLibrary.XML_NODE_NAME)) {
				cptThumb = new CcComponentThumb();
				cptThumb.deSerialize(child, this.themeId, CcComponentThumb.PARENT_TYPE_BODYSHAPE, this.id);
				this.addComponentThumb(cptThumb);
			}
		}
	}
}
