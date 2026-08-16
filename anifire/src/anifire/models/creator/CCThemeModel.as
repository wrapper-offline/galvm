package anifire.models.creator
{
	import anifire.constant.CcLibConstant;
	import anifire.util.UtilNetwork;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	
	public class CCThemeModel extends EventDispatcher
	{
		/** Seems to have enabled parsing of data useful to Creator. */
		public var runwayMode:Boolean;

		public var themeId:String;
		public var defaultBodyShape:CCBodyShapeModel;
		public var bodyShapes:Object;
		public var components:Object;
		public var faces:Object;

		/** Whether the theme has finished parsing. */
		public var completed:Boolean = false;

		/** Used to download the theme XML. */
		protected var loader:URLLoader;

		/**
		 * Contains cached action models for specific bodies.<br/>
		 * <br/>
		 * Entries are pairs of asset IDs and Objects that store
		 * <code>CCCharacterActionModel</code>s indexed by their action ID.
		 */
		private var _actionModels:Object;

		public function CCThemeModel(themeId:String)
		{
			super();
			this.themeId = themeId;
			this.bodyShapes = {};
			this.faces = {};
			this.components = {};
			this._actionModels = {};
		}

		public function load() : void
		{
			if (!this.loader) {
				this.loader = new URLLoader();
				this.loader.addEventListener(Event.COMPLETE, this.onLoaderComplete);
				this.loader.load(UtilNetwork.getGetCcThemeRequest(this.themeId));
			}
		}

		protected function onLoaderComplete(event:Event) : void
		{
			this.loader.removeEventListener(Event.COMPLETE, this.onLoaderComplete);
			this.parse(XML(this.loader.data));
		}

		/**
		 * Parses all children in a theme XML.
		 */
		public function parse(themeNode:XML) : void
		{
			var children:XMLList = themeNode.children();
			var numChildren:int = children.length();
			for (var child:XML, i:int = 0; i < numChildren; i++) {
				child = children[i];
				var tagName:String = child.localName() as String;
				switch (tagName) {
					case "facial":
						var face:CCFaceModel = new CCFaceModel();
						face.parse(child);
						this.faces[face.id] = face;
						break;
					case "bodyshape":
						var bs:CCBodyShapeModel = new CCBodyShapeModel(this);
						bs.parse(child);
						if (!this.defaultBodyShape) {
							this.defaultBodyShape = bs;
						}
						this.bodyShapes[bs.bodyShapeId] = bs;
						break;
					case "component":
						var component:CCComponentModel = new CCComponentModel(this.runwayMode);
						component.parse(child);
						this.storeSharedComponent(component);
				}
			}
			this.completed = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}

		/**
		 * Returns an Object containing every action of a body shape.
		 * @param bsId Body shape ID
		 */
		public function getActions(bsId:String) : Object
		{
			var bs:CCBodyShapeModel = this.bodyShapes[bsId];
			if (bs) {
				return bs.actions;
			}
			return null;
		}

		protected function componentUniqueId(type:String, id:String) : String
		{
			return type + ":" + id;
		}

		protected function storeSharedComponent(component:CCComponentModel) : void
		{
			var uniqueId:String = this.componentUniqueId(component.type, component.id);
			this.components[uniqueId] = component;
		}

		protected function getSharedComponent(type:String, id:String) : CCComponentModel
		{
			var uniqueId:String = this.componentUniqueId(type, id);
			return this.components[uniqueId];
		}

		protected function getComponent(bs:CCBodyShapeModel, type:String, id:String) : CCComponentModel
		{
			var component:CCComponentModel = bs.getComponent(type, id);
			if (!component) {
				component = this.getSharedComponent(type, id);
			}
			return component;
		}

		public function createCharacterActionModel(body:CCBodyModel, action:CCActionModel) : CCCharacterActionModel
		{
			var bs:CCBodyShapeModel = this.bodyShapes[body.bodyShapeId];
			if (!this.runwayMode) {
				var cams:Object = this._actionModels[body.assetId];
				if (cams) {
					// i'm not quite sure how shortId ended up being used here,
					// BUT we're going for 100% accuracy, so it's staying like this
					var existingCam:CCCharacterActionModel = cams[shortId];
					if (existingCam) {
						return existingCam;
					}
				}
			}
			var bsExists:CCBodyShapeModel = this.bodyShapes[body.bodyShapeId];
			if (!bsExists) {
				return null;
			}
			var cam:CCCharacterActionModel = new CCCharacterActionModel();
			cam.actionModel = action;
			cam.enabled = action.enabled;
			var shortId:String = action.shortId;
			var states:Object = action.componentStates;
			for (var type:String in states) {
				var bodyComponent:CCBodyComponentModel;
				var freeaction:CCComponentModel;
				var componentId:String;
				var component:CCComponentModel;
				if (type == "freeaction") {
					freeaction = this.getComponent(bs, "freeaction", shortId);
					if (freeaction) {
						bodyComponent = body.getComponentId("freeaction") as CCBodyComponentModel;
						cam.addComponent(bodyComponent, shortId + ".swf", this.themeId + "/freeaction/" + bodyComponent.folder + "/" + shortId + ".swf");
						cam.freeactionFolderName = bodyComponent.folder;
					}
				} else if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(type) > -1) {
					var bodyComponents:Object = body.getComponentId(type);
					for (var bcIndex:String in bodyComponents) {
						bodyComponent = bodyComponents[bcIndex] as CCBodyComponentModel;
						if (bodyComponent) {
							componentId = bodyComponent.component_id;
							component = this.getComponent(bs, type, componentId);
							if (component) {
								cam.addComponent(bodyComponent, component.getFilenameByState(states[type]), this.themeId + "/" + component.getPathByState(states[type]));
							}
						}
					}
				} else {
					bodyComponent = body.getComponentId(type) as CCBodyComponentModel;
					if (bodyComponent) {
						componentId = bodyComponent.component_id;
						component = this.getComponent(bs, type, componentId);
						if (component) {
							cam.addComponent(bodyComponent,component.getFilenameByState(states[type]), this.themeId + "/" + component.getPathByState(states[type]));
						}
					}
				}
			}
			var libraries:Object = body.libraries;
			for (var libType:String in libraries) {
				var libId:String = body.getLibraryId(libType);
				var library:CCLibraryModel = bs.getLibrary(libType, libId);
				if (library) {
					cam.addLibrary(libType, this.themeId + "/" + library.getPath());
				}
			}
			var colors:Object = body.colors;
			for (var colorI:String in colors) {
				cam.addColor(colorI, colors[colorI]);
			}
			cam.bodyScale.scalex = body.bodyScale.scalex;
			cam.bodyScale.scaley = body.bodyScale.scalex;
			cam.headScale.scalex = body.headScale.scalex;
			cam.headScale.scaley = body.headScale.scaley;
			cam.headPos.dx = body.headPos.dx;
			cam.headPos.dy = body.headPos.dy;
			cam.version = body.version;
			if (!cam.propXML) {
				cam.propXML = action.propXML;
			}
			cam.themeId = this.themeId;
			cam.defaultActionId = bs.defaultActionId;
			return cam;
		}

		protected function getCache(assetId:String, actionId:String) : CCCharacterActionModel
		{
			var cams:Object = this._actionModels[assetId];
			if (cams) {
				return cams[actionId];
			}
			return null;
		}

		protected function putCache(assetId:String, actionId:String, cam:CCCharacterActionModel) : void
		{
			if (!this._actionModels[assetId]) {
				this._actionModels[assetId] = {};
			}
			this._actionModels[assetId][actionId] = cam;
		}

		public function getCharacterActionModel(body:CCBodyModel, actionId:String) : CCCharacterActionModel
		{
			var cam:CCCharacterActionModel = this.getCache(body.assetId, actionId);
			if (cam) {
				return cam;
			}
			var bs:CCBodyShapeModel = this.bodyShapes[body.bodyShapeId];
			if (!bs) {
				return null;
			}
			var action:CCActionModel = bs.actions[actionId];
			if (action) {
				cam = this.createCharacterActionModel(body, action);
			}
			this.putCache(body.assetId, actionId, cam);
			return cam;
		}

		public function getCharacterFacialModel(body:CCBodyModel, facialId:String) : CCCharacterActionModel
		{
			var cam:CCCharacterActionModel = this.getCache(body.assetId, facialId);
			if (cam) {
				return cam;
			}
			var bs:CCBodyShapeModel = this.bodyShapes[body.bodyShapeId];
			if (!bs) {
				return null;
			}
			cam = new CCCharacterActionModel();
			facialId = facialId.split(".")[0];
			var face:CCFaceModel = this.faces[facialId];
			if (face) {
				var states:Object = face.componentStates;
				for (var type:String in states) {
					var bodyComponent:CCBodyComponentModel;
					var componentId:String;
					var component:CCComponentModel;
					if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(type) > -1) {
						var bodyComponents:Object = body.getComponentId(type);
						for (var bcIndex:String in bodyComponents) {
							bodyComponent = bodyComponents[bcIndex] as CCBodyComponentModel;
							if (bodyComponent) {
								componentId = bodyComponent.component_id;
								component = this.getComponent(bs, type, componentId);
								if (component) {
									cam.addComponent(bodyComponent, component.getFilenameByState(states[type]), this.themeId + "/" + component.getPathByState(states[type]));
								}
							}
						}
					} else {
						bodyComponent = body.getComponentId(type) as CCBodyComponentModel;
						if (bodyComponent) {
							componentId = bodyComponent.component_id;
							component = this.getComponent(bs, type, componentId);
							if (component) {
								cam.addComponent(bodyComponent, component.getFilenameByState(states[type]), this.themeId + "/" + component.getPathByState(states[type]));
							}
						}
					}
				}
				var colors:Object = body.colors;
				for (var colorI:String in colors) {
					cam.addColor(colorI, colors[colorI]);
				}
				cam.version = body.version;
				cam.themeId = this.themeId;
			}
			this.putCache(body.assetId, facialId, cam);
			return cam;
		}

		public function getCharacterDefaultActionId(bsId:String) : String
		{
			var bs:CCBodyShapeModel = this.bodyShapes[bsId];
			return bs.defaultActionId;
		}

		public function getCharacterDefaultMotionId(bsId:String) : String
		{
			var bs:CCBodyShapeModel = this.bodyShapes[bsId];
			return bs.defaultMotionId;
		}
	}
}
