package anifire.creator.models
{
	import anifire.constant.CcLibConstant;
	import anifire.creator.events.CcCoreEvent;
	import anifire.util.UtilHashArray;
	import anifire.util.UtilNetwork;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	public class CcTheme extends EventDispatcher
	{
		private var _id:String;
		private var _studioThemeId:String;
		private var _componentThumbs:UtilHashArray = new UtilHashArray();
		private var _componentsByType:UtilHashArray = new UtilHashArray();
		private var _ccColors:UtilHashArray = new UtilHashArray();
		private var _facials:UtilHashArray = new UtilHashArray();
		private var _bodyshapes:UtilHashArray = new UtilHashArray();
		private var _templates:UtilHashArray = new UtilHashArray();
		private var _preMadeChars:Array;
		private var _availableLibrary:Array = new Array();

		public function CcTheme(target:IEventDispatcher = null)
		{
			super(target);
		}

		public function get studioThemeId() : String
		{
			return this._studioThemeId;
		}

		public function get preMadeChars() : Array
		{
			return this._preMadeChars;
		}

		public function getLibraryNum() : Number
		{
			return this._availableLibrary.length;
		}

		public function getComponentThumbByInternalId(id:String) : CcComponentThumb
		{
			return this._componentThumbs.getValueByKey(id);
		}

		public function getComponentThumbByType(type:String) : UtilHashArray
		{
			return this._componentsByType.getValueByKey(type);
		}

		public function getComponentThumbWithinBodyshapeByType(type:String) : UtilHashArray
		{
			var i:int;
			var bs:CcBodyShape;
			var cptThumbArr:UtilHashArray = new UtilHashArray();
			for (i = 0; i < this.getBodyShapeNum(); i++) {
				bs = this.getBodyShapeByIndex(i);
				cptThumbArr.insert(0, bs.getComponentThumbByType(type));
			}
			return cptThumbArr;
		}

		public function addComponentThumb(cptThumb:CcComponentThumb) : void
		{
			this._componentThumbs.push(cptThumb.internalId, cptThumb);
			var cptThumbArr:UtilHashArray = this._componentsByType.getValueByKey(cptThumb.type);
			if (cptThumbArr == null) {
				cptThumbArr = new UtilHashArray();
				this._componentsByType.push(cptThumb.type, cptThumbArr);
				if (CcLibConstant.ALL_LIBRARY_TYPES.indexOf(cptThumb.type) > -1) {
					this._availableLibrary.push(cptThumb.type);
				}
			}
			cptThumbArr.push(cptThumb.internalId, cptThumb);
		}

		private function addBodyShape(bs:CcBodyShape) : void
		{
			this._bodyshapes.push(bs.id, bs);
		}

		public function getBodyShapeNum() : Number
		{
			return this._bodyshapes.length;
		}

		public function getBodyShapeByIndex(index:int) : CcBodyShape
		{
			return this._bodyshapes.getValueByIndex(index) as CcBodyShape;
		}

		public function getBodyShapeByShapeId(id:String) : CcBodyShape
		{
			return this._bodyshapes.getValueByKey(id) as CcBodyShape;
		}

		public function getBodyShapeTypes() : Array
		{
			var bs:CcBodyShape;
			var bsArray:UtilHashArray = new UtilHashArray();
			for (var i:int = 0; i < this.getBodyShapeNum(); i++) {
				bs = this.getBodyShapeByIndex(i);
				bsArray.push(bs.bodyType, bs.bodyType);
			}
			return bsArray.getArray();
		}

		public function getBodyShapesByShapeType(bodyType:String) : Array
		{
			var bsArray:Array = new Array();
			var bs:CcBodyShape;
			for (var i:int = 0; i < this.getBodyShapeNum(); i++) {
				bs = this.getBodyShapeByIndex(i);
				if (bs.bodyType == bodyType) {
					bsArray.push(bs);
				}
			}
			return bsArray;
		}

		private function addFacial(facial:CcFacial) : void
		{
			this._facials.push(facial.internalId, facial);
		}

		public function getFacialNum() : Number
		{
			return this._facials.length;
		}

		public function getFacialByIndex(index:int) : CcFacial
		{
			return this._facials.getValueByIndex(index) as CcFacial;
		}

		public function getFacialById(id:String) : CcFacial
		{
			return this._facials.getValueByKey(id) as CcFacial;
		}

		private function addTemplate(template:CcTemplate) : void
		{
			this._templates.push(template.id, template);
		}

		public function getTemplateById(id:String) : CcTemplate
		{
			return this._templates.getValueByKey(id) as CcTemplate;
		}

		public function set id(value:String) : void
		{
			this._id = value;
		}
		public function get id() : String
		{
			return this._id;
		}

		private function addColorThumb(clrThumb:CcColorThumb) : void
		{
			this._ccColors.push(clrThumb.internalId, clrThumb);
		}

		public function getColorThumbNum() : int
		{
			return this._ccColors.length;
		}

		public function getColorThumbByIndex(index:int) : CcColorThumb
		{
			return this._ccColors.getValueByIndex(index) as CcColorThumb;
		}

		public function getColorThumbByInternalId(id:String) : CcColorThumb
		{
			return this._ccColors.getValueByKey(id) as CcColorThumb;
		}

		public function getAvailableComponentTypes() : Array
		{
			var unused:Array = new Array();
			return CcLibConstant.USER_CHOOSE_ABLE_BODY_COMPONENT_TYPES
				.concat(CcLibConstant.USER_CHOOSE_ABLE_HEAD_COMPONENT_TYPES);
		}

		public function initCcThemeByLoadThemeFile(ccThemeId:String) : void
		{
			this.id = ccThemeId;
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			var req:URLRequest = UtilNetwork.getGetCcThemeRequest(ccThemeId);
			loader.addEventListener(Event.COMPLETE, this.onLoadThemeComplete);
			loader.load(req);
		}

		public function initCcThemePreMadeChar() : void
		{
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			var req:URLRequest = UtilNetwork.getGetCcThemePreMadeCharRequest(this.id);
			loader.addEventListener(Event.COMPLETE, this.onLoadCcThemePreMadeCharComplete);
			loader.load(req);
		}

		private function onLoadCcThemePreMadeCharComplete(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.onLoadCcThemePreMadeCharComplete);
			var loader:URLLoader = event.target as URLLoader;
			var res:String = loader.data as String;
			res = "<?xml version=\"1.0\"?><chars>" + res + "</chars>";
			var chars:XML = new XML(res);
			this._preMadeChars = new Array();
			for each (var charXml:XML in chars.child(CcCharacter.XML_NODE_NAME)) {
				var char:CcCharacter = new CcCharacter();
				var components:UtilHashArray = new UtilHashArray();
				components.push(this.id, this);
				char.deserialize(charXml, components);
				this._preMadeChars.push(char);
			}
			var evt:CcCoreEvent = new CcCoreEvent(CcCoreEvent.LOAD_PRE_MADE_CHARACTER_COMPLETE, this);
			this.dispatchEvent(evt);
		}

		public function initCcThemeByXml(xmlString:String) : void
		{
			var xml:XML = new XML(xmlString);
			this.id = xml.@id;
			this.doHandleLoadedThemeXml(xml);
		}

		private function onLoadThemeComplete(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.onLoadThemeComplete);
			var loader:URLLoader = event.target as URLLoader;
			var xml:XML = new XML(loader.data as String);
			this.doHandleLoadedThemeXml(xml);
			this.dispatchEvent(new CcCoreEvent(CcCoreEvent.LOAD_THEME_COMPLETE, this));
		}

		private function doHandleLoadedThemeXml(xml:XML) : void
		{
			this.deserialize(xml);
		}

		private function deserialize(xml:XML) : void
		{
			var child:XML;
			this._studioThemeId = xml.@studio_theme_id;
			for each (child in xml.child(CcColorThumb.XML_NODE_NAME)) {
				var clrThumb:CcColorThumb = new CcColorThumb();
				clrThumb.deSerialize(child);
				this.addColorThumb(clrThumb);
			}
			for each (child in xml.child(CcComponentThumb.XML_NODE_NAME)) {
				var cptThumb:CcComponentThumb = new CcComponentThumb();
				cptThumb.deSerialize(child, this.id, CcComponentThumb.PARENT_TYPE_THEME, this.id);
				this.addComponentThumb(cptThumb);
			}
			for each (child in xml.child(CcFacial.XML_NODE_NAME)) {
				var facial:CcFacial = new CcFacial();
				facial.deserialize(child);
				this.addFacial(facial);
			}
			for each (child in xml.child(CcBodyShape.XML_NODE_NAME)) {
				var bs:CcBodyShape = new CcBodyShape();
				bs.deserialize(child, this.id, this);
				this.addBodyShape(bs);
			}
			for each (child in xml.child(CcTemplate.XML_NODE_NAME)) {
				var template:CcTemplate = new CcTemplate();
				var themes:UtilHashArray = new UtilHashArray();
				themes.push(this.id, this);
				template.deserialize(child, themes);
				this.addTemplate(template);
			}
		}
	}
}
