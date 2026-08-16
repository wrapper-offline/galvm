package anifire.models.creator
{
	import anifire.constant.CcLibConstant;

	public class CCBodyShapeModel
	{
		protected var themeModel:CCThemeModel;	
		public var bodyShapeId:String;
		public var components:Object;
		public var libraries:Object;
		public var actions:Object;
		public var runwayMode:Boolean;
		public var defaultCharacterXML:Vector.<XML>;
		public var defaultActionId:String;
		public var defaultMotionId:String;
		public var defaultFaceId:String;

		/**
		 * Stores the amount of actions per category, indexed by category ID.
		 */
		public var actionCategories:Object;

		public function CCBodyShapeModel(parentTheme:CCThemeModel)
		{
			super();
			this.themeModel = parentTheme;
			this.components = {};
			this.libraries = {};
			this.actions = {};
			if (parentTheme.runwayMode) {
				this.runwayMode = true;
				this.defaultCharacterXML = new Vector.<XML>();
				this.actionCategories = {};
			}
		}

		public function parse(bsNode:XML) : void
		{
			this.bodyShapeId = bsNode.@id;
			this.defaultActionId = bsNode.@default_action + ".xml";
			this.defaultMotionId = bsNode.@default_motion + ".xml";
			this.defaultFaceId = bsNode.@facial_thumb;
			var children:XMLList = bsNode.children();
			var numChildren:int = children.length();
			for (var i:int = 0; i < numChildren; i++) {
				this.processNode(children[i]);
			}
		}

		protected function processNode(node:XML) : void
		{
			var tagName:String = node.localName() as String;
			switch (tagName) {
				case "actionpack":
					this.processActionPackNode(node);
					break;
				case "component":
					this.processComponentNode(node);
					break;
				case "library":
					this.processLibraryNode(node);
					break;
				case "action":
					this.createAction(node);
					break;
				case "default_char":
					if (this.runwayMode) {
						this.defaultCharacterXML.push(node);
					}
			}
		}

		protected function processComponentNode(componentNode:XML) : void
		{
			var component:CCComponentModel = new CCComponentModel(this.runwayMode);
			component.parse(componentNode);
			this.storeComponent(component);
		}

		protected function processLibraryNode(libNode:XML) : void
		{
			var library:CCLibraryModel = new CCLibraryModel(this.runwayMode);
			library.parse(libNode);
			this.storeLibrary(library);
		}

		protected function processActionPackNode(apNode:XML) : void
		{
			var children:XMLList = apNode.children();
			var numChildren:int = children.length();
			for (var i:int = 0; i < numChildren; i++) {
				this.createAction(children[i], apNode.@enable != "N");
			}
		}

		private function createAction(actionElem:XML, packEnabled:Boolean = true) : void
		{
			var action:CCActionModel = new CCActionModel();
			action.id = actionElem.@id + ".xml";
			action.name = actionElem.@name;
			action.isMotion = actionElem.@is_motion == "Y";
			action.isLoop = actionElem.@loop == "Y";
			action.totalframe = actionElem.@totalframe;
			action.category = actionElem.@category;
			action.enabled = packEnabled && actionElem.@enable != "N";
			if (this.runwayMode && Boolean(action.category)) {
				var numActions = int(this.actionCategories[action.category]);
				numActions = numActions + 1;
				this.actionCategories[action.category] = numActions;
			}
			var _loc4_:String = actionElem.@next as String;
			if ("@next" in actionElem) {
				action.nextActionId = actionElem.@next + ".xml";
			}
			var selections:XMLList = actionElem.selection;
			var numSels:int = selections.length();
			for (var selI:int = 0; selI < numSels; selI++) {
				var componentType:String = selections[selI].@type;
				if (componentType == "facial") {
					// flatten face selections into the action
					var faceId:String = selections[selI].@facial_id;
					action.defaultFacialId = faceId + ".xml";
					var face:CCFaceModel = this.themeModel.faces[faceId];
					if (face) {
						var states:Object = face.componentStates;
						for (var stateI:String in states) {
							action.addComponent(stateI, states[stateI]);
						}
					}
				} else {
					action.addComponent(componentType, selections[selI].@state_id);
				}
			}
			if (actionElem.prop.length() > 0) {
				action.propXML = actionElem.prop;
			}
			if (CcLibConstant.CHAR_WITH_FREEACTION(this.themeModel.themeId)) {
				action.addComponent("freeaction", actionElem.@id);
				var component:CCComponentModel = new CCComponentModel(this.runwayMode);
				component.id = actionElem.@id;
				component.type = "freeaction";
				this.storeComponent(component);
			}
			this.actions[action.id] = action;
		}

		/** Deprecated */
		protected function createDefaultCharacter(_unused:XML) : void
		{
		}
		
		private function componentUniqueId(type:String, id:String) : String
		{
			return type + ":" + id;
		}

		public function storeComponent(component:CCComponentModel) : void
		{
			var uniqueId:String = this.componentUniqueId(component.type, component.id);
			this.components[uniqueId] = component;
		}

		public function getComponent(type:String, id:String) : CCComponentModel
		{
			var uniqueId:String = this.componentUniqueId(type, id);
			return this.components[uniqueId];
		}

		public function storeLibrary(library:CCLibraryModel) : void
		{
			var uniqueId:String = this.componentUniqueId(library.type, library.id);
			this.libraries[uniqueId] = library;
		}

		public function getLibrary(type:String, id:String) : CCLibraryModel
		{
			var uniqueId:String = this.componentUniqueId(type, id);
			return this.libraries[uniqueId];
		}

		/**
		 * Returns the body shape ID.
		 */
		public function toString() : String
		{
			return this.bodyShapeId;
		}
	}
}
