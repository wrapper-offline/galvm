package anifire.browser.models
{
	import mx.collections.ArrayCollection;
	import mx.core.IFactory;
	import mx.events.PropertyChangeEvent;
	import spark.collections.Sort;
	import spark.layouts.supportClasses.LayoutBase;
	
	public class ProductCollection extends ArrayCollection
	{
		 
		[Bindable]
		public var categoryName:String;

		[Bindable]
		public var layout:LayoutBase;

	  [Bindable]
		public var itemRenderer:IFactory;
		
	  [Bindable]
		public var iconName:String = "";
		
	  [Bindable]
		public var emptyMessage:String;
		
	  [Bindable]
		public var valid:Boolean = true;
		
		public var productFilter:Function;
		
		public var sortOrder:int;
		
		protected var _label:String;
		
		protected var _productSort:Sort;
		
	  [Bindable]
		public var locked:Boolean;
		
		public function ProductCollection(param1:String, param2:Array = null)
		{
			super(param2);
			this.categoryName = param1;
			this.label = param1;
		}
		
		public function get properProductCount() : int
		{
			return this.isProperCollection ? int(length) : 0;
		}
		
		public function addProductIfAppropriate(param1:ThumbModel, param2:Boolean = true) : Boolean
		{
			if(this.productFilter != null && param1 && this.productFilter(param1))
			{
				this.addProduct(param1,param2);
				return true;
			}
			return false;
		}
		
		public function addProduct(param1:ThumbModel, param2:Boolean = true) : void
		{
			var _loc3_:int = param2 ? int(length) : 0;
			addItemAt(param1,_loc3_);
		}
		
		public function removeProductById(param1:String) : Boolean
		{
			var _loc2_:int = 0;
			while(_loc2_ < length)
			{
			 var _loc3_:ThumbModel = getItemAt(_loc2_) as ThumbModel;
				if(_loc3_.id == param1)
				{
					removeItemAt(_loc2_);
					return true;
				}
				_loc2_++;
			}
			return false;
		}
		
		public function get isProperCollection() : Boolean
		{
			return true;
		}
		
		[Bindable]
		public function get label() : String
		{
			return this._label;
		}
		
		public function set label(param1:String) : void
		{
			if(this._label != param1)
			{
				this._label = param1;
			}
		}
		
		public function sortProducts() : void
		{
			if(this._productSort)
			{
				this.sort = this._productSort;
				refresh();
			}
		}
	}
}
