package anifire.browser.core
{
	import anifire.browser.events.CoreEvent;
	import anifire.browser.interfaces.IBehavior;
	import anifire.browser.interfaces.ITheme;
	import anifire.browser.interfaces.IThumb;
	import anifire.browser.utils.UtilHashThumb;
	import anifire.constant.ProductConstants;
	import anifire.constant.ThemeConstants;
	import anifire.managers.CCThemeManager;
	import anifire.models.creator.CCThemeModel;
	import anifire.util.UtilErrorLogger;
	import anifire.util.UtilHashArray;
	import anifire.util.UtilNetwork;
	import anifire.util.UtilXmlInfo;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.setTimeout;
	
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;
	
	import nochump.util.zip.ZipFile;
	
	public class Theme extends EventDispatcher implements ITheme
	{
		private var _id:String;
		private var _ccThemeId:String = "";
		private var _name:String;
		private var _backgroundThumbs:UtilHashThumb;
		private var _charThumbs:UtilHashThumb;
		private var _bubbleThumbs:UtilHashThumb;
		private var _propThumbs:UtilHashThumb;
		private var _soundThumbs:UtilHashThumb;
		private var _effectThumbs:UtilHashThumb;
		private var _themeXML:XML;
		private var _nodeIndex:int;
		private var _totalNodes:int;
		private var _nodes:XMLList;
		private var isMovieTheme:Boolean;
		
		public function Theme()
		{
			super();
			this._backgroundThumbs = new UtilHashThumb();
			this._charThumbs = new UtilHashThumb();
			this._bubbleThumbs = new UtilHashThumb();
			this._propThumbs = new UtilHashThumb();
			this._soundThumbs = new UtilHashThumb();
			this._effectThumbs = new UtilHashThumb();
			this._themeXML = null;
		}

		/**
		 * Clears the theme.
		 */
		public function clearAllThumbs() : void
		{
			this._charThumbs.removeAll();
			this._backgroundThumbs.removeAll();
			this._propThumbs.removeAll();
			this._effectThumbs.removeAll();
			this._soundThumbs.removeAll();
			this._bubbleThumbs.removeAll();
		}
		
		public function doOutputThumbs(param1:XML) : UtilHashArray
		{
			return null;
		}

		public function getPropThumbById(param1:String) : IThumb
		{
			return null;
		}
		
		public function getThemeXML() : XML
		{
			return this._themeXML;
		}
		
		/**
		 * if the theme xml isn't already set, it sets it. otherwise, i'm not sure what this does.
		 * i think it merges the already set xml with the xml argument but i have no idea why it would need to do that
		 */
		private function setThemeXML(xml:XML) : void
		{
			if (this._themeXML == null)
			{
				this._themeXML = xml;
			}
			else if (this._themeXML != xml)
			{
				this.mergeThemeXML(xml);
			}
		}
		
		/**
		 * i think what this function does is pretty self-explanatory, but again
		 * i don't know why it would need to merge 2 theme xmls. when does this happen
		 */
		public function mergeThemeXML(xml:XML) : void
		{
			var _loc2_:int = 0;
			var _loc3_:XML = null;
			if (this._themeXML == null)
			{
				this._themeXML = xml;
				return;
			}
			this._themeXML = merge2ThemeXml(this._themeXML, xml, this.id, this.name, true);
		}

		public function get ccThemeId() : String
		{
			return this._ccThemeId;
		}
		
		public function set id(id:String) : void
		{
			this._id = id;
		}
		
		public function get id() : String
		{
			return this._id;
		}
		
		public function get name() : String
		{
			return this._name;
		}
		
		public function get charThumbs() : UtilHashThumb
		{
			return this._charThumbs;
		}

		/**
		 * Initialize by retrieving a zipped theme XML.
		 */
		public function initThemeByLoadThemeFile(themeId:String) : void
		{
			this._id = themeId;
			this.loadXML();
		}
		
		/**
		 * Initialize by using a theme XML.
		 */
		public function initThemeByXml(themeId:String, xml:XML) : void
		{
			this._id = themeId;
			this.deSerialize(xml, false);
		}

		/**
		 * and then this is in a separate function because why the hell not
		 * do we just not have access to UtilXmlInfo? i don't think so
		 */
		public static function merge2ThemeXml(xml:XML, xml2:XML, id:String, name:String, ihavenoidea:Boolean = false) : XML
		{
			return UtilXmlInfo.merge2ThemeXml(xml, xml2, id, name, ihavenoidea);
		}

		/**
		 * Adds a Thumb to its respective UtilHashThumb if it doesn't exist.
		 */
		public function addThumb(thumb:Thumb, xml:XML = null) : void
		{
			var charThumb:CharThumb = null;
			if (!this._themeXML)
			{
				this._themeXML = UtilXmlInfo.createThemeXml(this._id, this._name);
			}
			if (xml)
			{
				this._themeXML.appendChild(xml);
			}
			if (thumb is CharThumb)
			{
				charThumb = this._charThumbs.getValueByKey(thumb.id) as CharThumb;
				if (!charThumb)
				{
					this._charThumbs.push(thumb.id, thumb);
				}
			}
		}

		/**
		 * This is a heavily cut down version of the studio's deserializeThumb function.
		 * This one is only capable of deserializing character thumbs.
		 */
		private function deserializeThumb(node:XML, isMovieTheme:Boolean = false) : void
		{
			var tagName:String = String(node.name().localName);
			if (tagName == CharThumb.XML_NODE_NAME)
			{
				var charThumb:CharThumb = new CharThumb();
				charThumb.deSerialize(node, this);
				this.addThumb(charThumb);
			}
		}

		/**
		 * Begin parsing the theme XML.
		 */
		public function deSerialize(xml:XML, isMovieTheme:Boolean = false) : void
		{
			var _loc3_:XMLList;
			var _loc4_:XML;
			var _loc5_:int;
			// extract the main data
			this.setThemeXML(xml);
			this.id = xml.@id;
			this._ccThemeId = xml.@cc_theme_id;
			this.isMovieTheme = isMovieTheme;
			this._nodes = xml.children();
			this._totalNodes = this._nodes.length();
			this._nodeIndex = 0;
			UtilErrorLogger.getInstance().info("Deserialize Theme XML nodes: " + this._totalNodes);
			addEventListener(CoreEvent.DESERIALIZE_THEME_COMPLETE, this.onDeserializeComplete);
			// start actually going through the assets
			this.doNextPrepare();
		}

		/**
		 * Loops through 32 XML nodes, wait 5ms, and repeats itself.
		 */
		private function doNextPrepare() : void
		{
			// check if we've gone through the entire xml
			if (this._nodeIndex >= this._totalNodes)
			{
				dispatchEvent(new CoreEvent(CoreEvent.DESERIALIZE_THEME_COMPLETE, this));
				return;
			}
			// parse 32 nodes, wait 5 ms and repeat
			var _loc1_:int = this._nodeIndex + 32;
			while (this._nodeIndex < _loc1_ && this._nodeIndex < this._totalNodes)
			{
				this.deserializeThumb(this._nodes[this._nodeIndex], this.isMovieTheme);
				++this._nodeIndex;
			}
			setTimeout(this.doNextPrepare, 5);
		}
		
		public function getThumbNodeFromThemeXML(param1:XML, param2:Thumb) : XML
		{
			var themeXML:XML = param1;
			var thumb:Thumb = param2;
			var nodeName:String = "";
			if(thumb is CharThumb)
			{
				nodeName = CharThumb.XML_NODE_NAME;
			}
			return themeXML.child(nodeName).(@id == thumb.id)[0];
		}
		
		public function setThumbNodeFromXML(param1:XML, param2:String) : XML
		{
			var cxml:XML = param1;
			var idd:String = param2;
			if(this._themeXML != null)
			{
				this._themeXML.children().(@id == idd)[0] = cxml;
				return this._themeXML.children().(@id == idd)[0];
			}
			return null;
		}

		private function onLoadThemeXmlError(e:Event) : void
		{
			UtilErrorLogger.getInstance().appendCustomError("onLoadThemeXmlError: " + this.id);
			UtilErrorLogger.getInstance().fatal("Error: Load theme failed.");
		}
		
		private function doLoadXMLComplete(e:Event) : void
		{
			(e.target as IEventDispatcher).removeEventListener(e.type,this.doLoadXMLComplete);
			var urlLoader:URLLoader = e.target as URLLoader;
			this.doLoadXMLBytesComplete(urlLoader.data as ByteArray);
		}
		
		public function isStateExists(param1:XML, param2:IBehavior) : Boolean
		{
			var _loc3_:Boolean = false;
			var _loc4_:String;
			var _loc5_:String;
			var _loc6_:Theme;
			var _loc7_:String;
			var _loc8_:String;
			var _loc9_:String;
			var _loc10_:XMLListCollection = new XMLListCollection(param1.children());
			var _loc11_:Sort = new Sort();
			_loc11_.fields = [new SortField("@index",true,false,true)];
			_loc10_.sort = _loc11_;
			_loc10_.refresh();
			param1.setChildren(_loc10_.copy());
			return _loc3_;
		}

		/**
		 * Extracts the XML from the theme zip.
		 */
		private function doLoadXMLBytesComplete(themeZip:IDataInput) : void
		{
			var _loc2_:ZipFile = new ZipFile(themeZip);
			this.deSerialize(new XML(_loc2_.getInput(_loc2_.getEntry("theme.xml"))));
		}

		/**
		 * alright we're done
		 */
		private function onDeserializeComplete(event:CoreEvent) : void
		{
			removeEventListener(CoreEvent.DESERIALIZE_THEME_COMPLETE, this.onDeserializeComplete);
			// nvm we're not done we still have to parse the cctheme
			if (this._ccThemeId)
			{
				var ccThemeModel:CCThemeModel = CCThemeManager.instance.getThemeModel(this._ccThemeId);
				if (!ccThemeModel.completed)
				{
					UtilErrorLogger.getInstance().info("Load CC Theme Model: " + this._ccThemeId);
					ccThemeModel.addEventListener(Event.COMPLETE, this.onThemeModelComplete);
					ccThemeModel.load();
					return;
				}
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}

		private function onThemeModelComplete(e:Event) : void
		{
			(e.currentTarget as CCThemeModel).removeEventListener(Event.COMPLETE, this.onThemeModelComplete);
			dispatchEvent(new Event(Event.COMPLETE));
		}

		/**
		 * Retrieves the zipped theme XML from the server.
		 */
		private function loadXML() : void
		{
			var urlRequest:URLRequest = UtilNetwork.getGetThemeRequest(this.id, false);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, this.doLoadXMLComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onLoadThemeXmlError);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onLoadThemeXmlError);
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.load(urlRequest);
		}
		
		public function isThumbExist(param1:Thumb) : Boolean
		{
			if (param1 is CharThumb && Boolean(this.getCharThumbById(param1.id)))
			{
				return true;
			}
			return false;
		}
		
		public function getCharThumbById(key:String) : CharThumb
		{
			return this._charThumbs.getValueByKey(key) as CharThumb;
		}

		/**
		 * Merges this Theme with another Theme.
		 */
		public function mergeTheme(theme:Theme) : void
		{
			if (theme != null)
			{
				var index:int = 0;
				index = 0;
				while (index < theme.charThumbs.length)
				{
					theme.getCharThumbById(theme.charThumbs.getKey(index)).theme = this;
					this.addThumb(theme.getCharThumbById(theme.charThumbs.getKey(index)));
					index++;
				}
			}
		}

		// iii'm not sure what products are yet
		public function getProducts(param1:String = null) : Array
		{
			var _loc2_:Array = new Array();
			if(param1)
			{
				switch(param1)
				{
					case ProductConstants.PRODUCT_TYPE_CHARACTER:
						_loc2_ = _loc2_.concat(this.charThumbs.getArray());
				}
			}
			return _loc2_;
		}

		// wonder why whiteboard wasn't included in this
		public function get isBusinessTheme() : Boolean
		{
			switch (this._id)
			{
				case ThemeConstants.BUSINESS_THEME_ID:
				case ThemeConstants.BIZ_MODEL_THEME_ID:
				case ThemeConstants.STICKLY_BIZ_THEME_ID:
					return true;
				default:
					return false;
			}
		}

		public function get isCCTheme() : Boolean
		{
			return this._ccThemeId != "";
		}

		/**
		 * I think this function is used by the studio to determine whether or not the create character button should be shown.
		 * Haven't confirmed it yet.
		 */
		// TODO: ^^^ see if this is true
		// TODO 2: add a tag to the theme xml that determines this, as i wanna cut down on hardcoded shit
		public function get isUserCreateEnable() : Boolean
		{
			switch (this._id)
			{
				case ThemeConstants.BUSINESS_THEME_ID:
				case ThemeConstants.COMEDY_WORLD_THEME_ID:
				case ThemeConstants.LIL_PEEPZ_THEME_ID:
				case ThemeConstants.ANIME_THEME_ID:
				case ThemeConstants.NINJAANIME_THEME_ID:
				case ThemeConstants.CHIBI_THEME_ID:
				case ThemeConstants.NINJA_THEME_ID:
					return true;
				default:
					return false;
			}
		}
	}
}
