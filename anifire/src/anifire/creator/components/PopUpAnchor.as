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

	/**
	 * This PopUpAnchor class extends the Spark PopUpAnchor class with auto
	 * close functionality and improved position calculation.
	 */
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
		public function set autoClose(value:Boolean) : void
		{
			if (this._autoClose != value) {
				this._autoClose = value;
				if (!this._autoClose) {
					this.removeCloseTrigger();
				} else if (displayPopUp) {
					this.addCloseTrigger();
				}
			}
		}

		override public function set popUpPosition(value:String) : void
		{
			super.popUpPosition = value;
		}

		override public function set displayPopUp(value:Boolean) : void
		{
			super.displayPopUp = value;
			if (this.autoClose) {
				if (value) {
					this.addCloseTrigger();
				} else {
					this.removeCloseTrigger();
				}
			}
		}

		/**
		 * Adds systemManager_mouseHandler listeners for all mouse up events.
		 */
		protected function addCloseTrigger() : void
		{
			if (!this.hasCloseTrigger) {
				systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, this.systemManager_mouseHandler);
				systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, this.systemManager_mouseHandler);
				this.hasCloseTrigger = true;
			}
		}

		/**
		 * Removes systemManager_mouseHandler listeners for all mouse up
		 * events.
		 */
		protected function removeCloseTrigger() : void
		{
			if (this.hasCloseTrigger) {
				systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, this.systemManager_mouseHandler);
				systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, this.systemManager_mouseHandler);
				this.hasCloseTrigger = false;
			}
		}

		private function systemManager_mouseHandler(event:Event) : void
		{
			this.displayPopUp = false;
		}

		override protected function determinePosition(
			placement:String,
			popUpWidth:Number,
			popUpHeight:Number,
			matrix:Matrix,
			registrationPoint:Point,
			bounds:Rectangle
		) : void
		{
			function setBounds() {
				var obj:DisplayObject = popUp as DisplayObject;
				var regPoint:Point = registrationPoint.clone();
				var transformed:Point = MatrixUtil.transformBounds(obj.width, obj.height, matrix, regPoint);
				bounds.left = regPoint.x;
				bounds.top = regPoint.y;
				bounds.width = transformed.x;
				bounds.height = transformed.y;
			}
			switch (placement) {
				case BELOW_RIGHT:
					registrationPoint.x = unscaledWidth - popUpWidth;
					registrationPoint.y = unscaledHeight;
					setBounds();
					return;
				case ABOVE_RIGHT:
					registrationPoint.x = unscaledWidth - popUpWidth;
					registrationPoint.y = -popUpHeight;
					setBounds();
					return;
				case BELOW_CENTER:
					registrationPoint.x = (unscaledWidth - popUpWidth) / 2;
					registrationPoint.y = unscaledHeight;
			}
			super.determinePosition(placement, popUpWidth, popUpHeight, matrix, registrationPoint, bounds);
			return;
		}
	}
}
