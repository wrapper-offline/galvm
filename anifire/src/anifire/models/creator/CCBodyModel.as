package anifire.models.creator
{
	import anifire.constant.CcLibConstant;
	import anifire.constant.ServerConstants;
	import anifire.managers.AppConfigManager;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * The CCBodyModel class represents a custom character body.
	 */
	public class CCBodyModel extends EventDispatcher
	{
		/**
		 * All property keys are component types. Property values can be either
		 * a <code>Vector.&lt;CCBodyComponentModel&gt;</code> or a
		 * <code>CCBodyComponentModel</code>, depending on whether the
		 * component type supports multiselection or not.
		 */
		public var components:Object;

		public var libraries:Object;
		public var colors:Object;
		public var bodyScale:Object;
		public var headScale:Object;
		public var headPos:Object;

		/** Whether the character body has finished parsing. */
		public var completed:Boolean = false;

		/** Character asset ID. */
		public var assetId:String;

		/**
		 * Specifies how the character should be animated.<br/>
		 * <br/>
		 * <code>1</code>: Skeleton<br/>
		 * <code>2</code>: Freeaction
		 */
		public var version:Number;

		public var bodyShapeId:String;

		/** CC theme ID of the character. */
		public var themeId:String;

		/** Original character body XML. */
		public var source:XML;

		/** Used to download the character body XML. */
		protected var loader:URLLoader;

		public function CCBodyModel(param1:String)
		{
			super();
			this.assetId = param1;
			this.components = {};
			this.libraries = {};
			this.colors = {};
			this.bodyScale = {};
			this.headScale = {};
			this.headPos = {};
			this.version = 1;
		}

		/**
		 * Downloads the character body from the API server.
		 */
		public function load() : void
		{
			if (!this.loader) {
				var request:URLRequest = new URLRequest(ServerConstants.ACTION_GET_CC_CHAR_COMPOSITION_XML);
				request.method = URLRequestMethod.POST;
				var variables:URLVariables = AppConfigManager.instance.createURLVariables();
				variables["assetId"] = this.assetId;
				request.data = variables;
				if (Boolean(this.assetId) && this.assetId != "") {
					this.loader = new URLLoader();
					this.loader.addEventListener(Event.COMPLETE, this.onLoaderComplete);
					this.loader.addEventListener(IOErrorEvent.IO_ERROR, this.onLoaderError);
					this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onLoaderError);
					this.loader.load(request);
				}
			}
		}
		protected function onLoaderComplete(event:Event) : void
		{
			this.loader.removeEventListener(Event.COMPLETE, this.onLoaderComplete);
			var response:String = this.loader.data;
			if (response.charAt(0) == "0") {
				this.parse(XML(response.substr(1)));
			} else {
				this.dispatchError();
			}
		}
		protected function onLoaderError(event:Event) : void
		{
			this.dispatchError();
		}

		protected function dispatchError() : void
		{
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
		}

		/**
		 * Parses a character body element.
		 */
		public function parse(bodyElem:XML) : void
		{
			var i:int = 0;
			var children:XMLList = bodyElem.component;
			var length:int = children.length();
			for (i = 0; i < length; i++) {
				var bodyComponent:CCBodyComponentModel = new CCBodyComponentModel();
				bodyComponent.parse(children[i]);
				if (bodyComponent.type == "bodyshape") {
					this.bodyShapeId = bodyComponent.component_id;
					this.themeId = bodyComponent.theme_id;
				}
				var bodyComponents:Vector.<CCBodyComponentModel>;
				if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(bodyComponent.type) > -1) {
					if (!this.components[bodyComponent.type]) {
						bodyComponents = this.components[bodyComponent.type] = new Vector.<CCBodyComponentModel>();
					} else {
						bodyComponents = this.components[bodyComponent.type];
					}
					bodyComponents.push(bodyComponent);
				} else {
					this.components[bodyComponent.type] = bodyComponent;
				}
			}
			children = bodyElem.library;
			length = children.length();
			for (i = 0; i < length; i++) {
				var libType:String = children[i].@type;
				var libId:String = children[i].@component_id;
				this.libraries[libType] = libId;
			}
			children = bodyElem.color;
			length = children.length();
			for (i = 0; i < length; i++) {
				var color:CCColor = new CCColor();
				color.parse(children[i]);
				if (color.targetComponent) {
					this.colors[color.type + color.targetComponent] = color;
				} else {
					this.colors[color.type] = color;
				}
			}
			this.bodyScale.scalex = Number(bodyElem.@xscale);
			this.bodyScale.scaley = Number(bodyElem.@yscale);
			this.headScale.scalex = Number(bodyElem.@hxscale);
			this.headScale.scaley = Number(bodyElem.@hyscale);
			this.headPos.dx = Number(bodyElem.@headdx);
			this.headPos.dy = Number(bodyElem.@headdy);
			this.version = Number(bodyElem.@version);
			this.source = bodyElem;
			this.completed = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function getColor(type:String) : CCColor
		{
			return this.colors[type];
		}

		/**
		 * Returns either a <code>Vector.&lt;CCBodyComponentModel&gt;</code> or
		 * a <code>CCBodyComponentModel</code>, depending on whether the
		 * component type supports multiselection or not. 
		 */
		public function getComponentId(type:String) : Object
		{
			return this.components[type];
		}

		/**
		 * Returns a library ID.
		 */
		public function getLibraryId(type:String) : String
		{
			return this.libraries[type];
		}
	}
}
