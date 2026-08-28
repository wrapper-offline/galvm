package anifire.browser.components
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import spark.components.Button;
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class PageNavigation extends SkinnableComponent
	{
		
		[SkinPart(required="true")]
		public var btnPrev:Button;
		
		[SkinPart(required="true")]
		public var btnNext:Button;
		
		[SkinPart(required="true")]
		public var btnFirst:Button;
		
		[SkinPart(required="true")]
		public var btnLast:Button;
		
		[SkinPart(required="false")]
		public var currentPageTextInput:TextInput;
		
		private var _totalPage:uint = 1;
		
		private var _currentPage:uint = 1;
		
		public function PageNavigation()
		{
			super();
		}

		
		[Bindable]
		public function get totalPage() : uint
		{
			return this._totalPage;
		}
		
		public function set totalPage(param1:uint) : void
		{
			this._totalPage = param1;
			this.updateUI();
		}
		
		[Bindable]
		public function get currentPage() : uint
		{
			return this._currentPage;
		}
		
		public function set currentPage(param1:uint) : void
		{
			this._currentPage = param1;
			this.dispatchEvent(new Event(Event.CHANGE));
			this.updateUI();
		}
		
		override protected function getCurrentSkinState() : String
		{
			return super.getCurrentSkinState();
		}
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			if (instance == this.btnPrev)
			{
				this.btnPrev.addEventListener(MouseEvent.CLICK,this.onPrevBtnClick);
			}
			else if(instance == this.btnNext)
			{
				this.btnNext.addEventListener(MouseEvent.CLICK,this.onNextBtnClick);
			}
			else if(instance == this.btnFirst)
			{
				this.btnFirst.addEventListener(MouseEvent.CLICK,this.onFirstBtnClick);
			}
			else if(instance == this.btnLast)
			{
				this.btnLast.addEventListener(MouseEvent.CLICK,this.onLastBtnClick);
			}
			else if(instance == this.currentPageTextInput)
			{
				this.currentPageTextInput.addEventListener(FocusEvent.FOCUS_OUT,this.onCurrentPageTextInputValueCommit);
				this.currentPageTextInput.addEventListener(FlexEvent.ENTER,this.onCurrentPageTextInputValueCommit);
			}
			this.updateUI();
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			if (instance == this.btnPrev)
			{
				this.btnPrev.removeEventListener(MouseEvent.CLICK,this.onPrevBtnClick);
			}
			else if (instance == this.btnNext)
			{
				this.btnNext.removeEventListener(MouseEvent.CLICK,this.onNextBtnClick);
			}
			else if (instance == this.btnFirst)
			{
				this.btnFirst.removeEventListener(MouseEvent.CLICK,this.onFirstBtnClick);
			}
			else if (instance == this.btnLast)
			{
				this.btnLast.removeEventListener(MouseEvent.CLICK,this.onLastBtnClick);
			}
			else if (instance == this.currentPageTextInput)
			{
				this.currentPageTextInput.removeEventListener(FocusEvent.FOCUS_OUT,this.onCurrentPageTextInputValueCommit);
				this.currentPageTextInput.removeEventListener(FlexEvent.ENTER,this.onCurrentPageTextInputValueCommit);
			}
		}
		
		private function onCurrentPageTextInputValueCommit(param1:Event) : void
		{
			var _loc2_:uint = uint(this.currentPageTextInput.text);
			if(_loc2_ < 1)
			{
				_loc2_ = 1;
			}
			else if(_loc2_ > this._totalPage)
			{
				_loc2_ = this._totalPage;
			}
			this.currentPage = _loc2_;
		}
		
		private function onPrevBtnClick(param1:MouseEvent) : void
		{
			if(this._currentPage > 1)
			{
				--this.currentPage;
			}
		}
		
		private function onNextBtnClick(param1:MouseEvent) : void
		{
			if(this._currentPage < this._totalPage)
			{
				++this.currentPage;
			}
		}
		
		private function onFirstBtnClick(param1:MouseEvent) : void
		{
			if(this._currentPage > 1)
			{
				this.currentPage = 1;
			}
		}
		
		private function onLastBtnClick(param1:MouseEvent) : void
		{
			if(this._currentPage < this._totalPage)
			{
				this.currentPage = this._totalPage;
			}
		}
		
		private function updateUI() : void
		{
			if(this.btnPrev)
			{
				this.btnPrev.enabled = this._currentPage > 1;
			}
			if(this.btnFirst)
			{
				this.btnFirst.enabled = this._currentPage > 1;
			}
			if(this.btnNext)
			{
				this.btnNext.enabled = this._currentPage < this._totalPage;
			}
			if(this.btnLast)
			{
				this.btnLast.enabled = this._currentPage < this._totalPage;
			}
		}
		
	}
}