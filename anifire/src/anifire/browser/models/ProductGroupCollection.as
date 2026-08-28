package anifire.browser.models
{
	import anifire.browser.core.Thumb;
	import flash.events.Event;
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import spark.collections.Sort;
	import spark.collections.SortField;
	
	public class ProductGroupCollection extends ArrayCollection
	{
		 
		
		protected var productKeys:Object;
		
		protected var collections:Vector.<ProductCollection>;
		
		public function ProductGroupCollection(param1:Array = null)
		{
			super(param1);
			this.productKeys = {};
			this.collections = new Vector.<ProductCollection>();
		}
		
		public function addCollection(param1:ProductCollection) : void
		{
			addItem(param1);
			this.collections.push(param1);
		}
		
		public function addProduct(param1:ThumbModel, param2:Boolean = true) : Boolean
		{
			var _loc3_:Boolean = false;
			var _loc4_:int = int(this.collections.length);
			var _loc5_:int = 0;
			while(_loc5_ < _loc4_)
			{
			var _loc6_:ProductCollection = this.collections[_loc5_];
			var _loc7_:Boolean = _loc6_.isProperCollection;
				if(_loc6_.addProductIfAppropriate(param1,param2))
				{
					dispatchEvent(new Event(Event.CHANGE));
					if(_loc7_)
					{
						this.registerProduct(param1);
						this.registerProductCollection(param1,_loc6_);
						return _loc6_.valid;
					}
				}
				_loc5_++;
			}
			return _loc3_;
		}
		
		public function addProductsFromThumbList(param1:IList, param2:Boolean = true) : void
		{
			var _loc3_:int = 0;
			while(_loc3_ < param1.length)
			{
				this.addProduct(new ThumbModel(param1.getItemAt(_loc3_) as Thumb),param2);
				_loc3_++;
			}
		}
		
		public function removeAllProducts() : void
		{
			var _loc1_:int = int(this.collections.length);
			var _loc2_:int = 0;
			while(_loc2_ < _loc1_)
			{
			 var _loc3_:ProductCollection = this.collections[_loc2_];
				_loc3_.filterFunction = null;
				_loc3_.refresh();
				_loc3_.source = [];
				_loc2_++;
			}
			this.productKeys = {};
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		[Bindable(event="change")]
		public function get totalProducts() : int
		{
			var _loc1_:int = 0;
			var _loc2_:int = 0;
			while(_loc2_ < length)
			{
			 var _loc3_:ProductCollection = getItemAt(_loc2_) as ProductCollection;
				if(Boolean(_loc3_) && _loc3_.valid)
				{
					_loc1_ += _loc3_.properProductCount;
				}
				_loc2_++;
			}
			return _loc1_;
		}
		
		protected function registerProduct(param1:ThumbModel) : void
		{
			this.productKeys[param1.id] = param1;
		}
		
		protected function registerProductCollection(param1:ThumbModel, param2:ProductCollection) : void
		{
		}
		
		public function containsProduct(param1:ThumbModel) : Boolean
		{
			return this.productKeys[param1.id] != null;
		}
		
		public function removeProductById(param1:String) : void
		{
			var _loc2_:int = 0;
			var _loc3_:int = 0;
			var _loc4_:ProductCollection = null;
			if(this.productKeys[param1] != null)
			{
				_loc2_ = int(this.collections.length);
				_loc3_ = 0;
				while(_loc3_ < _loc2_)
				{
					if((_loc4_ = this.collections[_loc3_]).removeProductById(param1))
					{
						this.productKeys[param1] = null;
					}
					_loc3_++;
				}
			}
		}
		
		public function getSearchCollection() : SearchCollection
		{
			return null;
		}
		
		public function getCategoryByProductId(param1:String) : ProductCollection
		{
			return null;
		}
		
		public function getProductById(param1:String) : ThumbModel
		{
			return this.productKeys[param1];
		}
		
		public function sortByCategoryName() : void
		{
			var _loc1_:Sort = new Sort();
			var _loc2_:Array = [];
			_loc2_.push(new SortField("sortOrder",false,true));
			_loc2_.push(new SortField("categoryName"));
			_loc1_.fields = _loc2_;
			sort = _loc1_;
			refresh();
		}
	}
}
