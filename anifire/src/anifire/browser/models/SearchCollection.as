package anifire.browser.models
{
	import anifire.util.UtilDict;
	import mx.events.PropertyChangeEvent;
	import mx.utils.StringUtil;
	
	public class SearchCollection extends ProductCollection
	{
		 
		
		protected var _keyword:String;
		
		public function SearchCollection(param1:String, param2:Array = null)
		{
			super(param1,param2);
			sortOrder = -1;
			this.reset();
		}
		
		[Bindable(event="propertyChange")]
		public function get keyword() : String
		{
			return this._keyword;
		}
		
		private function set _814408215keyword(param1:String) : void
		{
			if(this._keyword != param1)
			{
				this._keyword = param1;
			}
		}
		
		public function search(param1:String) : void
		{
			this.completeSearch();
		}
		
		protected function completeSearch() : void
		{
			label = StringUtil.substitute(UtilDict.toDisplay("go","{0} results for \"{1}\""),length,this.keyword);
			valid = true;
		}
		
		public function reset() : void
		{
			this.keyword = "";
			label = categoryName;
			valid = false;
		}
		
		override public function addProductIfAppropriate(param1:ThumbModel, param2:Boolean = true) : Boolean
		{
			return false;
		}
		
		override public function get isProperCollection() : Boolean
		{
			return false;
		}
		
		public function set keyword(param1:String) : void
		{
			var _loc2_:Object = this.keyword;
			if(_loc2_ !== param1)
			{
				this._814408215keyword = param1;
				if(this.hasEventListener("propertyChange"))
				{
					this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"keyword",_loc2_,param1));
				}
			}
		}
	}
}
