package anifire.browser.models
{
	import anifire.browser.core.Thumb;
	import flash.events.EventDispatcher;
	
	public class ThumbModel extends EventDispatcher
	{
		 
		
		protected var _id:String;
		
		protected var _thumb:Thumb;
		
		public var colorSetId:String;
		
		public var isStoreCharacter:Boolean;
		
		public var isTemplateCharacter:Boolean;
		
		public var isPlaceHolder:Boolean;
		
		public var locked:Boolean;
		
		public var copyable:Boolean;
		
		public function ThumbModel(param1:Thumb, param2:String = "")
		{
			super();
			this.thumb = param1;
			this.colorSetId = param2;
		}
		
		public function set thumb(param1:Thumb) : void
		{
			this._thumb = param1;
			if(this._thumb)
			{
				this._id = this._thumb.id;
			}
		}
		
		public function get thumb() : Thumb
		{
			return this._thumb;
		}
		
		public function get id() : String
		{
			return this._id;
		}
		
		public function get name() : String
		{
			return this._thumb.name;
		}
	}
}
