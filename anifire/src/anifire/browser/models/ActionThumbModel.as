package anifire.browser.models
{
	import anifire.browser.core.Action;
	import anifire.browser.core.CharThumb;
	import anifire.models.creator.CCCharacterActionModel;
	
	public class ActionThumbModel extends ThumbModel
	{
		 
		
		public var actionId:String;
		
		public var charThumbId:String;
		
		public var action:Action;
		
		public var categoryName:String;
		
		public var isMotion:Boolean;
		
		public var loading:Boolean;
		
		protected var _characterAction:CCCharacterActionModel;
		
		protected var _name:String;
		
		public function ActionThumbModel(param1:CharThumb, param2:String)
		{
			super(param1);
			this.charThumbId = param1.id;
			this.actionId = param2;
			if(!param1.isCC)
			{
				this.action = param1.getActionById(param2);
				this._name = this.action.name;
			}
		}
		
		public function get charThumb() : CharThumb
		{
			return thumb as CharThumb;
		}
		
		override public function get id() : String
		{
			return this.actionId;
		}
		
		public function set characterAction(param1:CCCharacterActionModel) : void
		{
			if(this._characterAction != param1)
			{
				this._characterAction = param1;
				this._name = this._characterAction.actionModel.name;
				this.categoryName = this._characterAction.actionModel.category;
				this.isMotion = this._characterAction.actionModel.isMotion;
			}
		}
		
		public function get characterAction() : CCCharacterActionModel
		{
			return this._characterAction;
		}
		
		public function get defaultFacialId() : String
		{
			if(this._characterAction)
			{
				return this._characterAction.actionModel.defaultFacialId;
			}
			return null;
		}
		
		public function get cacheId() : String
		{
			return thumb.themeId + ":" + this.charThumbId + ":" + this.actionId;
		}
		
		override public function get name() : String
		{
			return this._name;
		}
	}
}
