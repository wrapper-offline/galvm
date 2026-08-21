package anifire.models.creator
{
	import anifire.constant.CcLibConstant;

	public class CCCharacterActionModel
	{
		public var components:Object;
		public var libraryPaths:Object;
		public var colorCodes:Object;
		public var bodyScale:Object;
		public var headScale:Object;
		public var headPos:Object;
		public var version:Number;
		public var themeId:String;
		public var actionModel:CCActionModel;
		public var propXML:XMLList;
		public var defaultActionId:String;
		public var enabled:Boolean;
		public var freeactionFolderName:String;

		public function CCCharacterActionModel()
		{
			super();
			this.components = {};
			this.libraryPaths = {};
			this.colorCodes = {};
			this.bodyScale = {};
			this.headScale = {};
			this.headPos = {};
			this.version = 1;
			this.themeId = "";
			this.enabled = true;
		}

		public function addComponent(bodyComponent:CCBodyComponentModel, file:String, path:String) : void
		{
			var cacm:CCCharActionComponentModel = new CCCharActionComponentModel();
			cacm.type = bodyComponent.type;
			cacm.path = path;
			cacm.file = file;
			cacm.x = bodyComponent.x;
			cacm.y = bodyComponent.y;
			cacm.xscale = bodyComponent.xscale;
			cacm.yscale = bodyComponent.yscale;
			cacm.offset = bodyComponent.offset;
			cacm.rotation = bodyComponent.rotation;
			cacm.split = bodyComponent.split;
			cacm.theme_id = bodyComponent.theme_id;
			cacm.component_id = bodyComponent.component_id;
			cacm.folder = bodyComponent.folder;
			if (bodyComponent.id) {
				cacm.id = bodyComponent.id;
			}
			if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(cacm.type) > -1) {
				var _loc5_:Vector.<CCBodyComponentModel>
				if (!this.components[cacm.type]) {
					_loc5_ = this.components[cacm.type] = new Vector.<CCBodyComponentModel>();
				} else {
					_loc5_ = this.components[cacm.type];
				}
				_loc5_.push(cacm);
			} else {
				this.components[cacm.type] = cacm;
			}
		}

		public function getComponentByType(param1:String) : Object
		{
			return this.components[param1];
		}

		public function addLibrary(param1:String, param2:String) : void
		{
			this.libraryPaths[param1] = param2;
		}

		public function getLibraryFilename(param1:String) : String
		{
			return this.libraryPaths[param1];
		}

		public function addColor(param1:String, param2:CCColor) : void
		{
			this.colorCodes[param1] = param2;
		}

		public function getColor(param1:String) : CCColor
		{
			return this.colorCodes[param1];
		}

		public function serialize() : XML
		{
			var _loc2_:XML = null;
			var _loc3_:String = null;
			var _loc4_:Vector.<CCBodyComponentModel> = null;
			var _loc5_:String = null;
			var _loc6_:CCCharActionComponentModel = null;
			var _loc1_:XML = <cam/>;
			for(_loc3_ in this.colorCodes)
			{
				_loc1_.appendChild(CCColor(this.getColor(_loc3_)).serialize());
			}
			for(_loc3_ in this.components)
			{
				if(CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(_loc3_) > -1)
				{
					_loc4_ = this.getComponentByType(_loc3_) as Vector.<CCBodyComponentModel>;
					for(_loc5_ in _loc4_)
					{
						_loc6_ = _loc4_[_loc5_] as CCCharActionComponentModel;
						_loc1_.appendChild(_loc6_.serialize());
					}
				}
				else
				{
					_loc1_.appendChild(CCCharActionComponentModel(this.getComponentByType(_loc3_)).serialize());
				}
			}
			for(_loc3_ in this.libraryPaths)
			{
				_loc2_ = <library>{this.getLibraryFilename(_loc3_)}</library>;
				_loc2_.@type = _loc3_;
				_loc1_.appendChild(_loc2_);
			}
			for(_loc3_ in this.bodyScale)
			{
				_loc2_ = <bodyscale>{this.bodyScale[_loc3_]}</bodyscale>;
				_loc2_.@type = _loc3_;
				_loc1_.appendChild(_loc2_);
			}
			for(_loc3_ in this.headScale)
			{
				_loc2_ = <headscale>{this.headScale[_loc3_]}</headscale>;
				_loc2_.@type = _loc3_;
				_loc1_.appendChild(_loc2_);
			}
			for(_loc3_ in this.headPos)
			{
				_loc2_ = <headpos>{this.headPos[_loc3_]}</headpos>;
				_loc2_.@type = _loc3_;
				_loc1_.appendChild(_loc2_);
			}
			_loc1_.@version = this.version;
			_loc1_.@themeId = this.themeId;
			return _loc1_;
		}

		public function deserialize(param1:XML) : void
		{
			var _loc3_:XML = null;
			var _loc4_:CCCharActionComponentModel = null;
			var _loc5_:CCColor = null;
			var _loc6_:Vector.<CCBodyComponentModel> = null;
			var _loc2_:int = 0;
			while(_loc2_ < param1.children().length())
			{
				_loc3_ = param1.children()[_loc2_];
				switch(_loc3_.localName())
				{
					case "component":
						_loc4_ = new CCCharActionComponentModel();
						_loc4_.deserialize(_loc3_);
						if(CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(_loc4_.type) > -1)
						{
							if(!this.components[_loc4_.type])
							{
								_loc6_ = this.components[_loc4_.type] = new Vector.<CCBodyComponentModel>();
							}
							else
							{
								_loc6_ = this.components[_loc4_.type];
							}
							_loc6_.push(_loc4_);
						}
						else
						{
							this.components[_loc4_.type] = _loc4_;
						}
						break;
					case "library":
						this.addLibrary(_loc3_.@type, _loc3_.text());
						break;
					case "bodyscale":
						this.bodyScale[_loc3_.@type] = _loc3_.text();
						break;
					case "headscale":
						this.headScale[_loc3_.@type] = _loc3_.text();
						break;
					case "headpos":
						this.headPos[_loc3_.@type] = _loc3_.text();
						break;
					case "color":
						_loc5_ = new CCColor();
						_loc5_.deserialize(_loc3_);
						if(_loc5_.targetComponent)
						{
							this.colorCodes[_loc5_.type + _loc5_.targetComponent] = _loc5_;
						}
						else
						{
							this.colorCodes[_loc5_.type] = _loc5_;
						}
				}
				_loc2_++;
			}
			this.version = param1.@version;
			this.themeId = param1.@themeId;
		}

		public function clone() : CCCharacterActionModel
		{
			var _loc1_:CCCharacterActionModel = new CCCharacterActionModel();
			_loc1_.deserialize(this.serialize());
			return _loc1_;
		}
	}
}
