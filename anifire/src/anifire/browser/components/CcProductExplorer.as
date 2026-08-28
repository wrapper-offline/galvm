package anifire.browser.components
{
	import anifire.browser.events.ProductExplorerEvent;
	import anifire.browser.models.CharacterExplorerCollection;
	import anifire.browser.models.ProductCollection;
	import anifire.browser.models.ProductGroupCollection;
	import anifire.browser.models.SearchCollection;
	import anifire.browser.models.ThumbModel;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.core.IFactory;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	import spark.components.Group;
	import spark.components.List;
	import spark.components.Scroller;
	import spark.components.VScrollBar;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.components.supportClasses.TextBase;
	import spark.events.IndexChangeEvent;
	import spark.events.TrackBaseEvent;
	import spark.layouts.supportClasses.LayoutBase;
	
	public class CcProductExplorer extends SkinnableComponent
	{
		[SkinPart(required="false")]
		public var categoryList:List;
		[SkinPart(required="true")]
		public var productList:List;
		[SkinPart(required="false")]
		public var promptDisplay:TextBase;
		[SkinPart(required="false")]
		public var categoryListGroup:Group;
		[SkinPart(required="false")]
		public var pageNav:anifire.browser.components.PageNavigation;
		private const CHARARCTER_PER_PAGE:uint = 20;
		protected var _categoryExpanded:Boolean;
		protected var _productProvider:ProductGroupCollection;
		protected var _productListSkin:Class;
		protected var _productLayout:LayoutBase;
		protected var _searchCollection:SearchCollection;
		protected var _productRenderer:IFactory;
		protected var _selectedCollection:ProductCollection;
		protected var lastSelectedCollection:ProductCollection;
		protected var _collapseDelay:int = 600;
		protected var collapseTimer:Timer;
		protected var registeredCategoryListDragEvents:Boolean;
		protected var categoryListActive:Boolean;
		protected var _isSearching:Boolean;
		[Bindable]
		public var categoryListWidth:Number = 98;
		protected var _loading:Boolean = false;
		private var _themeId:String;
		[Bindable]
		public var allowSelection:Boolean;
		[Bindable]
		public var emptyPrompt:String;
		public var selectedProduct:ThumbModel;
		
		public function CcProductExplorer()
		{
			super();
			this.collapseTimer = new Timer(this._collapseDelay, 1);
			this.collapseTimer.addEventListener(TimerEvent.TIMER, this.onCollapseTimer);
		}

		[Bindable]
		public function get loading() : Boolean
		{
			return this._loading;
		}
		
		public function set loading(isLoading:Boolean) : void
		{
			if (this._loading != isLoading)
			{
				this._loading = isLoading;
				invalidateSkinState();
			}
		}
		
		public function get isSearching() : Boolean
		{
			return this._isSearching;
		}
		
		public function set collapseDelay(param1:int) : void
		{
			this._collapseDelay = param1;
			this.collapseTimer.delay = param1;
		}
		
		public function get collapseDelay() : int
		{
			return this._collapseDelay;
		}
		
		[Bindable(event="productCategoryChanged")]
		[Bindable(event="productSearched")]
		public function shouldDisplayPrompt() : Boolean
		{
			return !this.selectedCollection || this._searchCollection && this.selectedCollection == this._searchCollection && this._searchCollection.length == 0;
		}
		
		protected function getSearchEmptyPromptText(param1:String) : String
		{
			return "";
		}
		
		[Bindable]
		public function get searchCollection() : SearchCollection
		{
			return this._searchCollection;
		}
		
		public function set searchCollection(param1:SearchCollection) : void
		{
			if (this._searchCollection != param1)
			{
				if (this._searchCollection)
				{
					this._searchCollection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, this.onSearchUpdate);
				}
				this._searchCollection = param1;
				if (this._searchCollection)
				{
					this._searchCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, this.onSearchUpdate);
				}
			}
		}
		
		[Bindable]
		public function get selectedCollection() : ProductCollection
		{
			return this._selectedCollection;
		}

		public function set selectedCollection(param1:ProductCollection) : void
		{
			this._selectedCollection = param1;
			if(this._selectedCollection)
			{
				this._selectedCollection.sortProducts();
			}
			if(this.categoryList)
			{
				this.categoryList.selectedItem = this._selectedCollection;
			}
			if(this.productList)
			{
				this.productList.dataProvider = this.getCharacterSubList(this._selectedCollection,0,this.CHARARCTER_PER_PAGE);
			}
			if(Boolean(this.pageNav) && Boolean(param1))
			{
				this.pageNav.totalPage = Math.ceil(param1.length / this.CHARARCTER_PER_PAGE);
				this.pageNav.currentPage = 1;
			}
			var _loc2_:ProductExplorerEvent = new ProductExplorerEvent(ProductExplorerEvent.CATEGORY_CHANGED);
			_loc2_.collection = this._selectedCollection;
			dispatchEvent(_loc2_);
			if(this.promptDisplay)
			{
				this.promptDisplay.visible = this.shouldDisplayPrompt();
			}
		}
		
		private function onPageChange(param1:Event) : void
		{
			if(this.productList)
			{
				this.productList.dataProvider = this.getCharacterSubList(this._selectedCollection,(this.pageNav.currentPage - 1) * this.CHARARCTER_PER_PAGE,this.CHARARCTER_PER_PAGE);
			}
		}
		
		private function getCharacterSubList(param1:IList, param2:uint, param3:uint) : IList
		{
			var _loc4_:IList = new ArrayCollection();
			var _loc5_:uint = param2;
			while(_loc5_ < param2 + param3)
			{
				if(_loc5_ >= param1.length)
				{
					break;
				}
				_loc4_.addItem(param1.getItemAt(_loc5_));
				_loc5_++;
			}
			return _loc4_;
		}
		
		public function set themeId(param1:String) : void
		{
			this._themeId = param1;
		}
		
		public function set productListSkin(param1:Class) : void
		{
			this._productListSkin = param1;
			if(this.productList)
			{
				this.productList.setStyle("skinClass",this._productListSkin);
			}
		}
		
		public function get productListSkin() : Class
		{
			return this._productListSkin;
		}
		
		public function get productRenderer() : IFactory
		{
			return this._productRenderer;
		}
		
		public function set productRenderer(param1:IFactory) : void
		{
			if(this._productRenderer != param1)
			{
				this._productRenderer = param1;
				if(this.productList)
				{
					this.productList.itemRenderer = this._productRenderer;
				}
			}
		}
		
		[Bindable]
		public function get categoryExpanded() : Boolean
		{
			return this._categoryExpanded;
		}
		
		public function set categoryExpanded(param1:Boolean) : void
		{
			if(this._categoryExpanded != param1)
			{
				this._categoryExpanded = param1;
				invalidateSkinState();
			}
		}

		[Bindable]
		public function get productProvider() : ProductGroupCollection
		{
			return this._productProvider;
		}
		
		public function set productProvider(param1:ProductGroupCollection) : void
		{
			if(this._productProvider != param1)
			{
				this.searchCollection = null;
				this.selectedCollection = null;
				this._productProvider = param1;
				if(this.productProvider)
				{
					this.searchCollection = this.productProvider.getSearchCollection();
					if(this.categoryList)
					{
						this.categoryList.dataProvider = this.productProvider;
					}
				}
			}
		}
		
		[Bindable]
		public function get productLayout() : LayoutBase
		{
			return this._productLayout;
		}
		
		public function set productLayout(param1:LayoutBase) : void
		{
			if(this._productLayout != param1)
			{
				this._productLayout = param1;
				if(this.productList)
				{
					this.productList.layout = this._productLayout;
				}
			}
		}
		
		public function hideInvalidCategories() : void
		{
			this.productProvider.filterFunction = this.validCategoryFilter;
			this.productProvider.refresh();
		}
		
		public function showAllCategories() : void
		{
			this.productProvider.filterFunction = null;
			this.productProvider.refresh();
		}
		
		public function selectCustomCollection() : void
		{
			if(this.productProvider is CharacterExplorerCollection)
			{
				this.selectedCollection = (this.productProvider as CharacterExplorerCollection).userCharacters;
			}
		}
		
		public function selectFirstProperCategory() : void
		{
			var _loc1_:Boolean;
			var _loc2_:int = int(this.productProvider.length);
			var _loc3_:int = 0;
			while(_loc3_ < _loc2_)
			{
				var _loc4_:ProductCollection = this.productProvider.getItemAt(_loc3_) as ProductCollection;
				if(_loc4_.isProperCollection)
				{
					_loc1_ = true;
					this.selectedCollection = _loc4_;
					callLater(this.updateProductSelection);
					break;
				}
				_loc3_++;
			}
			if(!_loc1_)
			{
				this.selectedCollection = null;
			}
		}
		
		public function selectProperCateogryIfCurrentIsEmpty() : void
		{
			if(Boolean(this.selectedCollection) && this.selectedCollection.length == 0)
			{
				this.clearSearch();
				this.hideInvalidCategories();
				this.selectFirstProperCategory();
			}
		}
		
		public function selectProperCategoryIfNoSelection() : void
		{
			if(!this.selectedCollection)
			{
				this.selectFirstProperCategory();
			}
		}
		
		public function selectCategoryIndex(param1:int) : void
		{
			if(Boolean(this.productProvider) && param1 < this.productProvider.length)
			{
				this.selectedCollection = this.productProvider.getItemAt(param1) as ProductCollection;
			}
		}
		
		public function selectSearchResult() : void
		{
			if(this.searchCollection)
			{
				this.productProvider.filterFunction = this.searchCategoryFilter;
				this.productProvider.refresh();
				if(this.selectedCollection != this.searchCollection)
				{
					this.lastSelectedCollection = this.selectedCollection;
				}
				this.selectedCollection = this.searchCollection;
			}
		}
		
		public function clearSearch() : void
		{
			if(this.promptDisplay)
			{
				this.promptDisplay.text = this.emptyPrompt;
			}
			this._isSearching = false;
			this.hideInvalidCategories();
		}

		private function onSearchUpdate(param1:Event) : void
		{
			dispatchEvent(new ProductExplorerEvent(ProductExplorerEvent.SEARCHED));
		}

		public function displayNaturally() : void
		{
			this.clearSearch();
			this.selectFirstProperCategory();
		}
		
		protected function restoreCategories() : void
		{
			this.clearSearch();
			if(this.lastSelectedCollection)
			{
				this.selectedCollection = this.lastSelectedCollection;
				this.lastSelectedCollection = null;
			}
			callLater(this.updateProductSelection);
		}
		
		public function displayByProductId(param1:String) : void
		{
			this.clearSearch();
			var _loc2_:ProductCollection = this.productProvider.getCategoryByProductId(param1);
			if(_loc2_)
			{
				this.selectedCollection = _loc2_;
				if(this.allowSelection)
				{
					this.selectedProduct = this.productProvider.getProductById(param1);
				}
				callLater(this.updateProductSelection);
			}
		}
		
		public function clearSelection() : void
		{
			this.clearSearch();
			this.hideInvalidCategories();
			this._selectedCollection = null;
		}
		
		protected function validCategoryFilter(param1:Object) : Boolean
		{
			var _loc2_:ProductCollection = param1 as ProductCollection;
			return Boolean(_loc2_) && _loc2_ != this.searchCollection && (!_loc2_.isProperCollection || _loc2_.valid && _loc2_.length > 0);
		}
		
		protected function searchCategoryFilter(param1:Object) : Boolean
		{
			return Boolean(param1) && param1 == this.searchCollection;
		}
		
		public function searchProduct(param1:String) : void
		{
			if(this.searchCollection)
			{
				if(StringUtil.trim(param1).length > 0)
				{
					this.searchCollection.search(param1);
					if(this.promptDisplay)
					{
						this.promptDisplay.text = this.getSearchEmptyPromptText(param1);
					}
					this.selectSearchResult();
					this._isSearching = true;
				}
			}
		}
		
		protected function onSearchInputEnter(param1:FlexEvent) : void
		{
		}
		
		protected function onSearchInputCancel(param1:Event) : void
		{
			this.restoreCategories();
		}
		
		protected function onSearchInputKeyDown(param1:KeyboardEvent) : void
		{
			if(param1.keyCode == Keyboard.ESCAPE)
			{
				this.restoreCategories();
			}
		}
		
		protected function onCategoryChange(param1:IndexChangeEvent) : void
		{
			this.selectCategoryIndex(param1.newIndex);
		}
		
		protected function onCategoryRollOver(param1:MouseEvent) : void
		{
			this.collapseTimer.reset();
			this.categoryExpanded = true;
			this.registerCategoryListEvents();
		}
		
		protected function onCategoryRollOut(param1:MouseEvent) : void
		{
			this.collapseTimer.reset();
			this.collapseTimer.start();
		}
		
		protected function onCollapseTimer(param1:TimerEvent) : void
		{
			if(!this.categoryListActive)
			{
				this.unregisterCategoryListEvents();
				this.categoryExpanded = false;
			}
		}
		
		protected function registerCategoryListEvents() : void
		{
			if(this.categoryList.scroller)
			{
				this.categoryList.scroller.verticalScrollBar.addEventListener(TrackBaseEvent.THUMB_PRESS,this.onCategoryListThumbPress);
				this.categoryList.scroller.verticalScrollBar.addEventListener(TrackBaseEvent.THUMB_RELEASE,this.onCategoryListThumbRelease);
				this.registeredCategoryListDragEvents = true;
			}
		}
		
		protected function unregisterCategoryListEvents() : void
		{
			if(this.registeredCategoryListDragEvents)
			{
				this.categoryList.scroller.verticalScrollBar.addEventListener(TrackBaseEvent.THUMB_PRESS,this.onCategoryListThumbPress);
				this.categoryList.scroller.verticalScrollBar.addEventListener(TrackBaseEvent.THUMB_RELEASE,this.onCategoryListThumbRelease);
				this.registeredCategoryListDragEvents = false;
			}
		}
		
		protected function onCategoryListThumbPress(param1:TrackBaseEvent) : void
		{
			this.categoryListActive = true;
			this.collapseTimer.reset();
		}
		
		protected function onCategoryListThumbRelease(param1:TrackBaseEvent) : void
		{
			this.categoryListActive = false;
			this.collapseTimer.start();
		}
		
		protected function onProductListVerticalScroll(param1:Event) : void
		{
		}
		
		protected function onProductSelected(param1:IndexChangeEvent) : void
		{
		}
		
		protected function updateProductSelection() : void
		{
			var _loc1_:int = 0;
			if(this.selectedCollection)
			{
				_loc1_ = int(this.selectedCollection.getItemIndex(this.selectedProduct));
				if(this.productList)
				{
					this.productList.selectedIndex = _loc1_;
				}
				if(Boolean(this.categoryList) && Boolean(this.productProvider))
				{
					_loc1_ = int(this.productProvider.getItemIndex(this.selectedCollection));
					this.categoryList.selectedItem = this.selectedCollection;
					this.categoryList.ensureIndexIsVisible(_loc1_);
				}
			}
		}
		
		override protected function getCurrentSkinState() : String
		{
			if (this.loading)
			{
				return "loading";
			}
			return this.categoryExpanded ? "categoryExpanded" : "normal";
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			var _loc3_:Scroller = null;
			var _loc4_:VScrollBar = null;
			super.partAdded(partName, instance);
			if (instance == this.categoryList)
			{
				this.categoryList.addEventListener(IndexChangeEvent.CHANGE, this.onCategoryChange);
				this.categoryList.dataProvider = this.productProvider;
				this.categoryList.selectedItem = this.selectedCollection;
			}
			else if (instance == this.categoryListGroup)
			{
				this.categoryListGroup.addEventListener(MouseEvent.ROLL_OVER, this.onCategoryRollOver);
				this.categoryListGroup.addEventListener(MouseEvent.ROLL_OUT, this.onCategoryRollOut);
			}
			else if (instance == this.productList)
			{
				this.productList.addEventListener(IndexChangeEvent.CHANGE, this.onProductSelected);
				if(this._productListSkin)
				{
					this.productList.setStyle("skinClass" ,this._productListSkin);
				}
				this.productList.itemRenderer = this.productRenderer;
				if(this._productLayout)
				{
					this.productList.layout = this._productLayout;
				}
				this.productList.dataProvider = this.selectedCollection;
				_loc3_ = this.productList.scroller;
				if (_loc3_)
				{
					_loc4_ = _loc3_.verticalScrollBar;
					if (_loc4_)
					{
						_loc4_.addEventListener(Event.CHANGE, this.onProductListVerticalScroll);
					}
				}
			}
			else if (instance == this.promptDisplay)
			{
				this.promptDisplay.text = this.emptyPrompt;
				this.promptDisplay.visible = this.shouldDisplayPrompt();
			}
			else if (instance == this.pageNav)
			{
				this.pageNav.addEventListener(Event.CHANGE, this.onPageChange);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			var _loc3_:Scroller = null;
			var _loc4_:VScrollBar = null;
			super.partRemoved(partName, instance);
			if (instance == this.categoryList)
			{
				this.categoryList.removeEventListener(IndexChangeEvent.CHANGE, this.onCategoryChange);
				this.unregisterCategoryListEvents();
			}
			else if (instance == this.categoryListGroup)
			{
				this.categoryListGroup.removeEventListener(MouseEvent.ROLL_OVER, this.onCategoryRollOver);
				this.categoryListGroup.removeEventListener(MouseEvent.ROLL_OUT, this.onCategoryRollOut);
			}
			else if (instance == this.productList)
			{
				this.productList.removeEventListener(IndexChangeEvent.CHANGE, this.onProductSelected);
				_loc3_ = this.productList.scroller;
				if (_loc3_)
				{
					_loc4_ = _loc3_.verticalScrollBar;
					if (_loc4_)
					{
						_loc4_.removeEventListener(Event.CHANGE, this.onProductListVerticalScroll);
					}
				}
			}
			else if (instance == this.pageNav)
			{
				this.pageNav.removeEventListener(Event.CHANGE, this.onPageChange);
			}
		}
	}
}
