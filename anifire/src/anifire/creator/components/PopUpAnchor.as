package anifire.creator.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import mx.core.mx_internal;
	import mx.events.SandboxMouseEvent;
	import mx.utils.MatrixUtil;
	import spark.components.PopUpAnchor;

	use namespace mx_internal;

	public class PopUpAnchor extends spark.components.PopUpAnchor
	{
		public static const ABOVE_RIGHT:String = "aboveRight";

		public static const BELOW_RIGHT:String = "belowRight";

		public static const BELOW_CENTER:String = "belowCenter";


		protected var _autoClose:Boolean = true;

		protected var hasCloseTrigger:Boolean;

		public function PopUpAnchor()
		{
			super();
		}

		public function get autoClose() : Boolean
		{
			return this._autoClose;
		}

		public function set autoClose(param1:Boolean) : void
		{
			if(this._autoClose != param1)
			{
				this._autoClose = param1;
				if(!this._autoClose)
				{
					this.removeCloseTrigger();
				}
				else if(displayPopUp)
				{
					this.addCloseTrigger();
				}
			}
		}

		override public function set popUpPosition(param1:String) : void
		{
			super.popUpPosition = param1;
		}

		override public function set displayPopUp(param1:Boolean) : void
		{
			super.displayPopUp = param1;
			if(this.autoClose)
			{
				if(param1)
				{
					this.addCloseTrigger();
				}
				else
				{
					this.removeCloseTrigger();
				}
			}
		}

		protected function addCloseTrigger() : void
		{
			if(!this.hasCloseTrigger)
			{
				systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP,this.systemManager_mouseHandler);
				systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.systemManager_mouseHandler);
				this.hasCloseTrigger = true;
			}
		}

		protected function removeCloseTrigger() : void
		{
			if (this.hasCloseTrigger)
			{
				systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP,this.systemManager_mouseHandler);
				systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.systemManager_mouseHandler);
				this.hasCloseTrigger = false;
			}
		}

		private function systemManager_mouseHandler(param1:Event) : void
		{
			this.displayPopUp = false;
		}

		mx_internal function determinePosition(
			placement:String,
			popUpWidth:Number,
			popUpHeight:Number,
			matrix:Matrix,
			registrationPoint:Point,
			bounds:Rectangle
		) : void
		{
			switch (placement)
			{
				case BELOW_RIGHT:
					registrationPoint.x = unscaledWidth - popUpWidth;
					registrationPoint.y = unscaledHeight;
				case ABOVE_RIGHT:
					registrationPoint.x = unscaledWidth - popUpWidth;
					registrationPoint.y = -popUpHeight;
				case BELOW_CENTER:
					registrationPoint.x = (unscaledWidth - popUpWidth) / 2;
					registrationPoint.y = unscaledHeight;
				default:
					var _loc7_:DisplayObject = popUp as DisplayObject;
					var _loc8_:Point = registrationPoint.clone();
					var _loc9_:Point = MatrixUtil.transformBounds(_loc7_.width, _loc7_.height, matrix, _loc8_);
					bounds.left = _loc8_.x;
					bounds.top = _loc8_.y;
					bounds.width = _loc9_.x;
					bounds.height = _loc9_.y;
			}
			super.determinePosition(placement, popUpWidth, popUpHeight, matrix, registrationPoint, bounds);
			return;
		}
	}
}
