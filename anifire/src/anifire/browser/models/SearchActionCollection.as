package anifire.browser.models
{
	import anifire.util.UtilText;
	
	public class SearchActionCollection extends SearchCollection
	{
		 
		
		public function SearchActionCollection(param1:String, param2:Array = null)
		{
			super(param1,param2);
		}
		
		override public function search(param1:String) : void
		{
			this.keyword = param1;
			filterFunction = this.searchFilter;
			refresh();
			completeSearch();
		}
		
		protected function searchFilter(param1:Object) : Boolean
		{
			var _loc2_:ActionThumbModel = param1 as ActionThumbModel;
			if(_loc2_)
			{
				return UtilText.search(keyword,_loc2_.name);
			}
			return false;
		}
	}
}
