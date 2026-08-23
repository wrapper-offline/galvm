package anifire.creator.models
{
	import anifire.constant.CcLibConstant;
	import anifire.util.UtilHashArray;
	import com.adobe.crypto.MD5;
	import flash.geom.Point;

	public class CcCharacter
	{
		public static const XML_NODE_NAME:String = "cc_char";
		private var _userChosenColors:UtilHashArray = new UtilHashArray();
		private var _userChosenComponents:Array = new Array();
		private var _userChosenLibraries:Array = new Array();
		private var _bodyShape:CcBodyShape;
		private var _assetId:String = "";
		private var _templateId:String = "";
		private var _templateMD5:String = "";
		private var _currentTheme:CcTheme;
		private var _name:String;
		private var _createDateTime:String = "";
		private var _tags:Array = new Array();
		private var _category:String = null;
		private var _headScaleX:Number = 1;
		private var _headScaleY:Number = 1;
		private var _headDX:Number = 0;
		private var _headDY:Number = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _ver:Number = 1;
		private var _isRandom:Boolean = false;

		public function CcCharacter()
		{
			super();
		}

		public static function getComponentScaling(bodyType:String) : Number
		{
			if (bodyType == "female") {
				return CcLibConstant.COMPONENT_SCALE_FEMALE;
			}
			return CcLibConstant.COMPONENT_SCALE_MALE;
		}

		public function get isRandom() : Boolean
		{
			return this._isRandom;
		}

		public function set isRandom(value:Boolean) : void
		{
			this._isRandom = value;
		}

		public function get category() : String
		{
			if (this._category == null) {
				var catBase:String = "_category_";
				this._category = "";
				var tag:String;
				for (var i:int = 0; i < this.tags.length; i++) {
					tag = this.tags[i] as String;
					if (tag.substr(0, catBase.length) == catBase) {
						this._category = tag.substr(catBase.length);
						break;
					}
				}
			}
			return this._category;
		}

		public function get tags() : Array
		{
			return this._tags;
		}

		public function get name() : String
		{
			return this._name;
		}

		public function set currentTheme(value:CcTheme) : void
		{
			this._currentTheme = value;
		}
		public function get currentTheme() : CcTheme
		{
			return this._currentTheme;
		}

		public function get templateId() : String
		{
			return this._templateId;
		}

		public function get copiedFromTemplate() : Boolean
		{
			return this._templateId != "";
		}

		public function markAsTemplate() : void
		{
			this._templateId = this.assetId;
			this._templateMD5 = MD5.hash(this.serialize());
		}

		public function isTemplateModified() : Boolean
		{
			return this.copiedFromTemplate && this._templateMD5 != MD5.hash(this.serialize());
		}

		public function get assetId() : String
		{
			return this._assetId;
		}

		public function set assetId(value:String) : void
		{
			this._assetId = value;
		}

		public function set bodyShape(value:CcBodyShape) : void
		{
			this._bodyShape = value;
		}

		public function get bodyShape() : CcBodyShape
		{
			return this._bodyShape;
		}

		public function get createDateTime() : String
		{
			return this._createDateTime;
		}

		public function get thumbnailActionId() : String
		{
			return this.bodyShape.thumbnailActionId;
		}

		public function set headScale(value:Point) : void
		{
			this._headScaleX = value.x;
			this._headScaleY = value.y;
		}
		public function get headScale() : Point
		{
			return new Point(this._headScaleX, this._headScaleY);
		}

		public function set bodyScale(value:Point) : void
		{
			this._scaleX = value.x;
			this._scaleY = value.y;
		}
		public function get bodyScale() : Point
		{
			return new Point(this._scaleX, this._scaleY);
		}

		public function set headShift(value:Point) : void
		{
			this._headDX = value.x;
			this._headDY = value.y;
		}
		public function get headShift() : Point
		{
			return new Point(this._headDX, this._headDY);
		}

		public function set ver(value:Number) : void
		{
			this._ver = value;
		}
		public function get ver() : Number
		{
			return this._ver;
		}

		public function clone() : CcCharacter
		{
			var i:int;
			var char:CcCharacter = new CcCharacter();
			char.currentTheme = this.currentTheme;
			char.assetId = this.assetId;
			char.bodyShape = this.bodyShape;
			char._name = this._name;
			char._tags = this.tags.slice();
			char.ver = this._ver;
			char._templateId = this._templateId;
			char._templateMD5 = this._templateMD5;
			for (i = 0; i < this.getUserChosenColorNum(); i++) {
				var color:CcColor = this.getUserChosenColorByIndex(i);
				char.addUserChosenColor(color.clone());
			}
			for (i = 0; i < this.getUserChosenComponentSize(); i++) {
				var component:CcComponent = this.getUserChosenComponentByIndex(i);
				char.addUserChosenComponent(component.clone());
			}
			for (i = 0; i < this.getUserChosenLibraryNum(); i++) {
				var library:CcLibrary = this.getUserChosenLibraryByIndex(i);
				char.addUserChosenLibrary(library.clone());
			}
			char.bodyScale = this.bodyScale;
			char.headScale = this.headScale;
			char.headShift = this.headShift;
			return char;
		}

		public function cloneFromSourceToMe(char:CcCharacter) : void
		{
			var i:int;
			this.currentTheme = char.currentTheme;
			this.removeAllUserChosenComponent();
			for (i = 0; i < char.getUserChosenComponentSize(); i++) {
				this.addUserChosenComponent(char.getUserChosenComponentByIndex(i));
			}
			this.removeAllUserChosenColors();
			for (i = 0; i < char.getUserChosenColorNum(); i++) {
				this.addUserChosenColor(char.getUserChosenColorByIndex(i));
			}
			this.removeAllUserChosenLibraries();
			for (i = 0; i < char.getUserChosenLibraryNum(); i++) {
				this.addUserChosenLibrary(char.getUserChosenLibraryByIndex(i));
			}
			this.bodyShape = char.bodyShape;
			this.assetId = char.assetId;
			this._name = char._name;
			this._tags = char.tags.slice();
			this._ver = char.ver;
			this._templateId = char._templateId;
			this._templateMD5 = char._templateMD5;
			this.bodyScale = char.bodyScale;
			this.headScale = char.headScale;
			this.headShift = char.headShift;
		}

		public function getUserChosenLibraryByIndex(index:Number) : CcLibrary
		{
			return this._userChosenLibraries[index];
		}

		public function getUserChosenLibraryNum() : Number
		{
			return this._userChosenLibraries.length;
		}

		public function removeAllUserChosenLibraries() : void
		{
			this._userChosenLibraries.splice(0, this._userChosenLibraries.length);
		}

		public function addUserChosenLibrary(library:CcLibrary) : void
		{
			this.removeUserChosenLibraryByType(library.type);
			this._userChosenLibraries.push(library);
		}

		public function getUserChosenLibraryByType(type:String) : CcLibrary
		{
			for (var i:int = this._userChosenLibraries.length - 1; i >= 0; i--) {
				var library:CcLibrary = this._userChosenLibraries[i] as CcLibrary;
				if (library.type == type) {
					return library;
				}
			}
			return null;
		}

		public function removeUserChosenLibraryByType(type:String) : void
		{
			for (var i:int = this._userChosenLibraries.length - 1; i >= 0; i--) {
				var library:CcLibrary = this._userChosenLibraries[i] as CcLibrary;
				if (library.type == type) {
					this._userChosenLibraries.splice(i, 1);
				}
			}
		}

		public function addUserChosenColor(color:CcColor) : void
		{
			var idx:String;
			if (
				color.ccComponent != null &&
				CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(color.ccColorThumb.componentType) > -1
			) {
				idx = color.ccComponent.id + color.ccColorThumb.internalId;
			} else {
				idx = color.ccColorThumb.internalId;
			}
			this._userChosenColors.push(idx, color);
		}

		public function getUserChosenColorNum() : Number
		{
			return this._userChosenColors.length;
		}

		public function getUserChosenColorByColorReference(ref:String) : CcColor
		{
			var color:CcColor;
			for (var i:int = 0; i < this._userChosenColors.length; i++) {
				color = this._userChosenColors.getValueByIndex(i) as CcColor;
				if (color.ccColorThumb.colorReference == ref) {
					return color;
				}
			}
			return null;
		}

		public function getUserChosenColorByComponentType(type:String) : Array
		{
			var colors:Array = new Array();
			var color:CcColor;
			for (var i:int = 0; i < this._userChosenColors.length; i++) {
				color = this._userChosenColors.getValueByIndex(i) as CcColor;
				if (color.ccColorThumb.componentType == type) {
					colors.push(color);
				}
			}
			return colors;
		}

		public function getUserChosenColorByIndex(index:int) : CcColor
		{
			return this._userChosenColors.getValueByIndex(index);
		}

		public function removeUserChosenColorByIndex(index:int) : void
		{
			this._userChosenColors.remove(index, 1);
		}

		public function removeAllUserChosenColors() : void
		{
			this._userChosenColors.removeAll();
		}

		public function getUserChosenComponentSize() : Number
		{
			return this._userChosenComponents.length;
		}

		public function getUserChosenComponentByIndex(index:int) : CcComponent
		{
			return this._userChosenComponents[index] as CcComponent;
		}

		public function getUserChosenComponentByComponentType(type:String) : Array
		{
			var components:Array = new Array();
			var component:CcComponent;
			for (var i:int = 0; i < this._userChosenComponents.length; i++) {
				component = this._userChosenComponents[i] as CcComponent;
				if (component.componentThumb.type == type) {
					components.push(component);
				}
			}
			return components;
		}

		public function addUserChosenComponent(component:CcComponent) : void
		{
			if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(component.componentThumb.type) == -1) {
				this.removeUserChosenComponentByType(component.componentThumb.type);
			}
			this._userChosenComponents.push(component);
		}

		public function getFacialByFacialId(facialId:String) : CcFacial
		{
			return this.currentTheme.getFacialById(facialId);
		}

		public function calculateGobuck() : Number
		{
			var component:CcComponent;
			var library:CcLibrary;
			var gobux:Number = 0;
			var i:int = 0;
			for (i = 0; i < this.getUserChosenComponentSize(); i++) {
				component = this.getUserChosenComponentByIndex(i);
				gobux += component.componentThumb.money;
			}
			for (i = 0; i < this.getUserChosenLibraryNum(); i++) {
				library = this.getUserChosenLibraryByIndex(i);
				gobux += library.money;
			}
			return gobux;
		}

		public function calculateGoPoint() : Number
		{
			var component:CcComponent;
			var library:CcLibrary;
			var pointz:Number = 0;
			for (var i:int = 0; i < this.getUserChosenComponentSize(); i++) {
				component = this.getUserChosenComponentByIndex(i);
				pointz += component.componentThumb.sharingPoint;
			}
			for (i = 0; i < this.getUserChosenLibraryNum(); i++) {
				library = this.getUserChosenLibraryByIndex(i);
				pointz += library.sharingPoint;
			}
			return pointz;
		}

		private function addBodyShapeThumb() : void {}

		public function removeUserChosenComponentByType(type:String) : void
		{
			for (var lI:int = this._userChosenLibraries.length - 1; lI >= 0; lI--) {
				var library:CcLibrary = this._userChosenLibraries[lI] as CcLibrary;
				if (library.type == type) {
					this._userChosenLibraries.splice(lI, 1);
				}
			}
			for (var cI:int = this._userChosenComponents.length - 1; cI >= 0; cI--) {
				var component:CcComponent = this._userChosenComponents[cI] as CcComponent;
				if (component.componentThumb.type == type) {
					this._userChosenComponents.splice(cI, 1);
				}
			}
		}

		public function removeUserChosenComponentById(componentId:String) : void
		{
			for (var cptI:int = this._userChosenComponents.length - 1; cptI >= 0; cptI--) {
				var component:CcComponent = this._userChosenComponents[cptI] as CcComponent;
				if (component.id == componentId) {
					this._userChosenComponents.splice(cptI, 1);
				}
			}
			for (var clrI:int = this._userChosenColors.length - 1; clrI >= 0; clrI--) {
				var color:CcColor = this._userChosenColors.getValueByIndex(clrI) as CcColor;
				if (color.ccComponent != null && color.ccComponent.id == componentId) {
					this._userChosenColors.remove(clrI, 1);
				}
			}
		}

		public function removeAllUserChosenComponent() : void
		{
			this._userChosenComponents.splice(0, this._userChosenComponents.length);
		}

		public function transformBodyShape(bs:CcBodyShape) : void
		{
			if (bs.id != this.bodyShape.id) {
				this._bodyShape = bs;
				var bsComponent:CcComponent = new CcComponent();
				bsComponent.componentThumb = CcComponentThumb.createBodyShapeComponentThumb(this.bodyShape);
				this.addUserChosenComponent(bsComponent);
				var animComponent:CcComponent = new CcComponent();
				var typea:String = this.ver < 2 ?
					CcLibConstant.COMPONENT_TYPE_SKELETON :
					CcLibConstant.COMPONENT_TYPE_FREEACTION;
				var animThumb:CcComponentThumb = this.bodyShape.getComponentThumbByType(typea)
					.getValueByIndex(0) as CcComponentThumb;
				animComponent.componentThumb = animThumb;
				this.addUserChosenComponent(animComponent);
				for each (var type:String in CcLibConstant.USER_CHOOSE_ABLE_BODY_COMPONENT_TYPES) {
					if (type != CcLibConstant.COMPONENT_TYPE_BODYSHAPE) {
						if (this.ver == 1) {
							if (CcLibConstant.ALL_LIBRARY_TYPES.indexOf(type) > -1) {
								continue;
							}
						} else {
							if (CcLibConstant.ALL_LIBRARY_TYPES.indexOf(type) == -1) {
								continue;
							}
							if (CcLibConstant.HEAD_RELATED_LIBRARY.indexOf(type) > -1) {
								continue;
							}
						}
						var array:UtilHashArray = new UtilHashArray();
						if (this.bodyShape.getComponentThumbByType(type)) {
							var cptThumb:CcComponentThumb = this.bodyShape.getComponentThumbByType(type)
								.getValueByIndex(0) as CcComponentThumb;
							array.push(cptThumb.componentId, cptThumb);
							this.randomlyChooseComponentInArray(array, this.bodyShape.bodyType);
						}
					}
				}
			}
		}

		public function randomize(ccTheme:CcTheme, bodyType:String, bs:CcBodyShape = null) : void
		{
			var charI:int = 0;
			var noPremadeChars:Boolean = false;
			var char:CcCharacter = null;
			if (Math.random() > CcLibConstant.PROBABILITY_RANDOM_FROM_PRE_MADE_CHAR) {
				noPremadeChars = true;
			} else if (Boolean(ccTheme.preMadeChars) && ccTheme.preMadeChars.length <= 0) {
				noPremadeChars = true;
			} else {
				noPremadeChars = true;
				if (ccTheme.preMadeChars) {
					for (charI = 0; charI < ccTheme.preMadeChars.length; charI++) {
						char = ccTheme.preMadeChars[charI] as CcCharacter;
						if (char.bodyShape.bodyType == bodyType) {
							noPremadeChars = false;
							break;
						}
					}
				}
			}
			if (noPremadeChars) {
				this.randomizeEverythingRandomlly(ccTheme, bodyType, bs);
			} else {
				this.randomizeFromPreMadeChar(ccTheme, bodyType);
			}
			this._isRandom = true;
		}

		private function randomizeFromPreMadeChar(ccTheme:CcTheme, bodyType:String) : void
		{
			var matchingChars:Array = new Array();
			var char:CcCharacter;
			for (var i:int = 0; i < ccTheme.preMadeChars.length; i++) {
				char = ccTheme.preMadeChars[i] as CcCharacter;
				if (
					char.bodyShape.bodyType == bodyType &&
					CcLibConstant.CHAR_TAG_MATCH_CURR_THEME(char.tags)
				) {
					matchingChars.push(char);
				}
			}
			var rand:int = Math.floor(Math.random() * matchingChars.length);
			char = matchingChars[rand] as CcCharacter;
			char.markAsTemplate();
			var ccThemes:UtilHashArray = new UtilHashArray();
			ccThemes.push(ccTheme.id, ccTheme);
			this.cloneFromSourceToMe(char);
			this.assetId = "";
		}

		private function randomizeEverythingRandomlly(ccTheme:CcTheme, bodyType:String, bs:CcBodyShape = null) : void
		{
			var type:String;
			var cptArray:UtilHashArray;
			var cptThumb:CcComponentThumb;
			var clrThumb:CcColorThumb
			var color:CcColor;
			var bses:Array = ccTheme.getBodyShapesByShapeType(bodyType);
			this._currentTheme = ccTheme;
			this.removeAllUserChosenColors();
			this.removeAllUserChosenComponent();
			this.removeAllUserChosenLibraries();
			var clrI:int;
			for (clrI = 0; clrI < ccTheme.getColorThumbNum(); clrI++) {
				clrThumb = ccTheme.getColorThumbByIndex(clrI);
				if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(clrThumb.componentType) == -1) {
					color = new CcColor();
					color.ccColorThumb = clrThumb;
					color.colorValue = clrThumb.colorChoices[Math.floor(Math.random() * clrThumb.colorChoices.length)];
					this.addUserChosenColor(color);
				}
			}
			if (bs == null) {
				this._bodyShape = bses[Math.floor(Math.random() * bses.length)] as CcBodyShape;
			} else {
				this._bodyShape = bs;
			}
			var bsCpt:CcComponent = new CcComponent();
			bsCpt.componentThumb = CcComponentThumb.createBodyShapeComponentThumb(this.bodyShape);
			this.addUserChosenComponent(bsCpt);
			var animCpt:CcComponent = new CcComponent();
			var animCptThumb:CcComponentThumb;
			switch (this.ver) {
				case 2:
					animCptThumb = this.bodyShape
						.getComponentThumbByType(CcLibConstant.COMPONENT_TYPE_FREEACTION)
						.getValueByIndex(0) as CcComponentThumb;
					break;
				default:
					animCptThumb = this.bodyShape
						.getComponentThumbByType(CcLibConstant.COMPONENT_TYPE_SKELETON)
						.getValueByIndex(0) as CcComponentThumb;
			}
			animCpt.componentThumb = animCptThumb;
			this.addUserChosenComponent(animCpt);
			var prob:Number;
			for each (type in CcLibConstant.USER_CHOOSE_ABLE_BODY_COMPONENT_TYPES) {
				prob = CcLibConstant.GET_COMPONENT_TYPE_OCCURANCE_PROBABILITY(type);
				if (Math.random() < prob) {
					cptArray = this.bodyShape.getComponentThumbByType(type);
					this.randomlyChooseComponentInArray(cptArray, this.bodyShape.bodyType);
				}
			}
			for each (type in CcLibConstant.USER_CHOOSE_ABLE_HEAD_COMPONENT_TYPES) {
				prob = CcLibConstant.GET_COMPONENT_TYPE_OCCURANCE_PROBABILITY(type);
				if (Math.random() < prob) {
					cptArray = ccTheme.getComponentThumbByType(type);
					this.randomlyChooseComponentInArray(cptArray, this.bodyShape.bodyType);
				}
			}
		}

		private function randomlyChooseComponentInArray(array:UtilHashArray, bodyType:String) : void
		{
			if (array != null && array.length > 0) {
				array = array.clone();
				var i:int;
				var cptThumb:CcComponentThumb;
				for (i = array.length - 1; i >= 0; i--) {
					cptThumb = array.getValueByIndex(i) as CcComponentThumb;
					if (!cptThumb.is_randomable || !cptThumb.enable) {
						array.remove(i, 1);
					}
				}
				cptThumb = array.getValueByIndex(Math.random() * array.length) as CcComponentThumb;
				var component:CcComponent = new CcComponent();
				component.xscale = component.yscale = CcCharacter.getComponentScaling(bodyType);
				component.componentThumb = cptThumb;
				var clrThumb:CcColorThumb;
				var color:CcColor;
				var library:CcLibrary;
				if (CcLibConstant.ALL_LIBRARY_TYPES.indexOf(cptThumb.type) > -1) {
					library = new CcLibrary();
					library.type = cptThumb.type;
					library.theme_id = cptThumb.themeId;
					library.component_id = cptThumb.componentId;
					library.money = cptThumb.money;
					library.sharingPoint = cptThumb.sharingPoint;
					this.addUserChosenLibrary(library);
				} else {
					this.addUserChosenComponent(component);
				}
				for (i = 0; i < cptThumb.getMyOwnColorNum(); i++) {
					clrThumb = cptThumb.getMyOwnColorByIndex(i);
					color = new CcColor();
					color.ccColorThumb = clrThumb;
					color.colorValue = clrThumb.defaultColor;
					this.addUserChosenColor(color);
				}
			}
		}

		public function serialize() : String
		{
			var i:int = 0;
			var xml:String = "<" + XML_NODE_NAME + " xscale=\'" + this._scaleX + "\' yscale=\'" + this._scaleY + "\' hxscale=\'" + this._headScaleX + "\' hyscale=\'" + this._headScaleY + "\' headdx=\'" + this._headDX + "\' headdy=\'" + this._headDY + "\'>";
			for (i = 0; i < this.getUserChosenColorNum(); i++) {
				xml += this.getUserChosenColorByIndex(i).serialize();
			}
			for (i = 0; i < this.getUserChosenComponentSize(); i++) {
				xml += this.getUserChosenComponentByIndex(i).serialize();
			}
			for (i = 0; i < this.getUserChosenLibraryNum(); i++) {
				xml += this.getUserChosenLibraryByIndex(i).serialize();
			}
			return xml + ("</" + XML_NODE_NAME + ">");
		}

		public function deserialize(xml:XML, components:UtilHashArray) : void
		{
			var child:XML;
			var component:CcComponent;
			var color:CcColor;
			var library:CcLibrary;
			this._assetId = xml.@aid;
			this._name = xml.@name;
			this._createDateTime = xml.@create || "";
			if (xml.@tags != null) {
				var tagString:String = xml.@tags;
				this._tags = tagString.split(",");
			} else {
				this._tags = new Array();
			}
			if (xml.@xscale > 0 && xml.@yscale > 0) {
				this._scaleX = Number(xml.@xscale);
				this._scaleY = Number(xml.@yscale);
			}
			if (xml.@hxscale > 0 && xml.@hyscale > 0) {
				this._headScaleX = Number(xml.@hxscale);
				this._headScaleY = Number(xml.@hyscale);
			}
			this._headDX = xml.@headdx != 0 ? Number(xml.@headdx) : 0;
			this._headDY = xml.@headdy != 0 ? Number(xml.@headdy) : 0;

			this.removeAllUserChosenComponent();
			for each (child in xml.child(CcComponent.XML_NODE_NAME)) {
				var type:String = CcComponent.getComponentThumbTypeFromXml(child);
				if (type == CcLibConstant.COMPONENT_TYPE_BODYSHAPE) {
					var themeId:String = CcComponent.getComponentThemeIdFromXml(child);
					var cptId:String = CcComponent.getComponentIdFromXml(child);
					this._bodyShape = (components.getValueByKey(themeId) as CcTheme).getBodyShapeByShapeId(cptId);
					this.currentTheme = components.getValueByKey(themeId) as CcTheme;
					var bsCpt:CcComponent = new CcComponent();
					bsCpt.componentThumb = CcComponentThumb.createBodyShapeComponentThumb(this.bodyShape);
					this.addUserChosenComponent(bsCpt);
				} else {
					component = new CcComponent();
					component.deserialize(child, components);
					this.addUserChosenComponent(component);
				}
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
				var cptThumb:CcComponentThumb = this.currentTheme.getComponentThumbByInternalId(CcComponentThumb.generateInternalId(child.@type, child.@component_id));
				if (cptThumb) {
					child.@money = cptThumb.money;
					child.@sharing = cptThumb.sharingPoint;
				}
				library.deserialize(child);
				this.addUserChosenLibrary(library);
			}

			if (this.getUserChosenLibraryNum() > 0) {
				this.ver = 2;
			} else {
				this.ver = 1;
			}
		}

		public function getComponentTypeOrdering() : Array
		{
			if (this._ver == 1) {
				return CcLibConstant.COMPONENT_TYPE_CHOOSER_ORDERING_VER1;
			}
			if (this._ver == 2) {
				return CcLibConstant.COMPONENT_TYPE_CHOOSER_ORDERING_VER2;
			}
			return null;
		}
	}
}
