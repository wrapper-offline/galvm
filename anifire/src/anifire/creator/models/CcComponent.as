package anifire.creator.models
{
	import anifire.constant.CcLibConstant;
	import anifire.util.Util;
	import anifire.util.UtilHashArray;

	public class CcComponent
	{
		public static const XML_NODE_NAME:String = "component";
		public static const XML_TAG_NODE_NAME:String = "tag";
		public static const XML_TEMPLATE_NAME:String = "apply-template";
		public var id:String;
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _xscale:Number = 1;
		private var _yscale:Number = 1;
		private var _offset:Number = 0;
		private var _rotation:Number = 0;
		private const _max:Number = 100;
		private const _min:Number = -100;
		private const _maxScale:Number = 10;
		private const _minScale:Number = -10;
		private const _maxRotate:Number = 180;
		private const _minRotate:Number = -180;
		private var _split:Boolean = true;
		public var componentThumb:CcComponentThumb;

		public function CcComponent()
		{
			super();
			this.id = "ID" + Math.round(Math.random() * 10000);
		}

		public static function getIdFromXml(xml:XML) : String
		{
			return xml.@id;
		}

		public static function getComponentThumbTypeFromXml(xml:XML) : String
		{
			return xml.@type;
		}

		public static function getComponentThemeIdFromXml(xml:XML) : String
		{
			return xml.@theme_id;
		}

		public static function getComponentIdFromXml(xml:XML) : String
		{
			return xml.@component_id;
		}

		public function get split() : Boolean
		{
			if (this.componentThumb) {
				return this.componentThumb.split;
			}
			return this._split;
		}
		public function set split(value:Boolean) : void
		{
			this._split = value;
		}

		public function clone() : CcComponent
		{
			var cloned:CcComponent = new CcComponent();
			cloned.x = this.x;
			cloned.y = this.y;
			cloned.xscale = this.xscale;
			cloned.yscale = this.yscale;
			cloned.offset = this.offset;
			cloned.rotation = this.rotation;
			cloned.split = this.split;
			cloned.componentThumb = this.componentThumb;
			cloned.id = this.id;
			return cloned;
		}

		public function set x(value:Number) : void
		{
			this._x = value;
			if (this._x > this._max) {
				this._x = this._max;
			}
			if (this._x < this._min) {
				this._x = this._min;
			}
		}
		public function get x() : Number
		{
			return this._x;
		}

		public function set y(value:Number) : void
		{
			this._y = value;
			if (this._y > this._max) {
				this._y = this._max;
			}
			if (this._y < this._min) {
				this._y = this._min;
			}
		}
		public function get y() : Number
		{
			return this._y;
		}

		public function set xscale(value:Number) : void
		{
			this._xscale = value;
			if (this._xscale > this._maxScale) {
				this._xscale = this._maxScale;
			}
			if (this._xscale < this._minScale) {
				this._xscale = this._minScale;
			}
			this._xscale = Util.roundNum(this._xscale, 2);
		}
		public function get xscale() : Number
		{
			return this._xscale;
		}

		public function set yscale(value:Number) : void
		{
			this._yscale = value;
			if (this._yscale > this._maxScale) {
				this._yscale = this._maxScale;
			}
			if (this._yscale < this._minScale) {
				this._yscale = this._minScale;
			}
			this._yscale = Util.roundNum(this._yscale, 2);
		}
		public function get yscale() : Number
		{
			return this._yscale;
		}

		public function set offset(value:Number) : void
		{
			this._offset = value;
			if (this._offset > this._max) {
				this._offset = this._max;
			}
			if (this._offset < this._min) {
				this._offset = this._min;
			}
		}
		public function get offset() : Number
		{
			return this._offset;
		}

		public function set rotation(value:Number) : void
		{
			this._rotation = value;
			if (this._rotation > this._maxRotate) {
				this._rotation = this._maxRotate;
			}
			if (this._rotation < this._minRotate) {
				this._rotation = this._minRotate;
			}
		}
		public function get rotation() : Number
		{
			return this._rotation;
		}

		public function get userChosenComponentId() : String
		{
			return this.componentThumb.componentId;
		}

		/**
		 * jesus this is ugly
		 */
		public function serialize() : String
		{
			var idAttr:String = CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(this.componentThumb.type) > -1 ?
				" id=\"" + this.id + "\"" :
				"";
			var splitAttr:String = "";
			if (!this.split) {
				splitAttr = " split=\"N\"";
			}
			return "<" + XML_NODE_NAME + idAttr + " type=\"" + this.componentThumb.type + "\"" + " component_id=\"" + this.componentThumb.componentId + "\"" + " theme_id=\"" + this.componentThumb.themeId + "\"" + " x=\"" + this.x + "\"" + " y=\"" + this.y + "\"" + " xscale=\"" + this.xscale + "\"" + " yscale=\"" + this.yscale + "\"" + " offset=\"" + this.offset + "\"" + " rotation=\"" + this.rotation + "\"" + splitAttr + "/>";
		}

		public function deserialize(xml:XML, ccThemes:UtilHashArray) : void
		{
			this.id = getIdFromXml(xml);
			var themeId:String = getComponentThemeIdFromXml(xml);
			var type:String = getComponentThumbTypeFromXml(xml);
			var cptId:String = getComponentIdFromXml(xml);
			var ccTheme:CcTheme = ccThemes.getValueByKey(themeId) as CcTheme;
			if (CcLibConstant.ALL_BODY_COMPONENT_TYPES.indexOf(type) >= 0) {
				this.componentThumb = ccTheme.getComponentThumbWithinBodyshapeByType(type)
					.getValueByKey(CcComponentThumb.generateInternalId(type, cptId)) as CcComponentThumb;
			} else {
				this.componentThumb = ccTheme.getComponentThumbByType(type)
					.getValueByKey(CcComponentThumb.generateInternalId(type, cptId)) as CcComponentThumb;
			}
			this.x = xml.@x;
			this.y = xml.@y;
			this.xscale = xml.@xscale;
			this.yscale = xml.@yscale;
			this.offset = xml.@offset;
			this.rotation = xml.@rotation;
			this.split = String(xml.@split) == "N" ? false : true;
		}
	}
}
